local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
local select, unpack = select, unpack
local find = string.find
--WoW API / Variables
local GetLFGDungeonRewardLink = GetLFGDungeonRewardLink
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetItemInfo = GetItemInfo

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfd ~= true then return end

	LFDDungeonReadyStatus:SetTemplate("Transparent")

	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, "-")

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

	--[[LFDDungeonReadyDialogRoleIcon:Size(57)
	LFDDungeonReadyDialogRoleIcon:ClearAllPoints()
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
	GameTooltip:SetLFGDungeonReward(287, 1)]]

	local scan
	local function GetLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		local _, link = GetLFGDungeonRewardLink(dungeonID, rewardIndex)
		if not link then
			if not scan then
				scan = CreateFrame("GameTooltip", "DungeonRewardLinkScan", nil, "GameTooltipTemplate")
				scan:SetOwner(UIParent, "ANCHOR_NONE")
			end
			scan:ClearLines()
			scan:SetLFGDungeonReward(dungeonID, rewardIndex)
			_, link = scan:GetItem()
		end
		return link
	end

	local function SkinLFDDungeonReadyDialogReward(button)
		if button.isSkinned then return end

		button:Size(28)
		button:SetTemplate("Default")
		button.texture:SetInside()
		button.texture:SetTexCoord(unpack(E.TexCoords))
		button:DisableDrawLayer("OVERLAY")
		button.isSkinned = true
	end

	hooksecurefunc("LFDDungeonReadyDialogReward_SetMisc", function(button)
		SkinLFDDungeonReadyDialogReward(button)

		SetPortraitToTexture(button.texture, "")
		button.texture:SetTexture("Interface\\Icons\\inv_misc_coin_02")
	end)

	hooksecurefunc("LFDDungeonReadyDialogReward_SetReward", function(button, dungeonID, rewardIndex)
		SkinLFDDungeonReadyDialogReward(button)

		local link = GetLFGDungeonRewardLinkFix(dungeonID, rewardIndex)
		if link then
			local _, _, quality = GetItemInfo(link)
			button:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			button:SetBackdropBorderColor(unpack(E["media"].bordercolor))
		end

		local texturePath = button.texture:GetTexture()
		if texturePath then
			SetPortraitToTexture(button.texture, "")
			button.texture:SetTexture(texturePath)
		end
	end)

	LFDRoleCheckPopup:SetTemplate("Transparent")

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton)

	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	LFDSearchStatus:SetTemplate("Transparent")

	LFDQueueFrame:StripTextures(true)
	LFDQueueFrame:CreateBackdrop("Transparent")
	LFDQueueFrame.backdrop:Point("TOPLEFT", 10, -11)
	LFDQueueFrame.backdrop:Point("BOTTOMRIGHT", -1, 0)

	LFDParentFramePortrait:Kill()

	for i = 1, LFDParentFrame:GetNumChildren() do
		local child = select(i, LFDParentFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

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
	LFDQueueFrameTypeDropDown:Point("TOPLEFT", 151, -125)

	local function SkinLFDRandomDungeonLoot(frame)
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

	hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", function()
		local dungeonID = LFDQueueFrame.type
		if not dungeonID then return end

		local _, _, _, _, _, numRewards = GetLFGDungeonRewards(dungeonID)
		for i = 1, numRewards do
			local frame = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
			SkinLFDRandomDungeonLoot(frame)

			local link = GetLFGDungeonRewardLinkFix(dungeonID, i)
			if link then
				local _, _, quality = GetItemInfo(link)
				if quality then
					frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
				end
			else
				frame.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
			end
		end
	end)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton" .. i]
		button.enableButton:StripTextures()
		button.enableButton:CreateBackdrop("Default")
		button.enableButton.backdrop:SetInside(nil, 4, 4)

		button.expandOrCollapseButton:SetNormalTexture("")
		button.expandOrCollapseButton.SetNormalTexture = E.noop
		button.expandOrCollapseButton:SetHighlightTexture(nil)

		button.expandOrCollapseButton.Text = button.expandOrCollapseButton:CreateFontString(nil, "OVERLAY")
		button.expandOrCollapseButton.Text:FontTemplate(nil, 22)
		button.expandOrCollapseButton.Text:Point("CENTER", 4, 0)
		button.expandOrCollapseButton.Text:SetText("+")

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			if find(texture, "MinusButton") then
				self.Text:SetText("-")
			else
				self.Text:SetText("+")
			end
		end)
	end

	LFDQueueFrameSpecificListScrollFrame:StripTextures()
	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

	S:HandleButton(LFDQueueFrameFindGroupButton)
	S:HandleButton(LFDQueueFrameCancelButton)

	hooksecurefunc("LFDQueueFrameRandomCooldownFrame_Update", function()
		if LFDQueueFrameCooldownFrame:IsShown() then
			LFDQueueFrameCooldownFrame:SetFrameLevel(LFDQueueFrameCooldownFrame:GetParent():GetFrameLevel() + 5)
		end
	end)

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)

	S:HandleButton(LFDQueueFrameNoLFDWhileLFRLeaveQueueButton)
end

S:AddCallback("LFD", LoadSkin)