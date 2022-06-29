local ITEM = BOTCHED.FUNC.CreateItemType( "weapon" )

ITEM:SetTitle( "Weapon" )
ITEM:SetDescription( "Gives the player a weapon." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Class", "The weapon class to give." )
ITEM:SetAllowInstantUse( true )
ITEM:SetUseFunction( function( ply, useAmount, weaponClass ) 
    for i = 1, useAmount do
        ply:Give( weaponClass )
    end
end )

ITEM:Register()