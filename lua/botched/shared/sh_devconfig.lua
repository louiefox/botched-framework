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

-- MENUES SAVING --
BOTCHED.DEVCONFIG.MenuTypes = BOTCHED.DEVCONFIG.MenuTypes or {}
BOTCHED.DEVCONFIG.MenuTypes["default"] = {
    Title = "Default",
    Element = "DPanel"
}