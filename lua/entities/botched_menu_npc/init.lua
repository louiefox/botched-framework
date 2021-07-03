AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/breen.mdl" )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )

	self:SetUseType( SIMPLE_USE )
end

function ENT:SetMenuInfo( menuType, npcKey )
	self:SetMenuType( menuType )
	self:SetNPCKey( npcKey )

	if( not BOTCHED.DEVCONFIG.MenuTypes[menuType] ) then return end

	local menuConfig = BOTCHED.CONFIG.GENERAL.Menus[menuType]
	if( not menuConfig ) then return end

	local npcConfig = (menuConfig.NPCs or {})[npcKey]
	if( npcConfig ) then return end

	if( npcConfig.Model ) then
		self:SetModel( "models/breen.mdl" )
	end
end

function ENT:Use( ply )
	if( (ply.BOTCHED_NPC_COOLDOWN or 0) > CurTime() ) then return end
	ply.BOTCHED_NPC_COOLDOWN = CurTime()+1

	if( not BOTCHED.DEVCONFIG.MenuTypes[self:GetMenuType() or ""] ) then return end

	BOTCHED.FUNC.SendOpenMenu( ply, self:GetMenuType() )
end

function ENT:OnTakeDamage( dmgInfo )
	return 0
end