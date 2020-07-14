local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local find = string.find
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

S:AddCallback("Skin_LFR", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lfr then return end

	LFRParentFrame:StripTextures()
	LFRParentFrame:CreateBackdrop("Transparent")
	LFRParentFrame.backdrop:Point("TOPLEFT", 11, -12)
	LFRParentFrame.backdrop:Point("BOTTOMRIGHT", -3, 4)

	S:HookScript(LFRParentFrame, "OnShow", function(self)
		S:SetUIPanelWindowInfo(self, "width")
		S:SetBackdropHitRect(self)
		S:Unhook(self, "OnShow")
	end)

	S:HandleCloseButton((LFRParentFrame:GetChildren()), LFRParentFrame.backdrop)

	LFRQueueFrame:StripTextures()
	LFRBrowseFrame:StripTextures()

	local buttons = {
		LFRQueueFrameFindGroupButton,
		LFRQueueFrameAcceptCommentButton,
		LFRBrowseFrameSendMessageButton,
		LFRBrowseFrameInviteButton,
		LFRBrowseFrameRefreshButton,
		LFRQueueFrameNoLFRWhileLFDLeaveQueueButton
	}
	for i = 1, #buttons do
		S:HandleButton(buttons[i], true)
	end

	S:HandleTab(LFRParentFrameTab1)
	S:HandleTab(LFRParentFrameTab2)

	S:HandleDropDownBox(LFRBrowseFrameRaidDropDown)
	S:HandleScrollBar(LFRQueueFrameSpecificListScrollFrameScrollBar)

	LFRQueueFrameCommentTextButton:CreateBackdrop("Default")

	--DPS, Healer, Tank check button's don't have a name, use it's parent as a referance.
	S:HandleCheckBox((LFRQueueFrameRoleButtonTank:GetChildren()))
	S:HandleCheckBox((LFRQueueFrameRoleButtonHealer:GetChildren()))
	S:HandleCheckBox((LFRQueueFrameRoleButtonDPS:GetChildren()))
	LFRQueueFrameRoleButtonTank:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonTank:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonHealer:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonHealer:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonDPS:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonDPS:GetChildren():GetFrameLevel() + 2)

	LFRQueueFrameSpecificListScrollFrame:StripTextures()

	for i = 1, 7 do
		local button = "LFRBrowseFrameColumnHeader"..i
		_G[button.."Left"]:Kill()
		_G[button.."Middle"]:Kill()
		_G[button.."Right"]:Kill()
		_G[button]:StyleButton()
	end

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton"..i]
		S:HandleCheckBox(button.enableButton)

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

	LFRQueueFrameSpecificListScrollFrameScrollBar:Point("TOPLEFT", LFRQueueFrameSpecificListScrollFrame, "TOPRIGHT", 5, -17)
	LFRQueueFrameSpecificListScrollFrameScrollBar:Point("BOTTOMLEFT", LFRQueueFrameSpecificListScrollFrame, "BOTTOMRIGHT", 5, 17)

	LFRQueueFrameNoLFRWhileLFD:Size(325, 271)
	LFRQueueFrameNoLFRWhileLFD:Point("BOTTOMRIGHT", -11, 41)

	LFRQueueFrameComment:Width(323)
	LFRQueueFrameComment:Point("TOPLEFT", LFRQueueFrame, "BOTTOMLEFT", 20, 74)

	LFRQueueFrameCommentTextButton:Size(323, 32)

	LFRQueueFrameFindGroupButton:Point("BOTTOMLEFT", 19, 12)
	LFRQueueFrameAcceptCommentButton:Point("BOTTOMRIGHT", -11, 12)
	LFRBrowseFrameSendMessageButton:Point("BOTTOMLEFT", 19, 12)
	LFRBrowseFrameInviteButton:Point("LEFT", LFRBrowseFrameSendMessageButton, "RIGHT", 4, 0)
	LFRBrowseFrameRefreshButton:Point("LEFT", LFRBrowseFrameInviteButton, "RIGHT", 4, 0)

	LFRParentFrameTab1:Point("BOTTOMLEFT", 11, -26)
end)