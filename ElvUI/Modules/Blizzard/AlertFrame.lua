local E, L = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule("Blizzard")
local Misc = E:GetModule("Misc")

--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

function E:PostAlertMove()
	local _, y = AlertFrameMover:GetCenter()
	local screenHeight = E.UIParent:GetTop()
	if y > (screenHeight / 2) then
		POSITION = "TOP"
		ANCHOR_POINT = "BOTTOM"
		YOFFSET = -10
		AlertFrameMover:SetText(AlertFrameMover.textString.." [Grow Down]")
	else
		POSITION = "BOTTOM"
		ANCHOR_POINT = "TOP"
		YOFFSET = 10
		AlertFrameMover:SetText(AlertFrameMover.textString.." [Grow Up]")
	end

	if E.private.general.lootRoll then
		local lastframe, lastShownFrame
		for i, frame in pairs(Misc.RollBars) do
			frame:ClearAllPoints()
			if i ~= 1 then
				if POSITION == "TOP" then
					frame:Point("TOP", lastframe, "BOTTOM", 0, -4)
				else
					frame:Point("BOTTOM", lastframe, "TOP", 0, 4)
				end
			else
				if POSITION == "TOP" then
					frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
				else
					frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4)
				end
			end
			lastframe = frame

			if frame:IsShown() then
				lastShownFrame = frame
			end
		end

		AlertFrame:ClearAllPoints()
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
		end
	elseif E.private.skins.blizzard.enable and E.private.skins.blizzard.lootRoll then
		local lastframe, lastShownFrame
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame"..i]
			if frame then
				frame:ClearAllPoints()
				if i ~= 1 then
					if POSITION == "TOP" then
						frame:Point("TOP", lastframe, "BOTTOM", 0, -4)
					else
						frame:Point("BOTTOM", lastframe, "TOP", 0, 4)
					end
				else
					if POSITION == "TOP" then
						frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
					else
						frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4)
					end
				end
				lastframe = frame

				if frame:IsShown() then
					lastShownFrame = frame
				end
			end
		end

		AlertFrame:ClearAllPoints()
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame)
		else
			AlertFrame:SetAllPoints(AlertFrameHolder)
		end
	else
		AlertFrame:ClearAllPoints()
		AlertFrame:SetAllPoints(AlertFrameHolder)
	end
end

function B:AchievementAlertFrame_FixAnchors()
	local alertAnchor
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		local frame = _G["AchievementAlertFrame"..i]
		if frame then
			frame:ClearAllPoints()
			if alertAnchor and alertAnchor:IsShown() then
				frame:Point(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET)
			else
				frame:Point(POSITION, AlertFrame, ANCHOR_POINT)
			end

			alertAnchor = frame
		end
	end
end

function B:DungeonCompletionAlertFrame_FixAnchors()
	for i = MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		local frame = _G["AchievementAlertFrame"..i]
		if frame and frame:IsShown() then
			DungeonCompletionAlertFrame1:ClearAllPoints()
			DungeonCompletionAlertFrame1:Point(POSITION, frame, ANCHOR_POINT, 0, YOFFSET)
			return
		end

		DungeonCompletionAlertFrame1:ClearAllPoints()
		DungeonCompletionAlertFrame1:Point(POSITION, AlertFrame, ANCHOR_POINT)
	end
end

function B:AlertMovers()
	local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent)
	AlertFrameHolder:Size(250, 20)
	AlertFrameHolder:Point("TOP", E.UIParent, "TOP", 0, -18)

	self:SecureHook("AlertFrame_FixAnchors", E.PostAlertMove)
	self:SecureHook("AchievementAlertFrame_FixAnchors")
	self:SecureHook("DungeonCompletionAlertFrame_FixAnchors")

	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove, nil, nil, "general,blizzUIImprovements")
end