local E, L, V, P, G, _ = unpack(select(2, ...));
local S = E:GetModule("Skins")

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.tutorial ~= true then return end

	for i=1, TutorialFrame:GetNumChildren() do
		local child = select(i, TutorialFrame:GetChildren())
		if child.GetPushedTexture and child:GetPushedTexture() and not child:GetName() then
			S:HandleCloseButton(child)
			child:SetPoint("TOPRIGHT", TutorialFrame, "TOPRIGHT", 2, 4)
		end
	end

	local tutorialbutton = TutorialFrameAlertButton
	local tutorialbuttonIcon = TutorialFrameAlertButton:GetNormalTexture()

	tutorialbutton:StripTextures()
	tutorialbutton:CreateBackdrop("Default", true)
	tutorialbutton:SetWidth(50)
	tutorialbutton:SetHeight(50)

	tutorialbuttonIcon:SetTexture("INTERFACE\\ICONS\\INV_Letter_18")
	tutorialbuttonIcon:ClearAllPoints()
	tutorialbuttonIcon:SetPoint("TOPLEFT", TutorialFrameAlertButton, "TOPLEFT", 5, -5)
	tutorialbuttonIcon:SetPoint("BOTTOMRIGHT", TutorialFrameAlertButton, "BOTTOMRIGHT", -5, 5)
	tutorialbuttonIcon:SetTexCoord(unpack(E.TexCoords))

	TutorialFrame:StripTextures()
	TutorialFrame:SetTemplate("Transparent")

	S:HandleNextPrevButton(TutorialFrameNextButton)
	TutorialFrameNextButton:SetPoint("BOTTOMRIGHT", TutorialFrame, "BOTTOMRIGHT", -132, 7)
	TutorialFrameNextButton:SetWidth(22)
	TutorialFrameNextButton:SetHeight(22)

	S:HandleNextPrevButton(TutorialFramePrevButton)
	TutorialFramePrevButton:SetPoint("BOTTOMLEFT", TutorialFrame, "BOTTOMLEFT", 30, 7)
	TutorialFramePrevButton:SetWidth(22)
	TutorialFramePrevButton:SetHeight(22)

	S:HandleButton(TutorialFrameOkayButton)

	TutorialFrameCallOut:Kill()
end

S:AddCallback("Tutorial", LoadSkin);