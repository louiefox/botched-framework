BOTCHED.TEMP.Notifications = BOTCHED.TEMP.Notifications or {}
local function CreateBaseNotification( height, width )
    width = width or ScrW()*0.15

    local yStartPos = ScrH()*0.3
    local spacing = BOTCHED.FUNC.ScreenScale( 10 )

    local panel = vgui.Create( "DPanel" )
    panel:SetSize( height, height )
    panel:SetPos( (ScrW()/2)-(panel:GetWide()/2), yStartPos )
    panel:SetDrawOnTop( true )
    panel:SizeTo( width, height, 0.2, 0.1, -1, function()
        panel:SetX( (ScrW()/2)-(panel:GetWide()/2) )
    end )
    panel.OnSizeChanged = function( self2, w, h )
        self2:SetX( (ScrW()/2)-(w/2) )
    end

    table.insert( BOTCHED.TEMP.Notifications, 1, panel )

    local previousH = 0
    for k, v in ipairs( BOTCHED.TEMP.Notifications ) do
        previousH = previousH+v:GetTall()+spacing

        local startY, endY = v:GetY(), yStartPos-previousH
        local anim = v:NewAnimation( 0.2, 0, -1 )  
        anim.Think = function( anim, pnl, fraction )
            v:SetY( startY+((endY-startY)*fraction) )
        end
    end

    timer.Simple( 3, function()
        if( not IsValid( panel ) ) then return end
        table.RemoveByValue( BOTCHED.TEMP.Notifications, panel )
        panel:SizeTo( height, height, 0.2, 0, -1, function()
            panel:Remove()
        end )
        panel:AlphaTo( 0, 0.2 )
    end )
    
    surface.PlaySound( "UI/buttonclick.wav" ) 

    return panel
end

local materialIcons = {
    ["admin"] = Material( "botched/icons/admin.png" ),
    ["error"] = Material( "botched/icons/error.png" ),
    ["settings"] = Material( "botched/icons/settings.png" ),
    ["reward"] = Material( "botched/icons/reward.png" )
}

function BOTCHED.FUNC.CreateNotification( title, text, icon )
    surface.SetFont( "MontserratBold17" )
    local titleY = select( 2, surface.GetTextSize( title ) )

    surface.SetFont( "MontserratMedium20" )
    local textX, textY = surface.GetTextSize( text )
    
    local contentH = titleY+textY-3
    local iconMat = materialIcons[icon] or Material( "botched/icons/notification.png" )
    local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
    local tall = BOTCHED.FUNC.ScreenScale( 60 )

    local panel = CreateBaseNotification( tall, math.max( ScrW()*0.15, tall+textX+margin10 ) )
    panel.Paint = function( self2, w, h )
        local uniqueID = "notification_" .. (table.KeyFromValue( BOTCHED.TEMP.Notifications, self2 ) or 0)
        local x, y = self2:LocalToScreen( 0, 0 )

        BOTCHED.FUNC.BeginShadow( uniqueID )
        BOTCHED.FUNC.SetShadowSize( uniqueID, w, h )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        BOTCHED.FUNC.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        local iconBackH = h-(2*margin10)
        draw.RoundedBox( 8, margin10, margin10, iconBackH, iconBackH, BOTCHED.FUNC.GetTheme( 2, 150 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
        surface.SetMaterial( iconMat )
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( title, "MontserratBold17", h, (h/2)-(contentH/2), BOTCHED.FUNC.GetTheme( 3 ), 0, 0 )
        draw.SimpleText( text, "MontserratMedium20", h, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_BOTTOM )
    end
end

function BOTCHED.FUNC.CreateItemNotification( title, itemKey, amount )
    local itemConfig = BOTCHED.CONFIG.LOCKER.Items[itemKey]
    if( not itemConfig ) then return end

    local border = BOTCHED.CONFIG.GENERAL.Borders[itemConfig.Border]

    amount = amount or 1

    surface.SetFont( "MontserratBold17" )
    local titleY = select( 2, surface.GetTextSize( title ) )

    local text = string.upper( itemConfig.Name )

    surface.SetFont( "MontserratBold22" )
    local textY = select( 2, surface.GetTextSize( text ) )
    
    local contentH = titleY+textY-3
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
    local margin25 = BOTCHED.FUNC.ScreenScale( 25 )
    local borderW = 2

    local iconMat = nil

    local panel = CreateBaseNotification( BOTCHED.FUNC.ScreenScale( 100 ) )
    panel.Paint = function( self2, w, h )
        local uniqueID = "notification_" .. (table.KeyFromValue( BOTCHED.TEMP.Notifications, self2 ) or 0)
        local x, y = self2:LocalToScreen( 0, 0 )

        BOTCHED.FUNC.BeginShadow( uniqueID )
        BOTCHED.FUNC.SetShadowSize( uniqueID, w, h )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        BOTCHED.FUNC.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        local modelBackH = h-(2*margin10)

        BOTCHED.FUNC.BeginShadow( uniqueID .. "_itemback" )
        local x, y = self2:LocalToScreen( margin10, margin10 )
        draw.RoundedBox( 8, x, y, modelBackH, modelBackH, BOTCHED.FUNC.GetTheme( 1 ) )
        BOTCHED.FUNC.EndShadow( uniqueID .. "_itemback", x, y, 1, 2, 2, 255, 0, 0, true )

        if( IsValid( self2.borderAnim ) ) then
            self2.borderAnim:PaintManual()
        elseif( border and not border.Anim ) then
            BOTCHED.FUNC.DrawRoundedMask( 8, margin10, margin10, modelBackH, modelBackH, function()
                BOTCHED.FUNC.DrawGradientBox( margin10, margin10, modelBackH, modelBackH, 1, unpack( border.Colors ) )
            end )
        end

        local modelX, modelY, modelW, modelH = margin10+borderW, margin10+borderW, modelBackH-(2*borderW), modelBackH-(2*borderW)
        draw.RoundedBox( 8, modelX, modelY, modelW, modelH, BOTCHED.FUNC.GetTheme( 1 ) )
        draw.RoundedBox( 8, modelX, modelY, modelW, modelH, BOTCHED.FUNC.GetTheme( 2, 150 ) )

        if( iconMat ) then
            local iconSize = modelBackH*0.75
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end

        draw.SimpleText( title, "MontserratBold17", h+margin25, (h/2)-(contentH/2), BOTCHED.FUNC.GetTheme( 3 ), 0, 0 )
        draw.SimpleText( text, "MontserratBold22", h+margin25, (h/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_BOTTOM )

        draw.SimpleText( amount .. "X", "MontserratBold30", w-(h/2), (h/2), BOTCHED.FUNC.GetTheme( 4, 50 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    if( border and border.Anim ) then
        panel.borderAnim = vgui.Create( "botched_gradientanim", panel )
        panel.borderAnim:SetPos( margin10, margin10 )
        panel.borderAnim:SetSize( panel:GetTall()-(2*margin10), panel:GetTall()-(2*margin10) )
        panel.borderAnim:SetDirection( 1 )
        panel.borderAnim:SetAnimTime( 5 )
        panel.borderAnim:SetAnimSize( panel.borderAnim:GetTall()*6 )
        panel.borderAnim:SetColors( unpack( border.Colors ) )
        panel.borderAnim:SetCornerRadius( 8 )
        panel.borderAnim:StartAnim()
        panel.borderAnim:SetPaintedManually( true )
    end

    if( string.EndsWith( itemConfig.Model, ".mdl" ) ) then
        local modelPanel = vgui.Create( "DModelPanel", panel )
        modelPanel:Dock( LEFT )
        modelPanel:SetWide( panel:GetTall()-(2*margin10)-(2*borderW) )
        modelPanel:DockMargin( margin10+borderW, margin10+borderW, 0, margin10+borderW )
        modelPanel:SetModel( itemConfig.Model )
        modelPanel.LayoutEntity = function() end
        modelPanel.PreDrawModel = function()
            render.ClearDepth()
        end

        if( IsValid( modelPanel.Entity ) ) then
            local itemTypeConfig = BOTCHED.DEVCONFIG.ItemTypes[itemConfig.Type]
        
            if( not itemTypeConfig or not itemTypeConfig.ModelDisplay ) then
                local mn, mx = modelPanel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                modelPanel:SetFOV( 50 )
                modelPanel:SetCamPos( Vector( size, size, size ) )
                modelPanel:SetLookAt( (mn + mx) * 0.5 )
            else
                itemTypeConfig.ModelDisplay( modelPanel )
            end
        end
    else
        BOTCHED.FUNC.GetImage( itemConfig.Model, function( mat )
            iconMat = mat
        end )
    end
end