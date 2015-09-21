local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule('Skins');

local function LoadSkin()
	if ( E.private.skins.blizzard.enable ~= true ) or ( E.private.skins.blizzard.spellbook ~= true ) then return; end
	
	SpellBookFrame:StripTextures(true);
	SpellBookFrame:CreateBackdrop('Transparent');
	SpellBookFrame.backdrop:Point('TOPLEFT', 10, -12);
	SpellBookFrame.backdrop:Point('BOTTOMRIGHT', -31, 75);
	
	for i = 1, 3 do
		local Tab = _G['SpellBookFrameTabButton'..i];
		
		Tab:GetNormalTexture():SetTexture(nil);
		Tab:GetDisabledTexture():SetTexture(nil);
		
		S:HandleTab(Tab);
		Tab:SetHeight(32);
	end
	
	S:HandleNextPrevButton(SpellBookPrevPageButton);
	S:HandleNextPrevButton(SpellBookNextPageButton);
	
	S:HandleCloseButton(SpellBookCloseButton);
	
	S:HandleCheckBox(ShowAllSpellRanksCheckBox);

	for i = 1, SPELLS_PER_PAGE do
		local Button = _G['SpellButton'..i];
		local IconTexture = _G['SpellButton'..i..'IconTexture'];
		
		for i = 1, Button:GetNumRegions() do
			local Region = select(i, Button:GetRegions());
			
			if ( Region:GetObjectType() == 'Texture' ) then
				if ( Region:GetTexture() ~= 'Interface\\Buttons\\ActionBarFlyoutButton' ) then
					Region:SetTexture(nil);
				end
			end
		end
		
		if ( IconTexture ) then
			Button:SetTemplate('Default', true);
			
			IconTexture:SetTexCoord(unpack(E.TexCoords));
			IconTexture:SetInside();
		end
	end
	
	hooksecurefunc('SpellButton_UpdateButton', function(self)
		local Name = self:GetName();
		local SubSpellName = _G[Name..'SubSpellName'];
		local IconTexture = _G[Name..'IconTexture'];
		local Highlight = _G[Name..'Highlight'];
		
		SubSpellName:SetTextColor(1, 1, 1);
		
		Highlight:SetTexture(1, 1, 1, .3);
		Highlight:SetAllPoints(IconTexture);
	end)
	
	for i = 1, MAX_SKILLLINE_TABS do
		local Tab = _G['SpellBookSkillLineTab'..i];
		
		Tab:StripTextures();
		Tab:StyleButton(nil, true);
		Tab:SetTemplate('Default', true);
		
		Tab:GetNormalTexture():SetTexCoord(unpack(E.TexCoords));
		Tab:GetNormalTexture():SetInside();
	end
end

S:RegisterSkin('ElvUI', LoadSkin);