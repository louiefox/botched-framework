local ITEM = BOTCHED.FUNC.CreateItemType( "darkrp_money" )

ITEM:SetTitle( "DarkRP Money" )
ITEM:SetDescription( "Adds DarkRP money to the players' wallet." )

ITEM:AddReqInfo( BOTCHED.TYPE.Int, "Amount", "The amount of money to give the player." )
ITEM:SetAllowInstantUse( true )
ITEM:SetUseFunction( function( ply, useAmount, amount ) 
    ply:addMoney( useAmount*amount )
end )

ITEM:Register()