-- PLAYERS --
if( not sql.TableExists( "botched_players" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_players ( 
		userID INTEGER PRIMARY KEY AUTOINCREMENT,
		steamID64 varchar(20) NOT NULL UNIQUE
	); ]] )
end

print( "[BOTCHED SQLLite] botched_players table validated!" )

-- LOCKER --
if( not sql.TableExists( "botched_locker" ) ) then
	BOTCHED.FUNC.SQLQuery( [[ CREATE TABLE botched_locker (
		userID int NOT NULL,
		itemKey varchar(20) NOT NULL,
		amount int,
		equipped bool
	); ]] )
end

print( "[BOTCHED SQLLite] botched_locker table validated!" )