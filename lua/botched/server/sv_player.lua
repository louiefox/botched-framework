-- DATA FUNCTIONS --
util.AddNetworkString( "Botched.SendFirstSpawn" )
hook.Add( "PlayerInitialSpawn", "Botched.PlayerInitialSpawn.LoadData", function( ply )
	BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
        if( data ) then
            local userID = tonumber( data.userID or "" ) or 1 
            ply:Botched():SetUserID( userID )

			BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_locker WHERE userID = '" .. userID .. "';", function( data )
                if( not data ) then return end
                
                local lockerData = {}
                for k, v in pairs( data or {} ) do
                    if( not v.itemKey ) then continue end
                    lockerData[v.itemKey] = { 
                        Amount = tonumber( v.amount or "" ) or 1, 
                        Equipped = tobool( v.equipped ) 
                    }

                    if( v.equipped == "NULL" ) then
                        lockerData[v.itemKey].Equipped = false
                    end
                end

                ply:Botched():SetLocker( lockerData )
                ply:Botched():SendLockerItems( table.GetKeys( lockerData ) )

                timer.Simple( 1, function()
                    if( not IsValid( ply ) ) then return end

                    for k, v in pairs( ply:Botched():GetLocker() ) do
                        if( not v.Equipped ) then continue end
                            
                        local configItem = BOTCHED.CONFIG.LOCKER.Items[k]
                        if( not configItem ) then continue end
                    
                        local typeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]
                        if( not typeConfig or not typeConfig.EquipFunction ) then continue end

                        typeConfig.EquipFunction( ply, unpack( configItem.TypeInfo ) )
                    end
                end )
            end )

			hook.Run( "Botched.Hooks.PlayerLoadData", ply, userID )
        else
            BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_players( steamID64 ) VALUES(" .. ply:SteamID64() .. ");", function()
                BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
                    if( data ) then
                        local userID = tonumber( data.userID or "" ) or 1 
                        ply:Botched():SetUserID( userID )
                    else
                        ply:Kick( "ERROR: Could not create unique UserID, try rejoining!\n\nPlease contact support for Botched on gmodstore." )
                    end
                end, true )
            end )
        end
    end, true )

    BOTCHED.FUNC.SendConfig( ply )

    net.Start( "Botched.SendFirstSpawn" )
    net.Send( ply )
end )

-- GENERAL FUNCTIONS --
util.AddNetworkString( "Botched.SendUserID" )
function BOTCHED.PLAYERMETA:SetUserID( userID )
    self.UserID = userID

    net.Start( "Botched.SendUserID" )
        net.WriteUInt( userID, 16 )
    net.Send( self.Player )
end

function BOTCHED.PLAYERMETA:TakeCost( costTable )
    for k, v in pairs( costTable ) do
        local devCfg = BOTCHED.DEVCONFIG.RewardTypes[k]
        if( not devCfg ) then continue end

        devCfg.TakeCost( self, costTable )
    end
end

function BOTCHED.PLAYERMETA:GiveReward( rewardTable )
    for k, v in pairs( rewardTable ) do
        local devCfg = BOTCHED.DEVCONFIG.RewardTypes[k]
        if( k == "Items" or not devCfg ) then continue end

        devCfg.GiveReward( self, rewardTable )
    end

    if( rewardTable.Items ) then
        local itemsToGive = {}
        for k, v in pairs( rewardTable.Items ) do
            table.insert( itemsToGive, k )
            table.insert( itemsToGive, v )
        end

        self:AddLockerItems( unpack( itemsToGive ) )
    end
end

function BOTCHED.PLAYERMETA:CheckNetworkDelay( time, key )
    if( not self.NetworkDelays ) then
        self.NetworkDelays = {}
    end

    if( self.NetworkDelays[key] and CurTime() < self.NetworkDelays[key]+time ) then 
        return false 
    end

    self.NetworkDelays[key] = CurTime()

    return true
end

-- LOCKER FUNCTIONS --
function BOTCHED.PLAYERMETA:SetLocker( locker )
    self.LockerData = locker
end

util.AddNetworkString( "Botched.SendLockerItems" )
function BOTCHED.PLAYERMETA:SendLockerItems( itemsTable )
    local lockerItems = self:GetLocker()

    net.Start( "Botched.SendLockerItems" )
        net.WriteUInt( #itemsTable, 10 )
        for k, v in ipairs( itemsTable ) do
            local lockerItem = lockerItems[v]
            net.WriteString( v )
            net.WriteBool( lockerItem == nil )

            if( lockerItem == nil ) then continue end
            net.WriteUInt( lockerItem.Amount or 1, 32 )
            net.WriteBool( lockerItem.Equipped )
        end
    net.Send( self.Player )
end

function BOTCHED.PLAYERMETA:AddLockerItems( ... )
    local itemsToGive = { ... }

    local itemsGiven = {}
    local locker = self:GetLocker()
    for k, v in ipairs( itemsToGive ) do
        if( k % 2 == 0 or not BOTCHED.CONFIG.LOCKER.Items[v] ) then continue end

        local lockerItem = locker[v] or {}
        lockerItem.Amount = (lockerItem.Amount or 0)+(itemsToGive[k+1] or 1)

        locker[v] = lockerItem

        BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_locker WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';", function( data )
            if( data ) then
                BOTCHED.FUNC.SQLQuery( "UPDATE botched_locker SET amount = " .. lockerItem.Amount .. " WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';" )
            else
                BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_locker( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "', " .. lockerItem.Amount .. ");" )
            end
        end, true )

        table.insert( itemsGiven, v )
    end

    if( #itemsGiven < 1 ) then return end

    self:SetLocker( locker )
    self:SendLockerItems( itemsGiven )
end

function BOTCHED.PLAYERMETA:TakeLockerItems( ... )
    local itemsToTake = { ... }

    local itemsTaken = {}
    local locker = self:GetLocker()
    for k, v in ipairs( itemsToTake ) do
        if( k % 2 == 0 or not BOTCHED.CONFIG.LOCKER.Items[v] ) then continue end

        local lockerItem = locker[v] or {}
        lockerItem.Amount = (lockerItem.Amount or 0)-(itemsToTake[k+1] or 1)

        if( lockerItem.Amount > 0 ) then
            locker[v] = lockerItem
        else
            locker[v] = nil
        end

        if( lockerItem.Amount > 0 ) then
            BOTCHED.FUNC.SQLQuery( "SELECT * FROM botched_locker WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';", function( data )
                if( data ) then
                    BOTCHED.FUNC.SQLQuery( "UPDATE botched_locker SET amount = " .. lockerItem.Amount .. " WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';" )
                else
                    BOTCHED.FUNC.SQLQuery( "INSERT INTO botched_locker( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "', " .. lockerItem.Amount .. ");" )
                end
            end, true )
        else
            BOTCHED.FUNC.SQLQuery( "DELETE FROM botched_locker WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';" )
        end

        table.insert( itemsTaken, v )
    end

    if( #itemsTaken < 1 ) then return end

    self:SetLocker( locker )
    self:SendLockerItems( itemsTaken )
end