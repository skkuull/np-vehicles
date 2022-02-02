//winky

export function CanUseDegradationRepair(pNetId: null) {
    //const vehicle = NetworkGetEntityFromNetworkId(pNetId);
    const playerPed = PlayerPedID();
    const veh = GetVehiclePedIsIn(playerPed, false);

    SetVehicleFixed(veh); //?0x115722B1B9C14C1C - 0x17469AA1
}