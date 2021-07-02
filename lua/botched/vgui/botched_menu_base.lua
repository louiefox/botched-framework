local PANEL = {}

function PANEL:SetMenuType( menuType )
	local menuConfig = BOTCHED.DEVCONFIG.MenuTypes[menuType or ""]
	if( not menuConfig ) then return end

    self:SetHeader( menuConfig.Title )

    local w, h = ScrW()*0.5, ScrH()*0.55
    if( menuConfig.GetSize ) then w, h = menuConfig.GetSize() end

    self:SetWide( w )
    self.targetH = h+self.headerSize

    self.content = vgui.Create( menuConfig.Element, self )
    self.content:Dock( FILL )
    self.content:SetSize( w, h )

    if( self.content.FillPanel ) then
        self.content:FillPanel()
    end

    self:Open()
end

function PANEL:OnOpenFinish()
    if( not self.content.OnOpenFinish ) then return end
    self.content:OnOpenFinish()
end

function PANEL:OnCloseStart()
    if( not self.content.OnCloseStart ) then return end
    self.content:OnCloseStart()
end

vgui.Register( "botched_menu_base", PANEL, "botched_frame" )