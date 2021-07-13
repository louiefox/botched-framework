local PANEL = {}

function PANEL:Init()

end

function PANEL:Refresh()
    self:Clear()

    local panelH, panelSpacing = BOTCHED.FUNC.ScreenScale( 200 ), BOTCHED.FUNC.ScreenScale( 10 )

    local gridWide = self:GetWide()
    local slotsWide = 3
    local panelW = (gridWide-((slotsWide-1)*panelSpacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( panelSpacing )
    self.grid:SetSpaceX( panelSpacing )

    local values = BOTCHED.FUNC.GetChangedVariable( "GENERAL", "Borders" ) or BOTCHED.CONFIGMETA.GENERAL:GetConfigValue( "Borders" )
    local totalGridH, currentRowMax, currentRowCount = -panelSpacing, 0, 0
    for k, v in ipairs( values ) do
        currentRowCount = currentRowCount+1

        local borderPanel = vgui.Create( "DPanel", self.grid )
        borderPanel:SetSize( panelW, panelH )
        borderPanel.Paint = function( self2, w, h )
            local startY, endY = self.GetYShadowScissor()

            local uniqueID = "botched_config_border_" .. k
            BOTCHED.FUNC.BeginShadow( uniqueID, 0, startY, ScrW(), endY )
            BOTCHED.FUNC.SetShadowSize( uniqueID, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )		
            BOTCHED.FUNC.EndShadow( uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )

            if( not v.Anim ) then
                BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                    BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( v.Colors ) )
                end )
            end
        end

        local borderInfo = vgui.Create( "DPanel", borderPanel )
        borderInfo:Dock( FILL )
        borderInfo:DockMargin( 3, 3, 3, 3 )
        borderInfo.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        end

        local totalH = 0
        local margin10, margin5 = BOTCHED.FUNC.ScreenScale( 10 ), BOTCHED.FUNC.ScreenScale( 5 )

        local function AddText( text )
            local headerLabel = vgui.Create( "DLabel", borderInfo )
            headerLabel:Dock( TOP )
            headerLabel:DockMargin( margin10, margin10, 0, 0 )
            headerLabel:SetText( text )
            headerLabel:SetFont( "MontserratBold20" )
            headerLabel:SetTextColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            headerLabel:SizeToContentsY()

            totalH = totalH+margin10+headerLabel:GetTall()
        end

        AddText( "NAME" )

        local nameEntry = vgui.Create( "botched_textentry", borderInfo )
        nameEntry:Dock( TOP )
        nameEntry:SetTall( BOTCHED.FUNC.ScreenScale( 30 ) )
        nameEntry:DockMargin( margin10, margin5, margin10, 0 )
        nameEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
        nameEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 50 ) )
        nameEntry:SetFont( "MontserratMedium20" )
        nameEntry:SetValue( v.Name )
        nameEntry.OnLoseFocus = function()
            values[k].Name = nameEntry:GetValue()
            BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
        end

        totalH = totalH+nameEntry:GetTall()+margin5

        AddText( "COLOURS" )

        local colourRow = vgui.Create( "DIconLayout", borderInfo )
        colourRow:Dock( TOP )
        colourRow:DockMargin( margin10, margin5, margin10, 0 )
        colourRow:SetSpaceY( margin5 )
        colourRow:SetSpaceX( margin5 )
        colourRow.Paint = function( self2, w, h ) end

        local colourBlocksWide = 8
        local colourBlockSize = (panelW-6-margin10-margin10-((colourBlocksWide-1)*margin5))/colourBlocksWide

        for key, val in pairs( v.Colors ) do
            local colourBlock = vgui.Create( "DButton", colourRow )
            colourBlock:SetSize( colourBlockSize, colourBlockSize )
            colourBlock:SetText( "" )
            colourBlock.Paint = function( self2, w, h )
                self2:CreateFadeAlpha( 0.2, 255 )

                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ) )

                draw.RoundedBox( 8, 2, 2, w-4, h-4, val )
            end
            colourBlock.DoClick = function( self2 )
                if( IsValid( self2.popup ) ) then return end

                self2.popup = vgui.Create( "botched_popup_choice" )
                self2.popup:SetHeader( "BORDER COLOUR EDITOR" )
                self2.popup:AddOption( "Edit Colour", function() 
                    BOTCHED.FUNC.DermaColorRequest( "What should the new colour be?", "EDIT COLOUR", val, false, function( value )
                        values[k].Colors[key] = value
                        BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
                        self:Refresh()
                    end ) 
                end )

                if( #v.Colors > 1 ) then
                    self2.popup:AddOption( "Delete", function() 
                        table.remove( values[k].Colors, key )
                        BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
                        self:Refresh()
                    end )
                end
            end
        end

        local colourAdd = vgui.Create( "DButton", colourRow )
        colourAdd:SetSize( colourBlockSize, colourBlockSize )
        colourAdd:SetText( "" )
        local addMat = Material( "botched/icons/add_16.png" )
        colourAdd.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( 0.2, 155 )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ) )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100+self2.alpha ) )
            surface.SetMaterial( addMat )
            local iconSize = BOTCHED.FUNC.ScreenScale( 16 )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        colourAdd.DoClick = function( self2 )
            table.insert( values[k].Colors, Color( 255, 255, 255 ) )
            BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
            self:Refresh()
        end

        local rows = math.ceil( (#v.Colors+1)/colourBlocksWide )
        totalH = totalH+(rows*(colourBlockSize+margin5))

        AddText( "ANIMATED" )

        local checkRow = vgui.Create( "DPanel", borderInfo )
        checkRow:Dock( TOP )
        checkRow:DockMargin( margin10, margin5, margin10, 0 )
        checkRow:SetTall( BOTCHED.FUNC.ScreenScale( 30 ) )
        checkRow.Paint = function( self2, w, h ) end

        totalH = totalH+checkRow:GetTall()+margin5

        local checkBox = vgui.Create( "botched_checkbox", checkRow )
        checkBox:Dock( LEFT )
        checkBox:SetWide( checkRow:GetTall() )
        checkBox:SetChecked( v.Anim )
        checkBox.OnChange = function( self2, checked )
            values[k].Anim = checked
            BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
            self:Refresh()
        end

        local optionsButton = vgui.Create( "DButton", checkRow )
        optionsButton:Dock( RIGHT )
        optionsButton:SetWide( checkRow:GetTall() )
        optionsButton:SetText( "" )
        local optionsMat = Material( "botched/icons/options_24.png" )
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
            self2.popup:SetHeader( "BORDER EDITOR" )
            self2.popup:AddOption( "Duplicate", function() 
                table.insert( values, v )
                BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
                self:Refresh()
            end )
            self2.popup:AddOption( "Delete", function() 
                table.remove( values, k )
                BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
                self:Refresh()
            end )
        end

        borderPanel:SetTall( totalH+6+margin10 )

        if( v.Anim ) then
            local borderAnim = vgui.Create( "botched_gradientanim", borderPanel )
            borderAnim:SetSize( borderPanel:GetSize() )
            borderAnim:SetZPos( -100 )
            borderAnim:SetDirection( 1 )
            borderAnim:SetAnimTime( 5 )
            borderAnim:SetAnimSize( borderAnim:GetTall()*6 )
            borderAnim:SetColors( unpack( v.Colors ) )
            borderAnim:SetCornerRadius( 8 )
            borderAnim:StartAnim()
        end

        currentRowMax = math.max( currentRowMax, borderPanel:GetTall() )

        if( currentRowCount >= slotsWide ) then
            currentRowCount = 0
            totalGridH = totalGridH+currentRowMax+panelSpacing
            currentRowMax = 0
        end
    end

    local iconSize = BOTCHED.FUNC.ScreenScale( 64 )
    surface.SetFont( "MontserratBold40" )
    local contentH = iconSize+select( 2, surface.GetTextSize( "ADD NEW" ) )-BOTCHED.FUNC.ScreenScale( 5 )

    local addNewButton = vgui.Create( "DButton", self.grid )
    addNewButton:SetSize( panelW, panelH )
    addNewButton:SetText( "" )
    local addMat = Material( "botched/icons/add_64.png" )
    addNewButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.2, 50 )

        local startY, endY = self.GetYShadowScissor()

        local uniqueID = "botched_config_border_add"
        BOTCHED.FUNC.BeginShadow( uniqueID, 0, startY, ScrW(), endY )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )		
        BOTCHED.FUNC.EndShadow( uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )

        draw.RoundedBox( 8, 3, 3, w-6, h-6, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, 3, 3, w-6, h-6, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        local textColor = BOTCHED.FUNC.GetTheme( 4, 100+((self2.alpha/50)*155) )
        surface.SetDrawColor( textColor )
        surface.SetMaterial( addMat )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(contentH/2), iconSize, iconSize )

        draw.SimpleText( "ADD NEW", "MontserratBold40", w/2, (h/2)+(contentH/2)+BOTCHED.FUNC.ScreenScale( 5 ), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end
    addNewButton.DoClick = function()
        table.insert( values, { Name = "New Border", Colors = { Color( 255, 125, 125 ), Color( 125, 255, 125 ), Color( 125, 125, 255 ) } } )
        BOTCHED.FUNC.RequestConfigChange( "GENERAL", "Borders", values )
        self:Refresh()
    end

    totalGridH = totalGridH+math.max( currentRowMax, panelH )+panelSpacing

    self:SetTall( totalGridH )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_config_borders", PANEL, "DPanel" )