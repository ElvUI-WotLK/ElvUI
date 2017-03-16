local E, L, DF = unpack(select(2, ...))
local B = E:GetModule("Blizzard");

local _G = _G;
local pairs = pairs;

local AlertFrame_FixAnchors = AlertFrame_FixAnchors;
local MAX_ACHIEVEMENT_ALERTS = MAX_ACHIEVEMENT_ALERTS;
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES;

local AlertFrameHolder = CreateFrame("Frame", "AlertFrameHolder", E.UIParent);
AlertFrameHolder:SetWidth(250);
AlertFrameHolder:SetHeight(20);
AlertFrameHolder:SetPoint("TOP", E.UIParent, "TOP", 0, -18);

local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10

function E:PostAlertMove(screenQuadrant)
	local _, y = AlertFrameMover:GetCenter();
	local screenHeight = E.UIParent:GetTop();
	if y > (screenHeight / 2) then
		POSITION = "TOP";
		ANCHOR_POINT = "BOTTOM";
		YOFFSET = -10;
		AlertFrameMover:SetText(AlertFrameMover.textString .. " [Grow Down]");
	else
		POSITION = "BOTTOM";
		ANCHOR_POINT = "TOP";
		YOFFSET = 10;
		AlertFrameMover:SetText(AlertFrameMover.textString .. " [Grow Up]");
	end

	local rollBars = E:GetModule("Misc").RollBars;
	if E.private.general.lootRoll then
		local lastframe, lastShownFrame;
		for i, frame in pairs(rollBars) do
			frame:ClearAllPoints();
			if i ~= 1 then
				if POSITION == "TOP" then
					frame:Point("TOP", lastframe, "BOTTOM", 0, -4);
				else
					frame:Point("BOTTOM", lastframe, "TOP", 0, 4);
				end
			else
				if POSITION == "TOP" then
					frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4);
				else
					frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4);
				end
			end
			lastframe = frame;

			if frame:IsShown() then
				lastShownFrame = frame;
			end
		end

		AlertFrame:ClearAllPoints();
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame);
		else
			AlertFrame:SetAllPoints(AlertFrameHolder);
		end
	elseif(E.private.skins.blizzard.enable and E.private.skins.blizzard.lootRoll) then
		local lastframe, lastShownFrame;
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			local frame = _G["GroupLootFrame" .. i];
			if(frame) then
				frame:ClearAllPoints();
				if i ~= 1 then
					if POSITION == "TOP" then
						frame:Point("TOP", lastframe, "BOTTOM", 0, -4);
					else
						frame:Point("BOTTOM", lastframe, "TOP", 0, 4);
					end
				else
					if POSITION == "TOP" then
						frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4);
					else
						frame:Point("BOTTOM", AlertFrameHolder, "TOP", 0, 4);
					end
				end
				lastframe = frame;

				if frame:IsShown() then
					lastShownFrame = frame;
				end
			end
		end

		AlertFrame:ClearAllPoints();
		if lastShownFrame then
			AlertFrame:SetAllPoints(lastShownFrame);
		else
			AlertFrame:SetAllPoints(AlertFrameHolder);
		end
	else
		AlertFrame:ClearAllPoints();
		AlertFrame:SetAllPoints(AlertFrameHolder);
	end

	if screenQuadrant then
		AlertFrame_FixAnchors();
	end
end

function B:AchievementAlertFrame_FixAnchors()
	local alertAnchor;
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		local frame = _G["AchievementAlertFrame"..i];
		if (frame) then
			frame:ClearAllPoints();
			if (alertAnchor and alertAnchor:IsShown()) then
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			else
				frame:SetPoint(POSITION, AlertFrame, ANCHOR_POINT);
			end

			alertAnchor = frame;
		end
	end
end

function B:DungeonCompletionAlertFrame_FixAnchors()
	for i = MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		local frame = _G["AchievementAlertFrame"..i]
		if (frame and frame:IsShown()) then
			DungeonCompletionAlertFrame1:ClearAllPoints();
			DungeonCompletionAlertFrame1:Point(POSITION, frame, ANCHOR_POINT, 0, YOFFSET);
			return;
		end

		DungeonCompletionAlertFrame1:ClearAllPoints();
		DungeonCompletionAlertFrame1:Point(POSITION, AlertFrame, ANCHOR_POINT);
	end
end

function B:AlertMovers()
	self:SecureHook("AlertFrame_FixAnchors", E.PostAlertMove)
	self:SecureHook("AchievementAlertFrame_FixAnchors")
	self:SecureHook("DungeonCompletionAlertFrame_FixAnchors")

	E:CreateMover(AlertFrameHolder, "AlertFrameMover", L["Loot / Alert Frames"], nil, nil, E.PostAlertMove);
end