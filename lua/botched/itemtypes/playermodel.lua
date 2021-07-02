local ITEM = BOTCHED.FUNC.CreateItemType( "playermodel" )

ITEM:SetTitle( "Player Model" )
ITEM:SetDescription( "Gives the player a permanent player model that they can equip from their locker." )

ITEM:AddReqInfo( "string", "Model Path", "The path for the player model to set the player to." )
ITEM:SetPermanent( true )
ITEM:SetUseFunction( function( ply ) 
    print( "HERE" )
end )

ITEM:SetModelDisplay( function( panel ) 
    local bone = panel.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
    if( bone ) then
        local headpos = panel.Entity:GetBonePosition( bone )
        panel:SetLookAt( headpos )
        panel:SetCamPos( headpos-Vector( -35, 0, 0 ) )
    end
end )

ITEM:Register()