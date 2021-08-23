local PANEL = {}

function PANEL:Init()
	self:SetTall( BOTCHED.FUNC.ScreenScale( 50 ) )
	self:SetText( "" )

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
		if( self:GetPlayerCount() <= 0 ) then
			self.textEntry:FocusNext()

			if( CurTime() >= (self.lastNotify or 0)+0.1 ) then
				BOTCHED.FUNC.CreateNotification( "LIST ERROR", "No available players were found!", "error" )
				self.lastNotify = CurTime()
			end

			return
		end

		self:Open()
	end
	self.textEntry.OnLoseFocus = function( self2 )
		timer.Simple( 0, function() self2:SetValue( "" ) end )
	end
end

function PANEL:SelectChoice( steamID64 )
	if( self.OnSelect ) then self:OnSelect( steamID64 ) end
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

function PANEL:IgnorePlayers( ... )
	self.ignoredPlayers = {}
	for k, v in ipairs( { ... } ) do
		self.ignoredPlayers[v] = true
	end
end

function PANEL:GetPlayerCount()
	local count = 0
	for k, v in pairs( player.GetAll() ) do
		if( (self.ignoredPlayers or {})[v] ) then continue end
		count = count+1
	end

	return count
end

function PANEL:Open()
	if( IsValid( self.menu ) ) then return end

    local stoppedEditing
	self.opened = true
	self:DoRotationAnim( true )

	self.choices = {}
	for k, v in pairs( player.GetAll() ) do
		if( (self.ignoredPlayers or {})[v] ) then continue end
		table.insert( self.choices, { v:Nick(), v:SteamID() } )
	end

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

            local button = vgui.Create( "DButton", self2 )
            button:Dock( TOP )
            button:SetTall( self.choiceHeight )
            button:SetText( "" )
            button:SetPaintedManually( true )
            button.Paint = function( self2, w, h )
                self2:CreateFadeAlpha( 0.2, 100 )

                draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ), false, false, false, false )

                draw.SimpleText( choiceInfo[1], "MontserratBold20", h, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( choiceInfo[2], "MontserratMedium15", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 150 ) )
            end
            button.DoClick = function()
                self:SelectChoice( util.SteamIDTo64( choiceInfo[2] ) )
                self2:Remove()
            end

			table.insert( self2.paintInMask, button )

			local spacing = BOTCHED.FUNC.ScreenScale( 10 )

			local avatar = vgui.Create( "botched_avatar", button )
			avatar:SetPos( spacing, spacing )
			avatar:SetSize( button:GetTall()-(2*spacing), button:GetTall()-(2*spacing) )
			avatar:SetSteamID( util.SteamIDTo64( choiceInfo[2] ) )
        end

        self.menu:SizeTo( self:GetWide(), math.min( #sortedChoices, 3 )*self.choiceHeight, 0.2 )
    end

    self.menu:Refresh( self.textEntry:GetValue() )
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
	draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 150+(self.alpha or 0) ), true, true, roundBottom, roundBottom )

	surface.SetDrawColor( self.textEntry.textEntry.backTextColor )
	surface.SetMaterial( arrow16Mat )
	local iconSize = BOTCHED.FUNC.ScreenScale( 16 )
	surface.DrawTexturedRectRotated( w-((h-iconSize)/2)-(iconSize/2), h/2, iconSize, iconSize, math.Clamp( (self.textureRotation or -90), -90, 0 ) )
end

derma.DefineControl( "botched_combo_players", "", PANEL, "DButton" )