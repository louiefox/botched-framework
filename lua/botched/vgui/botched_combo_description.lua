
local PANEL = {}

function PANEL:Init()
	self:SetTall( BOTCHED.FUNC.ScreenScale( 50 ) )
	self:SetText( "" )

	self.choices = {}
	self.textureRotation = -90
	self.choiceHeight = BOTCHED.FUNC.ScreenScale( 50 )
end

function PANEL:AddChoice( index, title, description )
	self.choices[index] = { title, description }
end

function PANEL:SelectChoice( index )
	self.selected = index
	if( self.OnSelect ) then self:OnSelect( index ) end
end

function PANEL:DoRotationAnim( expanding )
	local anim = self:NewAnimation( 0.2, 0, -1 )

	anim.Think = function( anim, pnl, fraction )
		if( expanding ) then
			self.textureRotation = (1-fraction)*-90
		else
			self.textureRotation = fraction*-90
		end
	end
end

function PANEL:DoClick()
	if( self.opened or CurTime() < (self.lastDeleted or 0)+0.2 ) then return end
	self:Open()
end

function PANEL:Open()
	if( IsValid( self.menu ) ) then return end

	self.opened = true
	self:DoRotationAnim( true )

	self.menu = vgui.Create( "botched_scrollpanel" )
	self.menu:SetPos( self:LocalToScreen( 0, self:GetTall() ) )
	self.menu:SetSize( self:GetWide(), 0 )
	self.menu:SetDrawOnTop( true )
	self.menu:SetIsMenu( true )
	self.menu.GetDeleteSelf = function() return true end
	self.menu.OnRemove = function()
		self.lastDeleted = CurTime()
		self.opened = false
		self:DoRotationAnim( false )
	end
	self.menu:SetBarBackColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
	self.menu:SetBarColor( BOTCHED.FUNC.GetTheme( 3, 50 ) )
	self.menu:SetBarDownColor( BOTCHED.FUNC.GetTheme( 3, 100 ) )
	self.menu:GetVBar():SetRounded( 0 )
	self.menu.paintInMask = {}
	self.menu.Paint = function( self2, w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, false, true, true )
		draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), false, false, true, true )

		BOTCHED.FUNC.DrawRoundedExMask( 8, 0, 0, w, h, function()
			for k, v in ipairs( self2.paintInMask ) do
				v:PaintManual()
			end
        end, false, false, true, true )
	end

	self.menu:GetVBar():SetPaintedManually( true )
	table.insert( self.menu.paintInMask, self.menu:GetVBar() )

	for k, v in pairs( self.choices ) do
		local button = vgui.Create( "DButton", self.menu )
        button:Dock( TOP )
        button:SetTall( self.choiceHeight )
        button:SetText( "" )
        button:SetPaintedManually( true )
        button.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( 0.2, 100 )

			draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, false, false, false )

			local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
			draw.SimpleText( v[1], "MontserratBold20", margin10, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( v[2], "MontserratMedium15", margin10, h/2-1, BOTCHED.FUNC.GetTheme( 4, 150 ) )
        end
        button.DoClick = function()
            self:SelectChoice( k )
			self.menu:Remove()
        end

		table.insert( self.menu.paintInMask, button )
	end

	self.menu:SizeTo( self:GetWide(), math.min( table.Count( self.choices ), 3 )*self.choiceHeight, 0.2 )
	self.menu:MakePopup()
	RegisterDermaMenuForClose( self.menu )
end

function PANEL:OnRemove()
	if( not IsValid( self.menu ) ) then return end
	self.menu:Remove()
end

function PANEL:SetBackColor( color )
    self.backColor = color
end

function PANEL:SetHighlightColor( color )
    self.highlightColor = color
end

function PANEL:SetRoundedBoxDimensions( roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH )
	self.roundedBoxX, self.roundedBoxY, self.roundedBoxW, self.roundedBoxH = roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH
end

local arrow16Mat = Material( "botched/icons/down_16.png" )
function PANEL:Paint( w, h )
	self:CreateFadeAlpha( 0.2, 155, false, false, self.opened, 155 )

	local roundBottom = not self.opened
	draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+(self.alpha or 0) ), true, true, roundBottom, roundBottom )

	surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
	surface.SetMaterial( arrow16Mat )
	local iconSize = BOTCHED.FUNC.ScreenScale( 16 )
	surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self.textureRotation or -90), -90, 0 ) )

	local currentSelect = self.choices[self.selected or ""]
	if( not currentSelect ) then return end

	local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
	draw.SimpleText( currentSelect[1], "MontserratBold20", margin10, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( currentSelect[2], "MontserratMedium17", margin10, h/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
end

derma.DefineControl( "botched_combo_description", "", PANEL, "DButton" )