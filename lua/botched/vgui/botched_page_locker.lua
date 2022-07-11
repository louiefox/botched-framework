local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.rightPanel = vgui.Create( "DPanel", self )
    self.rightPanel:Dock( RIGHT )
    self.rightPanel:SetSize( self:GetWide()*0.4, self:GetTall() )
    self.rightPanel.Paint = function( self2, w, h )
        if( self.FullyOpened ) then
            local x, y = self2:LocalToScreen( 0, 0 )

            BOTCHED.FUNC.BeginShadow( "inventory_sidepanel", 0, y, ScrW(), y+h )
            BOTCHED.FUNC.SetShadowSize( "inventory_sidepanel", w, h-4 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( x, y, w, h )
            BOTCHED.FUNC.EndShadow( "inventory_sidepanel", x, y, 1, 2, 2, 255, 0, 0, true )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 35 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.scrollPanel = vgui.Create( "botched_scrollpanel", self )
    self.scrollPanel:Dock( FILL )
    self.scrollPanel:DockMargin( 25, 25, 25, 25 )
    self.scrollPanel.screenX, self.scrollPanel.screenY = 0, 0
    self.scrollPanel.Paint = function( self2, w, h )
        self.scrollPanel.screenX, self.scrollPanel.screenY = self2:LocalToScreen( 0, 0 )
    end

    local gridWide = self:GetWide()-self.rightPanel:GetWide()-70
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 150 ) )
    local spacing = BOTCHED.FUNC.ScreenScale( 10 )
    self.slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    self.grid = vgui.Create( "DIconLayout", self.scrollPanel )
    self.grid:Dock( TOP )
    self.grid:SetSpaceY( spacing )
    self.grid:SetSpaceX( spacing )

    timer.Simple( 0, function() self:Refresh() end )

    hook.Add( "Botched.Hooks.LockerUpdated", self, self.Refresh )
end

function PANEL:SetDisplayItem( itemKey )
    local configItem = BOTCHED.CONFIG.LOCKER.Items[itemKey]
    if( not configItem ) then return end

    local lockerTable = LocalPlayer():Botched():GetLocker()
    local lockerItem = lockerTable[itemKey]

    self.displayItemKey = itemKey
    self.rightPanel:Clear()

    local infoTop = vgui.Create( "DPanel", self.rightPanel )
    infoTop:Dock( TOP )
    infoTop:SetTall( 75 )
    infoTop.Paint = function( self2, w, h )
        draw.SimpleText( configItem.Name, "MontserratBold40", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        local sectionWide = 12
        local sections = math.floor( ((w-50)/sectionWide)/2 )
        sectionWide = (w-50)/((sections*2)-1)

        for i = 1, sections do
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2 ) )
            surface.DrawRect( 25+((i-1)*(2*sectionWide)), h-2, sectionWide, 2 )
        end
    end

    local itemPanel = vgui.Create( "botched_item_slot", self.rightPanel )
    itemPanel:SetSize( BOTCHED.FUNC.ScreenScale( 175 ), BOTCHED.FUNC.ScreenScale( 175 )*1.2 )
    itemPanel:SetPos( 25, infoTop:GetTall()+25 )
    itemPanel:SetItemInfo( itemKey, lockerTable.Amount, false, configItem.Name .. "_selected" )
    itemPanel:DisableText( true )
    itemPanel:SetShadowDisable( function() return not self.FullyOpened end )

    surface.SetFont( "MontserratBold20" )
    local textX, textY = surface.GetTextSize( "ITEM INFO" )
    textX, textY = textX+15, textY+10

    local itemPanelInfo = vgui.Create( "DPanel", self.rightPanel )
    itemPanelInfo:Dock( TOP )
    itemPanelInfo:DockMargin( 25+itemPanel:GetWide()+25, 25, 25, 0 )
    itemPanelInfo:SetTall( itemPanel:GetTall() )
    itemPanelInfo.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, textX, textY, BOTCHED.FUNC.GetTheme( 2 ) )
        draw.SimpleText( "ITEM INFO", "MontserratBold20", textX/2, textY/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        local text = BOTCHED.FUNC.TextWrap( (configItem.Description or "Some random item that has no description because it hasn't been added yet."), "MontserratMedium20", w )
        BOTCHED.FUNC.DrawNonParsedText( text, "MontserratMedium20", 0, textY+5, BOTCHED.FUNC.GetTheme( 4 ) )
    end

    -- FUNCTIONALITY --
    local typeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]

    local disableEquip, errorMsg
    if( typeConfig.LimitOneType ) then
        for k, v in pairs( lockerTable ) do
            local otherItemCfg = BOTCHED.CONFIG.LOCKER.Items[k]
            if( k == itemKey or not otherItemCfg or configItem.Type != otherItemCfg.Type or not v.Equipped ) then continue end

            disableEquip, errorMsg = true, "Item type already equipped!"
            break
        end
    end

    local buttonText = "USE"
    if( typeConfig.EquipFunction ) then
        buttonText = not lockerItem.Equipped and "EQUIP" or "UNEQUIP"
    end

    local bottomButton = vgui.Create( "DButton", self.rightPanel )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( 25, 0, 25, 25 )
    bottomButton:SetTall( 50 )
    bottomButton:SetText( "" )
    local alpha = 0
    bottomButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 150 )
        else
            alpha = math.Clamp( alpha-10, 0, 255 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100*(alpha/255) ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-5, w, 5, BOTCHED.FUNC.GetTheme( 3, alpha ), false, 16, false, h-5-11 )

        draw.SimpleText( buttonText, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/150)) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    bottomButton.DoClick = function()
        if( typeConfig.UseFunction ) then
            net.Start( "Botched.RequestUseLockerItem" )
                net.WriteString( itemKey )
                net.WriteUInt( self.useAmount, 16 )
            net.SendToServer()
        elseif( not disableEquip ) then
            if( not lockerItem.Equipped ) then
                net.Start( "Botched.RequestEquipLockerItem" )
                    net.WriteString( itemKey )
                net.SendToServer()
            else
                net.Start( "Botched.RequestUnEquipLockerItem" )
                    net.WriteString( itemKey )
                net.SendToServer()
            end
        end
    end

    if( disableEquip ) then
        local errorPanel = vgui.Create( "DPanel", self.rightPanel )
        errorPanel:Dock( BOTTOM )
        errorPanel:DockMargin( 25, 0, 25, 10 )
        errorPanel:SetTall( 30 )
        errorPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.DEVCONFIG.Colors.DarkRed )

            draw.SimpleText( string.upper( errorMsg ), "MontserratBold20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    if( typeConfig.UseFunction ) then
        self.useAmount = 1
        self.maxUseAmount = lockerItem.Amount

        local amountPanel = vgui.Create( "DPanel", self.rightPanel )
        amountPanel:Dock( BOTTOM )
        amountPanel:DockMargin( 25, 0, 25, 10 )
        amountPanel:SetTall( 40 )
        amountPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        end

        local function IncreaseAmount( amount )
            self.useAmount = math.Clamp( (self.useAmount or 1)+amount, 1, self.maxUseAmount )
        end

        local decreaseButton = vgui.Create( "DButton", amountPanel )
        decreaseButton:Dock( LEFT )
        decreaseButton:SetWide( amountPanel:GetTall() )
        decreaseButton:SetText( "" )
        local alpha = 0
        decreaseButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), true, false, true, false )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ), true, false, true, false )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 3 ), 8 )

            draw.SimpleText( "-", "MontserratBold40", w/2, h/2-3, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        decreaseButton.DownFunc = function()
            if( timer.Exists( "BOTCHED.Timer.ItemUseDecrease." .. tostring( decreaseButton ) ) ) then return end

            timer.Create( "BOTCHED.Timer.ItemUseDecrease." .. tostring( decreaseButton ), 0.1, 1, function()
                if( decreaseButton:IsDown() ) then
                    IncreaseAmount( -1 )
                    timer.Simple( 0, function() decreaseButton.DownFunc() end )
                end
            end )
        end
        decreaseButton.OnDepressed = function( self2 )
            IncreaseAmount( -1 )
            decreaseButton.DownFunc()
        end

        surface.SetFont( "MontserratBold25" )
        local maxX, maxY = surface.GetTextSize( "MAX" )

        local maxButton = vgui.Create( "DButton", amountPanel )
        maxButton:Dock( RIGHT )
        maxButton:SetWide( maxX+20 )
        maxButton:SetText( "" )
        local alpha = 0
        maxButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ), false, true, false, true )
            draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ), false, true, false, true )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 3 ), 8 )

            draw.SimpleText( "MAX", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        maxButton.DoClick = function()
            IncreaseAmount( self.maxUseAmount )
        end

        local increaseButton = vgui.Create( "DButton", amountPanel )
        increaseButton:Dock( RIGHT )
        increaseButton:SetWide( amountPanel:GetTall() )
        increaseButton:SetText( "" )
        local alpha = 0
        increaseButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
            surface.DrawRect( 0, 0, w, h )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, alpha ) )
            surface.DrawRect( 0, 0, w, h )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 3 ) )

            draw.SimpleText( "+", "MontserratBold40", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        increaseButton.DownFunc = function()
            if( timer.Exists( "BOTCHED.Timer.ItemUseIncrease." .. tostring( increaseButton ) ) ) then return end

            timer.Create( "BOTCHED.Timer.ItemUseIncrease." .. tostring( increaseButton ), 0.1, 1, function()
                if( increaseButton:IsDown() ) then
                    IncreaseAmount( 1 )
                    timer.Simple( 0, function() increaseButton.DownFunc() end )
                end
            end )
        end
        increaseButton.OnDepressed = function( self2 )
            IncreaseAmount( 1 )
            increaseButton.DownFunc()
        end

        local amountBar = vgui.Create( "DPanel", amountPanel )
        amountBar:Dock( FILL )
        local barWLerp
        amountBar.Paint = function( self2, w, h )
            barWLerp = barWLerp and Lerp( FrameTime()*20, barWLerp, math.Clamp( w*(self.useAmount/self.maxUseAmount), 0, w ) ) or w*(self.useAmount/self.maxUseAmount)

            local barH = 5
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
            surface.DrawRect( 0, h-barH, w, barH )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
            surface.DrawRect( 0, h-barH, barWLerp+(self.useAmount > 0 and 1 or 0), barH )

            draw.SimpleText( math.min( self.maxUseAmount or 1, self.useAmount or 1 ) .. "/" .. (self.maxUseAmount or 1), "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end
end

function PANEL:Refresh()
    self.grid:Clear()

    local lockerTable = LocalPlayer():Botched():GetLocker()

    local sortedInventory = {}
    for k, v in pairs( lockerTable ) do
        local configItem = BOTCHED.CONFIG.LOCKER.Items[k]

        if( not configItem ) then continue end

        table.insert( sortedInventory, { ((configItem.Stars or 0)*100)+configItem.Border, configItem, k, v.Amount } )
    end

    table.SortByMember( sortedInventory, 1 )

    if( lockerTable[self.displayItemKey or ""] ) then
        self:SetDisplayItem( self.displayItemKey )
    else
        self.displayItemKey = nil
        self.rightPanel:Clear()
    end

    for k, v in pairs( sortedInventory ) do
        local configItem, itemKey, amount = v[2], v[3], v[4]

        if( not self.displayItemKey ) then
            self:SetDisplayItem( itemKey )
        end

        local itemPanel = self.grid:Add( "botched_item_slot" )
        itemPanel:SetSize( self.slotSize, self.slotSize*1.2 )
        itemPanel:SetItemInfo( itemKey, amount, function()
            self:SetDisplayItem( itemKey )
        end )
        itemPanel:SetShadowScissor( 0, self.scrollPanel.screenY, ScrW(), self.scrollPanel.screenY+self:GetTall()-50 )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_page_locker", PANEL, "DPanel" )