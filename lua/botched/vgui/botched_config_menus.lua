local PANEL = {}

function PANEL:Init()

end

function PANEL:Refresh()
    self:Clear()

    local panelSpacing = BOTCHED.FUNC.ScreenScale( 10 )
    local iconSize = BOTCHED.FUNC.ScreenScale( 32 )

    local values = BOTCHED.FUNC.GetChangedVariable( "GENERAL", "Menus" ) or BOTCHED.CONFIGMETA.GENERAL:GetConfigValue( "Menus" )

    local commandsIcon = Material( "botched/icons/command_32.png" )
    local npcsIcon = Material( "botched/icons/npc_32.png" )
    local keyIcon = Material( "botched/icons/hotkey_32.png" )

    local menuTotalH = -panelSpacing
    for k, v in pairs( BOTCHED.DEVCONFIG.MenuTypes ) do
        local title = string.upper( v.Title )

        local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
        local headerH = BOTCHED.FUNC.ScreenScale( 30 )

        local menuPanel = vgui.Create( "DPanel", self )
        menuPanel:Dock( TOP )
        menuPanel:DockMargin( 0, 0, 0, panelSpacing )
        menuPanel:DockPadding( 0, headerH+margin10, 0, 0 )
        menuPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ) )
            draw.RoundedBoxEx( 8, 0, 0, w, headerH, BOTCHED.FUNC.GetTheme( 2, 100 ), true, true )

            draw.SimpleText( title, "MontserratBold22", 10, headerH/2, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_CENTER )
        end

        local infoW = BOTCHED.FUNC.ScreenScale( 60 )

        local typePanelH = -margin10
        local function CreateOpenTypePanel( icon, height )
            typePanelH = typePanelH+height+margin10

            local panel = vgui.Create( "DPanel", menuPanel )
            panel:Dock( TOP )
            panel:DockMargin( margin10, 0, margin10, margin10 )
            panel:DockPadding( infoW, 0, 0, 0 )
            panel:SetTall( height )
            panel.Paint = function( self2, w, h )
                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
                draw.RoundedBoxEx( 8, 0, 0, infoW, h, BOTCHED.FUNC.GetTheme( 1 ), true, false, true, false )
    
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
                surface.SetMaterial( icon )
                surface.DrawTexturedRect( (infoW/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            return panel
        end

        local menuValues = values[k] or {}

        for key, val in pairs( menuValues.Commands or {} ) do
            local panel = CreateOpenTypePanel( commandsIcon, BOTCHED.FUNC.ScreenScale( 60 ) )

            local textEntry = vgui.Create( "botched_textentry", panel )
            textEntry:Dock( LEFT )
            textEntry:DockMargin( margin10, margin10, 0, margin10 )
            textEntry:SetWide( BOTCHED.FUNC.ScreenScale( 200 ) )
            textEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
            textEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
            textEntry:SetValue( key )
            textEntry.OnLoseFocus = function( self2 )
                local value = self2:GetValue()
                if( key == value ) then return end

                menuValues.Commands[key] = nil
                menuValues.Commands[value] = true
                BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
                self:Refresh()
            end
        end

        for key, val in pairs( menuValues.NPCs or {} ) do
            local entryH = BOTCHED.FUNC.ScreenScale( 40 )
            local panel = CreateOpenTypePanel( npcsIcon, (3*margin10)+(2*entryH) )

            local entriesBack = vgui.Create( "DPanel", panel )
            entriesBack:Dock( LEFT )
            entriesBack:DockMargin( margin10, margin10, 0, margin10 )
            entriesBack:SetWide( BOTCHED.FUNC.ScreenScale( 400 ) )
            entriesBack.Paint = function() end
            entriesBack.AddEntry = function( self2, field )
                local currentValue = menuValues.NPCs[key][field] or ""

                local leftPadding = BOTCHED.FUNC.ScreenScale( 100 )

                local entryBack = vgui.Create( "DPanel", self2 )
                entryBack:Dock( TOP )
                entryBack:DockMargin( 0, 0, 0, margin10 )
                entryBack:DockPadding( leftPadding, 0, 0, 0 )
                entryBack:SetTall( entryH )
                entryBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 100 ) )
                    draw.SimpleText( field, "MontserratBold22", leftPadding/2, h/2, BOTCHED.FUNC.GetTheme( 4, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                
                local textEntry = vgui.Create( "botched_textentry", entryBack )
                textEntry:Dock( FILL )
                textEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
                textEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
                textEntry:SetValue( currentValue )
                textEntry:SetRoundedCorners( false, true, false, true )
                textEntry.OnLoseFocus = function( self3 )
                    local value = self3:GetValue()
                    if( currentValue == value ) then return end
    
                    menuValues.NPCs[key][field] = value
                    BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
                    self:Refresh()
                end
            end

            entriesBack:AddEntry( "Name" )
            entriesBack:AddEntry( "Model" )
        end

        for key, val in pairs( menuValues.Keys or {} ) do
            local panel = CreateOpenTypePanel( keyIcon, BOTCHED.FUNC.ScreenScale( 60 ) )

            local comboEntry = vgui.Create( "botched_combosearch", panel )
            comboEntry:Dock( LEFT )
            comboEntry:DockMargin( margin10, margin10, 0, margin10 )
            comboEntry:SetWide( BOTCHED.FUNC.ScreenScale( 200 ) )
            comboEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
            comboEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
            comboEntry.OnSelect = function( self2, index, value, data )
                if( key == data ) then return end

                menuValues.Keys[key] = nil
                menuValues.Keys[data] = true
                BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
                self:Refresh()
            end

            for k, v in ipairs( BOTCHED.DEVCONFIG.KeyBinds ) do
                if( menuValues.Keys[k] ) then continue end
                comboEntry:AddChoice( v, k )
            end

            comboEntry:SetValue( BOTCHED.DEVCONFIG.KeyBinds[key] )
        end

        menuPanel:SetTall( BOTCHED.FUNC.ScreenScale( 40 )+typePanelH+panelSpacing  )
        menuTotalH = menuTotalH+menuPanel:GetTall()+panelSpacing
    end

    self:SetTall( menuTotalH )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_config_menus", PANEL, "DPanel" )