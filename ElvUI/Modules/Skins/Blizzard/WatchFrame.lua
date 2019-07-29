local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local _G = _G
local unpack = unpack

local WATCHFRAME_EXPANDEDWIDTH = WATCHFRAME_EXPANDEDWIDTH

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.watchframe ~= true then return end

	-- WatchFrame Expand/Collapse Button
	WatchFrameCollapseExpandButton:StripTextures()
	WatchFrameCollapseExpandButton:Size(16, 16)
	WatchFrameCollapseExpandButton.tex = WatchFrameCollapseExpandButton:CreateTexture(nil, "OVERLAY")
	WatchFrameCollapseExpandButton.tex:SetTexture(E.Media.Textures.MinusButton)
	WatchFrameCollapseExpandButton.tex:SetInside()
	WatchFrameCollapseExpandButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
	WatchFrameCollapseExpandButton:SetFrameStrata("MEDIUM")
	WatchFrameCollapseExpandButton:Point("TOPRIGHT", -20, 4)

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
		local questIndex
		local numQuestWatches = GetNumQuestWatches()

		local title, level
		local color
		for i = 1, numQuestWatches do
			questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				title, level = GetQuestLogTitle(questIndex)
				color = GetQuestDifficultyColor(level)
--[[
				local hex = E:RGBToHex(color.r, color.g, color.b)

				if questTag == ELITE then
					level = level.."+"
				elseif questTag == LFG_TYPE_DUNGEON then
					level = level.." D"
				elseif questTag == PVP then
					level = level.." PvP"
				elseif questTag == RAID then
					level = level.." R"
				elseif questTag == GROUP then
					level = level.." G"
				elseif questTag == PLAYER_DIFFICULTY2 then
					level = level.." HC"
				end

				local titleText = hex.."["..level.."]|r "..title
]]
				for j = 1, #WATCHFRAME_QUESTLINES do
					if WATCHFRAME_QUESTLINES[j].text:GetText() == title then
						--WATCHFRAME_QUESTLINES[j].text:SetText(titleText)
						WATCHFRAME_QUESTLINES[j].text:SetTextColor(color.r, color.g, color.b)
						WATCHFRAME_QUESTLINES[j].color = color
					end
				end

				for k = 1, #WATCHFRAME_ACHIEVEMENTLINES do
					WATCHFRAME_ACHIEVEMENTLINES[k].color = nil
				end
			end
		end

		-- WatchFrame Items
		for i = 1, WATCHFRAME_NUM_ITEMS do
			local button = _G["WatchFrameItem"..i]
			local icon = _G["WatchFrameItem"..i.."IconTexture"]
			local normal = _G["WatchFrameItem"..i.."NormalTexture"]
			local cooldown = _G["WatchFrameItem"..i.."Cooldown"]
			if not button.isSkinned then
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
	hooksecurefunc("QuestPOI_DisplayButton", function(parentName, buttonType, buttonIndex)
		local buttonName = "poi"..parentName..buttonType.."_"..buttonIndex
		local poiButton = _G[buttonName]

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

				poiButton:HookScript("OnEnter", function(self)
					self.bg:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
				end)
				poiButton:HookScript("OnLeave", function(self)
					self.bg:SetBackdropBorderColor(unpack(E["media"].bordercolor))
				end)

				poiButton.isSkinned = true
			end
		end
	end)

	hooksecurefunc("QuestPOI_SelectButton", function(poiButton)
		if poiButton and poiButton.bg then
			poiButton.bg:SetBackdropColor(unpack(E["media"].rgbvaluecolor))
		end
	end)

	hooksecurefunc("QuestPOI_DeselectButton", function(poiButton)
		if poiButton and poiButton.bg then
			poiButton.bg:SetBackdropColor(unpack(E["media"].backdropcolor))
		end
	end)
end

S:AddCallback("WatchFrame", LoadSkin)