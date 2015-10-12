local _, ns = ...;
local oUF = ns.oUF or oUF;
assert(oUF, "oUF not loaded");

local cos, sin, sqrt2, max = math.cos, math.sin, math.sqrt(2), math.max;
local _FRAMES, OnUpdateFrame = {};
local tinsert, tremove = table.insert, table.remove;
local atan2 = math.atan2;

local function CalculateCorner(r)
	return 0.5 + cos(r) / sqrt2, 0.5 + sin(r) / sqrt2;
end

local function RotateTexture(texture, angle)
	local LRx, LRy = CalculateCorner(angle + 0.785398163);
	local LLx, LLy = CalculateCorner(angle + 2.35619449);
	local ULx, ULy = CalculateCorner(angle + 3.92699082);
	local URx, URy = CalculateCorner(angle - 0.785398163);
	
	texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local function GetUnitAngle(unit)
	if((WorldMapFrame ~= nil and WorldMapFrame:IsShown()) or (GetMouseFocus() ~= nil and GetMouseFocus():GetName() == nil)) then
		return nil;
	end
	
	local x1, y1 = GetPlayerMapPosition("player");
	if((x1 or 0) + (y1 or 0) <= 0) then
		SetMapToCurrentZone();
		x1, y1 = GetPlayerMapPosition("player");
		if ((x1 or 0) + (y1 or 0) <= 0) then
			return nil;
		end
	end
	
	local x2, y2 = GetPlayerMapPosition(unit);
	if((x2 or 0) + (y2 or 0) <= 0) then
		return nil;
	end
	
	local angle = - GetPlayerFacing() - atan2(x2 - x1, y1 - y2);
	
	return angle;
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
						local angle = GetUnitAngle(unit);
						if(not angle) then
							GPS:Hide()
						else
							GPS:Show();
							RotateTexture(GPS.Texture, angle);
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