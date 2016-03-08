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

		for i = 1, button:GetNumRegions() do
			local region = select(i, button:GetRegions());
			if(region:GetObjectType() == "Texture") then
				if(region:GetTexture() ~= "Interface\\Buttons\\ActionBarFlyoutButton") then
					region:SetTexture(nil);
				end
			end
		end

		if(iconTexture) then
			button:SetTemplate("Default", true);

			iconTexture:SetTexCoord(unpack(E.TexCoords));
			iconTexture:SetInside();
		end
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		local name = self:GetName();
		local subSpellName = _G[name .. "SubSpellName"];
		local iconTexture = _G[name .. "IconTexture"];
		local highlight = _G[name .. "Highlight"];

		subSpellName:SetTextColor(1, 1, 1);

		highlight:SetTexture(1, 1, 1, .3);
		highlight:SetAllPoints(iconTexture);
	end);

	for i = 1, MAX_SKILLLINE_TABS do
		local tab = _G["SpellBookSkillLineTab" .. i];

		tab:StripTextures();
		tab:StyleButton(nil, true);
		tab:SetTemplate("Default", true);

		tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		tab:GetNormalTexture():SetInside();
	end
end

S:RegisterSkin("ElvUI", LoadSkin);