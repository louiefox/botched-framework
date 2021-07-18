local function ReadConfigTable()
    local variableCount = 0

    local moduleCount = net.ReadUInt( 5 )
    for i = 1, moduleCount do
        local moduleKey = net.ReadString()
        BOTCHED.CONFIG[moduleKey] = BOTCHED.CONFIG[moduleKey] or {}

        local configMeta = BOTCHED.CONFIGMETA[moduleKey] or {}
        configMeta.LastModified = net.ReadUInt( 32 )

        for i = 1, net.ReadUInt( 5 ) do
            local variable = net.ReadString()
            BOTCHED.CONFIG[moduleKey][variable] = BOTCHED.FUNC.ReadTypeValue( BOTCHED.FUNC.GetConfigVariableType( moduleKey, variable ) )
            variableCount = variableCount+1
        end

        configMeta.FileSize = string.len( util.TableToJSON( BOTCHED.CONFIG[moduleKey], true ) )
    end

    return moduleCount, variableCount
end

net.Receive( "Botched.SendConfig", function()
    BOTCHED.CONFIG = {}
    local modules, variables = ReadConfigTable()

    print( "[BOTCHED FRAMEWORK] Config Received: " .. modules .. " Module(s), " .. variables .. " Variable(s)" )
    hook.Run( "Botched.Hooks.ConfigUpdated" )
end )

net.Receive( "Botched.SendConfigUpdate", function()
    local modules, variables = ReadConfigTable()

    print( "[BOTCHED FRAMEWORK] Config Updated: " .. modules .. " Module(s), " .. variables .. " Variable(s)" )
    hook.Run( "Botched.Hooks.ConfigUpdated" )

    if( BOTCHED.FUNC.HasAdminAccess( LocalPlayer() ) ) then 
        RunConsoleCommand( "spawnmenu_reload" )
    end
end )

function BOTCHED.FUNC.RequestConfigChange( module, variable, value )
    if( not BOTCHED.FUNC.HasAdminAccess( LocalPlayer() ) ) then return end

    if( not BOTCHED.TEMP.ChangedConfig ) then
        BOTCHED.TEMP.ChangedConfig = {}
    end

    if( not BOTCHED.TEMP.ChangedConfig[module] ) then
        BOTCHED.TEMP.ChangedConfig[module] = {}
    end

    BOTCHED.TEMP.ChangedConfig[module][variable] = value
end

function BOTCHED.FUNC.GetChangedVariable( module, variable )
    if( not BOTCHED.TEMP.ChangedConfig or not BOTCHED.TEMP.ChangedConfig[module] or not BOTCHED.TEMP.ChangedConfig[module][variable] ) then return end
    return BOTCHED.TEMP.ChangedConfig[module][variable]
end