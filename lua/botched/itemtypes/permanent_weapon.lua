local ITEM = BOTCHED.FUNC.CreateItemType( "permanent_weapon" )

ITEM:SetTitle( "Permanent Weapon" )
ITEM:SetDescription( "A permanent weapon that the player can equip." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Class", "The weapon class to give." )
ITEM:SetPermanent( true )
ITEM:SetLimitOneType( true )

ITEM:SetEquipFunction( function( ply ) 
    print( "EQUIP" )
end )

ITEM:SetUnEquipFunction( function( ply ) 
    print( "UNEQUIP" )
end )

ITEM:Register()