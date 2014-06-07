local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if E.private.skins.addons.enable ~= true or E.private.skins.addons.powerauras ~= true then return end
	
	PowaOptionsFrame:SetTemplate("Transparent")
	PowaOptionsFrame:StripTextures(true)
	
	local Frame = {'PowaOptionsPlayerListFrame', 'PowaOptionsGlobalListFrame', 'PowaOptionsSelectorFrame'}
	for i = 1, #Frame do
		_G[Frame[i]]:SetTemplate("Transparent")
	end
	
	local Button = {'PowaOptionsRename', 'PowaMainTestAllButton', 'PowaMainTestButton', 'PowaOptionsSelectorNew', 'PowaOptionsMove', 'PowaOptionsSelectorImport', 'PowaOptionsSelectorImportSet', 'PowaMainHideAllButton', 'PowaOptionsSelectorDelete', 'PowaOptionsCopy', 'PowaOptionsSelectorExport', 'PowaOptionsSelectorExportSet', 'PowaEditButton' }
	for i = 1, #Button do
		S:HandleButton(_G[Button[i]])
	end
	
	local EditBox = {'PowaOptionsRenameEditBox'}
	for i = 1, #EditBox do
		S:HandleEditBox(_G[EditBox[i]])
	end
	
	for i = 1, 15 do
		_G['PowaOptionsList'..i]:StripTextures(true)
	end
	
	PowaBarConfigFrame:SetTemplate("Transparent")
	PowaBarConfigFrame:StripTextures(true)
	
	PowaBarConfigFrameEditor:SetTemplate("Transparent")
	PowaBarConfigFrameEditor2:SetTemplate("Transparent")
	
	S:HandleButton(PowaBarAuraTextureSliderMinus)
	S:HandleButton(PowaBarAuraTextureSliderPlus)
	
	S:HandleSliderFrame(PowaBarAuraTextureSlider)
	
	S:HandleEditBox(PowaBarAuraTextureEdit)
	
	S:HandleCheckBox(PowaTexModeButton)
	S:HandleCheckBox(PowaWowTextureButton)
	S:HandleCheckBox(PowaCustomTextureButton)
	S:HandleCheckBox(PowaTextAuraButton)
	S:HandleCheckBox(PowaIsMountedButton)
	
	S:HandleDropDownBox(PowaDropDownBuffType)
end

S:RegisterSkin('PowerAuras', LoadSkin);