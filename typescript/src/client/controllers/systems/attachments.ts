/*
    NOTICE: THIS IS ONLY A SAMPLE YOU NEED TO CONTINUE I PUT THIS CUZ I SHARED THIS PEIECE OF CODE BEFORE
*/

import { GetVehicleMetadata } from '../vehicle';

export async function InitAfterMarkets(): Promise<void> {}

export function GetVehicleAfterMarket(pVehicle: number, pAfterMarket?: AfterMarketEntry): number | VehicleAfterMarkets {
    return pAfterMarket ? GetVehicleMetadata(pVehicle, 'afterMarkets')?.[pAfterMarket] : GetVehicleMetadata(pVehicle, 'afterMarkets')?.[pAfterMarket];
}

exports('GetVehicleAfterMarket', GetVehicleAfterMarket);