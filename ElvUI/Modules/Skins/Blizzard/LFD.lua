local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local find = string.find
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetLFGDungeonRewardLink = GetLFGDungeonRewardLink
local GetLFGDungeonRewards = GetLFGDungeonRewards
local hooksecurefunc = hooksecurefunc

S:AddCallback("Skin_LFD", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfd then return end

	LFDQueueFrame:StripTextures(true)
	LFDQueueFrame:CreateBackdrop("Transparent")
	LFDQueueFrame.backdrop:Point("TOPLEFT", 11, -12)
	LFDQueueFrame.backdrop:Point("BOTTOMRIGHT", -3, 4)

	S:HookScript(LFDParentFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "width", 341)
		S:SetBackdropHitRect(self, LFDQueueFrame.backdrop)
		S:Unhook(self, "OnShow")
	end)

	S:HandleCloseButton((LFDParentFrame:GetChildren()), LFDQueueFrame.backdrop)

	LFDParentFramePortrait:Kill()

	S:HandleCheckBox(LFDQueueFrameRoleButtonTank.checkButton)
	LFDQueueFrameRoleButtonTank.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonTank.checkButton:GetFrameLevel() + 2)
	S:HandleCheckBox(LFDQueueFrameRoleButtonHealer.checkButton)
	LFDQueueFrameRoleButtonHealer.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonHealer.checkButton:GetFrameLevel() + 2)
	S:HandleCheckBox(LFDQueueFrameRoleButtonDPS.checkButton)
	LFDQueueFrameRoleButtonDPS.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonDPS.checkButton:GetFrameLevel() + 2)
	S:HandleCheckBox(LFDQueueFrameRoleButtonLeader.checkButton)
	LFDQueueFrameRoleButtonLeader.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonLeader.checkButton:GetFrameLevel() + 2)

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	LFDQueueFrameTypeDropDown:HookScript("OnShow", function(self) self:Width(200) end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton"..i]
		button.enableButton:StripTextures()
		button.enableButton:CreateBackdrop("Default")
		button.enableButton.backdrop:SetInside(nil, 4, 4)

		button.expandOrCollapseButton:SetNormalTexture(E.Media.Textures.Plus)
		button.expandOrCollapseButton.SetNormalTexture = E.noop
		button.expandOrCollapseButton:GetNormalTexture():Size(16)

		button.expandOrCollapseButton:SetHighlightTexture(nil)

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Minus)
			elseif find(texture, "PlusButton") then
				self:GetNormalTexture():SetTexture(E.Media.Textures.Plus)
			end
		end)
	end

	LFDQueueFrameSpecificListScrollFrame:StripTextures()
	S:HandleScrollBar(LFDQueueFrameRandomScrollFrameScrollBar)
	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

	S:HandleButton(LFDQueueFrameFindGroupButton)
	S:HandleButton(LFDQueueFrameCancelButton)

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)

	S:HandleButton(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)

	LFDQueueFrameRandomScrollFrameScrollBar:Point("TOPLEFT", LFDQueueFrameRandomScrollFrame, "TOPRIGHT", 5, -22)
	LFDQueueFrameRandomScrollFrameScrollBar:Point("BOTTOMLEFT", LFDQueueFrameRandomScrollFrame, "BOTTOMRIGHT", 5, 19)

	LFDQueueFrameSpecificListScrollFrameScrollBar:Point("TOPLEFT", LFDQueueFrameSpecificListScrollFrame, "TOPRIGHT", 5, -17)
	LFDQueueFrameSpecificListScrollFrameScrollBar:Point("BOTTOMLEFT", LFDQueueFrameSpecificListScrollFrame, "BOTTOMRIGHT", 5, 17)

	LFDQueueFrameFindGroupButton:Point("BOTTOMLEFT", 19, 12)
	LFDQueueFrameCancelButton:Point("BOTTOMRIGHT", -11, 12)

	LFDQueueFrameTypeDropDown:Point("TOPLEFT", 152, -119)

	LFDQueueFrameSpecificListButton1:Point("TOPLEFT", 25, -154)
	LFDQueueFrameRandomScrollFrame:Point("BOTTOMRIGHT", -34, 41)

	LFDQueueFrameCooldownFrame:Size(325, 259)
	LFDQueueFrameCooldownFrame:Point("BOTTOMRIGHT", LFDQueueFrame, "BOTTOMRIGHT", -11, 37)

	LFDQueueFrameCooldownFrame:HookScript("OnShow", function(self)
		self:SetFrameLevel(self:GetParent():GetFrameLevel() + 5)
	end)

	local function skinLFDRandomDungeonLoot(frame)
		if frame.isSkinned then return end

		local icon = _G[frame:GetName().."IconTexture"]
		local nameFrame = _G[frame:GetName().."NameFrame"]
		local count = _G[frame:GetName().."Count"]

		frame:StripTextures()
		frame:CreateBackdrop("Transparent")
		frame.backdrop:SetOutside(icon)

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetDrawLayer("BORDER")
		icon:SetParent(frame.backdrop)

		nameFrame:SetSize(118, 39)

		count:SetParent(frame.backdrop)

		frame.isSkinned = true
	end

	local function getLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		local _, link = GetLFGDungeonRewardLink(dungeonID, rewardIndex)

		if not link then
			E.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			E.ScanTooltip:SetLFGDungeonReward(dungeonID, rewardIndex)
			_, link = E.ScanTooltip:GetItem()
			E.ScanTooltip:Hide()
		end

		return link
	end

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
		local dungeonID = LFDQueueFrame.type
		if not dungeonID then return end

		local _, _, _, _, _, numRewards = GetLFGDungeonRewards(dungeonID)
		for i = 1, numRewards do
			local frame = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
			local name = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Name"]

			skinLFDRandomDungeonLoot(frame)

			local link = getLFGDungeonRewardLinkFix(dungeonID, i)
			if link then
				local _, _, quality = GetItemInfo(link)
				if quality then
					local r, g, b = GetItemQualityColor(quality)
					frame.backdrop:SetBackdropBorderColor(r, g, b)
					name:SetTextColor(r, g, b)
				end
			else
				frame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				name:SetTextColor(1, 1, 1)
			end
		end
	end)

	-- LFDDungeonReadyStatus
	LFDDungeonReadyStatus:SetTemplate("Transparent")
	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, "-")

	LFDSearchStatus:SetTemplate("Transparent")

	-- LFDRoleCheckPopup
	LFDRoleCheckPopup:SetTemplate("Transparent")

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton)

	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	-- LFDDungeonReadyDialog
	LFDDungeonReadyDialog:SetTemplate("Transparent")

	LFDDungeonReadyDialog.label:Size(280, 0)
	LFDDungeonReadyDialog.label:Point("TOP", 0, -10)

	LFDDungeonReadyDialog:CreateBackdrop("Default")
	LFDDungeonReadyDialog.backdrop:Point("TOPLEFT", 10, -35)
	LFDDungeonReadyDialog.backdrop:Point("BOTTOMRIGHT", -10, 40)

	LFDDungeonReadyDialog.backdrop:SetFrameLevel(LFDDungeonReadyDialog:GetFrameLevel())
	LFDDungeonReadyDialog.background:SetInside(LFDDungeonReadyDialog.backdrop)

	LFDDungeonReadyDialogFiligree:SetTexture("")
	LFDDungeonReadyDialogBottomArt:SetTexture("")

	S:HandleCloseButton(LFDDungeonReadyDialogCloseButton, nil, "-")

	LFDDungeonReadyDialogEnterDungeonButton:Point("BOTTOMRIGHT", LFDDungeonReadyDialog, "BOTTOM", -7, 10)
	S:HandleButton(LFDDungeonReadyDialogEnterDungeonButton)
	LFDDungeonReadyDialogLeaveQueueButton:Point("BOTTOMLEFT", LFDDungeonReadyDialog, "BOTTOM", 7, 10)
	S:HandleButton(LFDDungeonReadyDialogLeaveQueueButton)

--[[
	LFDDungeonReadyDialogRoleIcon:Size(57)
	LFDDungeonReadyDialogRoleIcon:Point("BOTTOM", 1, 54)
	LFDDungeonReadyDialogRoleIcon:SetTemplate("Default")
	LFDDungeonReadyDialogRoleIconTexture:SetInside()

	function GetTexCoordsForRole(role)
		if role == "GUIDE" then
			return 0.0625, 0.1953125, 0.05859375, 0.19140625
		elseif role == "TANK" then
			return 0.0625, 0.1953125, 0.3203125, 0.453125
		elseif role == "HEALER" ) then
			return 0.32421875, 0.45703125, 0.0546875, 0.1875
		elseif role == "DAMAGER" then
			return 0.32421875, 0.453125, 0.31640625, 0.4453125
		end
	end
	GameTooltip:SetLFGDungeonReward(287, 1)
--]]

	local function skinLFDDungeonReadyDialogReward(button)
		if button.isSkinned then return end

		button:Size(28)
		button:SetTemplate("Default")
		button.texture:SetInside()
		button.texture:SetTexCoord(unpack(E.TexCoords))
		button:DisableDrawLayer("OVERLAY")

		button.isSkinned = true
	end

	hooksecurefunc("LFDDungeonReadyDialogReward_SetMisc", function(button)
		skinLFDDungeonReadyDialogReward(button)

		SetPortraitToTexture(button.texture, "")
		button.texture:SetTexture("Interface\\Icons\\inv_misc_coin_02")
	end)

	hooksecurefunc("LFDDungeonReadyDialogReward_SetReward", function(button, dungeonID, rewardIndex)
		skinLFDDungeonReadyDialogReward(button)

		local link = getLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		if link then
			local _, _, quality = GetItemInfo(link)
			button:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		local texturePath = button.texture:GetTexture()
		if texturePath then
			SetPortraitToTexture(button.texture, "")
			button.texture:SetTexture(texturePath)
		end
	end)
end)