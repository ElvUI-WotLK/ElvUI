local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local format = string.format
--WoW API / Variables
local GetNumQuestWatches = GetNumQuestWatches
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestIndexForWatch = GetQuestIndexForWatch
local GetQuestLogTitle = GetQuestLogTitle
local hooksecurefunc = hooksecurefunc

S:AddCallback("Skin_WatchFrame", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.watchframe then return end

	-- WatchFrame Expand/Collapse Button
	WatchFrameCollapseExpandButton:StripTextures()
	WatchFrameCollapseExpandButton:Size(18)
	WatchFrameCollapseExpandButton.tex = WatchFrameCollapseExpandButton:CreateTexture(nil, "OVERLAY")
	WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.MinusButton)
	WatchFrameCollapseExpandButton.tex:SetInside()
	WatchFrameCollapseExpandButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
	WatchFrameCollapseExpandButton:SetFrameStrata("MEDIUM")
	WatchFrameCollapseExpandButton:Point("TOPRIGHT", 0, -2)

	hooksecurefunc("WatchFrame_Expand", function()
		WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.MinusButton)
		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	hooksecurefunc("WatchFrame_Collapse", function()
		WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.PlusButton)
		WatchFrame:Width(WATCHFRAME_EXPANDEDWIDTH)
	end)

	-- WatchFrame Text
	hooksecurefunc("WatchFrame_Update", function()
		local questIndex, title, level, color

		for i = 1, GetNumQuestWatches() do
			questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				title, level = GetQuestLogTitle(questIndex)
				color = GetQuestDifficultyColor(level)

				for j = 1, #WATCHFRAME_QUESTLINES do
					if WATCHFRAME_QUESTLINES[j].text:GetText() == title then
						WATCHFRAME_QUESTLINES[j].text:SetTextColor(color.r, color.g, color.b)
						WATCHFRAME_QUESTLINES[j].color = color
					end
				end
			end
		end

		for i = 1, #WATCHFRAME_ACHIEVEMENTLINES do
			WATCHFRAME_ACHIEVEMENTLINES[i].color = nil
		end

		-- WatchFrame Items
		for i = 1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]

			if button and not button.isSkinned then
				local icon = _G["WatchFrameItem"..i.."IconTexture"]
				local normal = _G["WatchFrameItem"..i.."NormalTexture"]
				local cooldown = _G["WatchFrameItem"..i.."Cooldown"]

				button:CreateBackdrop()
				button.backdrop:SetAllPoints()
				button:StyleButton()
				button:Size(25)

				normal:SetAlpha(0)

				icon:SetInside()
				icon:SetTexCoord(unpack(E.TexCoords))

				E:RegisterCooldown(cooldown)

				button.isSkinned = true
			end
		end
	end)

	-- WatchFrame Highlight
	hooksecurefunc("WatchFrameLinkButtonTemplate_Highlight", function(self, onEnter)
		local line

		for index = self.startLine, self.lastLine do
			line = self.lines[index]

			if line then
				if index == self.startLine then
					if onEnter then
						line.text:SetTextColor(1, 0.80, 0.10)
					else
						if line.color then
							line.text:SetTextColor(line.color.r, line.color.g, line.color.b)
						else
							line.text:SetTextColor(0.75, 0.61, 0)
						end
					end
				end
			end
		end
	end)

	-- WatchFrame POI Buttons
	local function poi_OnEnter(self)
		self.bg:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end

	local function poi_OnLeave(self)
		self.bg:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end

	hooksecurefunc("QuestPOI_DisplayButton", function(parentName, buttonType, buttonIndex)
		local poiButton = _G[format("poi%s%s_%d", parentName, buttonType, buttonIndex)]

		if poiButton and parentName == "WatchFrameLines" then
			if not poiButton.isSkinned then
				poiButton.normalTexture:SetTexture("")
				poiButton.pushedTexture:SetTexture("")
				poiButton.highlightTexture:SetTexture("")
				poiButton.selectionGlow:SetTexture("")

				poiButton:SetScale(1)
				poiButton:SetHitRectInsets(6, 6, 6, 6)

				poiButton.bg = CreateFrame("Frame", nil, poiButton)
				poiButton.bg:SetTemplate("Default", true)
				poiButton.bg:Point("TOPLEFT", 6, -6)
				poiButton.bg:Point("BOTTOMRIGHT", -6, 6)
				poiButton.bg:SetFrameLevel(poiButton.bg:GetFrameLevel() - 1)

				poiButton:HookScript("OnEnter", poi_OnEnter)
				poiButton:HookScript("OnLeave", poi_OnLeave)

				poiButton.isSkinned = true
			end
		end
	end)

	hooksecurefunc("QuestPOI_SelectButton", function(poiButton)
		if poiButton and poiButton.bg then
			poiButton.bg:SetBackdropColor(unpack(E.media.rgbvaluecolor))
		end
	end)

	hooksecurefunc("QuestPOI_DeselectButton", function(poiButton)
		if poiButton and poiButton.bg then
			poiButton.bg:SetBackdropColor(unpack(E.media.backdropcolor))
		end
	end)
end)