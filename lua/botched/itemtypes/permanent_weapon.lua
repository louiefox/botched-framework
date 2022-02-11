local ITEM = BOTCHED.FUNC.CreateItemType( "permanent_weapon" )

ITEM:SetTitle( "Permanent Weapon" )
ITEM:SetDescription( "A permanent weapon that the player can equip." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Class", "The weapon class to give." )
ITEM:SetPermanent( true )
ITEM:SetLimitOneType( true )

ITEM:SetEquipFunction( function( ply, weaponClass )
    ply:Give( weaponClass )

    local activeWeapons = ply:Botched():GetTempItemData().ActiveWeapons or {}
    activeWeapons[weaponClass] = true

    ply:Botched():GetTempItemData().ActiveWeapons = activeWeapons
end )

ITEM:SetUnEquipFunction( function( ply, weaponClass ) 
    ply:StripWeapon( weaponClass )

    if( ply:Botched():GetTempItemData().ActiveWeapons ) then
        ply:Botched():GetTempItemData().ActiveWeapons[weaponClass] = nil
    end
end )

ITEM:Register()

if( not SERVER ) then return end

local function CheckPermWeapon( ply, delay )
    local activeWeapons = ply:Botched():GetTempItemData().ActiveWeapons
    if( not activeWeapons ) then return end

    timer.Simple( 0, function() 
        for k, v in pairs( activeWeapons ) do
            ply:Give( k )
        end
    end )
end

hook.Add( "PlayerSpawn", "Botched.PlayerSpawn.PermWeapon", CheckPermWeapon )
hook.Add( "PlayerChangedTeam", "Botched.PlayerChangedTeam.PermWeapon", CheckPermWeapon )

local function ClearKind( ply, kind )
    if( not kind ) then return end

    for _, wep in ipairs( ply:GetWeapons() ) do
        if( wep.Kind and wep.Kind == kind ) then
            ply:StripWeapon( wep:GetClass() )

            break
        end
    end
end

hook.Add( "TTTBeginRound", "BricksServerHooks_TTTBeginRound_UnboxingPerm", function() 
    for _, ply in ipairs( player.GetAll() ) do
        local activeWeapons = ply:Botched():GetTempItemData().ActiveWeapons
        if( not activeWeapons ) then continue end

        for k, v in pairs( activeWeapons ) do
            ClearKind( ply, (weapons.Get( k ) or {}).Kind )

            ply:Give( k )
        end
    end
end )