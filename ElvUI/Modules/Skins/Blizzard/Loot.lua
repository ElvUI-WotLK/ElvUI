local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

local _G = _G
local unpack, select = unpack, select

local UnitName = UnitName
local IsFishingLoot = IsFishingLoot
local GetLootRollItemInfo = GetLootRollItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetLootSlotInfo = GetLootSlotInfo
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES
local LOOT, ITEMS = LOOT, ITEMS

local function LoadSkin()
	if E.private.general.loot then return end
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.loot ~= true then return end

	local LootFrame = _G["LootFrame"]
	LootFrame:StripTextures()

	LootFrame:CreateBackdrop("Transparent")
	LootFrame.backdrop:Point("TOPLEFT", 14, -14)
	LootFrame.backdrop:Point("BOTTOMRIGHT", -75, 5)

	LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	S:HandleNextPrevButton(LootFrameUpButton)
	LootFrameUpButton:Point("BOTTOMLEFT", 25, 20)

	S:HandleNextPrevButton(LootFrameDownButton)
	LootFrameDownButton:Point("BOTTOMLEFT", 145, 20)

	LootFrame:EnableMouseWheel(true)
	LootFrame:SetScript("OnMouseWheel", function(_, value)
		if value > 0 then
			if LootFrameUpButton:IsShown() and LootFrameUpButton:IsEnabled() == 1 then
				LootFrame_PageUp()
			end
		else
			if LootFrameDownButton:IsShown() and LootFrameDownButton:IsEnabled() == 1 then
				LootFrame_PageDown()
			end
		end
	end)

	S:HandleCloseButton(LootCloseButton)
	LootCloseButton:Point("CENTER", LootFrame, "TOPRIGHT", -87, -26)

	for i = 1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region:GetObjectType() == "FontString" then
			if region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:Point("TOPLEFT", LootFrame.backdrop, "TOPLEFT", 4, -4)
	LootFrame.Title:SetJustifyH("LEFT")

	LootFrame:HookScript("OnShow", function(self)
		if IsFishingLoot() then
			self.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
			self.Title:SetText(UnitName("target"))
		else
			self.Title:SetText(LOOT)
		end
	end)

	for i = 1, LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton"..i]
		local nameFrame = _G["LootButton"..i.."NameFrame"]

		S:HandleItemButton(button, true)

		button.bg = CreateFrame("Frame", nil, button)
		button.bg:SetTemplate("Default")
		button.bg:Point("TOPLEFT", 40, 0)
		button.bg:Point("BOTTOMRIGHT", 110, 0)
		button.bg:SetFrameLevel(button.bg:GetFrameLevel() - 1)

		nameFrame:Hide()
	end

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local numLootItems = LootFrame.numLootItems
		local numLootToShow = LOOTFRAME_NUMBUTTONS
		if numLootItems > LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1
		end

		local button = _G["LootButton"..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index

		if slot <= numLootItems then
			if (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) and index <= numLootToShow then
				local texture, _, _, quality = GetLootSlotInfo(slot)
				if texture then
					if quality then
						button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					else
						button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end
			end
		end
	end)
end

local function LoadRollSkin()
	if(E.private.general.lootRoll) then return; end
	if(not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll) then return; end

	local function OnShow(self)
		self:SetTemplate("Transparent");

		local cornerTexture = _G[self:GetName() .. "Corner"];
		cornerTexture:SetTexture();

		local iconFrame = _G[self:GetName() .. "IconFrame"];
		local _, _, _, quality = GetLootRollItemInfo(self.rollID);
		iconFrame:SetBackdropBorderColor(GetItemQualityColor(quality));
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frame = _G["GroupLootFrame" .. i]
		frame:StripTextures();
		frame:ClearAllPoints();

		if(i == 1) then
			frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4);
		else
			frame:Point("TOP", _G["GroupLootFrame" .. i - 1], "BOTTOM", 0, -4);
		end

		local frameName = frame:GetName();

		local iconFrame = _G[frameName .. "IconFrame"];
		iconFrame:SetTemplate("Default");

		local icon = _G[frameName .. "IconFrameIcon"];
		icon:SetInside();
		icon:SetTexCoord(unpack(E.TexCoords));

		local statusBar = _G[frameName .. "Timer"];
		statusBar:StripTextures();
		statusBar:CreateBackdrop("Default");
		statusBar:SetStatusBarTexture(E.media.normTex);
		E:RegisterStatusBar(statusBar);

		local decoration = _G[frameName .. "Decoration"];
		decoration:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon");
		decoration:Size(130);
		decoration:Point("TOPLEFT", -37, 20);

		local pass = _G[frameName .. "PassButton"];
		S:HandleCloseButton(pass, frame);

		_G["GroupLootFrame" .. i]:HookScript("OnShow", OnShow);
	end
end

S:AddCallback("Loot", LoadSkin);
S:AddCallback("LootRoll", LoadRollSkin);