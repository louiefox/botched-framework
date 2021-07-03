BOTCHED.LOCALPLYMETA = {
    Player = self
}

setmetatable( BOTCHED.LOCALPLYMETA, BOTCHED.PLAYERMETA )

-- CLIENT LOAD --
for k, v in pairs( file.Find( "botched/client/*.lua", "LUA" ) ) do
	include( "botched/client/" .. v )
    print( "[BOTCHED FRAMEWORK] Client file loaded: " .. v )
end

-- VGUI LOAD --
for k, v in pairs( file.Find( "botched/vgui/*.lua", "LUA" ) ) do
	include( "botched/vgui/" .. v )
    print( "[BOTCHED FRAMEWORK] VGUI file loaded: " .. v )
end

-- CORE --
concommand.Add( "botched_admin", function( ply, cmd, args )
    if( not BOTCHED.FUNC.HasAdminAccess( LocalPlayer() ) ) then return end
    if( IsValid( BOTCHED_ADMINMENU ) ) then BOTCHED_ADMINMENU:Open() return end

    BOTCHED_ADMINMENU = vgui.Create( "botched_adminmenu" )
end )

concommand.Add( "botched_removeonclose", function()
    BOTCHED.TEMP.RemoveOnClose = not BOTCHED.TEMP.RemoveOnClose
end )

net.Receive( "Botched.SendNotification", function()
    notification.AddLegacy( net.ReadString(), net.ReadUInt( 8 ) or 1, net.ReadUInt( 8 ) or 3 )
end )

net.Receive( "Botched.SendOpenMenu", function()
	local menuType = net.ReadString()
	local menuConfig = BOTCHED.DEVCONFIG.MenuTypes[menuType or ""]
	if( not menuConfig ) then return end

	if( not BOTCHED.TEMP.Menus ) then
		BOTCHED.TEMP.Menus = {}
	end

	if( IsValid( BOTCHED.TEMP.Menus[menuType] ) ) then
		BOTCHED.TEMP.Menus[menuType]:Open()
	else
		local menu = vgui.Create( "botched_menu_base" )
		menu:SetMenuType( menuType )

		BOTCHED.TEMP.Menus[menuType] = menu
	end
end )