BOTCHED.DEVCONFIG.ItemTypes = {}

local itemMeta = {
	Register = function( self )
        BOTCHED.DEVCONFIG.ItemTypes[self.Class] = self
	end,
	SetTitle = function( self, title )
        self.Title = title
	end,
	SetDescription = function( self, description )
        self.Description = description
	end,
	AddReqInfo = function( self, type, title, description )
		table.insert( self.ReqInfo, { type, title, description } )
	end,
	SetUseFunction = function( self, func )
		self.UseFunction = func
	end,
	SetEquipFunction = function( self, func )
		self.EquipFunction = func
	end,
	SetUnEquipFunction = function( self, func )
		self.UnEquipFunction = func
	end,
	SetPermanent = function( self, bool )
		self.Permanent = bool
	end,
	SetLimitOneType = function( self, bool )
		self.LimitOneType = bool
	end,
	SetAllowInstantUse = function( self, bool )
		self.AllowInstantUse = bool
	end,
	SetModelDisplay = function( self, func )
		self.ModelDisplay = func
	end
}

itemMeta.__index = itemMeta

function BOTCHED.FUNC.CreateItemType( class )
	local item = {
		Class = class,
		ReqInfo = {}
	}
	
	setmetatable( item, itemMeta )
	
	return item
end

for k, v in pairs( file.Find( "botched/itemtypes/*.lua", "LUA" ) ) do
    AddCSLuaFile( "botched/itemtypes/" .. v )
    include( "botched/itemtypes/" .. v )
end