concommand.Add( "botched_save_ents", function( ply, cmd, args )
	if( not BOTCHED.FUNC.HasAdminAccess( ply ) ) then 
		BOTCHED.FUNC.SendNotification( ply, "ACCESS ERROR", "You don't have admin access!", "error" )
		return 
	end

	local entities = {}
	for k, v in pairs( BOTCHED.DEVCONFIG.EntityTypes ) do
		for key, ent in pairs( ents.FindByClass( k ) ) do
			local pos = string.Explode(" ", tostring(ent:GetPos()))
			local angles = string.Explode(" ", tostring(ent:GetAngles()))
			
			local entTable = {
				Class = k,
				TranformData = pos[1] .. ";" .. pos[2] .. ";" .. pos[3] .. ";" .. angles[1] .. ";" .. angles[2] .. ";" .. angles[3]
			}

			if( v.GetDataFunc ) then
				entTable.Data = v.GetDataFunc( ent )
			end
			
			table.insert( entities, entTable )
		end
	end
	
	file.Write( "botched/saved_ents/".. string.lower( game.GetMap() ) ..".txt", util.TableToJSON( entities ), "DATA" )
	BOTCHED.FUNC.SendNotification( ply, "ENTITY SAVING", "Entity postions successfully saved!", "admin" )
end )

concommand.Add( "botched_clear_ents", function( ply, cmd, args )
	if( not BOTCHED.FUNC.HasAdminAccess( ply ) ) then 
		BOTCHED.FUNC.SendNotification( ply, "ACCESS ERROR", "You don't have admin access!", "error" )
		return 
	end

	for k, v in pairs( ents.GetAll() ) do
		if( not BOTCHED.DEVCONFIG.EntityTypes[v:GetClass()] ) then continue end
		v:Remove()
	end

	if( file.Exists( "botched/saved_ents/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) ) then
		file.Delete( "botched/saved_ents/".. string.lower( game.GetMap() ) ..".txt" )
	end
end )

local function SpawnSavedEntities()	
	if( not file.IsDir( "botched/saved_ents", "DATA" ) ) then
		file.CreateDir( "botched/saved_ents", "DATA" )
	end
	
	local entities = {}
	if( file.Exists( "botched/saved_ents/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) ) then
		entities = util.JSONToTable( file.Read( "botched/saved_ents/".. string.lower( game.GetMap() ) ..".txt", "DATA" ) )
	end
	
	if( table.Count( entities ) > 0 ) then
		for k, v in pairs( entities ) do
			local devConfig = BOTCHED.DEVCONFIG.EntityTypes[v.Class]
			if( not devConfig ) then
				entities[k] = nil
				continue
			end

			local transformData = string.Explode( ";", v.TranformData )
			
			local ent = ents.Create( v.Class )
			ent:SetPos( Vector( transformData[1], transformData[2], transformData[3] ) )
			ent:SetAngles( Angle( transformData[4], transformData[5], transformData[6] ) )
			ent:Spawn()

			if( devConfig.SetDataFunc ) then
				devConfig.SetDataFunc( ent, v.Data )
			end
		end
	end

	print( "[BOTCHED FRAMEWORK] " .. table.Count( entities ) .. " Entitie(s) Spawned" )
end

local function InitPostEnt()
	if( BOTCHED.CONFIG_LOADED ) then
		SpawnSavedEntities()
	else
		hook.Add( "Botched.Hooks.ConfigLoaded", "Botched.Hooks.ConfigLoaded.LoadEntities", SpawnSavedEntities )
	end
end

if( BOTCHED.INITPOSTENTITY_LOADED ) then
	InitPostEnt()
else
	hook.Add( "InitPostEntity", "Botched.InitPostEntity.LoadEntities", InitPostEnt )
end

hook.Add( "PostCleanupMap", "Botched.PostCleanupMap.LoadEntities", SpawnSavedEntities )