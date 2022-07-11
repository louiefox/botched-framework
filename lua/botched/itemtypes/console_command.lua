local ITEM = BOTCHED.FUNC.CreateItemType( "console_command" )

ITEM:SetTitle( "Console Command" )
ITEM:SetDescription( "Runs a command in the server console." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Command", "The weapon class to give." )
ITEM:AddReqInfo( BOTCHED.TYPE.String, "Arguments", "Using {steamid64} will input the steamid64." )
ITEM:SetAllowInstantUse( true )
ITEM:SetUseFunction( function( ply, useAmount, command, arguments )
    for i = 1, useAmount do
        RunConsoleCommand( command, unpack( string.Split( string.Replace( arguments, "{steamid64}", ply:SteamID64() ), " " ) ) )
    end
end )

ITEM:Register()