local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local unpack = unpack;

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
			
			ClassTrainerSkillIcon:SetTemplate("Default", true);
		else
			ClassTrainerSkillIcon:SetBackdrop(nil);
		end
	end);
	
	ClassTrainerCollapseAllButton:HookScript('OnUpdate', function(self)
		self:SetNormalTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self:SetHighlightTexture("")
		self:GetNormalTexture():SetPoint("LEFT", 3, 2)
		self:GetNormalTexture():Size(12)
		if (self.collapsed) then
			self:GetNormalTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
		else
			self:GetNormalTexture():SetTexCoord(0.5625, 1, 0, 0.4375)
		end
		self:SetDisabledTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
		self:GetDisabledTexture():SetPoint("LEFT", 3, 2)
		self:GetDisabledTexture():Size(11)
		self:GetDisabledTexture():SetTexCoord(0, 0.4375, 0, 0.4375)
		self:GetDisabledTexture():SetDesaturated(true)
	end)
end

S:RegisterSkin("Blizzard_TrainerUI", LoadSkin);