-- DATA FUNCTIONS --
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
                    lockerData[v.itemKey] = tonumber( v.amount or "" ) or 1
                end

                ply:Botched():SetLocker( lockerData )
                ply:Botched():SendLocker()
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
end )

-- GENERAL FUNCTIONS --
util.AddNetworkString( "Botched.SendUserID" )
function BOTCHED.PLAYERMETA:SetUserID( userID )
    self.UserID = userID

    net.Start( "Botched.SendUserID" )
        net.WriteUInt( userID, 10 )
    net.Send( self.Player )
end

function BOTCHED.PLAYERMETA:TakeCost( costTable )
    if( costTable.Gems ) then self:TakeGems( costTable.Gems ) end
    if( costTable.ExchangeTokens ) then self:TakeExchangeTokens( costTable.ExchangeTokens ) end
end

function BOTCHED.PLAYERMETA:GiveReward( rewardTable )
    if( rewardTable.Gems ) then self:AddGems( rewardTable.Gems ) end
    if( rewardTable.ExchangeTokens ) then self:AddExchangeTokens( rewardTable.ExchangeTokens ) end

    if( rewardTable.Items ) then
        local itemsToGive = {}
        for k, v in pairs( rewardTable.Items ) do
            table.insert( itemsToGive, k )
            table.insert( itemsToGive, v )
        end

        self:AddLockerItems( unpack( itemsToGive ) )
    end
end

-- LOCKER FUNCTIONS --
function BOTCHED.PLAYERMETA:SetLocker( locker )
    self.LockerData = locker
end

util.AddNetworkString( "Botched.SendLocker" )
function BOTCHED.PLAYERMETA:SendLocker()
    net.Start( "Botched.SendLocker" )
        net.WriteTable( self:GetLocker() )
    net.Send( self.Player )
end

util.AddNetworkString( "Botched.SendLockerItems" )
function BOTCHED.PLAYERMETA:SendLockerItems( itemsTable )
    net.Start( "Botched.SendLockerItems" )
        net.WriteUInt( table.Count( itemsTable ), 10 )
        for k, v in pairs( itemsTable ) do
            net.WriteString( k )
            net.WriteUInt( v, 32 )
        end
    net.Send( self.Player )
end

function BOTCHED.PLAYERMETA:AddLockerItems( ... )
    local itemsToGive = { ... }

    local itemsGiven = {}
    local locker = self:GetLocker()
    for k, v in ipairs( itemsToGive ) do
        if( k % 2 == 0 or not BOTCHED.CONFIG.LOCKER.Items[v] ) then continue end

        locker[v] = (locker[v] or 0)+(itemsToGive[k+1] or 1)

        BOTCHED.FUNC.SQLQuery( "INSERT OR REPLACE INTO botched_locker( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "'," .. locker[v] .. ");" )

        itemsGiven[v] = locker[v]
    end

    if( table.Count( itemsGiven ) < 1 ) then return end

    self:SetLocker( locker )
    self:SendLockerItems( itemsGiven )
end

function BOTCHED.PLAYERMETA:TakeLockerItems( ... )
    local itemsToTake = { ... }

    local itemsTaken = {}
    local locker = self:GetLocker()
    for k, v in ipairs( itemsToTake ) do
        if( k % 2 == 0 or not BOTCHED.CONFIG.LOCKER.Items[v] ) then continue end

        local newAmount = (locker[v] or 0)-(itemsToTake[k+1] or 1)

        if( newAmount > 0 ) then
            locker[v] = newAmount
        else
            locker[v] = nil
        end

        if( newAmount > 0 ) then
            BOTCHED.FUNC.SQLQuery( "INSERT OR REPLACE INTO botched_locker( userID, itemKey, amount ) VALUES(" .. self:GetUserID() .. ", '" .. v .. "'," .. newAmount .. ");" )
        else
            BOTCHED.FUNC.SQLQuery( "DELETE FROM botched_locker WHERE userID = '" .. self:GetUserID() .. "' AND itemKey = '" .. v .. "';" )
        end

        itemsTaken[v] = newAmount
    end

    if( table.Count( itemsTaken ) < 1 ) then return end

    self:SetLocker( locker )
    self:SendLockerItems( itemsTaken )
end