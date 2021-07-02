local function WriteConfigTable( configTable )
    net.WriteUInt( table.Count( configTable ), 5 )

    for k, v in pairs( configTable ) do
        net.WriteString( k )
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
        WriteConfigTable( BOTCHED.CONFIG )
    net.Send( ply )
end

util.AddNetworkString( "Botched.SendConfigUpdate" )
function BOTCHED.FUNC.SendConfigUpdate( ply, changedConfig )
    net.Start( "Botched.SendConfigUpdate" )
        WriteConfigTable( changedConfig )
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

        for key, val in pairs( v ) do
            BOTCHED.CONFIG[k][key] = val
            variableCount = variableCount+1
        end
    end

    print( "[BOTCHED FRAMEWORK] Config Saved: " .. table.Count( changedConfig ) .. " Module(s), " .. variableCount .. " Variable(s)" )

    BOTCHED.FUNC.SendConfigUpdate( player.GetAll(), changedConfig )
end )