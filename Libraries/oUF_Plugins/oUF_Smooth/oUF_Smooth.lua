local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "<name> was unable to locate oUF install.")

local smoothing = {}
local function Smooth(self, value)
	local _, max = self:GetMinMaxValues()
	if value == self:GetValue() or (self._max and self._max ~= max) then
		smoothing[self] = nil
		self:SetValue_(value)
	else
		smoothing[self] = value
	end
	self._max = max
end

local function SmoothBar(bar)
	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue;
		bar.SetValue = Smooth;
	end
end

local function hook(frame)
	if frame.Health then
		SmoothBar(frame.Health)
	end
	if frame.Power then
		SmoothBar(frame.Power)
	end
end

for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

local f, min, max = CreateFrame("Frame"), math.min, math.max
f:SetScript("OnUpdate", function()
	local limit = 30/GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/(bar.SmoothSpeed or 3), max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if (cur == value or abs(new - value) < 2) and bar.Smooth then
			bar:SetValue_(value)
			smoothing[bar] = nil
		elseif not bar.Smooth then
			bar:SetValue_(value)
			smoothing[bar] = nil
		end
	end
end)