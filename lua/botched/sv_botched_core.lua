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

util.AddNetworkString( "Botched.SendNotification" )
function BOTCHED.FUNC.SendNotification( ply, type, time, message )
	net.Start( "Botched.SendNotification" )
		net.WriteString( message or "" )
		net.WriteUInt( (type or 1), 8)
		net.WriteUInt( (time or 3), 8)
	net.Send( ply )
end