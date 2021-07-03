resource.AddFile( "resource/fonts/montserrat-bold.ttf" )
resource.AddFile( "resource/fonts/montserrat-medium.ttf" )

function BOTCHED.FUNC.SQLQuery( queryStr, func, singleRow )
	local query
	if( not singleRow ) then
		query = sql.Query( queryStr )
	else
		query = sql.QueryRow( queryStr, 1 )
	end
	
	if( query == false ) then
		print( "[Botched SQLLite] ERROR", sql.LastError() )
	elseif( func ) then
		func( query )
	end
end

-- CLIENT LOAD --
for k, v in pairs( file.Find( "botched/client/*.lua", "LUA" ) ) do
	AddCSLuaFile( "botched/client/" .. v )
end

-- SERVER LOAD --
for k, v in pairs( file.Find( "botched/server/*.lua", "LUA" ) ) do
	include( "botched/server/" .. v )
	print( "[BOTCHED FRAMEWORK] Server file loaded: " .. v )
end

-- VGUI LOAD --
for k, v in pairs( file.Find( "botched/vgui/*.lua", "LUA" ) ) do
	AddCSLuaFile( "botched/vgui/" .. v )
end

-- CORE --
util.AddNetworkString( "Botched.SendNotification" )
function BOTCHED.FUNC.SendNotification( ply, type, time, message )
	net.Start( "Botched.SendNotification" )
		net.WriteString( message or "" )
		net.WriteUInt( (type or 1), 8)
		net.WriteUInt( (time or 3), 8)
	net.Send( ply )
end

util.AddNetworkString( "Botched.SendOpenMenu" )
function BOTCHED.FUNC.SendOpenMenu( ply, type )
	net.Start( "Botched.SendOpenMenu" )
		net.WriteString( type )
	net.Send( ply )
end

util.AddNetworkString( "Botched.SendUseOpenMenu" )
hook.Add( "PlayerSay", "Botched.PlayerSay.MenuCommands", function( ply, text )
	text = string.lower( text )

	for k, v in pairs( BOTCHED.CONFIG.GENERAL.Menus ) do
		if( not v.Commands or not v.Commands[text] ) then continue end

		BOTCHED.FUNC.SendOpenMenu( ply, k )
		return ""
	end
end )