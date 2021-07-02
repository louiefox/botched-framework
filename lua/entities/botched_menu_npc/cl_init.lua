include('shared.lua')

local Padding = 10
function ENT:Draw()
	self:DrawModel()

	local menuConfig = BOTCHED.CONFIG.GENERAL.Menus[self:GetMenuType() or ""]
	if( not menuConfig ) then return end

	local npcConfig = (menuConfig.NPCs or {})[self:GetNPCKey()]
	if( not npcConfig ) then return end

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), 90)

	local YPos = -(self:OBBMaxs().z*20)-5

	if( LocalPlayer():GetPos():DistToSqr( self:GetPos() ) < BOTCHED.CONFIG.GENERAL.DisplayDistance3D2D ) then
		cam.Start3D2D(Pos + Ang:Up() * 0.5, Ang, 0.05)
		
			surface.SetFont("MontserratMedium33")
		
			local width, height = surface.GetTextSize( npcConfig.Name )
			width, height = width+20, height+15

			draw.RoundedBox( 5, -(width/2)-Padding, YPos-(height+(2*Padding)), width+(2*Padding), height+(2*Padding), BOTCHED.FUNC.GetTheme( 1 ) )		
			draw.RoundedBox( 5, -(width/2)-Padding, YPos-(height+(2*Padding)), 20, height+(2*Padding), BOTCHED.FUNC.GetTheme( 4 ) )	

			surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
			surface.DrawRect( -(width/2)-Padding+5, YPos-(height+(2*Padding)), 15, height+(2*Padding) )

			draw.SimpleText( npcConfig.Name, "MontserratMedium33", 0, YPos-((height+(2*Padding))/2), BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 1 )
			
		cam.End3D2D()
	end
end

net.Receive( "Botched.SendUseMenuNPC", function()
	local ent = net.ReadEntity()
	if( not IsValid( ent ) ) then return end

	local menuType = ent:GetMenuType()
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