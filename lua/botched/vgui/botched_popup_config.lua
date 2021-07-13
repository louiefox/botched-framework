local PANEL = {}

function PANEL:Init()
    self:SetPopupWide( ScrW()*0.4 )
    self:SetExtraHeight( ScrH()*0.4 )
    self:SetHeader( "POPUP CONFIG" )
end

function PANEL:FinishSetup()
    self.sectionMargin = BOTCHED.FUNC.ScreenScale( 25 )
    self.sectionWide = (self:GetPopupWide()-(3*self.sectionMargin))/2

    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )
    local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
    self.fieldHeaderH = BOTCHED.FUNC.ScreenScale( 50 )
    local arrowMat = Material( "botched/icons/down.png" )

    self.fieldsBack = vgui.Create( "botched_scrollpanel", self )
    self.fieldsBack:Dock( RIGHT )
    self.fieldsBack:DockMargin( 0, self.sectionMargin, self.sectionMargin, self.sectionMargin )
    self.fieldsBack:SetWide( self.sectionWide )
    self.fieldsBack.Paint = function() end
    self.fieldsBack.AddField = function( self2, name, description, iconMat ) 
        local fieldPanel = vgui.Create( "DPanel", self2 )
        fieldPanel:Dock( TOP )
        fieldPanel:SetSize( self.sectionWide-margin10-10, self.fieldHeaderH )
        fieldPanel:DockMargin( 0, 0, margin10, margin10 )
        fieldPanel.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ) )
        end
        fieldPanel.SetExpanded = function( self2, expanded )
            self2.expanded = expanded

            if( expanded ) then
                self2:SizeTo( self2:GetWide(), self2.fullHeight, 0.2 )
                self2.header:DoRotationAnim( true )
            else
                self2:SizeTo( self2:GetWide(), self.fieldHeaderH, 0.2 )
                self2.header:DoRotationAnim( false )
            end
        end
        fieldPanel.SetExtraHeight = function( self2, extraHeight )
            self2.fullHeight = self.fieldHeaderH+extraHeight

            if( self2.expanded ) then 
                self2:SetTall( self2.fullHeight )
                return 
            end

            self2:SetExpanded( true )
        end
        
        fieldPanel.header = vgui.Create( "DButton", fieldPanel )
        fieldPanel.header:Dock( TOP )
        fieldPanel.header:SetTall( self.fieldHeaderH )
        fieldPanel.header:SetText( "" )
        fieldPanel.header.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( 0.2, 155 )

            local roundBottom = fieldPanel:GetTall() <= self.fieldHeaderH
            draw.RoundedBoxEx( 8, 0, 0, w, self.fieldHeaderH, BOTCHED.FUNC.GetTheme( 2, 100+(self2.alpha or 0) ), true, true, roundBottom, roundBottom )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            surface.SetMaterial( arrowMat )
            surface.DrawTexturedRectRotated( w-((self.fieldHeaderH-iconSize)/2)-(iconSize/2), self.fieldHeaderH/2, iconSize, iconSize, math.Clamp( (self2.textureRotation or 0), -90, 0 ) )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( name, "MontserratBold22", h, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
            draw.SimpleText( description, "MontserratMedium20", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
        end
        fieldPanel.header.textureRotation = 0
        fieldPanel.header.DoRotationAnim = function( self2, expanding )
            local anim = self2:NewAnimation( 0.2, 0, -1 )
        
            anim.Think = function( anim, pnl, fraction )
                if( expanding ) then
                    self2.textureRotation = (1-fraction)*-90
                else
                    self2.textureRotation = fraction*-90
                end
            end
        end
        fieldPanel.header.DoClick = function( self2 )
            fieldPanel:SetExpanded( not fieldPanel.expanded )
        end

        return fieldPanel
    end
end

function PANEL:AddField( name, description, iconMat ) 
    return self.fieldsBack:AddField( name, description, iconMat ) 
end

function PANEL:SetInfo( title, description, iconMat )
    local margin10 = BOTCHED.FUNC.ScreenScale( 10 )

    self.infoBack = vgui.Create( "DPanel", self )
    self.infoBack:SetSize( self.sectionWide, BOTCHED.FUNC.ScreenScale( 110 ) )
    self.infoBack:SetPos( self.sectionMargin, self.mainPanel.targetH-self.sectionMargin-self.infoBack:GetTall() )
    self.infoBack.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 50 ) )
    end

    local itemInfo = vgui.Create( "DPanel", self.infoBack )
    itemInfo:Dock( TOP )
    itemInfo:SetTall( BOTCHED.FUNC.ScreenScale( 50 ) )
    itemInfo.Paint = function( self2, w, h )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), true, true, false, false )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 100 ) )
        surface.SetMaterial( iconMat )
        local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( title, "MontserratBold22", h, h/2+1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( description, "MontserratMedium20", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 100 ) )
    end

    self.infoBottom = vgui.Create( "DPanel", self.infoBack )
    self.infoBottom:Dock( FILL )
    self.infoBottom:SetTall( self.infoBack:GetTall()-itemInfo:GetTall() )
    self.infoBottom.Paint = function( self2, w, h ) end
    self.infoBottom.AddButton = function( self2, text, iconMat, doClick )
        local iconSize = BOTCHED.FUNC.ScreenScale( 24 )
        surface.SetFont( "MontserratBold20" )

        local button = vgui.Create( "DButton", self2 )
        button:Dock( RIGHT )
        button:DockMargin( 0, margin10, margin10, margin10 )
        button:SetWide( self2:GetTall()-(2*margin10)+surface.GetTextSize( text )+20 )
        button:SetText( "" )
        button.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( 0.2, 50 )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBoxEx( 8, 0, 0, h, h, BOTCHED.FUNC.GetTheme( 1 ), true, false, true, false )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, self2.alpha ) )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )

            local textColor = BOTCHED.FUNC.GetTheme( 4, 100+(self2.alpha/50)*155 )

            surface.SetDrawColor( textColor )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( text, "MontserratBold20", h+((w-h)/2), h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        button.DoClick = doClick
    end
end

function PANEL:AddActionButton( text, iconMat, doClick )
    self.infoBottom:AddButton( text, iconMat, doClick )
end

vgui.Register( "botched_popup_config", PANEL, "botched_popup_base" )