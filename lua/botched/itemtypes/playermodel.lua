local ITEM = BOTCHED.FUNC.CreateItemType( "playermodel" )

ITEM:SetTitle( "Player Model" )
ITEM:SetDescription( "A permanent model that the player can equip." )

ITEM:AddReqInfo( BOTCHED.TYPE.String, "Model Path", "The path for the player model to set the player to." )
ITEM:SetPermanent( true )
ITEM:SetLimitOneType( true )

ITEM:SetEquipFunction( function( ply, modelPath ) 
    ply:Botched():GetTempItemData().OldModel = ply:GetModel()
    ply:SetModel( modelPath )
    ply:Botched():GetTempItemData().ActiveModel = modelPath
end )

ITEM:SetUnEquipFunction( function( ply ) 
    local oldModel = ply:Botched():GetTempItemData().OldModel
    if( oldModel ) then
        ply:SetModel( oldModel )
    end

    ply:Botched():GetTempItemData().ActiveModel = nil
end )

ITEM:SetModelDisplay( function( panel ) 
    local bone = panel.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
    if( bone ) then
        local headpos = panel.Entity:GetBonePosition( bone )
        panel:SetLookAt( headpos )
        panel:SetCamPos( headpos-Vector( -35, 0, 0 ) )
    end
end )

ITEM:Register()

if( not SERVER ) then return end

local function CheckPermModel( ply, delay )
    if( not ply:Botched():GetTempItemData().ActiveModel ) then return end
    timer.Simple( 0, function() ply:SetModel( ply:Botched():GetTempItemData().ActiveModel ) end )
end

hook.Add( "PlayerSpawn", "Botched.PlayerSpawn.Playermodel", CheckPermModel )
hook.Add( "PlayerChangedTeam", "Botched.PlayerChangedTeam.Playermodel", CheckPermModel )