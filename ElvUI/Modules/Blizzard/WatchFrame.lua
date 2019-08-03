local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
local min = math.min
--WoW API / Variables
local GetScreenHeight = GetScreenHeight

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
	WatchFrameHolder:Size(150, 22)
	WatchFrameHolder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -135, -300)

	E:CreateMover(WatchFrameHolder, "WatchFrameMover", L["Watch Frame"])
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
end