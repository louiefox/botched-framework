TOOL.Category = "Botched Framework"
TOOL.Name = "Menu NPC Placer"
TOOL.Command = nil
TOOL.ConfigName = ""

function TOOL:LeftClick( trace )
	local ply = self:GetOwner()
	if( not BOTCHED.FUNC.HasAdminAccess( ply ) and CLIENT ) then
		BOTCHED.FUNC.CreateNotification( "ACCESS ERROR", "You don't have permission to use this tool!", "error" )
		return
	end
	
	if( !trace.HitPos or IsValid( trace.Entity ) ) then return false end
	if( CLIENT ) then return true end

	local menuType = ply:GetNWString( "botched_tool_menutype" )
	local menuConfig = BOTCHED.CONFIG.GENERAL.Menus[menuType or ""]
	if( not menuConfig ) then 
		BOTCHED.FUNC.SendNotification( ply, "NPC TOOL", "Invalid menu type selected!", "error" )
		return 
	end

	local npcKey = ply:GetNWInt( "botched_tool_npckey" )
	local npcConfig = (menuConfig.NPCs or {})[npcKey or 0]
	if( not npcConfig ) then 		
		BOTCHED.FUNC.SendNotification( ply, "NPC TOOL", "Invalid NPC key selected!", "error" )
		return  
	end

	local ent = ents.Create( "botched_menu_npc" )
	ent:SetPos( trace.HitPos )
	ent:SetAngles( Angle( 0, ply:GetAngles().y+180, 0 ) )
	ent:Spawn()
	ent:SetMenuInfo( menuType, npcKey )
	
	BOTCHED.FUNC.SendNotification( ply, "NPC TOOL", "Menu NPC successfully placed.", "admin" )
	ply:ConCommand( "botched_save_ents" )
end
 
function TOOL:RightClick( trace )
	local ply = self:GetOwner()
	if( not BOTCHED.FUNC.HasAdminAccess( ply ) ) then
		BOTCHED.FUNC.CreateNotification( "ACCESS ERROR", "You don't have permission to use this tool!", "error" )
		return
	end

	if( !trace.HitPos or !IsValid( trace.Entity ) or trace.Entity:GetClass() != "botched_menu_npc" ) then return false end
	if( CLIENT ) then return true end
	
	trace.Entity:Remove()
	BOTCHED.FUNC.SendNotification( ply, "NPC TOOL", "Menu NPC successfully removed.", "admin" )
	ply:ConCommand( "botched_save_ents" )
end

function TOOL:DrawToolScreen( width, height )
	local ply = LocalPlayer()
	if( not BOTCHED.FUNC.HasAdminAccess( ply ) ) then return end

	surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
	surface.DrawRect( 0, 0, width, height )

	surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
	surface.DrawRect( 0, 0, width, 60 )
	
	draw.SimpleText( language.GetPhrase( "tool.botched_menu_npcs.name" ), "MontserratMedium33", width/2, 30, BOTCHED.FUNC.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	draw.SimpleText( "Selected", "MontserratMedium33", width/2, 60+((height-60)/2)-15, BOTCHED.FUNC.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

	local menuType = ply:GetNWString( "botched_tool_menutype" )
	local menuTypeConfig = BOTCHED.DEVCONFIG.MenuTypes[ply:GetNWString( "botched_tool_menutype" )]
	local menuConfig = BOTCHED.CONFIG.GENERAL.Menus[menuType]

	local npcKey = ply:GetNWInt( "botched_tool_npckey" )
	local npcConfig = ((menuConfig or {}).NPCs or {})[npcKey or 0]

	if( menuTypeConfig and npcConfig ) then
		draw.SimpleText( menuTypeConfig.Title .. " - " .. npcConfig.Name, "MontserratMedium25", width/2, 60+((height-60)/2)-15, BOTCHED.FUNC.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
	else
		draw.SimpleText( "None", "MontserratMedium25", width/2, 60+((height-60)/2)-15, BOTCHED.FUNC.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
	end
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "Menu NPC", Description = "Used to place menu NPCs from the Botched Framework." } )
 
	local combo = panel:AddControl( "ComboBox", { Label = "Selected NPC" } )
	for k, v in pairs( BOTCHED.CONFIG.GENERAL.Menus or {} ) do
		local menuTypeConfig = BOTCHED.DEVCONFIG.MenuTypes[k]
		if( not menuTypeConfig ) then continue end

		for key, val in pairs( v.NPCs or {} ) do
			combo:AddOption( menuTypeConfig.Title .. " - " .. val.Name, { k, key } )
		end
	end

	function combo:OnSelect( index, text, data )
		net.Start( "Botched.RequestMenuToolDataChange" )
			net.WriteString( data[1] )
			net.WriteUInt( data[2], 8 )
		net.SendToServer()
	end
end

if( CLIENT ) then
	language.Add( "tool.botched_menu_npcs.name", "Menu NPC Placer" )
	language.Add( "tool.botched_menu_npcs.desc", "Used to place menu NPCs." )
	language.Add( "tool.botched_menu_npcs.0", "Left click to place NPC. Right click to remove NPC." )
elseif( SERVER ) then
	util.AddNetworkString( "Botched.RequestMenuToolDataChange" )
	net.Receive( "Botched.RequestMenuToolDataChange", function( len, ply )
		if( not BOTCHED.FUNC.HasAdminAccess( ply ) ) then return end

		ply:SetNWString( "botched_tool_menutype", net.ReadString() )
		ply:SetNWInt( "botched_tool_npckey", net.ReadUInt( 8 ) )
	end )
end