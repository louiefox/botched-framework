-- GENERAL FUNCTIONS --
net.Receive( "Botched.SendUserID", function()
    BOTCHED.LOCALPLYMETA.UserID = net.ReadUInt( 16 )
end )

-- LOCKER FUNCTIONS --
net.Receive( "Botched.SendLocker", function()
    BOTCHED.LOCALPLYMETA.LockerData = net.ReadTable()

    hook.Run( "Botched.Hooks.LockerUpdated" )
end )

net.Receive( "Botched.SendLockerItems", function()
    local lockerData = BOTCHED.LOCALPLYMETA.LockerData or {}

    local amount = net.ReadUInt( 10 )
    for i = 1, amount do
        local itemKey, itemAmount = net.ReadString(), net.ReadUInt( 32 )
        if( itemAmount > 0 ) then
            lockerData[itemKey] = itemAmount
        else
            lockerData[itemKey] = nil
        end
    end

    BOTCHED.LOCALPLYMETA.LockerData = lockerData

    hook.Run( "Botched.Hooks.LockerUpdated" )
end )