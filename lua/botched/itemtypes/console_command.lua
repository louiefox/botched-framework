local ITEM = BOTCHED.FUNC.CreateItemType( "console_command" )

ITEM:SetTitle( "Console Command" )
ITEM:SetDescription( "Runs a command in the server console." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Command", "The weapon class to give." )
ITEM:AddReqInfo( BOTCHED.TYPE.String, "Arguments", "Using {steamid64} will input the steamid64." )
ITEM:SetAllowInstantUse( true )
ITEM:SetUseFunction( function( ply, command, arguments ) 
    RunConsoleCommand( command, string.Replace( arguments, "{steamid64}", ply:SteamID64() ) )
end )

ITEM:Register()