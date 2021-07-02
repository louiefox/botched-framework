local PANEL = {}

function PANEL:Init()
    self:SetPopupWide( ScrW()*0.15 )
    self:SetHeader( "" )
end

local optionH, optionSpacing = 45, 10
function PANEL:AddOption( label, onClick )
    self.optionCount = (self.optionCount or 0)+1

	local optionButton = vgui.Create( "DButton", self )
	optionButton:Dock( TOP )
	optionButton:DockMargin( optionSpacing, 0, optionSpacing, optionSpacing )
	optionButton:SetTall( optionH )
	optionButton:SetText( "" )
    local alpha = 0
    optionButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 75 )
        else
            alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

        draw.SimpleText( label, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
    end
    optionButton.DoClick = function()
        onClick()
        self:Close()
    end

    self:SetExtraHeight( (self.optionCount*(optionH+optionSpacing)) )
end

vgui.Register( "botched_popup_choice", PANEL, "botched_popup_base" )