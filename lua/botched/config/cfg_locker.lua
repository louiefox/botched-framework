local MODULE = BOTCHED.FUNC.CreateConfigModule( "LOCKER" )

MODULE:SetTitle( "Items" )
MODULE:SetIcon( "botched/icons/inventory.png" )
MODULE:SetDescription( "Config for the locker system and items." )

MODULE:AddVariable( "Items", "Locker Items", "Add/edit items for the locker system and other modules.", BOTCHED.TYPE.Table, {
    ["god_eater"] = {
        Name = "God Eater",
        Model = "models/player/shi/God_Eater.mdl",
        Stars = 3,
        Border = 3,
        Type = "playermodel",
        TypeInfo = { "models/player/shi/God_Eater.mdl" }
    },
    ["zero_two"] = {
        Name = "Zero Two",
        Model = "models/CyanBlue/DarlingFranxx/ZeroTwo/ZeroTwo.mdl",
        Stars = 3,
        Border = 3,
        Type = "playermodel",
        TypeInfo = { "models/CyanBlue/DarlingFranxx/ZeroTwo/ZeroTwo.mdl" }
    },
    ["bunny_mei"] = {
        Name = "Bunny Mei",
        Model = "models/pacagma/seishun_buta_yarou_wa_bunny_girl_senpai_no_yume_wo_minai/mai_sakurajima_bunny/mai_sakurajima_bunny_player.mdl",
        Stars = 2,
        Border = 2,
        Type = "playermodel",
        TypeInfo = { "models/pacagma/seishun_buta_yarou_wa_bunny_girl_senpai_no_yume_wo_minai/mai_sakurajima_bunny/mai_sakurajima_bunny_player.mdl" }
    },
    ["astolfo"] = {
        Name = "Astolfo",
        Model = "models/CyanBlue/Fate/Astolfo/Astolfo.mdl",
        Stars = 2,
        Border = 2,
        Type = "playermodel",
        TypeInfo = { "models/CyanBlue/Fate/Astolfo/Astolfo.mdl" }
    },
    ["astolfo_sch"] = {
        Name = "School Astolfo",
        Model = "models/player/Astolfo.mdl",
        Stars = 1,
        Border = 1,
        Type = "playermodel",
        TypeInfo = { "models/player/Astolfo.mdl" }
    }
}, "botched_config_lockeritems" )

MODULE:Register()