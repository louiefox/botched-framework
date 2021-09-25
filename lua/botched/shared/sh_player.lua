local playerMeta = FindMetaTable( "Player" )

function playerMeta:Botched()
	if( SERVER ) then
		if( not self ) then return false end

		if( not self.BOTCHED_PLAYERMETA ) then
			self.BOTCHED_PLAYERMETA = {
				Player = self,
				TempItemData = {}
			}

			setmetatable( self.BOTCHED_PLAYERMETA, BOTCHED.PLAYERMETA )
		end

		return self.BOTCHED_PLAYERMETA
	else
		return BOTCHED.LOCALPLYMETA
	end
end

-- GENERAL FUNCTIONS --
function BOTCHED.PLAYERMETA:GetUserID()
	return self.UserID or 0
end

function BOTCHED.PLAYERMETA:CanAfford( costTable )
	for k, v in pairs( costTable ) do
        local devCfg = BOTCHED.DEVCONFIG.RewardTypes[k]
        if( not devCfg ) then continue end

		if( not devCfg.CanAfford( self, costTable ) ) then return false end
    end

	return true
end

-- LOCKER FUNCTIONS --
function BOTCHED.PLAYERMETA:GetLocker()
	return self.LockerData or {}
end

function BOTCHED.PLAYERMETA:GetTempItemData()
	return self.TempItemData or {}
end