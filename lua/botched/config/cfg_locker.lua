local MODULE = BOTCHED.FUNC.CreateConfigModule( "LOCKER" )

MODULE:SetTitle( "Items" )
MODULE:SetIcon( "botched/icons/inventory_32.png" )
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
    },

    ["daedric"] = {
        Name = "Daedric",
        Model = "models/player/daedric.mdl",
        Stars = 3,
        Border = 3,
        Type = "playermodel",
        TypeInfo = { "models/player/daedric.mdl" }
    },
    ["thresh"] = {
        Name = "Thresh",
        Model = "models/thresh/thresh.mdl",
        Stars = 3,
        Border = 3,
        Type = "playermodel",
        TypeInfo = { "models/thresh/thresh.mdl" }
    },
    ["doctor_who"] = {
        Name = "Doctor Who",
        Model = "models/11thdoctor/thedoctor.mdl",
        Stars = 2,
        Border = 2,
        Type = "playermodel",
        TypeInfo = { "models/11thdoctor/thedoctor.mdl" }
    },
    ["link"] = {
        Name = "Link",
        Model = "models/npc_link.mdl",
        Stars = 2,
        Border = 2,
        Type = "playermodel",
        TypeInfo = { "models/npc_link.mdl" }
    },
    ["skeleton"] = {
        Name = "Skeleton",
        Model = "models/player/skeleton.mdl",
        Stars = 1,
        Border = 1,
        Type = "playermodel",
        TypeInfo = { "models/player/skeleton.mdl" }
    },

    ["10000_money"] = {
        Name = "$10,000",
        Model = "models/props/cs_assault/money.mdl",
        Stars = 1,
        Border = 1,
        Type = "darkrp_money",
        TypeInfo = { 10000 }
    },
    ["25000_money"] = {
        Name = "$25,000",
        Model = "models/props/cs_assault/money.mdl",
        Stars = 2,
        Border = 2,
        Type = "darkrp_money",
        TypeInfo = { 25000 }
    },
    ["50000_money"] = {
        Name = "$50,000",
        Model = "models/props/cs_assault/money.mdl",
        Stars = 3,
        Border = 3,
        Type = "darkrp_money",
        TypeInfo = { 50000 }
    },
    ["1000000_money"] = {
        Name = "$1,000,000",
        Model = "models/props/cs_assault/money.mdl",
        Stars = 4,
        Border = 4,
        Type = "darkrp_money",
        TypeInfo = { 1000000 }
    },

    ["weapon_fiveseven2"] = {
        Name = "Five Seven",
        Model = "models/weapons/w_pist_fiveseven.mdl",
        Stars = 1,
        Border = 1,
        Type = "weapon",
        TypeInfo = { "weapon_fiveseven2" }
    },
    ["weapon_glock2"] = {
        Name = "Glock",
        Model = "models/weapons/w_pist_glock18.mdl",
        Stars = 1,
        Border = 1,
        Type = "weapon",
        TypeInfo = { "weapon_glock2" }
    },
    ["weapon_p2282"] = {
        Name = "P288",
        Model = "models/weapons/w_pist_p228.mdl",
        Stars = 1,
        Border = 1,
        Type = "weapon",
        TypeInfo = { "weapon_p2282" }
    },
    ["weapon_deagle2"] = {
        Name = "Deagle",
        Model = "models/weapons/w_pist_deagle.mdl",
        Stars = 2,
        Border = 2,
        Type = "weapon",
        TypeInfo = { "weapon_deagle2" }
    },
    ["weapon_mac102"] = {
        Name = "Mac 10",
        Model = "models/weapons/w_smg_mac10.mdl",
        Stars = 2,
        Border = 2,
        Type = "weapon",
        TypeInfo = { "weapon_mac102" }
    },
    ["weapon_mp52"] = {
        Name = "MP5",
        Model = "models/weapons/w_smg_mp5.mdl",
        Stars = 2,
        Border = 2,
        Type = "weapon",
        TypeInfo = { "weapon_mp52" }
    },
    ["weapon_pumpshotgun2"] = {
        Name = "Pump Shotgun",
        Model = "models/weapons/w_shot_m3super90.mdl",
        Stars = 3,
        Border = 3,
        Type = "weapon",
        TypeInfo = { "weapon_pumpshotgun2" }
    },
    ["weapon_m42"] = {
        Name = "M4",
        Model = "models/weapons/w_rif_m4a1.mdl",
        Stars = 3,
        Border = 3,
        Type = "weapon",
        TypeInfo = { "weapon_m42" }
    },
    ["weapon_ak472"] = {
        Name = "AK47",
        Model = "models/weapons/w_rif_ak47.mdl",
        Stars = 4,
        Border = 4,
        Type = "weapon",
        TypeInfo = { "weapon_ak472" }
    },
    ["ls_sniper"] = {
        Name = "Sniper",
        Model = "models/weapons/w_snip_g3sg1.mdl",
        Stars = 5,
        Border = 4,
        Type = "weapon",
        TypeInfo = { "ls_sniper" }
    },
}, "botched_config_lockeritems" )

MODULE:Register()