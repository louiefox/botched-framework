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
    local optionsMat = Material( "botched/icons/options_24.png" )

    local menuTotalH = -panelSpacing
    for k, v in pairs( BOTCHED.DEVCONFIG.MenuTypes ) do
        values[k] = values[k] or {}

        local title = string.upper( v.Title )
        local menuValues = values[k]

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
        local function CreateOpenTypePanel( icon, height, field, key )
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

            local optionsButton = vgui.Create( "DButton", panel )
            optionsButton:SetWide( BOTCHED.FUNC.ScreenScale( 30 ) )
            optionsButton:Dock( RIGHT )
            local topMargin = (height-optionsButton:GetWide())/2
            optionsButton:DockMargin( 0, topMargin, (BOTCHED.FUNC.ScreenScale( 60 )-optionsButton:GetWide())/2, topMargin )
            optionsButton:SetText( "" )
            optionsButton.Paint = function( self2, w, h )
                self2:CreateFadeAlpha( 0.2, 155 )
    
                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )
                BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
    
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100+self2.alpha ) )
                surface.SetMaterial( optionsMat )
                local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end
            optionsButton.DoClick = function( self2 )
                self2.popup = vgui.Create( "botched_popup_choice" )
                self2.popup:SetHeader( "MENU EDITOR" )
                self2.popup:AddOption( "Delete", function() 
                    menuValues[field][key] = nil
                    BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
                    self:Refresh()
                end )
            end

            return panel
        end

        menuValues.Commands = menuValues.Commands or {}
        for key, val in pairs( menuValues.Commands ) do
            local panel = CreateOpenTypePanel( commandsIcon, BOTCHED.FUNC.ScreenScale( 60 ), "Commands", key )

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

        menuValues.NPCs = menuValues.NPCs or {}
        for key, val in pairs( menuValues.NPCs ) do
            local entryH = BOTCHED.FUNC.ScreenScale( 40 )
            local panel = CreateOpenTypePanel( npcsIcon, (3*margin10)+(2*entryH), "NPCs", key )

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

        menuValues.Keys = menuValues.Keys or {}
        for key, val in pairs( menuValues.Keys ) do
            local panel = CreateOpenTypePanel( keyIcon, BOTCHED.FUNC.ScreenScale( 60 ), "Keys", key )

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

        local buttonPanel = vgui.Create( "DPanel", menuPanel )
        buttonPanel:Dock( TOP )
        buttonPanel:DockMargin( margin10, 0, margin10, margin10 )
        buttonPanel:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
        buttonPanel.Paint = function( self2, w, h ) end
        buttonPanel.AddButton = function( self2, text, iconMat, doClick )
            local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
            surface.SetFont( "MontserratBold20" )

            local button = vgui.Create( "DButton", self2 )
            button:Dock( LEFT )
            button:DockMargin( 0, 0, margin10, 0 )
            button:SetWide( self2:GetTall()+surface.GetTextSize( text )+20 )
            button:SetText( "" )
            button.Paint = function( self2, w, h )
                self2:CreateFadeAlpha( 0.2, 50 )

                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
                draw.RoundedBoxEx( 8, 0, 0, h, h, BOTCHED.FUNC.GetTheme( 1 ), true, false, true, false )

                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, self2.alpha ) )

                BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )
    
                local textColor = BOTCHED.FUNC.GetTheme( 4, 100+(self2.alpha/50)*155 )

                surface.SetDrawColor( textColor )
                surface.SetMaterial( iconMat )
                surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( text, "MontserratBold20", h+((w-h)/2), h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            button.DoClick = doClick
        end

        buttonPanel:AddButton( "Add Chat Command", Material( "botched/icons/command_24.png" ), function()
            BOTCHED.FUNC.DermaStringRequest( "What should the new command be?", "MENU EDITOR", "/newcmd", false, function( value )
                if( menuValues.Commands[value] ) then return end
                menuValues.Commands[value] = true
                BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
                self:Refresh()
            end )
        end )
        buttonPanel:AddButton( "Add NPC", Material( "botched/icons/npc_24.png" ), function()
            table.insert( menuValues.NPCs, {
                Name = "New NPC",
                Model = "models/breen.mdl"
            } )
            BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
            self:Refresh()
        end )
        buttonPanel:AddButton( "Add Hotkey", Material( "botched/icons/hotkey_24.png" ), function()
            local options = {}
            for k, v in ipairs( BOTCHED.DEVCONFIG.KeyBinds ) do
                if( menuValues.Keys[k] ) then continue end
                options[k] = v
            end

            BOTCHED.FUNC.DermaComboRequest( "What should the hotkey be?", "MENU EDITOR", options, false, true, false, function( value, data )
                if( not BOTCHED.DEVCONFIG.KeyBinds[data] ) then return end
                menuValues.Keys[data] = true
                BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Menus", values )
                self:Refresh()
            end )
        end )

        menuPanel:SetTall( BOTCHED.FUNC.ScreenScale( 40 )+typePanelH+panelSpacing+buttonPanel:GetTall()+panelSpacing  )
        menuTotalH = menuTotalH+menuPanel:GetTall()+panelSpacing
    end

    self:SetTall( menuTotalH )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_config_menus", PANEL, "DPanel" )