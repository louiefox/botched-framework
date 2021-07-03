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

        local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
        local headerH = BOTCHED.FUNC.ScreenScale( 30 )

        local themePanel = vgui.Create( "DPanel", self.grid )
        themePanel:SetSize( panelW, panelH )
        themePanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ) )
            draw.RoundedBoxEx( 8, 0, 0, w, headerH, BOTCHED.FUNC.GetTheme( 2, 100 ), true, true )

            draw.SimpleText( "THEME " .. k, "MontserratBold22", 10, headerH/2, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_CENTER )
        end

        local mixer = vgui.Create( "DColorMixer", themePanel )
        mixer:Dock( FILL )
        mixer:DockMargin( margin10, headerH+margin10, margin10, margin10 )
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