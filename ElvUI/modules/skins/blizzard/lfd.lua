local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G
local unpack = unpack
local find = string.find;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfd ~= true then return end

	LFDParentFrame:StripTextures(true);

	LFDQueueFrame:StripTextures(true);
	LFDQueueFrame:CreateBackdrop("Transparent")
	LFDQueueFrame.backdrop:Point("TOPLEFT", 10, -11)
	LFDQueueFrame.backdrop:Point("BOTTOMRIGHT", -1, 0)

	LFDParentFramePortrait:Kill()

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown)
	LFDQueueFrameTypeDropDown:Point("TOPLEFT", LFDQueueFrame, "TOPLEFT", 115, -125)

	for i = 1, LFDParentFrame:GetNumChildren() do
		local child = select(i, LFDParentFrame:GetChildren())
		if(child.GetPushedTexture and child:GetPushedTexture() and not child:GetName()) then
			S:HandleCloseButton(child)
		end
	end

	S:HandleButton(LFDQueueFrameFindGroupButton, true)
	S:HandleButton(LFDQueueFrameCancelButton, true)

	local tankIcon = "Interface\\Icons\\Ability_Defend"
	local healerIcon = "Interface\\Icons\\SPELL_NATURE_HEALINGTOUCH"
	local damagerIcon = "Interface\\Icons\\Ability_Warrior_PunishingBlow"
	local leaderIcon = "Interface\\Icons\\Ability_Vehicle_LaunchPlayer"

	S:HandleCheckBox(LFDQueueFrameRoleButtonTank.checkButton)
	S:HandleCheckBox(LFDQueueFrameRoleButtonHealer.checkButton)
	S:HandleCheckBox(LFDQueueFrameRoleButtonDPS.checkButton)
	S:HandleCheckBox(LFDQueueFrameRoleButtonLeader.checkButton)

	LFDQueueFrameRoleButtonTank.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonTank.checkButton:GetFrameLevel() + 2)
	LFDQueueFrameRoleButtonHealer.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonHealer.checkButton:GetFrameLevel() + 2)
	LFDQueueFrameRoleButtonDPS.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonDPS.checkButton:GetFrameLevel() + 2)
	LFDQueueFrameRoleButtonLeader.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonLeader.checkButton:GetFrameLevel() + 2)

	LFDQueueFrameRoleButtonTank:Point("TOPLEFT", LFDQueueFrame, "TOPLEFT", 40, -60)
	LFDQueueFrameRoleButtonHealer:Point("LEFT", LFDQueueFrameRoleButtonTank,"RIGHT", 23, 0)
	LFDQueueFrameRoleButtonLeader:Point("LEFT", LFDQueueFrameRoleButtonDPS, "RIGHT", 50, 0)

	LFDQueueFrameRoleButtonTank:StripTextures()
	LFDQueueFrameRoleButtonTank:CreateBackdrop()
	LFDQueueFrameRoleButtonTank.backdrop:Point("TOPLEFT", 3, -3)
	LFDQueueFrameRoleButtonTank.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LFDQueueFrameRoleButtonTank.icon = LFDQueueFrameRoleButtonTank:CreateTexture(nil, "OVERLAY");
	LFDQueueFrameRoleButtonTank.icon:SetTexCoord(unpack(E.TexCoords))
	LFDQueueFrameRoleButtonTank.icon:SetTexture(tankIcon);
	LFDQueueFrameRoleButtonTank.icon:SetInside(LFDQueueFrameRoleButtonTank.backdrop)

	LFDQueueFrameRoleButtonHealer:StripTextures()
	LFDQueueFrameRoleButtonHealer:CreateBackdrop()
	LFDQueueFrameRoleButtonHealer.backdrop:Point("TOPLEFT", 3, -3)
	LFDQueueFrameRoleButtonHealer.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LFDQueueFrameRoleButtonHealer.icon = LFDQueueFrameRoleButtonHealer:CreateTexture(nil, "OVERLAY");
	LFDQueueFrameRoleButtonHealer.icon:SetTexCoord(unpack(E.TexCoords))
	LFDQueueFrameRoleButtonHealer.icon:SetTexture(healerIcon);
	LFDQueueFrameRoleButtonHealer.icon:SetInside(LFDQueueFrameRoleButtonHealer.backdrop)

	LFDQueueFrameRoleButtonDPS:StripTextures()
	LFDQueueFrameRoleButtonDPS:CreateBackdrop()
	LFDQueueFrameRoleButtonDPS.backdrop:Point("TOPLEFT", 3, -3)
	LFDQueueFrameRoleButtonDPS.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LFDQueueFrameRoleButtonDPS.icon = LFDQueueFrameRoleButtonDPS:CreateTexture(nil, "OVERLAY");
	LFDQueueFrameRoleButtonDPS.icon:SetTexCoord(unpack(E.TexCoords))
	LFDQueueFrameRoleButtonDPS.icon:SetTexture(damagerIcon);
	LFDQueueFrameRoleButtonDPS.icon:SetInside(LFDQueueFrameRoleButtonDPS.backdrop)

	LFDQueueFrameRoleButtonLeader:StripTextures()
	LFDQueueFrameRoleButtonLeader:CreateBackdrop("Default")
	LFDQueueFrameRoleButtonLeader.backdrop:Point("TOPLEFT", 3, -3)
	LFDQueueFrameRoleButtonLeader.backdrop:Point("BOTTOMRIGHT", -3, 3)
	LFDQueueFrameRoleButtonLeader.icon = LFDQueueFrameRoleButtonLeader:CreateTexture(nil, "OVERLAY");
	LFDQueueFrameRoleButtonLeader.icon:SetTexCoord(unpack(E.TexCoords))
	LFDQueueFrameRoleButtonLeader.icon:SetTexture(leaderIcon);
	LFDQueueFrameRoleButtonLeader.icon:SetInside(LFDQueueFrameRoleButtonLeader.backdrop)

	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(button)
		if button.icon then
			button.icon:SetDesaturated(true)
		end
	end)

	hooksecurefunc("LFG_DisableRoleButton", function(button)
		if button.icon then
			button.icon:SetDesaturated(true)
		end
	end)

	hooksecurefunc("LFG_EnableRoleButton", function(button)
		if button.icon then
			button.icon:SetDesaturated(false)
		end
	end)

	-- LFD Rewards
	for i = 1, LFD_MAX_REWARDS do
		local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
		local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]
		local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
		local name  = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Name"]

		if button then
			button:StripTextures()
			button:CreateBackdrop()
			button.backdrop:SetOutside(icon)

			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetParent(button.backdrop)

			icon:SetDrawLayer("OVERLAY")
			count:SetDrawLayer("OVERLAY")

			if count then count:SetParent(button.backdrop) end
		end
	end

	-- LFD Cooldown Frame
	hooksecurefunc("LFDQueueFrameRandomCooldownFrame_Update", function()
		if LFDQueueFrameCooldownFrame:IsShown() then
			LFDQueueFrameCooldownFrame:SetFrameLevel(LFDQueueFrameCooldownFrame:GetParent():GetFrameLevel() + 5)
		end
	end)

	-- LFD Specific List
	LFDQueueFrameSpecific:StripTextures()

	LFDQueueFrameSpecificListScrollFrame:StripTextures()
	LFDQueueFrameSpecificListScrollFrame:Height(LFDQueueFrameSpecificListScrollFrame:GetHeight() - 8)

	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar)

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
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-")
			else
				self.Text:SetText("+")
			end
		end)
	end

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton)
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton)

	-- LFD Search Status
	LFDSearchStatus:SetTemplate("Transparent")

	LFDSearchStatusTank1:StripTextures()
	LFDSearchStatusTank1:CreateBackdrop("Default")
	LFDSearchStatusTank1.backdrop:Point("TOPLEFT", 5, -5)
	LFDSearchStatusTank1.backdrop:Point("BOTTOMRIGHT", -5, 5)
	LFDSearchStatusTank1.icon = LFDSearchStatusTank1:CreateTexture(nil, "OVERLAY")
	LFDSearchStatusTank1.icon:SetTexCoord(unpack(E.TexCoords))
	LFDSearchStatusTank1.icon:SetTexture(tankIcon)
	LFDSearchStatusTank1.icon:SetInside(LFDSearchStatusTank1.backdrop)

	LFDSearchStatusHealer1:StripTextures()
	LFDSearchStatusHealer1:CreateBackdrop("Default")
	LFDSearchStatusHealer1.backdrop:Point("TOPLEFT", 5, -5)
	LFDSearchStatusHealer1.backdrop:Point("BOTTOMRIGHT", -5, 5)
	LFDSearchStatusHealer1.icon = LFDSearchStatusHealer1:CreateTexture(nil, "OVERLAY")
	LFDSearchStatusHealer1.icon:SetTexCoord(unpack(E.TexCoords))
	LFDSearchStatusHealer1.icon:SetTexture(healerIcon)
	LFDSearchStatusHealer1.icon:SetInside(LFDSearchStatusHealer1.backdrop)

	for i = 1, 3 do
		local LFDSearchDPS = _G["LFDSearchStatusDamage"..i]
		LFDSearchDPS:StripTextures()
		LFDSearchDPS:CreateBackdrop("Default")
		LFDSearchDPS.backdrop:Point("TOPLEFT", 5, -5)
		LFDSearchDPS.backdrop:Point("BOTTOMRIGHT", -5, 5)
		LFDSearchDPS.icon = LFDSearchDPS:CreateTexture(nil, "OVERLAY")
		LFDSearchDPS.icon:SetTexCoord(unpack(E.TexCoords))
		LFDSearchDPS.icon:SetTexture(damagerIcon)
		LFDSearchDPS.icon:SetInside(LFDSearchDPS.backdrop)
	end

	hooksecurefunc("LFDSearchStatusPlayer_SetFound", function(button, isFound)
		if button.icon then
			if isFound then
				button.icon:SetDesaturated(false)
			else
				button.icon:SetDesaturated(true)
			end
		end
	end)

	hooksecurefunc("LFDSearchStatus_UpdateRoles", function()
		local _, tank, healer, damage = GetLFGRoles()
		local currentIcon = 1
		if tank then
			local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
			icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\tank.tga")
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(22)
			currentIcon = currentIcon + 1
		end
		if healer then
			local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
			icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\healer.tga")
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(20)
			currentIcon = currentIcon + 1
		end
		if damage then
			local icon = _G["LFDSearchStatusRoleIcon"..currentIcon]
			icon:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\dps.tga")
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Size(17)
			currentIcon = currentIcon + 1
		end
	end)

	-- LFD Role Check Popup
	LFDRoleCheckPopup:SetTemplate("Transparent")

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton)
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton)

	S:HandleButton(LFDRoleCheckPopupAcceptButton)
	S:HandleButton(LFDRoleCheckPopupDeclineButton)

	LFDRoleCheckPopupRoleButtonTank:StripTextures()
	LFDRoleCheckPopupRoleButtonTank:CreateBackdrop()
	LFDRoleCheckPopupRoleButtonTank.backdrop:Point("TOPLEFT", 7, -7)
	LFDRoleCheckPopupRoleButtonTank.backdrop:Point("BOTTOMRIGHT", -7, 7)
	LFDRoleCheckPopupRoleButtonTank.icon = LFDRoleCheckPopupRoleButtonTank:CreateTexture(nil, "OVERLAY")
	LFDRoleCheckPopupRoleButtonTank.icon:SetTexCoord(unpack(E.TexCoords))
	LFDRoleCheckPopupRoleButtonTank.icon:SetTexture(tankIcon)
	LFDRoleCheckPopupRoleButtonTank.icon:SetInside(LFDRoleCheckPopupRoleButtonTank.backdrop)

	LFDRoleCheckPopupRoleButtonHealer:StripTextures()
	LFDRoleCheckPopupRoleButtonHealer:CreateBackdrop()
	LFDRoleCheckPopupRoleButtonHealer.backdrop:Point("TOPLEFT", 7, -7)
	LFDRoleCheckPopupRoleButtonHealer.backdrop:Point("BOTTOMRIGHT", -7, 7)
	LFDRoleCheckPopupRoleButtonHealer.icon = LFDRoleCheckPopupRoleButtonHealer:CreateTexture(nil, "OVERLAY")
	LFDRoleCheckPopupRoleButtonHealer.icon:SetTexCoord(unpack(E.TexCoords))
	LFDRoleCheckPopupRoleButtonHealer.icon:SetTexture(healerIcon)
	LFDRoleCheckPopupRoleButtonHealer.icon:SetInside(LFDRoleCheckPopupRoleButtonHealer.backdrop)

	LFDRoleCheckPopupRoleButtonDPS:StripTextures()
	LFDRoleCheckPopupRoleButtonDPS:CreateBackdrop()
	LFDRoleCheckPopupRoleButtonDPS.backdrop:Point("TOPLEFT", 7, -7)
	LFDRoleCheckPopupRoleButtonDPS.backdrop:Point("BOTTOMRIGHT", -7, 7)
	LFDRoleCheckPopupRoleButtonDPS.icon = LFDRoleCheckPopupRoleButtonDPS:CreateTexture(nil, "OVERLAY")
	LFDRoleCheckPopupRoleButtonDPS.icon:SetTexCoord(unpack(E.TexCoords))
	LFDRoleCheckPopupRoleButtonDPS.icon:SetTexture(damagerIcon)
	LFDRoleCheckPopupRoleButtonDPS.icon:SetInside(LFDRoleCheckPopupRoleButtonDPS.backdrop)

	-- LFD Dungeon Ready Dialog
	LFDDungeonReadyDialogBackground:Kill()
	LFDDungeonReadyDialog:StripTextures()
	LFDDungeonReadyDialog:SetTemplate("Transparent")
	LFDDungeonReadyDialog.SetBackdrop = E.noop

	S:HandleButton(LFDDungeonReadyDialogEnterDungeonButton)
	S:HandleButton(LFDDungeonReadyDialogLeaveQueueButton)

	S:HandleCloseButton(LFDDungeonReadyDialogCloseButton)
	LFDDungeonReadyDialogCloseButton.text:SetText("-")
	LFDDungeonReadyDialogCloseButton.text:FontTemplate(nil, 22)

	for i = 1, 2 do
		local reward = _G["LFDDungeonReadyDialogRewardsFrameReward"..i]
		local texture = _G["LFDDungeonReadyDialogRewardsFrameReward"..i.."Texture"]
		local border = _G["LFDDungeonReadyDialogRewardsFrameReward"..i.."Border"]

		if reward and not reward.IsDone then
			border:Kill()

			reward:CreateBackdrop()
			reward.backdrop:Point("TOPLEFT", 7, -7)
			reward.backdrop:Point("BOTTOMRIGHT", -7, 7)

			texture:SetTexCoord(unpack(E.TexCoords))
			texture:SetInside(reward.backdrop)

			reward.IsDone = true
		end
	end

	hooksecurefunc("LFDDungeonReadyPopup_Update", function()
		local _, _, _, _, _, role = GetLFGProposal()
		if LFDDungeonReadyDialogRoleIcon:IsShown() then
			LFDDungeonReadyDialogRoleIcon:StripTextures()
			LFDDungeonReadyDialogRoleIcon:CreateBackdrop()
			LFDDungeonReadyDialogRoleIcon.backdrop:Point("TOPLEFT", 7, -7)
			LFDDungeonReadyDialogRoleIcon.backdrop:Point("BOTTOMRIGHT", -7, 7)

			LFDDungeonReadyDialogRoleIcon.icon = LFDDungeonReadyDialogRoleIcon:CreateTexture(nil, "OVERLAY")
			LFDDungeonReadyDialogRoleIcon.icon:SetTexCoord(unpack(E.TexCoords))

			if role == "DAMAGER" then
				LFDDungeonReadyDialogRoleIcon.icon:SetTexture(damagerIcon)
			elseif role == "TANK" then
				LFDDungeonReadyDialogRoleIcon.icon:SetTexture(tankIcon)
			elseif role == "HEALER" then
				LFDDungeonReadyDialogRoleIcon.icon:SetTexture(healerIcon)
			end

			LFDDungeonReadyDialogRoleIcon.icon:SetInside(LFDDungeonReadyDialogRoleIcon.backdrop)
		end
	end)

	-- LFD Dungeon Ready Status
	LFDDungeonReadyStatus:SetTemplate("Transparent")

	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, "-")
end

S:AddCallback("LFD", LoadSkin);