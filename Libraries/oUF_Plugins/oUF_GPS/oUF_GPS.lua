local _, ns = ...;
local oUF = ns.oUF or oUF;
assert(oUF, "oUF not loaded");

local cos, sin, sqrt2, max, atan2 = math.cos, math.sin, math.sqrt(2), math.max, math.atan2;
local tinsert, tremove = table.insert, table.remove;
local pi2 = 3.141592653589793 / 2;

local GetPlayerMapPosition = GetPlayerMapPosition
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsUnit = UnitIsUnit

local _FRAMES, OnUpdateFrame = {};

local function CalculateCorner(r) return .5 + cos(r) / sqrt2, .5 + sin(r) / sqrt2; end
local function RotateTexture(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 0.785398163);
	local LLx, LLy = CalculateCorner(angle + 2.35619449);
	local ULx, ULy = CalculateCorner(angle + 3.92699082);
	local URx, URy = CalculateCorner(angle - 0.785398163);

	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local GetAngle = function(unit1, unit2)
	local x1, y1 = GetPlayerMapPosition(unit1);
	if(x1 <= 0 and y1 <= 0) then return nil; end
	local x2, y2 = GetPlayerMapPosition(unit2)
	if(x2 <= 0 and y2 <= 0) then return nil; end
	return -pi2 - GetPlayerFacing() - atan2(y2 - y1, x2 - x1);
end

local minThrottle = 0.02
local numArrows, inRange, unit, GPS
local Update = function(self, elapsed)
	if(self.elapsed and self.elapsed > (self.throttle or minThrottle)) then
		numArrows = 0;
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				GPS = object.GPS;
				unit = object.unit;
				if(unit) then
					if(unit and GPS.outOfRange) then
						inRange = UnitInRange(unit);
					end

					if(not unit or not (UnitInParty(unit) or UnitInRaid(unit)) or UnitIsUnit(unit, "player") or not UnitIsConnected(unit) or (GPS.onMouseOver and (GetMouseFocus() ~= object)) or (GPS.outOfRange and inRange)) then
						GPS:Hide()
					else
						local angle = GetAngle("player", unit);
						if(angle == nil) then
							GPS:Hide();
						else
							GPS:Show();
							RotateTexture(GPS.Texture, angle);

							numArrows = numArrows + 1;
						end
					end
				else
					GPS:Hide();
				end
			end
		end

		self.elapsed = 0;
		self.throttle = max(minThrottle, 0.005 * numArrows);
	else
		self.elapsed = (self.elapsed or 0) + elapsed;
	end
end

local Enable = function(self)
	local GPS = self.GPS;
	if(GPS) then
		tinsert(_FRAMES, self);

		if(not OnUpdateFrame) then
			OnUpdateFrame = CreateFrame("Frame");
			OnUpdateFrame:SetScript("OnUpdate", Update);
		end

		OnUpdateFrame:Show();
		return true;
	end
end

local Disable = function(self)
	local GPS = self.GPS;
	if(GPS) then
		for k, frame in next, _FRAMES do
			if(frame == self) then
				tremove(_FRAMES, k);
				GPS:Hide();
				break
			end
		end

		if(#_FRAMES == 0 and OnUpdateFrame) then
			OnUpdateFrame:Hide();
		end
	end
end

oUF:AddElement("GPS", nil, Enable, Disable);