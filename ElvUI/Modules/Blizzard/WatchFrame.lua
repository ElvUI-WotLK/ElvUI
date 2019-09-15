local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
local min = math.min
--WoW API / Variables
local GetScreenHeight = GetScreenHeight

local hideRule = "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists]"

function B:SetObjectiveFrameAutoHide()
	if E.db.general.watchFrameAutoHide then
		RegisterStateDriver(WatchFrame, "visibility", hideRule)
	else
		UnregisterStateDriver(WatchFrame, "visibility")
	end
end

function B:SetWatchFrameHeight()
	local top = WatchFrame:GetTop() or 0
	local screenHeight = GetScreenHeight()
	local gapFromTop = screenHeight - top
	local maxHeight = screenHeight - gapFromTop
	local watchFrameHeight = min(maxHeight, E.db.general.watchFrameHeight)

	WatchFrame:Height(watchFrameHeight)
end

function B:MoveWatchFrame()
	local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
	WatchFrameHolder:Size(207, 22)
	WatchFrameHolder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -300)

	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Objective Frame"], nil, nil, nil, nil, nil, "general,objectiveFrameGroup")
	WatchFrameHolder:SetAllPoints(WatchFrameMover)

	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
	B:SetWatchFrameHeight()
	WatchFrame:SetClampedToScreen(false)

	hooksecurefunc(WatchFrame, "SetPoint", function(_, _, parent)
		if parent ~= WatchFrameHolder then
			WatchFrame:ClearAllPoints()
			WatchFrame:SetPoint("TOP", WatchFrameHolder, "TOP")
		end
	end)

	self:SetObjectiveFrameAutoHide()
end