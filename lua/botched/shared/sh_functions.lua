function BOTCHED.FUNC.FormatWordTime( time )
	local timeText = (time != 1 and string.format( "%d seconds", time )) or string.format( "%d second", time )

	if( time >= 60 ) then
		if( time < 3600 ) then
			local minutes = math.floor( time/60 )
			timeText = (minutes != 1 and string.format( "%d minutes", minutes )) or string.format( "%d minute", minutes )
		else
			if( time < 86400 ) then
				local hours = math.floor( time/3600 )
				timeText = (hours != 1 and string.format( "%d hours", hours )) or string.format( "%d hour", hours )
			else
				local days = math.floor( time/86400 )
				timeText = (days != 1 and string.format( "%d days", days )) or string.format( "%d day", days )
			end
		end
	end

	return timeText
end

function BOTCHED.FUNC.FormatLetterTime( time )
	local timeTable = string.FormattedTime( time )
	local days = math.floor( timeTable.h/24 )

	local formattedTime
	if( days > 0 ) then
		formattedTime = string.format( "%dd %dh", days, timeTable.h-(days*24) )
	elseif( timeTable.h > 0 ) then
		formattedTime = string.format( "%dh %dm", timeTable.h, timeTable.m )
	else
		formattedTime = string.format( "%dm %ds", timeTable.m, timeTable.s )
	end

	return formattedTime
end

function BOTCHED.FUNC.FormatLongLetterTime( time )
	local timeTable = string.FormattedTime( time )
	local days = math.floor( timeTable.h/24 )

	local formattedTime
	if( days > 0 ) then
		formattedTime = string.format( "%dd %dh %dm", days, timeTable.h-(days*24), timeTable.m )
	else
		formattedTime = string.format( "%dh %dm %ds", timeTable.h, timeTable.m, timeTable.s )
	end

	return formattedTime
end

function BOTCHED.FUNC.UTCTime()
	return os.time( os.date( "!*t" ) )
end

function BOTCHED.FUNC.HasAdminAccess( ply )
	return ply:IsSuperAdmin()
end

function BOTCHED.FUNC.CanOwnMultiple( itemKey )
	local configItem = BOTCHED.CONFIG.LOCKER.Items[itemKey]
	if( not configItem ) then return false end

	return BOTCHED.DEVCONFIG.ItemTypes[configItem.Type] and not BOTCHED.DEVCONFIG.ItemTypes[configItem.Type].Permanent
end