local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule("Bags")

--Lua functions
local _G = _G
local unpack = unpack
local tinsert = table.insert
--WoW API / Variables
local CreateFrame = CreateFrame
local CursorHasItem = CursorHasItem
local PutKeyInKeyRing = PutKeyInKeyRing
local RegisterStateDriver = RegisterStateDriver
local ToggleKeyRing = ToggleKeyRing

local KEYRING = KEYRING
local NUM_BAG_FRAMES = NUM_BAG_FRAMES

local function OnEnter()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 1)
end

local function OnLeave()
	if not E.db.bags.bagBar.mouseover then return end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 0)
end

function B:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"]
	bag.oldTex = icon:GetTexture()

	bag:StripTextures()
	bag:SetTemplate(nil, true)
	bag:StyleButton(true)

	icon:SetTexture(bag.oldTex)
	icon:SetInside()
	icon:SetTexCoord(unpack(E.TexCoords))
end

function B:SizeAndPositionBagBar()
	if not ElvUIBags then return end

	local buttonSpacing = E:Scale(E.db.bags.bagBar.spacing)
	local backdropSpacing = E:Scale(E.db.bags.bagBar.backdropSpacing)
	local bagBarSize = E:Scale(E.db.bags.bagBar.size)
	local showBackdrop = E.db.bags.bagBar.showBackdrop
	local growthDirection = E.db.bags.bagBar.growthDirection
	local sortDirection = E.db.bags.bagBar.sortDirection

	local visibility = E.db.bags.bagBar.visibility
	if visibility and string.match(visibility, "[\n\r]") then
		visibility = string.gsub(visibility, "[\n\r]","")
	end

	RegisterStateDriver(ElvUIBags, "visibility", visibility)

	if E.db.bags.bagBar.mouseover then
		ElvUIBags:SetAlpha(0)
	else
		ElvUIBags:SetAlpha(1)
	end

	if showBackdrop then
		ElvUIBags.backdrop:Show()
	else
		ElvUIBags.backdrop:Hide()
	end

	ElvUIKeyRingButton:Size(bagBarSize)
	ElvUIKeyRingButton:ClearAllPoints()

	local bdpSpacing = (showBackdrop and backdropSpacing + E.Border) or 0
	local btnSpacing = (buttonSpacing + E.Border)

	for i = 1, #ElvUIBags.buttons do
		local button = ElvUIBags.buttons[i]
		local prevButton = ElvUIBags.buttons[i-1]
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()

		if growthDirection == "HORIZONTAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:SetPoint("LEFT", ElvUIBags, "LEFT", bdpSpacing, 0)
			elseif prevButton then
				button:SetPoint("LEFT", prevButton, "RIGHT", btnSpacing, 0)
			end
		elseif growthDirection == "VERTICAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:SetPoint("TOP", ElvUIBags, "TOP", 0, -bdpSpacing)
			elseif prevButton then
				button:SetPoint("TOP", prevButton, "BOTTOM", 0, -btnSpacing)
			end
		elseif growthDirection == "HORIZONTAL" and sortDirection == "DESCENDING" then
			if i == 1 then
				button:SetPoint("RIGHT", ElvUIBags, "RIGHT", -bdpSpacing, 0)
			elseif prevButton then
				button:SetPoint("RIGHT", prevButton, "LEFT", -btnSpacing, 0)
			end
		else
			if i == 1 then
				button:SetPoint("BOTTOM", ElvUIBags, "BOTTOM", 0, bdpSpacing)
			elseif prevButton then
				button:SetPoint("BOTTOM", prevButton, "TOP", 0, btnSpacing)
			end
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 2)
	local btnSpace = btnSpacing * (NUM_BAG_FRAMES + 1)
	local bdpDoubled = bdpSpacing * 2

	if growthDirection == 'HORIZONTAL' then
		ElvUIBags:SetWidth(btnSize + btnSpace + bdpDoubled)
		ElvUIBags:SetHeight(bagBarSize + bdpDoubled)
	else
		ElvUIBags:SetHeight(btnSize + btnSpace + bdpDoubled)
		ElvUIBags:SetWidth(bagBarSize + bdpDoubled)
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then return end

	local ElvUIBags = CreateFrame("Frame", "ElvUIBags", E.UIParent)
	ElvUIBags:Point("TOPRIGHT", RightChatPanel, "TOPLEFT", -4, 0)
	ElvUIBags.buttons = {}
	ElvUIBags:CreateBackdrop(E.db.bags.transparent and "Transparent")
	ElvUIBags.backdrop:SetAllPoints()
	ElvUIBags:EnableMouse(true)
	ElvUIBags:SetScript("OnEnter", OnEnter)
	ElvUIBags:SetScript("OnLeave", OnLeave)

	MainMenuBarBackpackButton:SetParent(ElvUIBags)
	MainMenuBarBackpackButton.SetParent = E.noop
	MainMenuBarBackpackButton:ClearAllPoints()

	MainMenuBarBackpackButtonCount:FontTemplate(nil, 10)
	MainMenuBarBackpackButtonCount:ClearAllPoints()
	MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)

	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter)
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave)

	tinsert(ElvUIBags.buttons, MainMenuBarBackpackButton)
	self:SkinBag(MainMenuBarBackpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local b = _G["CharacterBag"..i.."Slot"]
		b:SetParent(ElvUIBags)
		b.SetParent = E.noop
		b:HookScript("OnEnter", OnEnter)
		b:HookScript("OnLeave", OnLeave)

		self:SkinBag(b)
		tinsert(ElvUIBags.buttons, b)
	end

	local ElvUIKeyRing = CreateFrame("CheckButton", "ElvUIKeyRingButton", UIParent, "ItemButtonTemplate")
	ElvUIKeyRing:StripTextures()
	ElvUIKeyRing:SetTemplate()
	ElvUIKeyRing:StyleButton(true)
	ElvUIKeyRing:SetParent(ElvUIBags)
	ElvUIKeyRing.SetParent = E.noop
	ElvUIKeyRing:RegisterForClicks("anyUp")

	_G[ElvUIKeyRing:GetName().."IconTexture"]:SetTexture("Interface\\ContainerFrame\\KeyRing-Bag-Icon")
	_G[ElvUIKeyRing:GetName().."IconTexture"]:SetInside()
	_G[ElvUIKeyRing:GetName().."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

	ElvUIKeyRing:SetScript("OnClick", function() if CursorHasItem() then PutKeyInKeyRing() else ToggleKeyRing() end end)
	ElvUIKeyRing:SetScript("OnReceiveDrag", function() if CursorHasItem() then PutKeyInKeyRing() end end)
	ElvUIKeyRing:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT") GameTooltip:SetText(KEYRING, 1, 1, 1) OnEnter() end)
	ElvUIKeyRing:SetScript("OnLeave",function() GameTooltip:Hide() OnLeave() end)

	tinsert(ElvUIBags.buttons, ElvUIKeyRing)

	self:SizeAndPositionBagBar()

	E:CreateMover(ElvUIBags, "BagsMover", L["Bags"], nil, nil, nil, nil, nil, "bags,general")
end