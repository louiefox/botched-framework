local PANEL = {}

function PANEL:Init()
    self.borderSize = 3
end

function PANEL:SetItemInfo( itemKey, amount, doClick, uniqueID )
    self:Clear()

    local configItem = istable( itemKey ) and itemKey or BOTCHED.CONFIG.LOCKER.Items[itemKey]
    if( not configItem ) then return end

    local itemTypeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]

    self.uniqueID = uniqueID or configItem.Name

    self.iconMat = nil
    
    local model = configItem.Model
    if( not string.EndsWith( model, ".mdl" ) ) then
        if( string.StartWith( model, "http" ) ) then
            BOTCHED.FUNC.GetImage( model, function( mat )
                if( not IsValid( self ) ) then return end
                self.iconMat = mat
            end )
        else
            self.iconMat = Material( model )
        end
    end

    self.hoverDraw = vgui.Create( "DPanel", self )
    self.hoverDraw:SetSize( self:GetSize() )
    self.hoverDraw.Paint = function( self2, w, h ) 
        draw.RoundedBox( 8, self.borderSize, self.borderSize, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 1 ) )

        if( not doClick or not IsValid( self.info ) ) then return end

        self.info:CreateFadeAlpha( 0.2, 50 )

        draw.RoundedBox( 8, self.borderSize, self.borderSize, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 2, self.info.alpha ) )
        BOTCHED.FUNC.DrawClickCircle( self.info, w-(2*self.borderSize), h-(2*self.borderSize), BOTCHED.FUNC.GetTheme( 2, 150 ), 8, false, self.borderSize+((h-(2*self.borderSize))/2) )
    end

    if( string.EndsWith( model, ".mdl" ) ) then
        self.model = vgui.Create( "DModelPanel", self )
        self.model:Dock( FILL )
        self.model:DockMargin( self.borderSize, self.borderSize, self.borderSize, self.borderSize )
        self.model:SetCursor( "arrow" )
        self.model.Load = function()
            if( not IsValid( self ) ) then return end
            
            self.model:SetModel( model )
            self.model.LayoutEntity = function() end
            self.model.PreDrawModel = function()
                render.ClearDepth()
            end
    
            if( IsValid( self.model.Entity ) ) then
                if( not (itemTypeConfig or {}).ModelDisplay ) then
                    local mn, mx = self.model.Entity:GetModelBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
    
                    self.model:SetFOV( 50 )
                    self.model:SetCamPos( Vector( size, size, size ) )
                    self.model:SetLookAt( (mn + mx) * 0.5 )
                else
                    itemTypeConfig.ModelDisplay( self.model )
                end
            end

            BOTCHED.TEMP.ModelsLoaded[model] = true
        end

        if( not BOTCHED.TEMP.ModelsLoaded[model] ) then
            BOTCHED.FUNC.AddSlotToLoad( self, self.model.Load )
        else
            self.model.Load()
        end
    end

    local stars = configItem.Stars

    self.info = vgui.Create( doClick and "DButton" or "DPanel", self )
    self.info:SetSize( self:GetSize() )
    if( doClick ) then self.info:SetText( "" ) end
    local starMat = Material( "materials/botched/icons/star_16.png" )
    self.info.Paint = function( self2, w, h ) 
        if( self.iconMat ) then
            local iconSize = w*0.5
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( self.iconMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end

        local textY = 30
        if( not self.disableText and configItem.Name ) then
            local text = BOTCHED.FUNC.TextWrap( configItem.Name, self.titleFont or "MontserratBold20", w-30 )
            BOTCHED.FUNC.DrawNonParsedText( text, self.titleFont or "MontserratBold20", w/2, 10, BOTCHED.FUNC.GetTheme( 3 ), 1 )
        end

        if( amount and amount > 1 ) then draw.SimpleText( "x" .. string.Comma( amount ), "MontserratMedium20", w-10, h-10, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM ) end

        if( not stars or self.disableStars or stars < 1 ) then return end

        local iconSize, starSpacing = BOTCHED.FUNC.ScreenScale( 16 ), 2
        surface.SetMaterial( starMat )

        local starTotalW = (stars*(iconSize+starSpacing))-starSpacing

        if( self.shadowStartX ) then
            render.SetScissorRect( self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY, true )
        end

        DisableClipping( true )
        for i = 1, stars do
            local starXPos, starYPos = ((w/2)-(starTotalW/2))+((i-1)*(iconSize+starSpacing)), h-(iconSize*0.65)
            surface.SetDrawColor( 0, 0, 0 )
            surface.DrawTexturedRect( starXPos+1, starYPos+1, iconSize, iconSize )

            surface.SetDrawColor( 255, 255, 255 )
            surface.DrawTexturedRect( starXPos, starYPos, iconSize, iconSize )
        end
        DisableClipping( false )

        if( self.shadowStartX ) then
            render.SetScissorRect( 0, 0, 0, 0, false )
        end
    end
    if( doClick ) then self.info.DoClick = doClick end

    if( configItem.Border ) then self:SetBorder( configItem.Border ) end
    if( configItem.ModelColor ) then self:SetModelColor( configItem.ModelColor ) end
end

function PANEL:SetShadowScissor( x, y, w, h )
    if( isfunction( x ) ) then
        self.shadowScissorFunc = x
        return
    end

    self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY = x, y, w, h
end

function PANEL:DisableText( bool )
    self.disableText = bool
end

function PANEL:DisableShadows( bool )
    self.disableShadows = bool
end

function PANEL:DisableStars( bool )
    self.disableStars = bool
end

function PANEL:SetTitleFont( titleFont )
    self.titleFont = titleFont
end

function PANEL:SetBorderSize( borderSize )
    self.borderSize = borderSize
end

function PANEL:SetModelColor( color )
    self.model:SetColor( color )
end

function PANEL:SetBorder( border )
    border = BOTCHED.CONFIG.GENERAL.Borders[border]
    if( not border ) then return end

    self.border = border

    if( IsValid( self.borderAnim ) ) then self.borderAnim:Remove() end

    if( border.Anim ) then
		self.borderAnim = vgui.Create( "botched_gradientanim", self )
		self.borderAnim:SetSize( self:GetSize() )
		self.borderAnim:SetZPos( -100 )
		self.borderAnim:SetDirection( 1 )
        self.borderAnim:SetAnimTime( 5 )
        self.borderAnim:SetAnimSize( self.borderAnim:GetTall()*6 )
		self.borderAnim:SetColors( unpack( border.Colors ) )
        self.borderAnim:SetCornerRadius( 8 )
		self.borderAnim:StartAnim()
    end
end

function PANEL:SetShadowDisable( func )
    self.shadowDisable = func
end

function PANEL:OnSizeChanged( w, h )
    if( not IsValid( self.hoverDraw ) ) then return end

    self.hoverDraw:SetSize( w, h )
    self.info:SetSize( w, h )
    if( IsValid( self.borderAnim ) ) then 
        self:SetBorder( self.border )
    end
end

function PANEL:Paint( w, h )
    if( not self.uniqueID ) then return end

    if( self.shadowScissorFunc ) then
        self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY = self.shadowScissorFunc()
    end

    if( (not self.disableShadows or (self.shadowDisable and self.shadowDisable() == true)) and (not self.shadowStartX or not self.shadowStartY or (self.shadowEndY > self.shadowStartY and self.shadowEndX > self.shadowStartX)) ) then
        BOTCHED.FUNC.BeginShadow( self.uniqueID, self.shadowStartX, self.shadowStartY, self.shadowEndX, self.shadowEndY )
        BOTCHED.FUNC.SetShadowSize( self.uniqueID, w, h )
        local x, y = self:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )		
        BOTCHED.FUNC.EndShadow( self.uniqueID, x, y, 1, 1, 2, 255, 0, 0, false )
    else
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
    end

    if( self.border ) then
        if( not self.border.Anim ) then
            BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
                BOTCHED.FUNC.DrawGradientBox( 0, 0, w, h, 1, unpack( self.border.Colors ) )
            end )
        end
    end
end

vgui.Register( "botched_item_slot", PANEL, "DPanel" )