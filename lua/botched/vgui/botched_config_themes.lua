local PANEL = {}

function PANEL:Init()

end

function PANEL:Refresh()
    local panelH, panelSpacing = BOTCHED.FUNC.ScreenScale( 150 ), BOTCHED.FUNC.ScreenScale( 10 )

    local gridWide = self:GetWide()
    local slotsWide = 2
    local panelW = (gridWide-((slotsWide-1)*panelSpacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( panelSpacing )
    self.grid:SetSpaceX( panelSpacing )

    local values = BOTCHED.CONFIGMETA.GENERAL:GetConfigValue( "Themes" )

    local count = 0
    for k, v in ipairs( BOTCHED.CONFIGMETA.GENERAL:GetConfigDefaultValue( "Themes" ) ) do
        count = count+1

        local themePanel = vgui.Create( "DPanel", self.grid )
        themePanel:SetSize( panelW, panelH )
        themePanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

            draw.SimpleText( "THEME " .. k, "MontserratBold22", 10, 10, BOTCHED.FUNC.GetTheme( 4, 100 ) )
        end

        local margin = BOTCHED.FUNC.ScreenScale( 10 )

        local mixer = vgui.Create( "DColorMixer", themePanel )
        mixer:Dock( FILL )
        mixer:DockMargin( margin, BOTCHED.FUNC.ScreenScale( 40 ), margin, margin )
        mixer:SetAlphaBar( true )
        mixer:SetWangs( true )
        mixer:SetPalette( false )
        mixer:SetColor( values[k] ) 
        mixer.ValueChanged = function( self2, col )
            values[k] = col
            BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Themes", values )
        end
    end

    self:SetTall( (math.ceil( count/slotsWide )*(panelH+panelSpacing))-panelSpacing )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_config_themes", PANEL, "DPanel" )