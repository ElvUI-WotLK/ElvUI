local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins")

local find = string.find;

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.lfr ~= true then return end

	local buttons = {
		"LFRQueueFrameFindGroupButton",
		"LFRQueueFrameAcceptCommentButton",
		"LFRBrowseFrameSendMessageButton",
		"LFRBrowseFrameInviteButton",
		"LFRBrowseFrameRefreshButton"
	};

	LFRParentFrame:StripTextures()
	LFRParentFrame:CreateBackdrop("Transparent")
	LFRParentFrame.backdrop:Point("TOPLEFT", 10, -11)
	LFRParentFrame.backdrop:Point("BOTTOMRIGHT", -1, 5)

	LFRQueueFrame:StripTextures()
	LFRBrowseFrame:StripTextures()

	for i=1, #buttons do
		S:HandleButton(_G[buttons[i]], true)
	end

	--Close button doesn't have a fucking name, extreme hackage
	for i=1, LFRParentFrame:GetNumChildren() do
		local child = select(i, LFRParentFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
		end
	end

	S:HandleTab(LFRParentFrameTab1)
	S:HandleTab(LFRParentFrameTab2)

	S:HandleDropDownBox(LFRBrowseFrameRaidDropDown)
	S:HandleScrollBar(LFRQueueFrameSpecificListScrollFrameScrollBar)

	LFRQueueFrameCommentTextButton:CreateBackdrop("Default")
	LFRQueueFrameCommentTextButton:Height(35)

	for i=1, 7 do
		local button = "LFRBrowseFrameColumnHeader"..i
		_G[button.."Left"]:Kill()
		_G[button.."Middle"]:Kill()
		_G[button.."Right"]:Kill()
		_G[button]:StyleButton()
	end

	for i=1, NUM_LFR_CHOICE_BUTTONS do
		local button = _G["LFRQueueFrameSpecificListButton" .. i];
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

	--DPS, Healer, Tank check button's don't have a name, use it's parent as a referance.
	S:HandleCheckBox(LFRQueueFrameRoleButtonTank:GetChildren())
	S:HandleCheckBox(LFRQueueFrameRoleButtonHealer:GetChildren())
	S:HandleCheckBox(LFRQueueFrameRoleButtonDPS:GetChildren())
	LFRQueueFrameRoleButtonTank:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonTank:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonHealer:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonHealer:GetChildren():GetFrameLevel() + 2)
	LFRQueueFrameRoleButtonDPS:GetChildren():SetFrameLevel(LFRQueueFrameRoleButtonDPS:GetChildren():GetFrameLevel() + 2)

	LFRQueueFrameSpecificListScrollFrame:StripTextures()

	--Skill Line Tabs
	for i=1, 2 do
		local tab = _G["LFRParentFrameSideTab"..i]
		if tab then
			local tex = tab:GetNormalTexture():GetTexture()
			tab:StripTextures()
			tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
			tab:GetNormalTexture():ClearAllPoints()
			tab:GetNormalTexture():Point("TOPLEFT", 2, -2)
			tab:GetNormalTexture():Point("BOTTOMRIGHT", -2, 2)
			tab:SetNormalTexture(tex)

			tab:CreateBackdrop("Default")
			tab.backdrop:SetAllPoints()
			tab:StyleButton(true)

			local point, relatedTo, point2, _, y = tab:GetPoint()
			tab:Point(point, relatedTo, point2, 1, y)
		end
	end

	for i=1, 1 do
		local button = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i]
		local icon = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."IconTexture"]
		local count = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."Count"]

		if button then
			local __texture = _G[button:GetName().."IconTexture"]:GetTexture()
			button:StripTextures()
			icon:SetTexture(__texture)
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:Point("TOPLEFT", 2, -2)
			icon:SetDrawLayer("OVERLAY")
			count:SetDrawLayer("OVERLAY")
			if not button.backdrop then
				button:CreateBackdrop("Default")
				button.backdrop:Point("TOPLEFT", icon, "TOPLEFT", -2, 2)
				button.backdrop:Point("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 2, -2)
				icon:SetParent(button.backdrop)
				icon.SetPoint = E.noop

				if count then
					count:SetParent(button.backdrop)
				end
			end
		end
	end
end

S:AddCallback("LFR", LoadSkin);