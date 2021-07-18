-- VARIABLE TYPES --
BOTCHED.TYPE = {
	Int = "Int",
	String = "String",
	Bool = "Bool",
	Table = "Table"
}

BOTCHED.TYPEFUNCS = {
	Int = {
		NetWrite = function( value )
			net.WriteInt( value, 32 )
		end,
		NetRead = function()
			return net.ReadInt( 32 )
		end
	},
	String = {
		NetWrite = function( value )
			net.WriteString( value )
		end,
		NetRead = function()
			return net.ReadString()
		end
	},
	Bool = {
		NetWrite = function( value )
			net.WriteBool( value )
		end,
		NetRead = function()
			return net.ReadBool()
		end
	},
	Table = {
		NetWrite = function( value )
			net.WriteString( util.TableToJSON( value ) )
		end,
		NetRead = function()
			return util.JSONToTable( net.ReadString() )
		end,
		CopyFunc = function( value )
			return table.Copy( value )
		end
	}
}

function BOTCHED.FUNC.GetConfigVariableType( module, variable )
	if( not BOTCHED.CONFIGMETA[module] or not BOTCHED.CONFIGMETA[module].Variables ) then return end
	return BOTCHED.CONFIGMETA[module].Variables[variable].Type
end

function BOTCHED.FUNC.CopyTypeValue( type, value )
	if( not type or not BOTCHED.TYPEFUNCS[type] or not BOTCHED.TYPEFUNCS[type].CopyFunc ) then return value end
	return BOTCHED.TYPEFUNCS[type].CopyFunc( value )
end

function BOTCHED.FUNC.WriteTypeValue( type, value )
	if( not type or not BOTCHED.TYPEFUNCS[type] ) then return end
	BOTCHED.TYPEFUNCS[type].NetWrite( value )
end

function BOTCHED.FUNC.ReadTypeValue( type )
	if( not type or not BOTCHED.TYPEFUNCS[type] ) then return end
	return BOTCHED.TYPEFUNCS[type].NetRead()
end

-- MODULE META --
BOTCHED.CONFIGMETA = {}

local cfgModuleMeta = {
	Register = function( self )
        BOTCHED.CONFIGMETA[self.ID] = self
	end,
	SetTitle = function( self, title )
        self.Title = title
	end,
	SetIcon = function( self, icon )
        self.Icon = icon
	end,
	SetDescription = function( self, description )
        self.Description = description
	end,
	AddVariable = function( self, variable, name, description, type, default, vguiElement )
        self.Variables[variable] = {
			Name = name,
			Description = description,
			Type = type,
			VguiElement = vguiElement or (type == BOTCHED.TYPE.Table && "DPanel"),
			Default = default,
			Order = table.Count( self.Variables )+1
		}
	end,
	GetSortedVariables = function( self )
		local sortedVariables = {}
        for k, v in pairs( self.Variables ) do
			local data = v
			data.Key = k

			table.insert( sortedVariables, data )
		end

		table.SortByMember( sortedVariables, "Order", true )
		return sortedVariables
	end,
	GetConfigDefaultValue = function( self, variable )
		return self.Variables[variable].Default
	end,
	GetConfigValue = function( self, variable )
		return BOTCHED.FUNC.CopyTypeValue( self.Variables[variable].Type, BOTCHED.CONFIG[self.ID][variable] or self.Variables[variable].Default )
	end
}

cfgModuleMeta.__index = cfgModuleMeta

function BOTCHED.FUNC.CreateConfigModule( id )
	local module = {
		ID = id,
		Variables = {}
	}
	
	setmetatable( module, cfgModuleMeta )
	
	return module
end

-- CONFIG LOAD --
for k, v in pairs( file.Find( "botched/config/*.lua", "LUA" ) ) do
	AddCSLuaFile( "botched/config/" .. v )
	include( "botched/config/" .. v )
end

if( not file.Exists( "botched/config", "DATA" ) ) then
	file.CreateDir( "botched/config" )
end

BOTCHED.CONFIG = {}
for k, v in pairs( BOTCHED.CONFIGMETA ) do
	local savedModule = util.JSONToTable( file.Read( "botched/config/" .. k .. ".txt", "DATA" ) or "" ) or {}

	local module = {}
	for key, val in pairs( v.Variables ) do
		module[key] = savedModule[key] or val.Default
	end

	BOTCHED.CONFIG[k] = module

	v.LastModified = file.Time( "botched/config/" .. k .. ".txt", "DATA" ) or 0
end

BOTCHED.CONFIG_LOADED = true
hook.Run( "Botched.Hooks.ConfigLoaded" )