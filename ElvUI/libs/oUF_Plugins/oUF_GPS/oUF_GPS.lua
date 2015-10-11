local _, ns = ...;
local oUF = ns.oUF or oUF;
assert(oUF, "oUF not loaded");

local max = math.max;
local _FRAMES, OnUpdateFrame = {};
local tinsert, tremove = table.insert, table.remove;
local pi, pi2 = math.pi, math.pi * 2;
local atan2 = math.atan2;

local function GetUnitDirection(unit)
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
	
	return pi - atan2(x1 - x2, y2 - y1) - GetPlayerFacing();
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
						
						local direction = GetUnitDirection(unit);
						if(direction == nil) then
							GPS:Hide();
						else
							GPS:Show();
							
							local cell = floor(direction / pi2 * 108 + 0.5) % 108;
							if(cell ~= nil) then
								local startX = (cell % 9) * 0.109375;
								local startY = floor(cell / 9) * 0.08203125;
								GPS.Texture:SetTexCoord(startX, startX + 0.109375, startY, startY + 0.08203125);
							end
							
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