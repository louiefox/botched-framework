local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
    local margin25 = BOTCHED.FUNC.ScreenScale( 25 )

    local navigation = vgui.Create( "DPanel", self )
    navigation:Dock( LEFT )
    navigation:DockMargin( margin25, margin25, margin25, margin25 )
    navigation:SetWide( ScrW()*0.1 )
    navigation.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
    end

    self.navigation = navigation

    self.searchBar = vgui.Create( "botched_textentry", navigation )
    self.searchBar:Dock( TOP )
    self.searchBar:SetTall( BOTCHED.FUNC.ScreenScale( 30 ) )
    self.searchBar:DockMargin( margin10, margin10, margin10, margin25 )
    self.searchBar:SetBackText( "Search" )
    self.searchBar:SetBackColor( BOTCHED.FUNC.GetTheme( 1 ) )
    self.searchBar:SetHighlightColor( BOTCHED.FUNC.GetTheme( 2, 50 ) )
    self.searchBar:SetFont( "MontserratMedium20" )
    self.searchBar.OnChange = function()
        self:Refresh()
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
                        local iconSize = 24
                        surface.DrawTexturedRectRotated( w-((headerH-iconSize)/2)-(iconSize/2), headerH/2, iconSize, iconSize, math.Clamp( (self2.button.textureRotation or 0), -90, 0 ) )
                    else
                        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
                    end

                    draw.SimpleText( val.Name, "MontserratBold22", 25, headerH/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
                    draw.SimpleText( val.Description, "MontserratMedium21", 25, headerH/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
                end

                if( customElement ) then
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
                    button.DoClick = function( self2 )
                        if( variablePanel:GetTall() > headerH ) then
                            variablePanel:SizeTo( variablePanel.actualW, headerH, 0.2 )
                            self2:DoRotationAnim( false )
                        else
                            variablePanel:SizeTo( variablePanel.actualW, variablePanel.fullHeight, 0.2 )
                            self2:DoRotationAnim( true )
                        end
                    end

                    variablePanel.button = button

                    local vguiElement = vgui.Create( val.VguiElement, variablePanel )
                    vguiElement:Dock( FILL )
                    vguiElement:DockMargin( margin25, margin25, margin25, margin25 )
                    vguiElement:SetWide( self:GetWide()-self.navigation:GetWide()-(5*margin25)-(2*margin10) )
                    if( vguiElement.Refresh ) then vguiElement:Refresh() end

                    variablePanel.fullHeight = headerH+50+vguiElement:GetTall()
                    variablePanel:SetTall( variablePanel.fullHeight )
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

        self:AddPage( page, v.Icon, v.Title )
    end

    hook.Add( "Botched.Hooks.ConfigUpdated", "Botched.Botched.Hooks.ConfigUpdated.ConfigPage", function() self:Refresh() end )
end

function PANEL:Refresh()
    for k, v in pairs( self.pages ) do
        v:Refresh()
    end
end

function PANEL:AddPage( panel, icon, text )
    panel:SetVisible( false )
    panel:SetAlpha( 0 )

    local key = #self.pages+1
    self.pages[key] = panel

    text = string.upper( text )

    surface.SetFont( "MontserratBold22" )
    local textX, textY = surface.GetTextSize( text )

    local iconMat = Material( icon )

    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )

    local button = vgui.Create( "DButton", self.navigation )
    button:Dock( TOP )
    button:SetTall( BOTCHED.FUNC.ScreenScale( 40 ) )
    button:DockMargin( margin10, 0, margin10, margin10 )
    button:SetText( "" )
    button.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( 0.2, 50, false, false, self.activePage == key, 155, 0.2 )

        if( self.FullyOpened ) then
            local x, y = self2:LocalToScreen( 0, 0 )

            BSHADOWS.BeginShadow( "adminmenu_config_" .. text )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BSHADOWS.EndShadow( "adminmenu_config_" .. text, x, y, 1, 1, 1, 255, 0, 0, false )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self2.alpha/2 ) )

        local textAlpha = 100+self2.alpha

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, textAlpha ) )
        surface.SetMaterial( iconMat )
        local iconSize = 16
        surface.DrawTexturedRect( (w/2)-(textX/2)-iconSize-5, (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( text, "MontserratBold22", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, textAlpha ), 1, 1 )
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

            BSHADOWS.BeginShadow( "adminmenu_config_savepopout", 0, self.startY, ScrW(), self.startY+self.actualH )
            BSHADOWS.SetShadowSize( "adminmenu_config_savepopout", w, h )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BSHADOWS.EndShadow( "adminmenu_config_savepopout", x, y, 1, 1, 1, 255, 0, 0, false )
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