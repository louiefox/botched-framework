-- COLORS --
BOTCHED.DEVCONFIG.Colors = { 
    Bronze = Color( 176, 122, 60 ),
    Silver = Color( 165, 165, 165 ),
    Gold = Color( 222, 175, 7 ),
    Diamond = Color( 0, 255, 233 ),

    Red = Color( 231, 76, 60 ),
    DarkRed = Color( 192, 57, 43 ),

    Blue = Color( 52, 152, 219 ),
    DarkBlue = Color( 41, 128, 185 ),

    Orange = Color( 243, 156, 18 ),
    DarkOrange = Color( 230, 126, 34 )
}

-- ENTITY SAVING --
BOTCHED.DEVCONFIG.EntityTypes = BOTCHED.DEVCONFIG.EntityTypes or {}
BOTCHED.DEVCONFIG.EntityTypes["botched_menu_npc"] = { 
    GetDataFunc = function( ent ) 
        return ent:GetMenuType() .. ";" .. ent:GetNPCKey()
    end,
    SetDataFunc = function( ent, data ) 
        local data = string.Explode( ";", data )
        ent:SetMenuType( data[1] )
        ent:SetNPCKey( tonumber( data[2] ) )
    end
}

-- REWARD TYPES --
BOTCHED.DEVCONFIG.RewardTypes = {}
BOTCHED.DEVCONFIG.RewardTypes["Gems"] = {
    Name = "Gems",
    Material = "materials/botched/icons/gems_128.png",
    Stars = 3,
    Border = 3,
    GetAmount = function( rewardTable ) return rewardTable.Gems end,
    GetOwned = function( self ) return self:GetGems() end,
    GiveReward = function( self, rewardTable ) self:AddGems( rewardTable.Gems ) end,
    TakeCost = function( self, costTable ) self:TakeGems( costTable.Gems ) end,
    CanAfford = function( self, costTable ) return self:GetGems() >= costTable.Gems end
}
BOTCHED.DEVCONFIG.RewardTypes["ExchangeTokens"] = {
    Name = "Exchange Tokens",
    Material = "materials/botched/icons/magic_coin_64.png",
    Stars = 3,
    Border = 3,
    GetAmount = function( rewardTable ) return rewardTable.ExchangeTokens end,
    GetOwned = function( self ) return self:GetExchangeTokens() end,
    GiveReward = function( self, rewardTable ) self:AddExchangeTokens( rewardTable.ExchangeTokens ) end,
    TakeCost = function( self, costTable ) self:TakeExchangeTokens( costTable.ExchangeTokens ) end,
    CanAfford = function( self, costTable ) return self:GetExchangeTokens() >= costTable.ExchangeTokens end
}
BOTCHED.DEVCONFIG.RewardTypes["Money"] = {
    Name = "Money",
    Material = "models/props/cs_assault/money.mdl",
    Stars = 3,
    Border = 3,
    GetAmount = function( rewardTable ) return rewardTable.Money end,
    GetOwned = function( self ) return self.Player:getDarkRPVar( "money" ) end,
    GiveReward = function( self, rewardTable ) self:addMoney( rewardTable.Money ) end,
    TakeCost = function( self, costTable ) self:takeMoney( costTable.Money ) end,
    CanAfford = function( self, costTable ) return self.Player:getDarkRPVar( "money" ) >= costTable.Money end
}