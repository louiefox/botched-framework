local MODULE = BOTCHED.FUNC.CreateConfigModule( "GENERAL" )

MODULE:SetTitle( "Base" )
MODULE:SetIcon( "botched/icons/crafting.png" )
MODULE:SetDescription( "Config for the base framework." )

MODULE:AddVariable( "DisplayDistance3D2D", "3D2D Render Distance", "The distance at which 3D2D panels should render.", BOTCHED.TYPE.Int, 500000 )

MODULE:AddVariable( "Themes", "Colour Themes", "The colours used for various UI elements.", BOTCHED.TYPE.Table, {
    [1] = Color( 34, 40, 49 ),
    [2] = Color( 57, 62, 70 ),
    [3] = Color( 0, 173, 181 ),
    [4] = Color( 238, 238, 238 )
}, "botched_config_themes" )

local rainbowColors, range = {}, 10
for i = 1, range do
    table.insert( rainbowColors, HSVToColor( (i/range)*360, 1, 1 ) )
end

MODULE:AddVariable( "Borders", "Theme Borders", "Themes used for borders on items.", BOTCHED.TYPE.Table, {
    { Name = "Bronze", Colors = { Color( 250, 158, 117 ), Color( 249, 220, 186 ), Color( 220, 126, 74 ), Color( 250, 186, 151 ) } },
    { Name = "Silver", Colors = { Color( 196, 203, 209 ), Color( 255, 254, 255 ), Color( 180, 181, 212 ), Color( 219, 235, 250 ) } },
    { Name = "Gold", Colors = { Color( 252, 205, 117 ), Color( 249, 249, 151 ), Color( 243, 178, 62 ), Color( 255, 223, 122 ) } },
    { Name = "Diamond", Colors = { Color( 134, 240, 240 ), Color( 141, 252, 252 ), Color( 81, 196, 196 ), Color( 135, 245, 245 ) } },
    { Name = "Rainbow", Colors = rainbowColors, Anim = true }
}, "botched_config_borders" )

MODULE:AddVariable( "Menus", "Menu Settings", "Configure the ways to access certain menus.", BOTCHED.TYPE.Table, {
    ["gacha"] = {
        Commands = {
            ["!gacha"] = true,
            ["/gacha"] = true
        },
        NPCs = {
            {
                Name = "Gacha NPC",
                Model = "models/breen.mdl"
            }
        },
        Keys = {
            [KEY_F2] = true
        }
    }
}, "botched_config_menus" )

MODULE:Register()