-- COLORS --
BOTCHED.DEVCONFIG.Colors = { 
    Bronze = Color( 176, 122, 60 ),
    Silver = Color( 165, 165, 165 ),
    Gold = Color( 222, 175, 7 ),
    Diamond = Color( 0, 255, 233 ),

    Red = Color( 231, 76, 60 ),
    DarkRed = Color( 192, 57, 43 ),

    Green = Color( 46, 204, 113 ),
    DarkGreen = Color( 39, 174, 96 ),

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
BOTCHED.DEVCONFIG.RewardTypes["Items"] = {
    Name = "Locker Item",
    Description = "An item created in the items config."
}
BOTCHED.DEVCONFIG.RewardTypes["Gems"] = {
    Name = "Gems",
    Description = "Gems used for the gacha addon.",
    Material = "materials/botched/icons/gems_128.png",
    Stars = 3,
    Border = 3,
    GetOwned = function( self ) return self:GetGems() end,
    GiveReward = function( self, rewardTable ) self:AddGems( rewardTable.Gems ) end,
    TakeCost = function( self, costTable ) self:TakeGems( costTable.Gems ) end,
    CanAfford = function( self, costTable ) return self:GetGems() >= costTable.Gems end
}
BOTCHED.DEVCONFIG.RewardTypes["ExchangeTokens"] = {
    Name = "Exchange Tokens",
    Description = "Tokens used for the gacha addon.",
    Material = "materials/botched/icons/magic_coin_64.png",
    Stars = 3,
    Border = 3,
    GetOwned = function( self ) return self:GetExchangeTokens() end,
    GiveReward = function( self, rewardTable ) self:AddExchangeTokens( rewardTable.ExchangeTokens ) end,
    TakeCost = function( self, costTable ) self:TakeExchangeTokens( costTable.ExchangeTokens ) end,
    CanAfford = function( self, costTable ) return self:GetExchangeTokens() >= costTable.ExchangeTokens end
}
BOTCHED.DEVCONFIG.RewardTypes["Money"] = {
    Name = "Money",
    Description = "DarkRP Money to be given.",
    Material = "models/props/cs_assault/money.mdl",
    Stars = 3,
    Border = 3,
    GetOwned = function( self ) return self.Player:getDarkRPVar( "money" ) end,
    GiveReward = function( self, rewardTable ) self.Player:addMoney( rewardTable.Money ) end,
    TakeCost = function( self, costTable ) self.Player:takeMoney( costTable.Money ) end,
    CanAfford = function( self, costTable ) return self.Player:getDarkRPVar( "money" ) >= costTable.Money end
}

-- KEY BINDS --
BOTCHED.DEVCONFIG.KeyBinds = {
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z",
    "Numpad 0",
    "Numpad 1",
    "Numpad 2",
    "Numpad 3",
    "Numpad 4",
    "Numpad 5",
    "Numpad 6",
    "Numpad 7",
    "Numpad 8",
    "Numpad 0",
    "Numpad /",
    "Numpad *",
    "Numpad -",
    "Numpad +",
    "Numpad Enter",
    "Numpad .",
    "(",
    ")",
    ";",
    "'",
    "`",
    ",",
    ".",
    "/",
    [[\]],
    "-",
    "=",
    "Enter",
    "Space",
    "Backspace",
    "Tab",
    "Capslock",
    "Numlock",
    "Escape",
    "Scrolllock",
    "Insert",
    "Delete",
    "Home",
    "End",
    "Pageup",
    "Pagedown",
    "Break",
    "Left Shift",
    "Right Shift",
    "Alt",
    "Right Alt",
    "Left Control",
    "Right Control",
    "Left Windows",
    "Right Windows",
    "App",
    "Up",
    "Left",
    "Down",
    "Right",
    "F1",
    "F2",
    "F3",
    "F4",
    "F5",
    "F6",
    "F7",
    "F8",
    "F9",
    "F10",
    "F11",
    "F12",
    "Capslock Toggle",
    "Numlock Toggle",
    "Last",
    "Count"
}