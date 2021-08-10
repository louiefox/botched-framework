-- DATA FUNCTIONS --
net.Receive( "Botched.SendFirstSpawn", function()
    hook.Run( "Botched.Hooks.FirstSpawn" )
end )

-- GENERAL FUNCTIONS --
net.Receive( "Botched.SendUserID", function()
    BOTCHED.LOCALPLYMETA.UserID = net.ReadUInt( 16 )
end )

-- LOCKER FUNCTIONS --
net.Receive( "Botched.SendLockerItems", function()
    local lockerData = BOTCHED.LOCALPLYMETA.LockerData or {}

    for i = 1, net.ReadUInt( 10 ) do
        local itemKey, shouldDelete = net.ReadString(), net.ReadBool()

        if( shouldDelete ) then
            lockerData[itemKey] = nil
            continue
        end

        local itemAmount, equipped = net.ReadUInt( 32 ), net.ReadBool()
        lockerData[itemKey] = {
            Amount = itemAmount,
            Equipped = equipped
        }
    end

    BOTCHED.LOCALPLYMETA.LockerData = lockerData

    hook.Run( "Botched.Hooks.LockerUpdated" )
end )