local function LoadSQLFiles()
    for k, v in pairs( file.Find( "botched/*.lua", "LUA" ) ) do
        if( not string.StartWith( v, "sv_sql" ) ) then continue end
        include( "botched/" .. v )
    end
end

if( not file.Exists( "botched/mysql.txt", "DATA" ) ) then
    file.Write( "botched/mysql.txt", util.TableToJSON( {
        Enabled = false,
        Host = "localhost",
        Username = "root",
        Password = "",
        DatabaseName = "garrysmod",
        DatabasePort = 3306
    }, true ) )
end

local mySqlInfo = util.JSONToTable( file.Read( "botched/mysql.txt", "DATA" ) or "" ) or {}
if( mySqlInfo.Enabled ) then
    require( "mysqloo" )

    BOTCHED_SQL_DB = mysqloo.connect( mySqlInfo.Host, mySqlInfo.Username, mySqlInfo.Password, mySqlInfo.DatabaseName, mySqlInfo.DatabasePort )
    BOTCHED_SQL_DB.onConnected = function() 
        print( "[BOTCHED MySQL] Database has connected!" ) 
        LoadSQLFiles()
    end
    BOTCHED_SQL_DB.onConnectionFailed = function( db, err ) print( "[BOTCHED MySQL] Connection to database failed! Error: " .. err ) end
    BOTCHED_SQL_DB:connect()
    
    function BOTCHED.FUNC.SQLQuery( queryStr, func, singleRow )
        local query = BOTCHED_SQL_DB:query( queryStr )
        if( func ) then
            function query:onSuccess( data ) 
                if( singleRow ) then
                    data = data[1]
                end
    
                func( data ) 
            end
        end
        function query:onError( err ) print( "[BOTCHED MySQL] An error occured while executing the query: " .. err ) end
        query:start()
    end

    function BOTCHED.FUNC.SQLCreateTable( tableName, sqlLiteQuery, mySqlQuery )
        BOTCHED.FUNC.SQLQuery( "CREATE TABLE IF NOT EXISTS " .. tableName .. " ( " .. (mySqlQuery or sqlLiteQuery) .. " );" )
        print( "[BOTCHED MySQL] " .. tableName .. " table validated!" )
    end    
else
    function BOTCHED.FUNC.SQLQuery( queryStr, func, singleRow )
        local query
        if( not singleRow ) then
            query = sql.Query( queryStr )
        else
            query = sql.QueryRow( queryStr, 1 )
        end
        
        if( query == false ) then
            print( "[Botched SQLLite] ERROR", sql.LastError() )
        elseif( func ) then
            func( query )
        end
    end    

    function BOTCHED.FUNC.SQLCreateTable( tableName, sqlLiteQuery, mySqlQuery )
        if( not sql.TableExists( tableName ) ) then
            BOTCHED.FUNC.SQLQuery( "CREATE TABLE " .. tableName .. " ( " .. (sqlLiteQuery or mySqlQuery) .. " );" )
        end

        print( "[BOTCHED SQLLite] " .. tableName .. " table validated!" )
    end

    LoadSQLFiles()
end