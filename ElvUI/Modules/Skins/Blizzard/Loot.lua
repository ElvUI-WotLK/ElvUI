local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack, select = unpack, select
--WoW API / Variables
local GetItemQualityColor = GetItemQualityColor
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootSlotInfo = GetLootSlotInfo
local IsFishingLoot = IsFishingLoot
local LootSlotIsCoin = LootSlotIsCoin
local LootSlotIsItem = LootSlotIsItem
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName

local ITEMS = ITEMS
local LOOT = LOOT
local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS

S:AddCallback("Skin_Loot", function()
	if E.private.general.loot then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.loot then return end

	local LootFrame = _G.LootFrame
	LootFrame:StripTextures()

	LootFrame:CreateBackdrop("Transparent")
	LootFrame.backdrop:Point("TOPLEFT", 16, -54)
	LootFrame.backdrop:Point("BOTTOMRIGHT", -77, 8)

	S:SetBackdropHitRect(LootFrame, nil, true)

	LootFramePortraitOverlay:SetParent(E.HiddenFrame)

	S:HandleNextPrevButton(LootFrameUpButton)
	LootFrameUpButton:Point("BOTTOMLEFT", 25, 20)
	LootFrameUpButton:Size(24)

	S:HandleNextPrevButton(LootFrameDownButton)
	LootFrameDownButton:Point("BOTTOMLEFT", 147, 21)
	LootFrameDownButton:Size(24)

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
	LootCloseButton:Point("CENTER", LootFrame, "TOPRIGHT", -88, -65)

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
	LootFrame.Title:SetWordWrap(false)
	LootFrame.Title:SetWidth(142)

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

		local questTexture = button:CreateTexture(nil, "OVERLAY")
		questTexture:SetInside()
		questTexture:SetTexture(E.Media.Textures.BagQuestIcon)
		button.questTexture = questTexture

		nameFrame:Hide()
	end

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local numLootItems = LootFrame.numLootItems
		local numLootToShow = LOOTFRAME_NUMBUTTONS

		if numLootItems > LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1
		end

		local slot = (numLootToShow * (LootFrame.page - 1)) + index

		if slot <= numLootItems then
			if index <= numLootToShow and (LootSlotIsItem(slot) or LootSlotIsCoin(slot)) then
				local texture, _, _, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)

				if texture then
					local button = _G["LootButton"..index]

					if questId and not isActive then
						button.backdrop:SetBackdropBorderColor(1.0, 1.0, 0.0)
						button.questTexture:Show()
						return
					elseif questId or isQuestItem then
						button.backdrop:SetBackdropBorderColor(1.0, 0.3, 0.3)
					elseif quality then
						button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					else
						button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end

					button.questTexture:Hide()
				end
			end
		end
	end)
end)

S:AddCallback("Skin_LootRoll", function()
	if E.private.general.lootRoll then return end
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.lootRoll then return end

	local function OnShow(self)
		local frameName = self:GetName()
		local iconFrame = _G[frameName.."IconFrame"]
		local statusBar = _G[frameName.."Timer"]
		local _, _, _, quality = GetLootRollItemInfo(self.rollID)
		local r, g, b = GetItemQualityColor(quality)

		self:SetTemplate("Transparent")

		iconFrame:SetBackdropBorderColor(r, g, b)
		statusBar:SetStatusBarColor(r, g, b)
	end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local frameName = "GroupLootFrame"..i
		local frame = _G[frameName]
		local iconFrame = _G[frameName.."IconFrame"]
		local icon = _G[frameName.."IconFrameIcon"]
		local statusBar = _G[frameName.."Timer"]
		local decoration = _G[frameName.."Decoration"]

		frame:EnableMouse(true)
		frame:StripTextures()
		frame:ClearAllPoints()

		if i == 1 then
			frame:Point("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
		else
			frame:Point("TOP", _G["GroupLootFrame"..i - 1], "BOTTOM", 0, -4)
		end

		iconFrame:SetTemplate("Default")
		iconFrame:StyleButton()

		icon:SetInside()
		icon:SetTexCoord(unpack(E.TexCoords))

		statusBar:StripTextures()
		statusBar:CreateBackdrop("Default")
		statusBar:SetStatusBarTexture(E.media.normTex)
		E:RegisterStatusBar(statusBar)

		decoration:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon")
		decoration:Size(130)
		decoration:Point("TOPLEFT", -37, 20)

		S:HandleCloseButton(_G[frameName.."PassButton"], frame)

		_G[frameName.."Corner"]:Hide()

		frame:HookScript("OnShow", OnShow)
	end
end)