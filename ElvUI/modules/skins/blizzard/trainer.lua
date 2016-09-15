local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack = unpack;
local find = string.find;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true) then return; end

	ClassTrainerFrame:CreateBackdrop("Transparent");
	ClassTrainerFrame.backdrop:Point("TOPLEFT", 10, -11);
	ClassTrainerFrame.backdrop:Point("BOTTOMRIGHT", -32, 74);

	ClassTrainerFrame:StripTextures(true);

	ClassTrainerExpandButtonFrame:StripTextures();

	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown);

	ClassTrainerListScrollFrame:StripTextures();
	S:HandleScrollBar(ClassTrainerListScrollFrameScrollBar);

	ClassTrainerDetailScrollFrame:StripTextures();
	S:HandleScrollBar(ClassTrainerDetailScrollFrameScrollBar);

	ClassTrainerSkillIcon:StripTextures();

	S:HandleButton(ClassTrainerTrainButton);
	S:HandleButton(ClassTrainerCancelButton);

	S:HandleCloseButton(ClassTrainerFrameCloseButton);

	hooksecurefunc("ClassTrainer_SetSelection", function()
		local skillIcon = ClassTrainerSkillIcon:GetNormalTexture();
		if(skillIcon) then
			skillIcon:SetInside();
			skillIcon:SetTexCoord(unpack(E.TexCoords));

			ClassTrainerSkillIcon:SetTemplate("Default");
		end
	end);

	for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
		local skillButton = _G["ClassTrainerSkill" .. i];
		skillButton:SetNormalTexture("");
		skillButton.SetNormalTexture = E.noop;

		_G["ClassTrainerSkill" .. i .. "Highlight"]:SetTexture("");
		_G["ClassTrainerSkill" .. i .. "Highlight"].SetTexture = E.noop;

		skillButton.Text = skillButton:CreateFontString(nil, "OVERLAY");
		skillButton.Text:FontTemplate(nil, 22);
		skillButton.Text:Point("LEFT", 3, 0);
		skillButton.Text:SetText("+");

		hooksecurefunc(skillButton, "SetNormalTexture", function(self, texture)
			if(find(texture, "MinusButton")) then
				self.Text:SetText("-");
			elseif(find(texture, "PlusButton")) then
				self.Text:SetText("+");
			else
				self.Text:SetText("");
			end
		end);
	end

	ClassTrainerCollapseAllButton:SetNormalTexture("");
	ClassTrainerCollapseAllButton.SetNormalTexture = E.noop;
	ClassTrainerCollapseAllButton:SetHighlightTexture("");
	ClassTrainerCollapseAllButton.SetHighlightTexture = E.noop;
	ClassTrainerCollapseAllButton:SetDisabledTexture("");
	ClassTrainerCollapseAllButton.SetDisabledTexture = E.noop;

	ClassTrainerCollapseAllButton.Text = ClassTrainerCollapseAllButton:CreateFontString(nil, "OVERLAY");
	ClassTrainerCollapseAllButton.Text:FontTemplate(nil, 22);
	ClassTrainerCollapseAllButton.Text:Point("LEFT", 3, 0);
	ClassTrainerCollapseAllButton.Text:SetText("+");

	hooksecurefunc(ClassTrainerCollapseAllButton, "SetNormalTexture", function(self, texture)
		if(find(texture, "MinusButton")) then
			self.Text:SetText("-");
		else
			self.Text:SetText("+");
		end
	end);
end

S:AddCallbackForAddon("Blizzard_TrainerUI", "Trainer", LoadSkin);