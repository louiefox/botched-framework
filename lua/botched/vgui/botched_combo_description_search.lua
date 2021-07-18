local PANEL = {}

function PANEL:Init()
	self:SetTall( BOTCHED.FUNC.ScreenScale( 50 ) )
	self:SetText( "" )

	self.choices = {}
	self.choiceHeight = BOTCHED.FUNC.ScreenScale( 50 )

	self.textEntry = vgui.Create( "botched_textentry", self )
	self.textEntry:Dock( FILL )
	self.textEntry.Paint = function() end
	self.textEntry:SetBackText( "Search" )
	self.textEntry:SetFont( "MontserratMedium20" )
	self.textEntry.OnChange = function()
        self.menu:Refresh( self.textEntry:GetValue() )
    end
	self.textEntry.OnGetFocus = function()
		self:Open()
	end
	self.textEntry.OnLoseFocus = function( self2 )
		timer.Simple( 0, function() self2:SetValue( "" ) end )
	end
end

function PANEL:Open()
	if( IsValid( self.menu ) ) then return end

    local stoppedEditing
	self.opened = true
	self:DoRotationAnim( true )

	self.menu = vgui.Create( "botched_scrollpanel", self:GetParent() )
	self.menu:SetPos( self:LocalToScreen( self:GetParent():ScreenToLocal( 0, self:GetTall() ) ) )
	self.menu:SetSize( self:GetWide(), 0 )
	self.menu.GetDeleteSelf = function() return true end
	self.menu.OnRemove = function()
		if( not IsValid( self ) ) then return end
		self.lastDeleted = CurTime()
		self.opened = false
        self:DoRotationAnim( false )
	end
	self.menu.Think = function()
        if( not self.textEntry:IsEditing() and not stoppedEditing ) then
            stoppedEditing = CurTime()
        elseif( self.textEntry:IsEditing() ) then
            stoppedEditing = nil
        end

		if( not IsValid( self ) or (not self.textEntry:IsEditing() and CurTime() >= stoppedEditing+0.1) ) then
			self.menu:Remove()
		end
	end
	self.menu:SetBarBackColor( BOTCHED.FUNC.GetTheme( 1, 100 ) )
	self.menu:SetBarColor( BOTCHED.FUNC.GetTheme( 3, 50 ) )
	self.menu:SetBarDownColor( BOTCHED.FUNC.GetTheme( 3, 100 ) )
	self.menu:GetVBar():SetRounded( 0 )
	self.menu.paintInMask = {}
	self.menu.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        BOTCHED.FUNC.BeginShadow( "combo_description_search", 0, y, ScrW(), y+h+10 )
        BOTCHED.FUNC.SetShadowSize( "combo_description_search", w, h )
		draw.RoundedBoxEx( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, false, true, true )
        BOTCHED.FUNC.EndShadow( "combo_description_search", x, y, 1, 2, 2, 255, 0, 0, true )

        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1 ), false, false, true, true )
		draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), false, false, true, true )

		BOTCHED.FUNC.DrawRoundedExMask( 8, 0, 0, w, h, function()
			for k, v in ipairs( self2.paintInMask ) do
                if( not IsValid( v ) ) then
                    table.remove( self2.paintInMask, k )
                    continue
                end

				v:PaintManual()
			end
        end, false, false, true, true )
	end

	self.menu:GetVBar():SetPaintedManually( true )
	table.insert( self.menu.paintInMask, self.menu:GetVBar() )

    self.menu.Refresh = function( self2, searchText )
        self2:Clear()

        searchText = string.lower( searchText )

        local sortedChoices = {}
        for k, v in pairs( self.choices ) do
            local foundInName, foundInDescription = string.find( string.lower( v[1] ), searchText ), string.find( string.lower( v[2] ), searchText )
            if( not foundInName and not foundInDescription ) then continue end

            table.insert( sortedChoices, { k, (foundInName and 100) or 0 } )
        end

        table.SortByMember( sortedChoices, 2 )

        local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
        for k, v in pairs( sortedChoices ) do
            local choiceInfo = self.choices[v[1]]

            local description = BOTCHED.FUNC.NiceTrimText( choiceInfo[2], "MontserratMedium15", self:GetWide()-10-(2*margin10) )

            local button = vgui.Create( "DButton", self2 )
            button:Dock( TOP )
            button:SetTall( self.choiceHeight )
            button:SetText( "" )
            button:SetPaintedManually( true )
            button.Paint = function( self2, w, h )
                self2:CreateFadeAlpha( 0.2, 100 )

                draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, false, false, false )

                draw.SimpleText( choiceInfo[1], "MontserratBold20", margin10, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( description, "MontserratMedium15", margin10, h/2-1, BOTCHED.FUNC.GetTheme( 4, 150 ) )
            end
            button.DoClick = function()
                self:SelectChoice( v[1] )
                self2:Remove()
            end

            table.insert( self2.paintInMask, button )
        end

        self.menu:SizeTo( self:GetWide(), math.min( #sortedChoices, 3 )*self.choiceHeight, 0.2 )
    end

    self.menu:Refresh( self.textEntry:GetValue() )
end

local arrow16Mat = Material( "botched/icons/down_16.png" )
function PANEL:Paint( w, h )
	self:CreateFadeAlpha( 0.2, 155, false, false, self.opened, 155 )

	local roundBottom = not self.opened
	draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100+(self.alpha or 0) ), true, true, roundBottom, roundBottom )

	surface.SetDrawColor( self.textEntry.textEntry.backTextColor )
	surface.SetMaterial( arrow16Mat )
	local iconSize = BOTCHED.FUNC.ScreenScale( 16 )
	surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self.textureRotation or -90), -90, 0 ) )
end

derma.DefineControl( "botched_combo_description_search", "", PANEL, "botched_combo_description" )