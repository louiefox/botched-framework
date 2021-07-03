local PANEL = {}

function PANEL:Init()
    self:SetText( "" )
end

function PANEL:SetChecked( checked )
    self.checked = checked

    if( self.OnChange ) then
        self:OnChange( checked )
    end
end

function PANEL:GetChecked()
    return self.checked
end

function PANEL:DoClick()
    self:SetChecked( not self.checked )
end

local tickMat = Material( "botched/icons/tick.png" )
function PANEL:Paint( w, h )
    self:CreateFadeAlpha( 0.2, 100, false, false, self.checked, 200 )

    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
    draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self.alpha ) )

    surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, (math.max( self.alpha-100, 0 )/100)*255 ) )
    surface.SetMaterial( tickMat )
    local iconSize = BOTCHED.FUNC.ScreenScale( 16 )
    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
end

vgui.Register( "botched_checkbox", PANEL, "DButton" )