local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
    local margin25 = BOTCHED.FUNC.ScreenScale( 25 )

    local navigation = vgui.Create( "DPanel", self )
    navigation:Dock( LEFT )
    navigation:DockMargin( 0, 0, margin25, 0 )
    navigation:SetWide( ScrW()*0.11 )
    navigation.Paint = function( self2, w, h )
        if( self.FullyOpened ) then
            local x, y = self2:LocalToScreen( 0, 0 )

            BOTCHED.FUNC.BeginShadow( "admin_config_side", 0, y, ScrW(), y+h )
            BOTCHED.FUNC.SetShadowSize( "admin_config_side", w, h-4 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( x, y, w, h )
            BOTCHED.FUNC.EndShadow( "admin_config_side", x, y, 1, 2, 2, 255, 0, 0, true )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( 0, 0, w, h )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )
            surface.DrawRect( 0, 0, w, h )
        end
    end

    self.navigation = navigation

    self.searchBar = vgui.Create( "botched_combo_description_search", navigation )
    self.searchBar:Dock( TOP )
    self.searchBar:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
    self.searchBar:DockMargin( margin10, margin10, margin10, margin10 )
    -- self.searchBar:SetBackText( "Search" )
    -- self.searchBar:SetBackColor( BOTCHED.FUNC.GetTheme( 2, 50 ) )
    -- self.searchBar:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 50 ) )
    -- self.searchBar:SetCornerRadius( 0 )
    -- self.searchBar:SetFont( "MontserratMedium20" )
    -- self.searchBar.OnChange = function()
    --     self:Refresh()
    -- end

    for k, v in pairs( BOTCHED.CONFIGMETA ) do
        for key, val in pairs( v:GetSortedVariables() ) do
            self.searchBar:AddChoice( key, val.Name, val.Description )
        end
    end

    self.contents = vgui.Create( "DPanel", self )
    self.contents:Dock( FILL )
    self.contents:DockMargin( 0, margin25, margin25, margin25 )
    self.contents.Paint = function() end

    local arrowMat = Material( "botched/icons/down.png" )

    self.pages = {}
    self.activePage = 0
    for k, v in pairs( BOTCHED.CONFIGMETA ) do
        local page = vgui.Create( "DPanel", self.contents )
        page:Dock( FILL )
        page.Paint = function( self2, w, h ) end

        local scrollPanel = vgui.Create( "botched_scrollpanel", page )
        scrollPanel:Dock( FILL )

        page.Refresh = function()
            scrollPanel:Clear()

            for key, val in pairs( v:GetSortedVariables() ) do
                local headerH = BOTCHED.FUNC.ScreenScale( 75 )
                local customElement = val.Type == BOTCHED.TYPE.Table and val.VguiElement

                local variablePanel = vgui.Create( "DPanel", scrollPanel )
                variablePanel:Dock( TOP )
                variablePanel:SetTall( headerH )
                variablePanel:DockMargin( 0, 0, margin10, margin10 )
                variablePanel.Paint = function( self2, w, h )
                    if( customElement and IsValid( self2.button ) ) then
                        if( (self2.actualW or 0) != w ) then
                            self2.actualW = w
                        end

                        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ) )

                        local roundBottom = h <= headerH
                        draw.RoundedBoxEx( 8, 0, 0, w, headerH, BOTCHED.FUNC.GetTheme( 1 ), true, true, roundBottom, roundBottom )
                        draw.RoundedBoxEx( 8, 0, 0, w, headerH, BOTCHED.FUNC.GetTheme( 2, 100+(self2.button.alpha or 0) ), true, true, roundBottom, roundBottom )

                        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
                        surface.SetMaterial( arrowMat )
                        local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
                        surface.DrawTexturedRectRotated( w-((headerH-iconSize)/2)-(iconSize/2), headerH/2, iconSize, iconSize, math.Clamp( (self2.button.textureRotation or 0), -90, 0 ) )
                    else
                        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
                    end

                    draw.SimpleText( val.Name, "MontserratBold22", margin25, headerH/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
                    draw.SimpleText( val.Description, "MontserratMedium21", margin25, headerH/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
                end

                if( customElement ) then
                    local vguiElement

                    local button = vgui.Create( "DButton", variablePanel )
                    button:Dock( TOP )
                    button:SetTall( headerH )
                    button:SetText( "" )
                    button.Paint = function( self2, w, h ) 
                        self2:CreateFadeAlpha( 0.2, 155 )
                    end
                    button.textureRotation = 0
                    button.DoRotationAnim = function( self2, expanding )
                        local anim = self2:NewAnimation( 0.2, 0, -1 )
                    
                        anim.Think = function( anim, pnl, fraction )
                            if( expanding ) then
                                self2.textureRotation = (1-fraction)*-90
                            else
                                self2.textureRotation = fraction*-90
                            end
                        end
                    end
                    button.SetExpanded = function( self2, expanded, noAnim )
                        if( expanded ) then
                            variablePanel:SizeTo( variablePanel.actualW, variablePanel.fullHeight, 0.2 )
                            self2:DoRotationAnim( true )
                        else
                            variablePanel:SizeTo( variablePanel.actualW, headerH, 0.2 )
                            self2:DoRotationAnim( false )
                        end

                        local newValue = expanded and 1 or 0
                        if( cookie.GetNumber( "botched.configexpanded." .. val.Key, 1 ) != newValue ) then
                            cookie.Set( "botched.configexpanded." .. val.Key, newValue )
                        end

                        if( vguiElement.SetYShadowScissor ) then
                            local startY, endY = vguiElement.GetYShadowScissor()
                            
                            if( expanded ) then
                                timer.Simple( 0.2, function() 
                                    if( not IsValid( vguiElement ) ) then return end
                                    vguiElement:SetYShadowScissor( startY, endY ) 
                                end )
                            else
                                vguiElement:SetYShadowScissor( startY, startY ) 
                            end
                        end
                    end
                    button.DoClick = function( self2 )
                        self2:SetExpanded( variablePanel:GetTall() <= headerH )
                    end

                    variablePanel.button = button

                    vguiElement = vgui.Create( val.VguiElement, variablePanel )
                    vguiElement:Dock( FILL )
                    vguiElement:DockMargin( margin25, margin25, margin25, margin25 )
                    vguiElement:SetWide( self:GetWide()-self.navigation:GetWide()-(4*margin25)-(2*margin10) )
                    vguiElement.GetYShadowScissor = function()
                        if( not self.FullyOpened ) then return 0, 0 end
                        return self.startY+25, self.startY+self.actualH-25
                    end

                    vguiElement.oldRefresh = vguiElement.Refresh
                    vguiElement.Refresh = function()
                        if( vguiElement.oldRefresh ) then vguiElement:oldRefresh() end

                        variablePanel.fullHeight = headerH+50+vguiElement:GetTall()
                        variablePanel:SetTall( cookie.GetNumber( "botched.configexpanded." .. val.Key, 1 ) == 1 and variablePanel.fullHeight or headerH )
                    end

                    vguiElement:Refresh()
                elseif( val.Type == BOTCHED.TYPE.Int ) then
                    local targetH = BOTCHED.FUNC.ScreenScale( 40 )
                    local margin = (variablePanel:GetTall()-targetH)/2

                    local numberWang = vgui.Create( "botched_numberwang", variablePanel )
                    numberWang:Dock( RIGHT )
                    numberWang:DockMargin( 0, margin, margin25, margin )
                    numberWang:SetWide( BOTCHED.FUNC.ScreenScale( 200 ) )
                    numberWang:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
                    numberWang:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 50 ) )
                    numberWang:SetValue( v:GetConfigValue( val.Key ) )
                    numberWang.OnChange = function( self2 )
                        BOTCHED.FUNC.RequestConfigChange( k, val.Key, numberWang:GetValue() )
                    end
                end
            end
        end

        self:AddPage( page, k, v )
    end

    hook.Add( "Botched.Hooks.ConfigUpdated", "Botched.Botched.Hooks.ConfigUpdated.ConfigPage", function() self:Refresh() end )
end

function PANEL:Refresh()
    for k, v in pairs( self.pages ) do
        v:Refresh()
    end
end

function PANEL:AddPage( panel, id, configMeta )
    panel:SetVisible( false )
    panel:SetAlpha( 0 )

    local key = #self.pages+1
    self.pages[key] = panel

    local text = string.upper( configMeta.Title )

    surface.SetFont( "MontserratBold22" )
    local textY = select( 2, surface.GetTextSize( text ) )

    surface.SetFont( "MontserratBold17" )
    local infoTextY = select( 2, surface.GetTextSize( text ) )

    local contentH = textY+infoTextY+infoTextY

    local button = vgui.Create( "DButton", self.navigation )
    button:Dock( TOP )
    button:SetTall( BOTCHED.FUNC.ScreenScale( 80 ) )
    button:SetText( "" )
    local iconMat = Material( configMeta.Icon )
    local modifiedRefresh = 0
    local lastModified = "Never"
    button.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.2, 50, false, false, self.activePage == key, 155, 0.2 )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )
        surface.DrawRect( 0, 0, w, h )

        local textAlpha = 100+self2.alpha

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, textAlpha ) )
        surface.SetMaterial( iconMat )
        local iconSize = BOTCHED.FUNC.ScreenScale( 32 )
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( text, "MontserratBold22", h, (h/2)-(contentH/2), BOTCHED.FUNC.GetTheme( 3, textAlpha ) )

        if( CurTime() >= modifiedRefresh ) then
            lastModified = ((configMeta.LastModified or 0) > 0 and BOTCHED.FUNC.FormatLetterTime( os.time()-configMeta.LastModified ) .. " ago") or "Never"
            modifiedRefresh = CurTime()+5
        end

        draw.SimpleText( "Modified: " .. lastModified, "MontserratBold17", h, (h/2)-(contentH/2)+textY, BOTCHED.FUNC.GetTheme( 4, textAlpha ) )

        draw.SimpleText( "File Size: " .. math.Round( (configMeta.FileSize or 0) / 1000, 2 ) .. "KB", "MontserratBold17", h, (h/2)-(contentH/2)+textY+infoTextY, BOTCHED.FUNC.GetTheme( 4, textAlpha ) )
    end
    button.DoClick = function()
        self:SetActivePage( key )
    end

    if( not self.pages[self.activePage] ) then
        self:SetActivePage( key )
    end
end

function PANEL:SetActivePage( key )
    if( key == self.activePage ) then return end

    if( self.pages[self.activePage] ) then
        self.pages[self.activePage]:SetVisible( false )
        self.pages[self.activePage]:SetAlpha( 0 )
    end

    self.pages[key]:SetVisible( true )
    self.pages[key]:AlphaTo( 255, 0.2 )
    self.activePage = key
end

function PANEL:CreateSavePopout()
    local popout = vgui.Create( "DPanel", self )
    popout:SetZPos( 1000 )
    popout:SetSize( ScrW()*0.22, BOTCHED.FUNC.ScreenScale( 85 ) )
    popout:SetPos( (self:GetWide()/2)-(popout:GetWide()/2), self:GetTall() )
    popout.finalX, popout.finalY = (self:GetWide()/2)-(popout:GetWide()/2), self:GetTall()-25-popout:GetTall()
    popout:MoveTo( popout.finalX, popout.finalY, 0.2 )
    popout.Paint = function( self2, w, h )
        if( self.FullyOpened ) then
            local x, y = self2:LocalToScreen( 0, 0 )

            BOTCHED.FUNC.BeginShadow( "adminmenu_config_savepopout", 0, self.startY, ScrW(), self.startY+self.actualH )
            BOTCHED.FUNC.SetShadowSize( "adminmenu_config_savepopout", w, h )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BOTCHED.FUNC.EndShadow( "adminmenu_config_savepopout", x, y, 1, 1, 1, 255, 0, 0, false )
        end

        local border = 2
        draw.RoundedBox( 8, border, border, w-(2*border), h-(2*border), BOTCHED.FUNC.GetTheme( 1 ) )

        draw.SimpleText( "UNSAVED CHANGES", "MontserratBold25", 25, h/2+2, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "Please save/reset your changes.", "MontserratMedium21", 25, h/2-2, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, 0 )
    end
    popout.Think = function( self2 )
        if( CurTime() >= (self2.shakeEnd or 0) ) then 
            if( self2:GetPos() <= self.savePopout.finalX+5 and self2:GetPos() >= self.savePopout.finalX-5 ) then return end
            self.savePopout:SetPos( self.savePopout.finalX, self.savePopout.finalY  )
            return 
        end

        if( self2.isMoving ) then return end
        self2:MoveNext()
    end
    popout.MoveNext = function( self2 )
        self2.isMoving = true

        local moveDistance = self2:GetPos() <= self.savePopout.finalX and 10 or -10
        self.savePopout:MoveTo( self.savePopout.finalX+moveDistance, self.savePopout.finalY, 0.05, 0, -1, function()
            self2.isMoving = false
        end )
    end

    local marginTop = BOTCHED.FUNC.ScreenScale( 25 )

    local saveButton = vgui.Create( "DButton", popout )
    saveButton:Dock( RIGHT )
    saveButton:DockMargin( 0, marginTop, BOTCHED.FUNC.ScreenScale( 25 ), marginTop )
    saveButton:SetText( "" )
    saveButton:SetWide( BOTCHED.FUNC.ScreenScale( 100 ) )
    saveButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.2, 75 )
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ) )

        draw.SimpleText( "SAVE", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) ), 1, 1 )
    end
    saveButton.DoClick = function()
        if( not BOTCHED.TEMP.ChangedConfig or table.Count( BOTCHED.TEMP.ChangedConfig ) <= 0 ) then return end

        net.Start( "Botched.RequestSaveConfigChanges" )
            net.WriteUInt( table.Count( BOTCHED.TEMP.ChangedConfig ), 5 )
     
            for k, v in pairs( BOTCHED.TEMP.ChangedConfig ) do
                net.WriteString( k )
                net.WriteUInt( table.Count( v ), 5 )
    
                for key, val in pairs( v ) do
                    net.WriteString( key )
                    BOTCHED.FUNC.WriteTypeValue( BOTCHED.FUNC.GetConfigVariableType( k, key ), val )
                end
            end
        net.SendToServer()
    
        BOTCHED.TEMP.ChangedConfig = nil
        self:Refresh()
    end

    local resetButton = vgui.Create( "DButton", popout )
    resetButton:Dock( RIGHT )
    resetButton:DockMargin( 0, marginTop, BOTCHED.FUNC.ScreenScale( 10 ), marginTop )
    resetButton:SetText( "" )
    resetButton:SetWide( BOTCHED.FUNC.ScreenScale( 100 ) )
    resetButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.2, 180 )
        
        draw.SimpleText( "RESET", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+self2.alpha ), 1, 1 )
    end
    resetButton.DoClick = function()
        BOTCHED.TEMP.ChangedConfig = nil
        self:Refresh()
    end

    self.savePopout = popout
end

function PANEL:CloseSavePopout()
    self.savePopout.Closing = true
    self.savePopout:MoveTo( (self:GetWide()/2)-(self.savePopout:GetWide()/2), self:GetTall(), 0.2, 0, -1, function()
        self.savePopout:Remove()
    end )
end

function PANEL:AttemptClose()
    if( not BOTCHED.TEMP.ChangedConfig or table.Count( BOTCHED.TEMP.ChangedConfig ) <= 0 ) then return true end

    self.savePopout.shakeEnd = CurTime()+0.5
    return false
end

function PANEL:Think()
    if( BOTCHED.TEMP.ChangedConfig and table.Count( BOTCHED.TEMP.ChangedConfig ) > 0 ) then
        if( IsValid( self.savePopout ) ) then return end

        self:CreateSavePopout()
    elseif( IsValid( self.savePopout ) and not self.savePopout.Closing ) then
        self:CloseSavePopout()
    end
end

function PANEL:Paint( w, h )
    self.startY = select( 2, self:LocalToScreen( 0, 0 ) )
    self.actualH = h
end

vgui.Register( "botched_adminmenu_config", PANEL, "DPanel" )