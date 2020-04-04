local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
local _G = _G
--WoW API / Variables
local GetVehicleUIIndicator = GetVehicleUIIndicator
local GetVehicleUIIndicatorSeat = GetVehicleUIIndicatorSeat

local function VehicleSeatIndicator_SetPosition(self, _, point)
	if point ~= VehicleSeatMover then
		self:ClearAllPoints()
		self:Point("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
	end
end

local function VehicleSetUp(vehicleID)
	if vehicleID == 0 or vehicleID == VehicleSeatIndicator.currSkin then return end

	local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)
	local size = E.db.general.vehicleSeatIndicatorSize

	VehicleSeatIndicator:Size(size)

	for i = 1, numSeatIndicators do
		local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i)
		local button = _G["VehicleSeatIndicatorButton"..i]
		button:Size(size / 4)
		button:Point("CENTER", button:GetParent(), "TOPLEFT", xOffset * size, -yOffset * size)
	end
end

function B:UpdateVehicleFrame()
	if VehicleSeatIndicator.currSkin then
		VehicleSetUp(VehicleSeatIndicator.currSkin)
	end
end

function B:PositionVehicleFrame()
	if not self.vehicleFrameHooked then
		hooksecurefunc(VehicleSeatIndicator, "SetPoint", VehicleSeatIndicator_SetPosition)
		hooksecurefunc("VehicleSeatIndicator_SetUpVehicle", VehicleSetUp)
		E:CreateMover(VehicleSeatIndicator, "VehicleSeatMover", L["Vehicle Seat Frame"], nil, nil, nil, nil, nil, "general,blizzUIImprovements")
		self.vehicleFrameHooked = true
	end

	VehicleSeatIndicator:Size(E.db.general.vehicleSeatIndicatorSize)

	self:UpdateVehicleFrame()
end