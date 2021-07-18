BOTCHED.FUNC.SQLCreateTable( "botched_players", [[
	userID INTEGER PRIMARY KEY AUTOINCREMENT,
	steamID64 varchar(20) NOT NULL UNIQUE
]], [[
	userID INTEGER PRIMARY KEY AUTO_INCREMENT,
	steamID64 varchar(20) NOT NULL UNIQUE
]] )

BOTCHED.FUNC.SQLCreateTable( "botched_locker", [[
	userID int NOT NULL,
	itemKey varchar(20) NOT NULL,
	amount int,
	equipped bool
]] )