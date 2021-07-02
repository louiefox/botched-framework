BOTCHED = {
    FUNC = {},
    CONFIG = {},
	DEVCONFIG = {},
    TEMP = (BOTCHED and BOTCHED.TEMP) or {},
	PLAYERMETA = {}
}

BOTCHED.PLAYERMETA.__index = BOTCHED.PLAYERMETA

hook.Add( "InitPostEntity", "Botched.InitPostEntity.Loaded", function()
	BOTCHED.INITPOSTENTITY_LOADED = true
end )

hook.Add( "Initialize", "Botched.Initialize.Loaded", function()
	BOTCHED.INITIALIZE_LOADED = true
end )

AddCSLuaFile( "botched/sh_config_loader.lua" )
include( "botched/sh_config_loader.lua" )

if( CLIENT ) then
	include( "botched/cl_botched_core.lua" )
else
	AddCSLuaFile( "botched/cl_botched_core.lua" )
	include( "botched/sv_botched_core.lua" )
end

AddCSLuaFile( "botched/sh_botched_core.lua" )
include( "botched/sh_botched_core.lua" )

-- SHARED LOAD --
for k, v in pairs( file.Find( "botched/shared/*.lua", "LUA" ) ) do
	AddCSLuaFile( "botched/shared/" .. v )
	include( "botched/shared/" .. v )
end