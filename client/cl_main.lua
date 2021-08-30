local wearingSeatbelt = false
local wearingHarness = false
local currentVehicle, currentVehicleIdentifier = 0, nil
local isInsideVehicle = 0
local modifiedVehicles = {}

local slipperySurfaceMaterial = {
  [9] = 'ROCK',
  [10] = 'ROCK_MOSSY',
  [11] = 'STONE',
  [17] = 'SANDSTONE_BRITTLE',
  [18] = 'SAND_LOOSE',
  [19] = 'SAND_COMPACT',
  [20] = 'SAND_WET',
  [21] = 'SAND_TRACK',
  [22] = 'SAND_UNDERWATER',
  [23] = 'SAND_DRY_DEEP',
  [24] = 'SAND_WET_DEEP',
  [31] = 'GRAVEL_SMALL',
  [32] = 'GRAVEL_LARGE',
  [33] = 'GRAVEL_DEEP',
  [34] = 'GRAVEL_TRAIN_TRACK',
  [35] = 'DIRT_TRACK',
  [36] = 'MUD_HARD',
  [37] = 'MUD_POTHOLE',
  [38] = 'MUD_SOFT',
  [39] = 'MUD_UNDERWATER',
  [40] = 'MUD_DEEP',
  [41] = 'MARSH',
  [42] = 'MARSH_DEEP',
  [43] = 'SOIL',
  [44] = 'CLAY_HARD',
  [45] = 'CLAY_SOFT',
  [46] = 'GRASS_LONG',
  [47] = 'GRASS',
  [48] = 'GRASS_SHORT',
  [55] = 'METAL_SOLID_SMALL'-- Train Track
}

CreateThread(function()
  while true do
    Citizen.Wait(0)
    if currentVehicle ~= 0 then
      if wearingHarness then
        DisableControlAction(0, 75, true)
        if IsDisabledControlJustPressed(1, 75) then
          TriggerEvent('DoLongHudText', 'You probably should undo your harness...', 101)
        end
      else
        Citizen.Wait(1000)
      end
    else
      Citizen.Wait(5000)
    end
  end
end)

local function isDriver()
  return GetPedInVehicleSeat(currentVehicle, -1) == PlayerPedId()
end

function toggleSeatbelt()
  currentVehicle = GetVehiclePedIsIn(PlayerPedId())
  isInsideVehicle = currentVehicle ~= 0

  if isInsideVehicle then
    local harnessLevel = exports['np-vehicles']:GetVehicleMetadata(currentVehicle, 'harness') or 0
    local hasHarness = harnessLevel > 0
    if wearingSeatbelt and not wearingHarness then -- Wearing seatbelt but no harness, taking off
      TriggerEvent('InteractSound_CL:PlayOnOne', 'seatbeltoff', 0.7)
      wearingSeatbelt = true
      SetFlyThroughWindscreenParams(10.0, 1.0, 1.0, 1.0)
    elseif wearingSeatbelt and wearingHarness and isDriver() then -- Wearing seatbelt/harness, taking off
      toggleHarness(false)
    elseif not wearingSeatbelt and not wearingSeatbelt and isDriver() and hasHarness then -- Not wearing anything and have harness
      toggleHarness(true)
    elseif not wearingSeatbelt and not wearingHarness then
      TriggerEvent('InteractSound_CL:PlayOnOne', 'seatbelt', 0.7) -- Not wearing anything and have no harness
      wearingSeatbelt = true
      SetFlyThroughWindscreenParams(45.0, 1.0, 1.0, 1.0)
    end
    TriggerEvent('harness', wearingHarness, exports['np-vehicles']:GetVehicleMetadata(currentVehicle, 'harness'))
    TriggerEvent('seatbelt', wearingSeatbelt)
  end
end

function toggleHarness(pState)
  local defaultSteering = GetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fSteeringLock')
  toggleTurning(currentVehicle, false, defaultSteering)
  local harnessTimer = exports['np-taskbar']:taskBar(5000, (pState and 'Putting on Harness' or 'Taking off Harness'), true)
  if harnessTimer == 100 then
    wearingHarness = pState
    wearingSeatbelt = pState
    TriggerEvent('InteractSound_CL:PlayOnOne', (pState and 'seatbelt' or 'seatbeltoff'), 0.7)
  end
  toggleTurning(currentVehicle, true, defaultSteering)
end

function toggleTurning(pVehicle, pToggle, pDefaultHandlingValue)
  if pVehicle ~= 0 then
    SetVehicleHandlingFloat(pVehicle, 'CHandlingData', 'fSteeringLock', (pToggle and pDefaultHandlingValue or (pDefaultHandlingValue / 4)))
  end
end

function getVehicleHandling(pVehicleIdentifier, pCurrentVehicleHandle, pHandling)
  if pVehicleIdentifier and pHandling then
    if modifiedVehicles[pVehicleIdentifier] ~= nil and modifiedVehicles[pVehicleIdentifier][pHandling] ~= nil then
      return true, modifiedVehicles[pVehicleIdentifier][pHandling]
    else
      return false, GetVehicleHandlingFloat(pCurrentVehicleHandle, 'CHandlingData', pHandling)
    end
  end
end

function setVehicleHandling(pVehicleIdentifier, pCurrentVehicleHandle, pHandling, pFactor)
  local isModified, fValue = getVehicleHandling(pVehicleIdentifier, pCurrentVehicleHandle, pHandling)
  if not isModified then
    fValue = (fValue * pFactor)
  end
  modifiedVehicles[pVehicleIdentifier][pHandling] = fValue
  SetVehicleHandlingFloat(pCurrentVehicleHandle, 'CHandlingData', pHandling, fValue)
end

function processVehicleHandling(pCurrentVehicle)
  local vehicleIdentifier = exports['np-vehicles']:GetVehicleIdentifier(pCurrentVehicle)
  if vehicleIdentifier then
    currentVehicleIdentifier = vehicleIdentifier
    SetVehiclePetrolTankHealth(pCurrentVehicle, 4000.0)
    SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fWeaponDamageMult', 5.500000)

    local isModified, fSteeringLock = getVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fSteeringLock')
    if not isModified then
      fSteeringLock = math.ceil((fSteeringLock * 0.6)) + 0.1
    end

    if not modifiedVehicles[vehicleIdentifier] then modifiedVehicles[vehicleIdentifier] = {} end 
    modifiedVehicles[vehicleIdentifier]['fSteeringLock'] = fSteeringLock
    SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fSteeringLock', fSteeringLock)

    if IsThisModelABike(GetEntityModel(pCurrentVehicle)) then
        setVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fTractionCurveMin', 0.6)
        setVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fTractionCurveMax', 0.6)
        setVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fInitialDriveForce', 2.2)
        setVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fBrakeForce', 1.4)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fSuspensionReboundDamp', 5.000000)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fSuspensionCompDamp', 5.000000)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fSuspensionForce', 22.000000)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fCollisionDamageMult', 1.150000)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fEngineDamageMult', 0.120000)
    else
      --  setVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fTractionCurveMin', 1.0)
      --  setVehicleHandling(vehicleIdentifier, pCurrentVehicle, 'fBrakeForce', 0.5)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fEngineDamageMult', 0.250000)
        SetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fCollisionDamageMult', 1.000000)

        -- test lower deformation for weird driving on cop / some race cars after minor crashes
        SetVehicleHandlingFloat(vepCurrentVehicleh, 'CHandlingData', 'fDeformationDamageMult', 0.400000)
    end

    modifiedVehicles[vehicleIdentifier].fInitialDriveMaxFlatVel = GetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    modifiedVehicles[vehicleIdentifier].fTractionLossMult = GetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fTractionLossMult')
    modifiedVehicles[vehicleIdentifier].fLowSpeedTractionLossMult = GetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fLowSpeedTractionLossMult')
    modifiedVehicles[vehicleIdentifier].fDriveBiasFront = GetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fDriveBiasFront')
    modifiedVehicles[vehicleIdentifier].fDriveInertia = GetVehicleHandlingFloat(pCurrentVehicle, 'CHandlingData', 'fDriveInertia')

    -- print("fTractionLoss", modifiedVehicles[currentVehicleIdentifier].fTractionLossMult)
    -- print("fTractionCurveMin", modifiedVehicles[currentVehicleIdentifier].fTractionCurveMin)
    -- print("fLowSpeedTractionLossMult", modifiedVehicles[currentVehicleIdentifier].fLowSpeedTractionLossMult)

    SetVehicleHasBeenOwnedByPlayer(pCurrentVehicle, true)
  end
end

AddEventHandler('baseevents:enteredVehicle', function(pCurrentVehicle, currentSeat, vehicleDisplayName)
  currentVehicle = pCurrentVehicle
  SetPedConfigFlag(PlayerPedId(), 35, false)
  local vehicleClass = GetVehicleClass(pCurrentVehicle)
  if vehicleClass == 15 or vehicleClass == 16 then
      SetAudioSubmixEffectParamInt(0, 0, `enabled`, 1)
  end
  if currentSeat == -1 then
    processVehicleHandling(pCurrentVehicle)
  end
end)

AddEventHandler('baseevents:leftVehicle', function(pCurrentVehicle, pCurrentSeat, vehicleDisplayName)
  wearingHarness = false
  wearingSeatbelt = false
  currentVehicle = 0
  offroadTicks = 0
  currentVehicleIdentifier = nil
  TriggerEvent('harness', false, 0);
  TriggerEvent('seatbelt', false);
  SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
  toggleOffroadState(false)
end)

AddEventHandler('baseevents:vehicleChangedSeat', function(pCurrentVehicle, pCurrentSeat, previousSeat)
  if pCurrentSeat == -1 then
    processVehicleHandling(pCurrentVehicle)
  end
end)


function toggleOffroadState(pState)
  if currentVehicleIdentifier ~= nil and GetVehicleClass(currentVehicle) ~= 9 then
    local isAWD = (modifiedVehicles[currentVehicleIdentifier].fDriveBiasFront > 0 and modifiedVehicles[currentVehicleIdentifier].fDriveBiasFront < 1)
    local lowSpeedTractionFactor = isAWD and 1.5 or 1.5
    local tractionFactor = isAWD and 0.8 or 0.9

    -- print("fTractionLoss", modifiedVehicles[currentVehicleIdentifier].fTractionLossMult * (pState and 1.5 or 1.0))
    -- print("fTractionCurveMin", modifiedVehicles[currentVehicleIdentifier].fTractionCurveMin * (pState and tractionFactor or 1.0))
    -- print("fLowSpeedTractionLossMult", modifiedVehicles[currentVehicleIdentifier].fLowSpeedTractionLossMult * (pState and lowSpeedTractionFactor or 1.0))
    SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionLossMult', modifiedVehicles[currentVehicleIdentifier].fTractionLossMult * (pState and 1.5 or 1.0))
    SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fTractionCurveMin', modifiedVehicles[currentVehicleIdentifier].fTractionCurveMin * (pState and tractionFactor or 1.0))
    SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', 'fLowSpeedTractionLossMult', modifiedVehicles[currentVehicleIdentifier].fLowSpeedTractionLossMult * (pState and lowSpeedTractionFactor or 1.0))
  end
end

-- CreateThread(function()
--     local currentMaterial, isOffroad, offroadTicks = 0, false, 0

--     while true do
--       Wait(500)
--       if currentVehicle ~= 0 then
--         local surfaceMaterialIndex = GetVehicleWheelSurfaceMaterial(currentVehicle, 1)
--         local isSlippery = slipperySurfaceMaterial[surfaceMaterialIndex]

--         if isSlippery and offroadTicks < 5 then
--           offroadTicks = offroadTicks + 1
--         elseif not isSlippery and offroadTicks >= 1 then
--           offroadTicks = offroadTicks - 1
--         end

--         if isSlippery and not isOffroad and offroadTicks > 3 then
--           isOffroad = true
--           toggleOffroadState(true)
--         elseif isOffroad and offroadTicks < 3 then
--           isOffroad = false
--           toggleOffroadState(false)
--         end
--       end
--     end
-- end)