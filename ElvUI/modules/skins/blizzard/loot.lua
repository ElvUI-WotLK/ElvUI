local E, L, V, P, G = unpack(select(2, ...));
local S = E:GetModule("Skins");

local _G = _G;
local unpack, select = unpack, select;
local ceil = ceil;

local GetItemQualityColor = GetItemQualityColor;
local GetLootSlotInfo = GetLootSlotInfo;
local UnitName = UnitName;
local IsFishingLoot = IsFishingLoot;
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS;
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS;
local LOOT = LOOT;

local function LoadSkin()
	if(E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.loot ~= true) then return; end

	LootFrame:StripTextures();

	LootFrame:CreateBackdrop("Transparent")
	LootFrame.backdrop:Point("TOPLEFT", 13, -14);
	LootFrame.backdrop:Point("BOTTOMRIGHT", -68, 5);

	LootFramePortraitOverlay:SetParent(E.HiddenFrame);

	S:HandleCloseButton(LootCloseButton);

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions());
		if(region:GetObjectType() == "FontString") then
			if(region:GetText() == ITEMS) then
				LootFrame.Title = region;
			end
		end
	end

	LootFrame.Title:ClearAllPoints();
	LootFrame.Title:Point("TOPLEFT", LootFrame.backdrop, "TOPLEFT", 4, -4);
	LootFrame.Title:SetJustifyH("LEFT");

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton" .. i];
		_G["LootButton" .. i .. "NameFrame"]:Hide();
		S:HandleItemButton(button, true);
	end

	S:HandleNextPrevButton(LootFrameDownButton);
	S:HandleNextPrevButton(LootFrameUpButton);
	S:SquareButton_SetIcon(LootFrameUpButton, "UP");
	S:SquareButton_SetIcon(LootFrameDownButton, "DOWN");

	LootFrame:HookScript("OnShow", function(self)
		if(IsFishingLoot()) then
			self.Title:SetText(L["Fishy Loot"]);
		elseif(not UnitIsFriend("player", "target") and UnitIsDead("target")) then
			self.Title:SetText(UnitName("target"));
		else
			self.Title:SetText(LOOT);
		end
	end);
end

S:AddCallback("Loot", LoadSkin);