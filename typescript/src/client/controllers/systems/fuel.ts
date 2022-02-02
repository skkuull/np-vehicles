export function GetVehicleFuel(pEntity) {
    //todo    
}

export function GetJerryCanFuelLevel() {
    //todo
}

export async function GetVehicleRefuelCost(fuelLevel, pArgs) {
    //todo
}

export function EmitLowFuelSound() {
    return emit('InteractSound_SV:PlayOnSource', 'Alarm3', 0.1);
}