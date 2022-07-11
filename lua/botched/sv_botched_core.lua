resource.AddFile( "resource/fonts/montserrat-bold.ttf" )
resource.AddFile( "resource/fonts/montserrat-medium.ttf" )

include( "botched/sv_database.lua" )

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
function BOTCHED.FUNC.SendNotification( ply, title, message, icon )
	net.Start( "Botched.SendNotification" )
		net.WriteString( title )
		net.WriteString( message )
		if( icon ) then net.WriteString( icon ) end
	net.Send( ply )
end

util.AddNetworkString( "Botched.SendItemNotification" )
function BOTCHED.FUNC.SendItemNotification( ply, title, itemKey, amount )
	net.Start( "Botched.SendItemNotification" )
		net.WriteString( title )
		net.WriteString( itemKey )
		net.WriteBool( tobool( amount ) )
		if( amount ) then net.WriteInt( amount, 16 ) end
	net.Send( ply )
end

util.AddNetworkString( "Botched.SendChatNotification" )
function BOTCHED.FUNC.SendChatNotification( ply, tag, text )
	net.Start( "Botched.SendChatNotification" )
		net.WriteString( tag )
		net.WriteString( text )
	net.Send( ply )
end

util.AddNetworkString( "Botched.SendOpenMenu" )
function BOTCHED.FUNC.SendOpenMenu( ply, type )
	net.Start( "Botched.SendOpenMenu" )
		net.WriteString( type )
	net.Send( ply )
end

hook.Add( "PlayerSay", "Botched.PlayerSay.MenuCommands", function( ply, text )
	text = string.lower( text )

	for k, v in pairs( BOTCHED.CONFIG.GENERAL.Menus ) do
		if( not v.Commands or not v.Commands[text] ) then continue end

		BOTCHED.FUNC.SendOpenMenu( ply, k )
		return ""
	end
end )

hook.Add( "PlayerButtonDown", "Botched.PlayerButtonDown.MenuKeys", function( ply, button )
	for k, v in pairs( BOTCHED.CONFIG.GENERAL.Menus ) do
		if( not v.Keys or not v.Keys[button] ) then continue end

		BOTCHED.FUNC.SendOpenMenu( ply, k )
	end
end )