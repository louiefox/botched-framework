local PANEL = {}

function PANEL:Init()
    self.header = ""
    self.IsDragging = false
    self.CenterX, self.CenterY = 0, 0

    local CenterStartX, CenterStartY, CursorStartX, CursorStartY

    self.headerSize = BOTCHED.FUNC.ScreenScale( 30 )

    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )

    self.headerPanel = vgui.Create( "DButton", self )
	self.headerPanel:Dock( TOP )
	self.headerPanel:SetTall( self.headerSize )
	self.headerPanel:SetText( "" )
	self.headerPanel:SetCursor( "arrow" )
	self.headerPanel.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), true, true, false, false )

        draw.SimpleText( self.header, "MontserratMedium21", margin10, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )
	end
    self.headerPanel.OnMousePressed = function( self2 )
        CenterStartX, CenterStartY = self.CenterX, self.CenterY
        CursorStartX, CursorStartY = input.GetCursorPos()
        self2:SetCursor( "sizeall" )

        self.IsDragging = true
    end
    self.headerPanel.OnMouseReleased = function( self2 )
        self2:SetCursor( "arrow" )
        self.IsDragging = false
    end
    self.headerPanel.Think = function( self2 )
        if( not self.IsDragging ) then return end

        local mouseX, mouseY = input.GetCursorPos()
        self.CenterX, self.CenterY = math.Clamp( CenterStartX+(mouseX-CursorStartX), self:GetWide()/2, ScrW()-(self:GetWide()/2) ), math.Clamp( CenterStartY+(mouseY-CursorStartY), self.targetH/2, ScrH()-(self.targetH/2) )
        self:UpdatePos()
    end

    self:SetSize( 0, 0 )
    self:SetStartCenter( ScrW()/2, ScrH()/2 )
    self:SetTargetSize( ScrW()*0.6, ScrH()*0.5 )
end

function PANEL:CreateCloseButton()
    if( IsValid( self.closeButton ) ) then
        self.closeButton:SetPos( self:GetWide()-self.closeButton:GetWide(), 0 )
        return
    end

    local iconSize = BOTCHED.FUNC.ScreenScale( 16 )

    self.closeButton = vgui.Create( "DButton", self )
	self.closeButton:SetSize( BOTCHED.FUNC.ScreenScale( 50 ), self.headerSize )
	self.closeButton:SetPos( self:GetWide()-self.closeButton:GetWide(), 0 )
	self.closeButton:SetText( "" )
    local closeMat = Material( "botched/icons/close_16.png" )
    local textColor = BOTCHED.FUNC.GetTheme( 4 )
	self.closeButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 100 )

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), false, true )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, true )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 155+self2.alpha ) )
		surface.SetMaterial( closeMat )
		surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
	end
    self.closeButton.DoClick = function()
        if( self.closeFunc ) then
            self.closeFunc()
            return
        end

        self:Close()
    end
end

function PANEL:Open( disablePopup, enableKeyboard )
    self.open = true
    if( not disablePopup ) then
        self:MakePopup()
    end

    self:SetVisible( true )
    self:SetMouseInputEnabled( true )
    self:SetKeyboardInputEnabled( enableKeyboard )

    self:SetAlpha( 0 )
    self:AlphaTo( 255, 0.2 )
    self:SizeTo( self:GetWide(), self.targetH, 0.2, 0, -1, function()
        self:UpdatePos()

        if( not self.OnOpenFinish ) then return end
        self:OnOpenFinish()
    end )

    if( self.OnOpenStart ) then 
        self:OnOpenStart()
    end
end

function PANEL:Close()
    if( self.CanClose and not self:CanClose() ) then return end

    self.open = false
    self:SetMouseInputEnabled( false )
    self:SetKeyboardInputEnabled( false )

    if( self.OnCloseStart ) then 
        self:OnCloseStart()
    end
    
    self:AlphaTo( 0, 0.2 )
    self:SizeTo( self:GetWide(), 0, 0.2, 0, -1, function()
        if( not BOTCHED.TEMP.RemoveOnClose ) then
            self:SetVisible( false )
        else
            self:Remove()
        end
    end )
end

function PANEL:UpdatePos()
    self:SetPos( self.CenterX-(self:GetWide()/2), self.CenterY-(self:GetTall()/2) )
end

function PANEL:OnSizeChanged( newW, newH )
    self:CreateCloseButton()
    self:UpdatePos()
end

function PANEL:SetHeader( header )
    self.header = header
end

function PANEL:SetStartCenter( x, y )
    self.CenterX, self.CenterY = x, y
end

function PANEL:SetTargetSize( w, h )
    self:SetWide( w )
    self.targetH = self.headerSize+h
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.BeginShadow( "menu_" .. self.header )
    BOTCHED.FUNC.SetShadowSize( "menu_" .. self.header, w, h )
    local x, y = self:LocalToScreen( 0, 0 )
    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
    BOTCHED.FUNC.EndShadow( "menu_" .. self.header, x, y, 1, 2, 2, 255, 0, 0, false )
end

vgui.Register( "botched_frame", PANEL, "EditablePanel" )