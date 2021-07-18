local ITEM = BOTCHED.FUNC.CreateItemType( "weapon" )

ITEM:SetTitle( "Weapon" )
ITEM:SetDescription( "Gives the player a weapon." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Class", "The weapon class to give." )
ITEM:SetAllowInstantUse( true )
ITEM:SetUseFunction( function( ply, useAmount, weaponClass ) 
    ply:Give( weaponClass )
end )

ITEM:Register()