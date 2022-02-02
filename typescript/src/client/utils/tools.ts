/*
    CONCEPT
*/

export function DoLongHudText(text: string, style: number) {
    return DoLongHudText(text, style);
}

export function GetClosetPlayer(x: number, y: number, z: number, radius: number, p4: boolean, p5: boolean, p7: boolean, p8: boolean, pedType: number) {
    return GetClosestPed(x, y, z, radius, p4, p5, p7, p8, pedType);
}

export function PlayEntitySound(soundId: number, audioName: string, entity, audioRef: string, isNetwork: boolean, p5): void {
    return PlaySoundFromEntity(soundId, audioName, entity, audioRef, isNetwork, p5);
}

export function SyncedExecution() {
    //todo
}

export function GetPedVehicleSeat(playerPed: number, CurrentVehicle: number) {
    return GetPedInVehicleSeat(playerPed, CurrentVehicle);
}

// export function GetClosetPlayer() {
//     return GetClosestPed();
// }