local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local select, unpack = select, unpack;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.spellbook ~= true) then return; end

	SpellBookFrame:StripTextures(true);
	SpellBookFrame:CreateBackdrop("Transparent");
	SpellBookFrame.backdrop:Point("TOPLEFT", 10, -12);
	SpellBookFrame.backdrop:Point("BOTTOMRIGHT", -31, 75);

	for i = 1, 3 do
		local tab = _G["SpellBookFrameTabButton" .. i];

		tab:GetNormalTexture():SetTexture(nil);
		tab:GetDisabledTexture():SetTexture(nil);

		S:HandleTab(tab);

		tab.backdrop:Point("TOPLEFT", 14, E.PixelMode and -17 or -19);
		tab.backdrop:Point("BOTTOMRIGHT", -14, 19);
	end

	S:HandleNextPrevButton(SpellBookPrevPageButton);
	S:HandleNextPrevButton(SpellBookNextPageButton);

	S:HandleCloseButton(SpellBookCloseButton);

	S:HandleCheckBox(ShowAllSpellRanksCheckBox);

	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton" .. i];
		local iconTexture = _G["SpellButton" .. i .. "IconTexture"];
		local cooldown = _G["SpellButton"..i.."Cooldown"];

		for i = 1, button:GetNumRegions() do
			local region = select(i, button:GetRegions());
			if(region:GetObjectType() == "Texture") then
				if(region:GetTexture() ~= "Interface\\Buttons\\ActionBarFlyoutButton") then
					region:SetTexture(nil);
				end
			end
		end

		if(iconTexture) then
			iconTexture:SetTexCoord(unpack(E.TexCoords))

			if not button.backdrop then
				button:CreateBackdrop("Default", true)
			end
		end

		if(cooldown) then
			E:RegisterCooldown(cooldown);
		end
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local name = self:GetName();
		local spellName = _G[name .. "SpellName"];
		local subSpellName = _G[name .. "SubSpellName"];
		local iconTexture = _G[name .. "IconTexture"];
		local highlight = _G[name .. "Highlight"];

		spellName:SetTextColor(1, 0.80, 0.10)
		subSpellName:SetTextColor(1, 1, 1);

		if (iconTexture) then
			if (highlight) then
				highlight:SetTexture(1, 1, 1, 0.3)
			end
		end
	end);

	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab" .. i];

		tab:StripTextures();
		tab:StyleButton(nil, true);
		tab:SetTemplate("Default", true);

		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		tab:GetNormalTexture():SetInside();
	end

	for i = 1, 12 do
		_G["SpellButton" .. i]:CreateBackdrop("Transparent", true);
		_G["SpellButton" .. i].backdrop:Point("TOPLEFT", -7, 6);
		_G["SpellButton" .. i].backdrop:Point("BOTTOMRIGHT", 116, -5);
	end

	ShowAllSpellRanksCheckBox:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", 30, -38)

	SpellButton1:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", 25, -75)
	SpellButton2:SetPoint("TOPLEFT", SpellButton1, "TOPLEFT", 167, 0)
	SpellButton3:SetPoint("TOPLEFT", SpellButton1, "BOTTOMLEFT", 0, -17)
	SpellButton4:SetPoint("TOPLEFT", SpellButton3, "TOPLEFT", 167, 0)
	SpellButton5:SetPoint("TOPLEFT", SpellButton3, "BOTTOMLEFT", 0, -17)
	SpellButton6:SetPoint("TOPLEFT", SpellButton5, "TOPLEFT", 167, 0)
	SpellButton7:SetPoint("TOPLEFT", SpellButton5, "BOTTOMLEFT", 0, -17)
	SpellButton8:SetPoint("TOPLEFT", SpellButton7, "TOPLEFT", 167, 0)
	SpellButton9:SetPoint("TOPLEFT", SpellButton7, "BOTTOMLEFT", 0, -17)
	SpellButton10:SetPoint("TOPLEFT", SpellButton9, "TOPLEFT", 167, 0)
	SpellButton11:SetPoint("TOPLEFT", SpellButton9, "BOTTOMLEFT", 0, -17)
	SpellButton12:SetPoint("TOPLEFT", SpellButton11, "TOPLEFT", 167, 0)

	SpellBookPrevPageButton:SetPoint("CENTER", SpellBookFrame, "BOTTOMLEFT", 30, 100)
	SpellBookNextPageButton:SetPoint("CENTER", SpellBookFrame, "BOTTOMLEFT", 330, 100)

	SpellBookPageText:SetTextColor(1, 1, 1)
	SpellBookPageText:SetPoint("CENTER", SpellBookFrame, "BOTTOMLEFT", 185, 0)
end

S:AddCallback("Spellbook", LoadSkin);