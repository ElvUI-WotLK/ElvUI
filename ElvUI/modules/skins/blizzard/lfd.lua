local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local find = string.find;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfd ~= true then return end

	LFDParentFrame:StripTextures(true);
	LFDQueueFrame:CreateBackdrop("Transparent");
	LFDQueueFrame.backdrop:Point("TOPLEFT", 10, -11);
	LFDQueueFrame.backdrop:Point("BOTTOMRIGHT", -1, 0);

	LFDParentFramePortrait:Kill();

	for i = 1, LFDParentFrame:GetNumChildren() do
		local child = select(i, LFDParentFrame:GetChildren());
		if(child.GetPushedTexture and child:GetPushedTexture() and not child:GetName()) then
			S:HandleCloseButton(child);
		end
	end

	S:HandleCheckBox(LFDQueueFrameRoleButtonTank.checkButton);
	LFDQueueFrameRoleButtonTank.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonTank.checkButton:GetFrameLevel() + 2);
	S:HandleCheckBox(LFDQueueFrameRoleButtonHealer.checkButton);
	LFDQueueFrameRoleButtonHealer.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonHealer.checkButton:GetFrameLevel() + 2);
	S:HandleCheckBox(LFDQueueFrameRoleButtonDPS.checkButton);
	LFDQueueFrameRoleButtonDPS.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonDPS.checkButton:GetFrameLevel() + 2);
	S:HandleCheckBox(LFDQueueFrameRoleButtonLeader.checkButton);
	LFDQueueFrameRoleButtonLeader.checkButton:SetFrameLevel(LFDQueueFrameRoleButtonLeader.checkButton:GetFrameLevel() + 2);

	LFDQueueFrame:StripTextures(true);

	S:HandleDropDownBox(LFDQueueFrameTypeDropDown);

	for i = 1, LFD_MAX_REWARDS do
		local Item = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i];
		local ItemIconTexture = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"];
		local ItemCount = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"];

		if(Item) then
			Item:StripTextures();
			Item:SetTemplate("Default");

			ItemIconTexture:SetTexCoord(unpack(E.TexCoords));
			ItemIconTexture:SetDrawLayer("OVERLAY");

			ItemCount:SetDrawLayer("OVERLAY");
		end
	end

	hooksecurefunc("LFDQueueFrameRandomCooldownFrame_Update", function()
		if LFDQueueFrameCooldownFrame:IsShown() then
			LFDQueueFrameCooldownFrame:SetFrameLevel(LFDQueueFrameCooldownFrame:GetParent():GetFrameLevel() + 5)
		end
	end)

	LFDQueueFrameSpecificListScrollFrame:StripTextures();
	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar);

	S:HandleButton(LFDQueueFrameFindGroupButton, true);
	S:HandleButton(LFDQueueFrameCancelButton, true);

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		local button = _G["LFDQueueFrameSpecificListButton" .. i];
		button.enableButton:StripTextures();
		button.enableButton:CreateBackdrop("Default");
		button.enableButton.backdrop:SetInside(nil, 4, 4);

		button.expandOrCollapseButton:SetNormalTexture("");
		button.expandOrCollapseButton.SetNormalTexture = E.noop;
		button.expandOrCollapseButton:SetHighlightTexture(nil);

		button.expandOrCollapseButton.Text = button.expandOrCollapseButton:CreateFontString(nil, "OVERLAY");
		button.expandOrCollapseButton.Text:FontTemplate(nil, 22);
		button.expandOrCollapseButton.Text:Point("CENTER", 4, 0);
		button.expandOrCollapseButton.Text:SetText("+");

		hooksecurefunc(button.expandOrCollapseButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-");
			else
				self.Text:SetText("+");
			end
		end);
	end

	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton);
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton);

	LFDSearchStatus:SetTemplate("Transparent");

	LFDRoleCheckPopup:SetTemplate("Transparent");

	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton);
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton);
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton);

	S:HandleButton(LFDRoleCheckPopupAcceptButton);
	S:HandleButton(LFDRoleCheckPopupDeclineButton);

	LFDDungeonReadyDialog:SetTemplate("Transparent");

	S:HandleCloseButton(LFDDungeonReadyDialogCloseButton, nil, "-");

	S:HandleButton(LFDDungeonReadyDialogEnterDungeonButton);
	S:HandleButton(LFDDungeonReadyDialogLeaveQueueButton);

	LFDDungeonReadyStatus:SetTemplate("Transparent");

	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, "-");
end

S:AddCallback("LFD", LoadSkin);