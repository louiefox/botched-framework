local ITEM = BOTCHED.FUNC.CreateItemType( "playermodel" )

ITEM:SetTitle( "Player Model" )
ITEM:SetDescription( "A permanent model that the player can equip." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Model Path", "The path for the player model to set the player to." )
ITEM:SetPermanent( true )
ITEM:SetLimitOneType( true )

ITEM:SetEquipFunction( function( ply ) 
    print( "EQUIP" )
end )

ITEM:SetUnEquipFunction( function( ply ) 
    print( "UNEQUIP" )
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