local lastStreetName = ""
local zone = "Unknown";

function playerLocation()
    return lastStreetName
end

function playerZone()
    return zone
end

function getCardinalDirectionFromHeading(heading)
    if heading >= 315 or heading < 45 then
        return "North Bound"
    elseif heading >= 45 and heading < 135 then
        return "West Bound"
    elseif heading >=135 and heading < 225 then
        return "South Bound"
    elseif heading >= 225 and heading < 315 then
        return "East Bound"
    end
end

local uiopen = false
local compass_on = false

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local veh = GetVehiclePedIsIn(player, false)
        if veh and IsVehicleDriveable(veh, false) and IsVehicleEngineOn(veh) then
            if not uiopen then
                uiopen = true
                SendNUIMessage({
                    open = 1,
                })
            end
            local x, y, z = table.unpack(GetEntityCoords(player, true))
            local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z)
            local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
            local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
            local zone = tostring(GetNameOfZone(x, y, z))
            local area = GetLabelText(zone)
            local playerStreetsLocation = ""
            if intersectStreetName ~= nil and intersectStreetName ~= "" then
                playerStreetsLocation = currentStreetName .. " | " .. intersectStreetName .. " | [" .. area .. "]"
            elseif currentStreetName ~= nil and currentStreetName ~= "" then
                playerStreetsLocation = currentStreetName .. " | [" .. area .. "]"
            else
                playerStreetsLocation = "[" .. area .. "]"
            end

            SendNUIMessage({
                open = 2,
                street = playerStreetsLocation,
            })

            local heading = math.floor(calcHeading(-GetFinalRenderedCamRot(0).z % 360))
            SendNUIMessage({
                direction = heading,
            })
            Citizen.Wait(500)
        else
            if uiopen then
                SendNUIMessage({
                    open = 3,
                })
                uiopen = false
            end
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(50)
        local player = PlayerPedId()
        local veh = GetVehiclePedIsIn(player, false)
        if veh and IsVehicleDriveable(veh, false) and IsVehicleEngineOn(veh) then
            SendNUIMessage({
                open = 2,
                direction = math.floor(calcHeading(-GetFinalRenderedCamRot(0).z % 360)),
            })
        elseif compass_on == true then
            if not uiopen then
                uiopen = true
                SendNUIMessage({
                    open = 1,
                })
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

local imageWidth = 100
local width =  0;
local south = (-imageWidth) + width
local west = (-imageWidth * 2) + width
local north = (-imageWidth * 3) + width
local east = (-imageWidth * 4) + width
local south2 = (-imageWidth * 5) + width

function calcHeading(direction)
    if (direction < 90) then
        return lerp(north, east, direction / 90)
    elseif (direction < 180) then
        return lerp(east, south2, rangePercent(90, 180, direction))
    elseif (direction < 270) then
        return lerp(south, west, rangePercent(180, 270, direction))
    elseif (direction <= 360) then
        return lerp(west, north, rangePercent(270, 360, direction))
    end
end

function rangePercent(min, max, amt)
    return (((amt - min) * 100) / (max - min)) / 100
end

function lerp(min, max, amt)
    return (1 - amt) * min + amt * max
end