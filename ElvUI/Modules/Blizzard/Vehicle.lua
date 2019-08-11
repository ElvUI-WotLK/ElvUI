local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat
local VehicleSeatIndicator_SetUpVehicle = VehicleSeatIndicator_SetUpVehicle

local function VehicleSeatIndicator_SetPosition(_, _, parent)
	if (parent == "MinimapCluster") or (parent == MinimapCluster) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:Point("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)
	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	if numSeatIndicators then
		for i = 1, numSeatIndicators do
			local button = _G["VehicleSeatIndicatorButton"..i]
			button:Size(E.db.general.vehicleSeatIndicatorSize / 4, E.db.general.vehicleSeatIndicatorSize / 4)
			local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i)
			button:ClearAllPoints()
			button:Point("CENTER", button:GetParent(), "TOPLEFT", xOffset * E.db.general.vehicleSeatIndicatorSize, -yOffset * E.db.general.vehicleSeatIndicatorSize)
		end
	end
end

function B:UpdateVehicleFrame()
	VehicleSeatIndicator_SetUpVehicle(VehicleSeatIndicator.currSkin)
end

function B:PositionVehicleFrame()
	if not VehicleSeatIndicator.PositionVehicleFrameHooked then
		hooksecurefunc(VehicleSeatIndicator, "SetPoint", VehicleSeatIndicator_SetPosition)
		hooksecurefunc("VehicleSeatIndicator_SetUpVehicle", VehicleSetUp)
		E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, "general,general")
		VehicleSeatIndicator.PositionVehicleFrameHooked = true
	end

	VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize, E.db.general.vehicleSeatIndicatorSize)

    if VehicleSeatIndicator.currSkin then
		VehicleSetUp(VehicleSeatIndicator.currSkin)
    end
end