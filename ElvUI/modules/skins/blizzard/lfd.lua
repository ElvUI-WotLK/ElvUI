local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

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
	
	for i=1, LFD_MAX_REWARDS do
		local Item = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i];
		local ItemIconTexture = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"];
		local ItemCount = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"];
		
		if(Item ) then
			Item:StripTextures();
			Item:SetTemplate("Default");
			
			ItemIconTexture:SetTexCoord(unpack(E.TexCoords));
			ItemIconTexture:SetDrawLayer('OVERLAY');
			
			ItemCount:SetDrawLayer('OVERLAY');
		end
	end
	
	LFDQueueFrameSpecificListScrollFrame:StripTextures();
	S:HandleScrollBar(LFDQueueFrameSpecificListScrollFrameScrollBar);
	
	S:HandleButton(LFDQueueFrameFindGroupButton, true);
	S:HandleButton(LFDQueueFrameCancelButton, true);
	
	for i=1, NUM_LFD_CHOICE_BUTTONS do
		S:HandleCheckBox(_G["LFDQueueFrameSpecificListButton"..i.."EnableButton"]);
	end
	
	S:HandleButton(LFDQueueFramePartyBackfillBackfillButton);
	S:HandleButton(LFDQueueFramePartyBackfillNoBackfillButton);
	
	LFDSearchStatus:SetTemplate('Transparent'); -- LFDSearchStatus
	
	LFDRoleCheckPopup:SetTemplate('Transparent'); -- LFDRoleCheckPopup
	
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonTank.checkButton);
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonHealer.checkButton);
	S:HandleCheckBox(LFDRoleCheckPopupRoleButtonDPS.checkButton);
	
	S:HandleButton(LFDRoleCheckPopupAcceptButton);
	S:HandleButton(LFDRoleCheckPopupDeclineButton);
	
	LFDDungeonReadyDialog:SetTemplate('Transparent'); -- LFDDungeonReadyDialog
	
	S:HandleCloseButton(LFDDungeonReadyDialogCloseButton, nil, '-');
	
	S:HandleButton(LFDDungeonReadyDialogEnterDungeonButton);
	S:HandleButton(LFDDungeonReadyDialogLeaveQueueButton);
	
	LFDDungeonReadyStatus:SetTemplate('Transparent'); -- LFDDungeonReadyStatus
	
	S:HandleCloseButton(LFDDungeonReadyStatusCloseButton, nil, '-');
end

S:RegisterSkin('ElvUI', LoadSkin)