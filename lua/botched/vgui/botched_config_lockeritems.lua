local PANEL = {}

function PANEL:Init()

end

function PANEL:Refresh()
    local panelH, panelSpacing = BOTCHED.FUNC.ScreenScale( 150 ), BOTCHED.FUNC.ScreenScale( 10 )

    local gridWide = self:GetWide()
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 150 ) )
    local spacing = BOTCHED.FUNC.ScreenScale( 10 )
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( panelSpacing )
    self.grid:SetSpaceX( panelSpacing )

    local startY, endY = self.GetYShadowScissor()

    local items = BOTCHED.FUNC.GetChangedVariable( "LOCKER", "Items" ) or BOTCHED.CONFIGMETA.LOCKER:GetConfigValue( "Items" )
    for k, v in pairs( items ) do
        local itemPanel = self.grid:Add( "botched_item_slot" )
        itemPanel:SetSize( slotSize, slotSize*1.2 )
        itemPanel:SetItemInfo( v, false, function()
            self:CreateItemPopup( k, items )
        end )
        itemPanel:SetShadowScissor( 0, startY, ScrW(), endY )
    end

    self:SetTall( (math.ceil( table.Count( items )/slotsWide )*((slotSize*1.2)+panelSpacing))-panelSpacing )
end

function PANEL:CreateItemPopup( itemKey, items )
    if( IsValid( self.popup ) ) then return end

    local configItem = items[itemKey]
    local itemPanel

    local valueChanged = false
    local function ChangeItemVariable( field, value )
        valueChanged = true
        configItem[field] = value
        itemPanel:SetItemInfo( configItem )
    end

    self.popup = vgui.Create( "botched_popup_base" )
    self.popup:SetPopupWide( ScrW()*0.35 )
    self.popup:SetExtraHeight( ScrH()*0.4 )
    self.popup:SetHeader( "ITEM CONFIG" )
    self.popup.OnClose = function()
        if( not valueChanged ) then return end
        BOTCHED.FUNC.RequestConfigChange( "LOCKER", "Items", items )
        self:Refresh()
    end

    local sectionMargin = BOTCHED.FUNC.ScreenScale( 25 )
    local sectionWide = (self.popup:GetPopupWide()-(2*sectionMargin))/2

    local itemPanelWide = BOTCHED.FUNC.ScreenScale( 200 )

    itemPanel = vgui.Create( "botched_item_slot", self.popup )
    itemPanel:SetSize( itemPanelWide, itemPanelWide*1.2 )
    itemPanel:SetPos( sectionMargin/2+(sectionWide/2)-(itemPanelWide/2), self.popup.header:GetTall()+(self.popup.mainPanel.targetH-self.popup.header:GetTall())/2-itemPanel:GetTall()/2 )
    itemPanel:SetItemInfo( configItem )

    local margin5 = BOTCHED.FUNC.ScreenScale( 5 )
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
    local margin25 = BOTCHED.FUNC.ScreenScale( 25 )
    local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
    local headerH = BOTCHED.FUNC.ScreenScale( 50 )
    local arrowMat = Material( "botched/icons/down.png" )

    local fieldsBack = vgui.Create( "botched_scrollpanel", self.popup )
    fieldsBack:Dock( RIGHT )
    fieldsBack:DockMargin( 0, sectionMargin, sectionMargin, sectionMargin )
    fieldsBack:SetWide( sectionWide )
    fieldsBack.Paint = function() end
    fieldsBack.AddField = function( self2, name, description, iconMat ) 
        local fieldPanel = vgui.Create( "DPanel", self2 )
        fieldPanel:Dock( TOP )
        fieldPanel:SetTall( headerH )
        fieldPanel:DockMargin( 0, 0, margin10, margin10 )
        fieldPanel.actualW = sectionWide-margin10-10
        fieldPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ) )
        end
        fieldPanel.SetExpanded = function( self2, expanded )
            self2.expanded = expanded

            if( expanded ) then
                self2:SizeTo( self2.actualW, self2.fullHeight, 0.2 )
                self2.header:DoRotationAnim( true )
            else
                self2:SizeTo( self2.actualW, headerH, 0.2 )
                self2.header:DoRotationAnim( false )
            end
        end
        fieldPanel.SetExtraHeight = function( self2, extraHeight )
            self2.fullHeight = headerH+extraHeight

            if( self2.expanded ) then return end
            self2:SetExpanded( true )
        end
        
        fieldPanel.header = vgui.Create( "DButton", fieldPanel )
        fieldPanel.header:Dock( TOP )
        fieldPanel.header:SetTall( headerH )
        fieldPanel.header:SetText( "" )
        fieldPanel.header.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( 0.2, 155 )

            local roundBottom = fieldPanel:GetTall() <= headerH
            draw.RoundedBoxEx( 8, 0, 0, w, headerH, BOTCHED.FUNC.GetTheme( 2, 100+(self2.alpha or 0) ), true, true, roundBottom, roundBottom )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            surface.SetMaterial( arrowMat )
            surface.DrawTexturedRectRotated( w-((headerH-iconSize)/2)-(iconSize/2), headerH/2, iconSize, iconSize, math.Clamp( (self2.textureRotation or 0), -90, 0 ) )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( name, "MontserratBold22", h, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( description, "MontserratMedium20", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
        end
        fieldPanel.header.textureRotation = 0
        fieldPanel.header.DoRotationAnim = function( self2, expanding )
            local anim = self2:NewAnimation( 0.2, 0, -1 )
        
            anim.Think = function( anim, pnl, fraction )
                if( expanding ) then
                    self2.textureRotation = (1-fraction)*-90
                else
                    self2.textureRotation = fraction*-90
                end
            end
        end
        fieldPanel.header.DoClick = function( self2 )
            fieldPanel:SetExpanded( not fieldPanel.expanded )
        end

        return fieldPanel
    end

    -- NAME --
    local nameField = fieldsBack:AddField( "Name", "The name of the item.", Material( "botched/icons/name_24.png" ) )
    nameField:SetExtraHeight( BOTCHED.FUNC.ScreenScale( 60 ) )

    local nameEntry = vgui.Create( "botched_textentry", nameField )
    nameEntry:Dock( TOP )
    nameEntry:DockMargin( margin10, margin10, margin10, margin10 )
    nameEntry:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
    nameEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
    nameEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )
    nameEntry:SetValue( configItem.Name )
    nameEntry.OnChange = function( self2 )
        ChangeItemVariable( "Name", self2:GetValue() )
    end

    -- MODEL --
    local modelField = fieldsBack:AddField( "Model", "The model/icon used for the item.", Material( "botched/icons/image_24.png" ) )

    local modelEntry

    local modelBack = vgui.Create( "DPanel", modelField )
    modelBack:Dock( TOP )
    modelBack:DockMargin( 0, margin10, 0, margin10 )
    modelBack:SetTall( BOTCHED.FUNC.ScreenScale( 150 ) )
    local loadingMat = Material( "botched/icons/loading.png" )
    modelBack.Paint = function( self2, w, h ) 
        if( self2.loadingModel ) then
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            surface.SetMaterial( loadingMat )
            local iconSize = BOTCHED.FUNC.ScreenScale( 32 )
            surface.DrawTexturedRectRotated( w/2, h/2, iconSize, iconSize, -CurTime()*200 )
            return
        end

        if( self2.modelType == "Image" ) then
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( self2.iconMat )
            local iconSize = BOTCHED.FUNC.ScreenScale( 64 )
            surface.DrawTexturedRect( w/2-iconSize/2, h/2-iconSize/2, iconSize, iconSize )
        end
    end
    modelBack.modelType = string.EndsWith( configItem.Model, ".mdl" ) and "Model" or "Image"
    modelBack.RefreshModel = function( self2 )
        self2.loadingModel = true

        if( self2.modelType == "Model" ) then
            if( IsValid( self2.modelPanel ) ) then
                self2.modelPanel:ChangeModel( configItem.Model )
                return
            end

            self2.modelPanel = vgui.Create( "DModelPanel", self2 )
            self2.modelPanel:Dock( FILL )
            self2.modelPanel:SetCursor( "arrow" )
            self2.modelPanel.LayoutEntity = function() end
            self2.modelPanel.ChangeModel = function( self3, model ) 
                self3:SetModel( model )

                if( not IsValid( self3.Entity ) ) then return end

                local itemTypeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]

                if( not itemTypeConfig or not itemTypeConfig.ModelDisplay ) then
                    local mn, mx = self3.Entity:GetRenderBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
                    self3:SetCamPos( Vector( size, size, size ) )
                    self3:SetLookAt( (mn + mx) * 0.5 )
                else
                    itemTypeConfig.ModelDisplay( self3 )
                end

                self3:SetFOV( 90 )
                self2.loadingModel = false
            end
            self2.modelPanel:ChangeModel( configItem.Model )
        else
            if( IsValid( self2.modelPanel ) ) then
                self2.modelPanel:Remove()
            end

            BOTCHED.FUNC.GetImage( configItem.Model, function( mat )
                self2.iconMat = mat
                self2.loadingModel = false
            end )
        end
    end

    modelBack:RefreshModel()

    surface.SetFont( "MontserratBold22" )

    local modelHint = vgui.Create( "DPanel", modelField )
    modelHint:Dock( TOP )
    modelHint:DockMargin( 0, 0, 0, margin10 )
    modelHint:SetTall( select( 2, surface.GetTextSize( "Press enter to update model." ) ) )
    modelHint.Paint = function( self2, w, h ) 
        local text = "Model loaded"
        if( IsValid( modelEntry ) and modelEntry:GetValue() != configItem.Model ) then
            text = "Press enter to update model"
        elseif( modelBack.loadingModel ) then
            text = "Loading model..."
        end

        draw.SimpleText( text, "MontserratBold22", w/2, 0, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER )
    end

    local modelTypeRow = vgui.Create( "DPanel", modelField )
    modelTypeRow:Dock( TOP )
    modelTypeRow:DockMargin( margin10, 0, margin10, 0 )
    modelTypeRow:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
    modelTypeRow.Paint = function() end
    modelTypeRow.TypeValues = {}
    modelTypeRow.AddType = function( self2, type, iconMat, default )
        self2.count = (self2.count or 0)+1
        local currentCount = self2.count

        self2.TypeValues[type] = modelBack.modelType == type and configItem.Model

        local button = vgui.Create( "DButton", modelTypeRow )
        button:Dock( LEFT )
        button:SetWide( (modelField.actualW-(2*margin10))/2 )
        button:SetText( "" )
        button.Paint = function( self3, w, h )
            self3:CreateFadeAlpha( 0.2, 100, false, false, modelBack.modelType == type, 155 )

            draw.RoundedBoxEx( 8, 0, 0, w, headerH, BOTCHED.FUNC.GetTheme( 2, 100+(self3.alpha or 0) ), currentCount == 1, currentCount == self2.count )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( type, "MontserratBold22", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        button.DoClick = function( self3 )
            modelBack.modelType = type

            ChangeItemVariable( "Model", self2.TypeValues[type] or "" )
            modelEntry:SetValue( self2.TypeValues[type] or "" )
            modelEntry:SetBackText( default )

            modelBack:RefreshModel()
        end
    end

    modelTypeRow:AddType( "Model", Material( "botched/icons/image_24.png" ), "Model Path" )
    modelTypeRow:AddType( "Image", Material( "botched/icons/image_24.png" ), "Direct Image URL" )

    modelEntry = vgui.Create( "botched_textentry", modelField )
    modelEntry:Dock( TOP )
    modelEntry:DockMargin( margin10, 0, margin10, 0 )
    modelEntry:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
    modelEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
    modelEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )
    modelEntry:SetRoundedCorners( false, false, true, true )
    modelEntry:SetValue( configItem.Model )
    modelEntry.OnEnter = function( self2 )
        modelTypeRow.TypeValues[modelBack.modelType] = self2:GetValue()
        ChangeItemVariable( "Model", self2:GetValue() )
        modelBack:RefreshModel()
    end

    modelField:SetExtraHeight( modelBack:GetTall()+(2*margin10)+modelTypeRow:GetTall()+modelEntry:GetTall()+margin10+modelHint:GetTall()+margin10 )

    -- STARS --
    local starsField = fieldsBack:AddField( "Stars", "The amount of stars this item is.", Material( "botched/icons/star_24_blank.png" ) )
    starsField:SetExtraHeight( BOTCHED.FUNC.ScreenScale( 60 ) )

    local starsEntry = vgui.Create( "botched_numberwang", starsField )
    starsEntry:Dock( TOP )
    starsEntry:DockMargin( margin10, margin10, margin10, margin10 )
    starsEntry:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
    starsEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
    starsEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )
    starsEntry:SetValue( configItem.Stars )
    starsEntry:SetMinMax( 1, 6 )
    starsEntry.OnChange = function( self2 )
        local value = math.Clamp( self2:GetValue(), 1, 6 )
        ChangeItemVariable( "Stars", value )

        self2:SetValue( value )
    end

    -- BORDER --
    local borderField = fieldsBack:AddField( "Border", "A border to use for the item display.", Material( "botched/icons/border_24.png" ) )

    local bordersSpacing = BOTCHED.FUNC.ScreenScale( 10 )
    local borderH = BOTCHED.FUNC.ScreenScale( 35 )
    local borderSize = BOTCHED.FUNC.ScreenScale( 2 )

    local bordersGrid = vgui.Create( "DIconLayout", borderField )
    bordersGrid:Dock( TOP )
    bordersGrid:DockMargin( margin10, margin10, margin10, margin10 )
    bordersGrid:SetSpaceY( bordersSpacing )
    bordersGrid:SetSpaceX( bordersSpacing )

    local borders = BOTCHED.FUNC.GetChangedVariable( "GENERAL", "Borders" ) or BOTCHED.CONFIGMETA.GENERAL:GetConfigValue( "Borders" )
    for k, v in pairs( borders ) do
        surface.SetFont( "MontserratBold20" )

        local button = vgui.Create( "DButton", bordersGrid )
        button:SetSize( surface.GetTextSize( v.Name )+20, borderH )
        button:SetText( "" )
        button.Paint = function( self3, w, h )
            self3:CreateFadeAlpha( 0.2, 50, false, false, configItem.Border == k, 100 )

            BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( v.Colors ) )
            end )

            draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 1 ) )
            draw.RoundedBox( 8, borderSize, borderSize, w-(2*borderSize), h-(2*borderSize), BOTCHED.FUNC.GetTheme( 3, self3.alpha ) )

            draw.SimpleText( v.Name, "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        button.DoClick = function()
            ChangeItemVariable( "Border", k )
        end
    end

    timer.Simple( 0, function() borderField:SetExtraHeight( bordersGrid:GetTall()+(2*margin10) ) end )

    -- TYPE INFO --
    local typeField = fieldsBack:AddField( "Type Info", "The type of item and info related to it.", Material( "botched/icons/type_24.png" ) )

    local typeSelect = vgui.Create( "botched_combo_description", typeField )
    typeSelect:Dock( TOP )
    typeSelect:DockMargin( margin10, margin10, margin10, margin10 )
    typeSelect:SetWide( typeField:GetWide()-(2*margin10) )
    typeSelect.OnSelect = function( self2, index )
        if( index != configItem.Type ) then
            ChangeItemVariable( "Type", index )
        end

        typeField:RefreshReqInfo()
    end

    for k, v in pairs( BOTCHED.DEVCONFIG.ItemTypes ) do
        typeSelect:AddChoice( v.Class, v.Title, v.Description )
    end
    
    typeField.RefreshReqInfo = function( self2 )
        for k, v in ipairs( self2.reqInfoPanels or {} ) do
            v:Remove()
        end

        self2.reqInfoPanels = {}
        
        local typeInfo = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]
        if( not typeInfo ) then return end

        local currentTypeInfo = configItem.TypeInfo

        local headerH = BOTCHED.FUNC.ScreenScale( 50 )
        local entryH = BOTCHED.FUNC.ScreenScale( 40 )
        local slotH = headerH+entryH+margin10
        for k, v in ipairs( typeInfo.ReqInfo ) do
            local slot = vgui.Create( "DPanel", self2 )
            slot:Dock( TOP )
            slot:DockMargin( margin10, 0, margin10, margin10 )
            slot:DockPadding( margin10, headerH, margin10, margin10 )
            slot:SetTall( slotH )
            slot.Paint = function( self2, w, h )
                draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    
                draw.SimpleText( v[2], "MontserratBold20", margin10, headerH/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( v[3], "MontserratMedium17", margin10, headerH/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
            end

            local currentValue = currentTypeInfo[k]
            if( v[1] == BOTCHED.TYPE.String ) then
                slot.entry = vgui.Create( "botched_textentry", slot )
                slot.entry:SetValue( currentValue or "" )
                slot.entry.OnChange = function( self2 )
                    currentTypeInfo[k] = self2:GetValue()
                    ChangeItemVariable( "TypeInfo", currentTypeInfo )
                end
            elseif( v[1] == BOTCHED.TYPE.Int ) then
                slot.entry = vgui.Create( "botched_numberwang", slot )
                slot.entry:SetValue( currentValue or 0 )
                slot.entry.OnChange = function( self2 )
                    currentTypeInfo[k] = self2:GetValue()
                    ChangeItemVariable( "TypeInfo", currentTypeInfo )
                end
            end

            slot.entry:Dock( BOTTOM )
            slot.entry:SetTall( entryH )
            slot.entry:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
            slot.entry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )

            table.insert( self2.reqInfoPanels, slot )
        end

        typeField:SetExtraHeight( margin10+typeSelect:GetTall()+margin10+(#typeInfo.ReqInfo*(slotH+margin10)) )
    end

    typeSelect:SelectChoice( configItem.Type )
end

function PANEL:SetYShadowScissor( startY, endY )
    for k, v in ipairs( self.grid:GetChildren() ) do
        v:SetShadowScissor( 0, startY, ScrW(), endY )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_config_lockeritems", PANEL, "DPanel" )