-- Config --
local function WriteConfigTable( ply, configTable )
    net.WriteUInt( table.Count( configTable ), 5 )

    for k, v in pairs( configTable ) do
        net.WriteString( k )
        net.WriteUInt( BOTCHED.CONFIGMETA[k].LastModified, 32 )
        net.WriteUInt( table.Count( v ), 5 )

        for key, val in pairs( v ) do
            net.WriteString( key )
            BOTCHED.FUNC.WriteTypeValue( BOTCHED.FUNC.GetConfigVariableType( k, key ), val )
        end
    end
end

util.AddNetworkString( "Botched.SendConfig" )
function BOTCHED.FUNC.SendConfig( ply )
    net.Start( "Botched.SendConfig" )
        WriteConfigTable( ply, BOTCHED.CONFIG )
    net.Send( ply )
end

util.AddNetworkString( "Botched.SendConfigUpdate" )
function BOTCHED.FUNC.SendConfigUpdate( ply, changedConfig )
    net.Start( "Botched.SendConfigUpdate" )
        WriteConfigTable( ply, changedConfig )
    net.Send( ply )
end

util.AddNetworkString( "Botched.RequestSaveConfigChanges" )
net.Receive( "Botched.RequestSaveConfigChanges", function( len, ply )
    if( not BOTCHED.FUNC.HasAdminAccess( ply ) ) then return end

    local changedConfig = {}

    local moduleCount = net.ReadUInt( 5 )
    for i = 1, moduleCount do
        local moduleKey = net.ReadString()
        changedConfig[moduleKey] = {}

        for i = 1, net.ReadUInt( 5 ) do
            local variable = net.ReadString()
            changedConfig[moduleKey][variable] = BOTCHED.FUNC.ReadTypeValue( BOTCHED.FUNC.GetConfigVariableType( moduleKey, variable ) )
        end
    end

    local variableCount = 0
    for k, v in pairs( changedConfig ) do
        if( not BOTCHED.CONFIG[k] ) then continue end

        BOTCHED.CONFIGMETA[k].LastModified = os.time()

        for key, val in pairs( v ) do
            BOTCHED.CONFIG[k][key] = val
            variableCount = variableCount+1
        end

        file.Write( "botched/config/" .. k .. ".txt", util.TableToJSON( BOTCHED.CONFIG[k], true ) )
    end

    print( "[BOTCHED FRAMEWORK] Config Saved: " .. table.Count( changedConfig ) .. " Module(s), " .. variableCount .. " Variable(s)" )
    BOTCHED.FUNC.SendNotification( ply, "CONFIG SAVED", "Config successfully saved!", "settings" )

    BOTCHED.FUNC.SendConfigUpdate( player.GetAll(), changedConfig )
end )

-- Commands --
local adminCommands = {}
adminCommands["giveitem"] = {
    Arguments = {
        [1] = { "Player", "Victim" },
        [2] = { "String", "ItemKey" },
        [3] = { "Integer", "Amount" }
    },
    Func = function( caller, ply, itemKey, amount )
        ply:Botched():AddLockerItems( itemKey, amount )
        BOTCHED.FUNC.SendItemNotification( ply, "ADMIN GAVE", itemKey, amount )

        local itemConfig = BOTCHED.CONFIG.LOCKER.Items[itemKey]
        if( not itemConfig ) then return end

        if( not IsValid( caller ) ) then return end
        BOTCHED.FUNC.SendNotification( caller, "ADMIN CMD", "Given " .. ply:Nick() .. " ".. amount .. " " .. itemConfig.Name .. "!", "admin" )
    end
}

if( BOTCHED.CONFIG.GACHA ) then
    adminCommands["setgems"] = {
        Arguments = {
            [1] = { "Player", "Victim" },
            [2] = { "Integer", "Gems" }
        },
        Func = function( caller, ply, gems )
            ply:Botched():SetGems( gems )

            if( not IsValid( caller ) ) then return end
            BOTCHED.FUNC.SendNotification( caller, "ADMIN CMD", "Set " .. ply:Nick() .. "'s gems to ".. string.Comma( gems ) .. "!", "admin" )
        end
    }
    adminCommands["settokens"] = {
        Arguments = {
            [1] = { "Player", "Victim" },
            [2] = { "Integer", "Tokens" }
        },
        Func = function( caller, ply, tokens )
            ply:Botched():SetExchangeTokens( tokens )

            if( not IsValid( caller ) ) then return end
            BOTCHED.FUNC.SendNotification( caller, "ADMIN CMD", "Set " .. ply:Nick() .. "'s tokens to ".. string.Comma( tokens ) .. "!", "admin" )
        end
    }
    adminCommands["givegempackage"] = {
        Arguments = {
            [1] = { "Player", "Victim" },
            [2] = { "String", "PackageKey" }
        },
        Func = function( caller, ply, packageKey )
            ply:Botched():GiveGemPackage( packageKey )

            local packageConfig = BOTCHED.CONFIG.GACHA.GemStore[packageKey]
            if( not packageConfig ) then return end

            if( not IsValid( caller ) ) then return end
            BOTCHED.FUNC.SendNotification( caller, "ADMIN CMD", "Given " .. ply:Nick() .. " " .. packageConfig.Name .. "!", "admin" )
        end
    }
end

concommand.Add( "botched_admincmd", function( ply, cmd, args )
    if( IsValid( ply ) and not BOTCHED.FUNC.HasAdminAccess( ply ) ) then return end

    local commandTable = adminCommands[args[1] or ""]
    if( not commandTable ) then return end

    local commandArguments = {}
    for k, v in pairs( commandTable.Arguments or {} ) do
        local argument = args[k+1]
        if( not argument ) then return end

        if( v[1] == "Player" ) then
            argument = player.GetBySteamID64( argument )
            if( not IsValid( argument ) ) then return end
        elseif( v[1] == "Integer" ) then
            argument = tonumber( argument )
            if( not isnumber( argument ) ) then return end
        end

        commandArguments[k] = argument
    end

    commandTable.Func( ply, unpack( commandArguments ) )
end )