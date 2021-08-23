local PANEL = {}

function PANEL:Init()
    self:SetHeader( "Admin Menu" )
    self:SetWide( ScrW()*0.5 )
    self.targetH = ScrH()*0.5+self.headerSize

    self.navigation = vgui.Create( "botched_sheet_bottom", self )
    self.navigation:Dock( FILL )
    self.navigation:SetSize( self:GetWide(), self.targetH-self.headerSize )
    self.navigation.Paint = function() end
    self.navigation.CanSwitch = function() 
        return self.configPage:AttemptClose()
    end

    -- local homePage = vgui.Create( "botched_adminmenu_home", self.navigation )
    -- self.navigation:AddPage( "HOME", Material( "materials/botched/icons/home.png" ), homePage )

    local playersPage = vgui.Create( "botched_adminmenu_players", self.navigation )
    self.navigation:AddPage( "PLAYERS", Material( "materials/botched/icons/players.png" ), playersPage )

    self.configPage = vgui.Create( "botched_adminmenu_config", self.navigation )
    self.configPage.actualH = self.targetH-self.headerSize-self.navigation.navigationPanel:GetTall()
    self.navigation:AddPage( "CONFIG", Material( "materials/botched/icons/settings.png" ), self.configPage )

    self.navigation:SetActivePage( 2 )

    self:Open()
end

function PANEL:OnOpenFinish()
    self:MakePopup()
    self.configPage.FullyOpened = true
end

function PANEL:OnOpenStart()
    self.configPage:Refresh()
end

function PANEL:CanClose()
    return self.configPage:AttemptClose()
end

function PANEL:OnCloseStart()
    self.configPage.FullyOpened = false
end

vgui.Register( "botched_adminmenu", PANEL, "botched_frame" )