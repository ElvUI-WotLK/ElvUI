local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
local _G = _G
--WoW API / Variables
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat

local function VehicleSeatIndicator_SetPosition(_, _, parent)
	if (parent == "MinimapCluster") or (parent == MinimapCluster) then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:Point("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	local size = E.db.general.vehicleSeatIndicatorSize

	VehicleSeatIndicator:Size(size)

	if numSeatIndicators then
		for i = 1, numSeatIndicators do
			local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i)
			local button = _G["VehicleSeatIndicatorButton"..i]
			button:Size(size / 4)
			button:ClearAllPoints()
			button:Point("CENTER", button:GetParent(), "TOPLEFT", xOffset * size, -yOffset * size)
		end
	end
end

function B:UpdateVehicleFrame()
	VehicleSetUp(VehicleSeatIndicator.currSkin or 0)
end

function B:PositionVehicleFrame()
	if not VehicleSeatIndicator.PositionVehicleFrameHooked then
		hooksecurefunc(VehicleSeatIndicator, "SetPoint", VehicleSeatIndicator_SetPosition)
		hooksecurefunc("VehicleSeatIndicator_SetUpVehicle", VehicleSetUp)
		E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, "general,general")
		VehicleSeatIndicator.PositionVehicleFrameHooked = true
	end

	VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize)

	if VehicleSeatIndicator.currSkin then
		VehicleSetUp(VehicleSeatIndicator.currSkin)
	end
end