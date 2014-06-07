local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.trainer ~= true then return end
	
	ClassTrainerFrame:StripTextures(true);
	ClassTrainerFrame:CreateBackdrop('Transparent');
	ClassTrainerFrame.backdrop:Point('TOPLEFT', 10, -11);
	ClassTrainerFrame.backdrop:Point('BOTTOMRIGHT', -32, 74);
	
	S:HandleCloseButton(ClassTrainerFrameCloseButton);
	
	ClassTrainerExpandButtonFrame:StripTextures();
	
	S:HandleDropDownBox(ClassTrainerFrameFilterDropDown);
	
	ClassTrainerListScrollFrame:StripTextures();
	S:HandleScrollBar(ClassTrainerListScrollFrameScrollBar);
	
	ClassTrainerDetailScrollFrame:StripTextures();
	S:HandleScrollBar(ClassTrainerDetailScrollFrameScrollBar);
	
	ClassTrainerSkillIcon:StripTextures();
	
	ClassTrainerSkillIcon:StripTextures();
	
	hooksecurefunc('ClassTrainer_SetSelection', function()
		local Icon = ClassTrainerSkillIcon:GetNormalTexture();
		
		if Icon then
			Icon:SetTexCoord(unpack(E.TexCoords));
			Icon:SetInside();
			
			ClassTrainerSkillIcon:SetTemplate('Default', true)
		else
			ClassTrainerSkillIcon:SetBackdrop(nil);
		end
	end)
	
	S:HandleButton(ClassTrainerTrainButton);
	S:HandleButton(ClassTrainerCancelButton);
end

S:RegisterSkin('Blizzard_TrainerUI', LoadSkin);