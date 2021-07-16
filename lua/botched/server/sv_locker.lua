util.AddNetworkString( "Botched.RequestUseLockerItem" )
net.Receive( "Botched.RequestUseLockerItem", function( len, ply )
    local itemKey = net.ReadString()
    local amount = net.ReadUInt( 16 )

    if( not itemKey or not amount ) then return end

    local configItem = BOTCHED.CONFIG.LOCKER.Items[itemKey]
    if( not configItem ) then return end

    local typeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]
    if( not typeConfig or not typeConfig.UseFunction ) then return end

    local lockerTable = ply:Botched():GetLocker()
    if( not lockerTable[itemKey] or lockerTable[itemKey].Amount < amount ) then return end

    ply:Botched():TakeLockerItems( itemKey, amount )
    typeConfig.UseFunction( ply, amount, unpack( configItem.TypeInfo ) )
end )

util.AddNetworkString( "Botched.RequestEquipLockerItem" )
net.Receive( "Botched.RequestEquipLockerItem", function( len, ply )
    local itemKey = net.ReadString()
    if( not itemKey ) then return end

    local configItem = BOTCHED.CONFIG.LOCKER.Items[itemKey]
    if( not configItem ) then return end

    local typeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]
    if( not typeConfig or not typeConfig.EquipFunction ) then return end

    local lockerTable = ply:Botched():GetLocker()
    if( not lockerTable[itemKey] or lockerTable[itemKey].Equipped ) then return end

    lockerTable[itemKey].Equipped = true
    ply:Botched():SetLocker( lockerTable )
    ply:Botched():SendLockerItems( { itemKey } )

    typeConfig.EquipFunction( ply, unpack( configItem.TypeInfo ) )
end )

util.AddNetworkString( "Botched.RequestUnEquipLockerItem" )
net.Receive( "Botched.RequestUnEquipLockerItem", function( len, ply )
    local itemKey = net.ReadString()
    if( not itemKey ) then return end

    local configItem = BOTCHED.CONFIG.LOCKER.Items[itemKey]
    if( not configItem ) then return end

    local typeConfig = BOTCHED.DEVCONFIG.ItemTypes[configItem.Type]
    if( not typeConfig or not typeConfig.UnEquipFunction ) then return end

    local lockerTable = ply:Botched():GetLocker()
    if( not lockerTable[itemKey] or not lockerTable[itemKey].Equipped ) then return end

    lockerTable[itemKey].Equipped = false
    ply:Botched():SetLocker( lockerTable )
    ply:Botched():SendLockerItems( { itemKey } )

    typeConfig.UnEquipFunction( ply, unpack( configItem.TypeInfo ) )
end )