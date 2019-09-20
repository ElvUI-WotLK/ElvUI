local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_GPS was unable to locate oUF install")

local next = next
local atan2, cos, max, sin = math.atan2, math.cos, math.max, math.sin
local tinsert, tremove = table.insert, table.remove

local sqrt2 = math.sqrt(2)
local pi2 = 3.1415926535898 / 2

local GetMouseFocus = GetMouseFocus
local GetPlayerFacing = GetPlayerFacing
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsUnit = UnitIsUnit

local _FRAMES = {}
local OnUpdateFrame

local function CalculateCorner(r)
	return 0.5 + cos(r) / sqrt2, 0.5 + sin(r) / sqrt2
end

local function RotateTexture(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 0.785398163)
	local LLx, LLy = CalculateCorner(angle + 2.35619449)
	local ULx, ULy = CalculateCorner(angle + 3.92699082)
	local URx, URy = CalculateCorner(angle - 0.785398163)

	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
end

local function GetAngle(unit1, unit2)
	local x1, y1 = GetPlayerMapPosition(unit1)
	if x1 <= 0 and y1 <= 0 then return end

	local x2, y2 = GetPlayerMapPosition(unit2)
	if x2 <= 0 and y2 <= 0 then return end

	return -pi2 - GetPlayerFacing() - atan2(y2 - y1, x2 - x1)
end

local minThrottle = 0.2
local numArrows, inRange, unit, GPS

local function Update(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed < self.throttle then return end

	numArrows = 0
	local object

	for i = 1, #_FRAMES do
		object = _FRAMES[i]

		if object:IsShown() then
			GPS = object.GPS
			unit = object.unit

			if unit then
				if unit and GPS.outOfRange then
					inRange = UnitInRange(unit)
				end

				if not unit or not (UnitInParty(unit) or UnitInRaid(unit)) or UnitIsUnit(unit, "player") or not UnitIsConnected(unit)
				or (GPS.onMouseOver and (GetMouseFocus() ~= object)) or (GPS.outOfRange and inRange) then
					GPS:Hide()
				else
					local angle = GetAngle("player", unit)

					if angle then
						RotateTexture(GPS.Texture, angle)
						GPS:Show()

						numArrows = numArrows + 1
					else
						GPS:Hide()
					end
				end
			else
				GPS:Hide()
			end
		end
	end

	self.elapsed = 0
	self.throttle = max(minThrottle, 0.005 * numArrows)
end

local function Enable(self)
	local element = self.GPS

	if element then
		tinsert(_FRAMES, self)

		if not OnUpdateFrame then
			OnUpdateFrame = CreateFrame("Frame")
			OnUpdateFrame:SetScript("OnUpdate", Update)
			OnUpdateFrame.throttle = minThrottle
			OnUpdateFrame.elapsed = 0
		end

		OnUpdateFrame:Show()

		return true
	end
end

local function Disable(self)
	local element = self.GPS

	if element then
		for i, frame in next, _FRAMES do
			if frame == self then
				tremove(_FRAMES, i)
				element:Hide()
				break
			end
		end

		if #_FRAMES == 0 and OnUpdateFrame then
			OnUpdateFrame:Hide()
		end
	end
end

oUF:AddElement("GPS", nil, Enable, Disable)