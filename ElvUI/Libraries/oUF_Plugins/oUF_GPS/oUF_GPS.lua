local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_GPS was unable to locate oUF install")

local atan2, cos, sin = math.atan2, math.cos, math.sin
local tremove = table.remove

local sqrt2 = math.sqrt(2)
local pi2 = math.pi / 2

local GetPlayerFacing = GetPlayerFacing
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsUnit = UnitIsUnit

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

local function UpdateElement(element, unit)
	if not unit or UnitIsUnit(unit, "player") or not UnitIsConnected(unit) or not (UnitInParty(unit) or UnitInRaid(unit)) or (element.outOfRange and UnitInRange(unit)) then
		element:Hide()
	else
		local angle = GetAngle("player", unit)

		if angle then
			RotateTexture(element.Texture, angle)
			element:Show()
		else
			element:Hide()
		end
	end
end

local _FRAMES = {}
local ListUpdateFrame

local function OnUpdateList(self, elapsed)
	self.elapsed = self.elapsed + elapsed

	if self.elapsed < 0.0333 then return end

	self.elapsed = 0

	for i = 1, #_FRAMES do
		local object = _FRAMES[i]

		if object:IsShown() then
			UpdateElement(object.GPS, object.unit)
		end
	end
end
local function OnUpdateFrame(self, elapsed)
	self.__elapsed = self.__elapsed + elapsed

	if self.__elapsed < 0.0333 then return end

	self.__elapsed = 0
	UpdateElement(self.GPS, self.unit)
end

local function OnEnter(self)
	if not self.__enabled then return end

	self.__elapsed = 0
	self:SetScript("OnUpdate", OnUpdateFrame)
end
local function OnLeave(self)
	if not self.__enabled then return end

	self:SetScript("OnUpdate", nil)
	self.GPS:Hide()
end

local function disableHook(self, element)
	if not element.__hooked then return end

	self.__enabled = false
	self:SetScript("OnUpdate", nil)
end
local function disableGlobal(self, element)
	if not element.__global then return end

	for i = 1, #_FRAMES do
		if _FRAMES[i] == self then
			tremove(_FRAMES, i)
			element:Hide()
			break
		end
	end

	element.__global = nil

	if #_FRAMES == 0 and ListUpdateFrame then
		ListUpdateFrame:Hide()
	end
end

local function UpdateState(self, disable)
	local element = self.GPS

	if not disable then
		if element.onMouseOver then
			disableGlobal(self, element)

			if not element.__hooked then
				self:HookScript("OnEnter", OnEnter)
				self:HookScript("OnLeave", OnLeave)

				element.__hooked = true
			end

			self.__enabled = true
		else
			disableHook(self, element)

			if not element.__global then
				_FRAMES[#_FRAMES + 1] = self
				element.__global = true

				if not ListUpdateFrame then
					ListUpdateFrame = CreateFrame("Frame")
					ListUpdateFrame:SetScript("OnUpdate", OnUpdateList)
					ListUpdateFrame.elapsed = 0
				end

				ListUpdateFrame:Show()
			end
		end
	else
		disableGlobal(self, element)
		disableHook(self, element)
	end
end

local function Enable(self)
	local element = self.GPS

	if element then
		element.UpdateState = UpdateState

		UpdateState(self)

		return true
	end
end

local function Disable(self)
	local element = self.GPS

	if element then
		UpdateState(self, true)
	end
end

oUF:AddElement("GPS", nil, Enable, Disable)