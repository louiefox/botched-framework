local PANEL = {}

function PANEL:Init()

end

function PANEL:Refresh()
    self:Clear()

    local gridWide = self:GetWide()
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 150 ) )
    local spacing = BOTCHED.FUNC.ScreenScale( 10 )
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( spacing )
    self.grid:SetSpaceX( spacing )

    local items = BOTCHED.FUNC.GetChangedVariable( "LOCKER", "Items" ) or BOTCHED.CONFIGMETA.LOCKER:GetConfigValue( "Items" )
    
    local sortedItems = {}
    for k, v in pairs( items ) do
        local item = table.Copy( v )
        item.Key = k

        table.insert( sortedItems, item )
    end

    table.SortByMember( sortedItems, "Stars" )

    for k, v in pairs( sortedItems ) do
        local itemPanel = self.grid:Add( "botched_item_slot" )
        itemPanel:SetSize( slotSize, slotSize*1.2 )
        itemPanel:SetItemInfo( v, false, function()
            self:CreateItemPopup( v.Key, items )
        end )
        itemPanel:SetShadowScissor( function() 
            local startY, endY = self.GetYShadowScissor()
            return 0, startY, ScrW(), endY 
        end )
    end

    local iconSize = BOTCHED.FUNC.ScreenScale( 64 )
    surface.SetFont( "MontserratBold30" )
    local contentH = iconSize+select( 2, surface.GetTextSize( "ADD NEW" ) )-BOTCHED.FUNC.ScreenScale( 5 )

    local addNewButton = vgui.Create( "DButton", self.grid )
    addNewButton:SetSize( slotSize, slotSize*1.2 )
    addNewButton:SetText( "" )
    local addMat = Material( "botched/icons/add_64.png" )
    addNewButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.2, 50 )

        local startY, endY = self.GetYShadowScissor()

        local uniqueID = "botched_config_item_add"
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

        draw.SimpleText( "ADD NEW", "MontserratBold30", w/2, (h/2)+(contentH/2)+BOTCHED.FUNC.ScreenScale( 5 ), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end
    addNewButton.DoClick = function()
        BOTCHED.FUNC.DermaStringRequest( "Enter a unique item ID, no spaces, no capitals.", "ITEM CREATION", "uniqueid", false, function( value )
            if( items[value] ) then 
                BOTCHED.FUNC.DermaMessage( "An item already exists with this ID.", "CREATION ERROR" )
                return
            end

            items[value] = {
                Name = "New Item",
                Model = "models/player/skeleton.mdl",
                Stars = 1,
                Border = 1,
                Type = "playermodel",
                TypeInfo = { "models/player/skeleton.mdl" }
            }
    
            BOTCHED.FUNC.RequestConfigChange( "LOCKER", "Items", items )
            self:Refresh()
        end )
    end

    self:SetTall( (math.ceil( (table.Count( items )+1)/slotsWide )*((slotSize*1.2)+spacing))-spacing )
end

function PANEL:CreateItemPopup( itemKey, items )
    if( IsValid( popup ) ) then return end

    local configItem = items[itemKey]
    local itemPanel

    local valueChanged = false
    local function ChangeItemVariable( field, value )
        valueChanged = true
        configItem[field] = value
        itemPanel:SetItemInfo( configItem )
    end

    local popup = vgui.Create( "botched_popup_config" )
    popup:SetHeader( "ITEM CONFIG" )
    popup.OnClose = function()
        if( not valueChanged ) then return end
        BOTCHED.FUNC.RequestConfigChange( "LOCKER", "Items", items )
        self:Refresh()
    end
    popup:FinishSetup()

    self.popup = popup

    popup:SetInfo( "Item Info", "Basic information and actions.", Material( "botched/icons/data.png" ) )

    popup:AddActionButton( "Delete", Material( "botched/icons/delete_24.png" ), function()
        BOTCHED.FUNC.DermaQuery( "Are you sure you want to delete this item?", "ITEM DELETION", "Confirm", function()
            items[itemKey] = nil
            valueChanged = true
            popup:Close()
        end, "Cancel" )
    end )

    -- VARIABLES --
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )

    -- ITEM ID --
    local itemIDLeftPadding = BOTCHED.FUNC.ScreenScale( 40 )

    local itemIDBack = vgui.Create( "DPanel", popup.infoBottom )
    itemIDBack:Dock( LEFT )
    itemIDBack:DockMargin( margin10, margin10, 0, margin10 )
    itemIDBack:DockPadding( itemIDLeftPadding, 0, 0, 0 )
    itemIDBack:SetWide( BOTCHED.FUNC.ScreenScale( 200 ) )
    itemIDBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 175 ) )

        draw.SimpleText( "ID:", "MontserratBold20", itemIDLeftPadding/2, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local itemIDEntry = vgui.Create( "botched_textentry", itemIDBack )
    itemIDEntry:Dock( FILL )
    itemIDEntry:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
    itemIDEntry:SetHighlightColor( BOTCHED.FUNC.GetTheme( 1 ) )
    itemIDEntry:SetRoundedCorners( false, true, false, true )
    itemIDEntry:SetValue( itemKey )
    itemIDEntry:SetEnabled( false )

    -- ITEM SLOT --
    local itemPanelWide = BOTCHED.FUNC.ScreenScale( 200 )
    itemPanel = vgui.Create( "botched_item_slot", popup )
    itemPanel:SetSize( itemPanelWide, itemPanelWide*1.2 )
    itemPanel:SetPos( popup.sectionMargin+(popup.sectionWide/2)-(itemPanelWide/2), popup.header:GetTall()+(popup.mainPanel.targetH-popup.header:GetTall()-popup.infoBack:GetTall())/2-itemPanel:GetTall()/2 )
    itemPanel:SetItemInfo( configItem )

    -- NAME --
    local nameField = popup:AddField( "Name", "The name of the item.", Material( "botched/icons/name_24.png" ) )
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
    local modelField = popup:AddField( "Model", "The model/icon used for the item.", Material( "botched/icons/image_24.png" ) )

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
        button:SetWide( (modelField:GetWide()-(2*margin10))/2 )
        button:SetText( "" )
        local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
        button.Paint = function( self3, w, h )
            self3:CreateFadeAlpha( 0.2, 100, false, false, modelBack.modelType == type, 155 )

            draw.RoundedBoxEx( 8, 0, 0, w, popup.fieldHeaderH, BOTCHED.FUNC.GetTheme( 2, 100+(self3.alpha or 0) ), currentCount == 1, currentCount == self2.count )

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
    local starsField = popup:AddField( "Stars", "The amount of stars this item is.", Material( "botched/icons/star_24_blank.png" ) )
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
    local borderField = popup:AddField( "Border", "A border to use for the item display.", Material( "botched/icons/border_24.png" ) )

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
    local typeField = popup:AddField( "Type Info", "The type of item and info related to it.", Material( "botched/icons/type_24.png" ) )

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

function PANEL:Paint( w, h )

end

vgui.Register( "botched_config_lockeritems", PANEL, "DPanel" )