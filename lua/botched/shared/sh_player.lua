local playerMeta = FindMetaTable( "Player" )

function playerMeta:Botched()
	if( SERVER ) then
		if( not self.BOTCHED_PLAYERMETA ) then
			self.BOTCHED_PLAYERMETA = {
				Player = self
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
	if( costTable.Gems and self:GetGems() < costTable.Gems ) then
		return false
	end

	if( costTable.ExchangeTokens and self:GetExchangeTokens() < costTable.ExchangeTokens ) then
		return false
	end

	return true
end

-- LOCKER FUNCTIONS --
function BOTCHED.PLAYERMETA:GetLocker()
	return self.LockerData or {}
end