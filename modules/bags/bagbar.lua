local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule("Bags");

local _G = _G;
local unpack = unpack;
local tinsert = table.insert;

local CreateFrame = CreateFrame;
local NUM_BAG_FRAMES = NUM_BAG_FRAMES;

local TOTAL_BAGS = NUM_BAG_FRAMES + 2;

local ElvUIKeyRing = CreateFrame("CheckButton", "ElvUIKeyRingButton", UIParent, "ItemButtonTemplate");
ElvUIKeyRing:RegisterForClicks("anyUp");
ElvUIKeyRing:StripTextures();
ElvUIKeyRing:SetScript("OnClick", function() if CursorHasItem() then PutKeyInKeyRing(); else ToggleKeyRing(); end end)
ElvUIKeyRing:SetScript("OnReceiveDrag", function() if CursorHasItem() then PutKeyInKeyRing(); end end)
ElvUIKeyRing:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_LEFT"); local color = HIGHLIGHT_FONT_COLOR; GameTooltip:SetText(KEYRING, color.r, color.g, color.b); GameTooltip:AddLine(); end)
ElvUIKeyRing:SetScript("OnLeave", function() GameTooltip:Hide(); end)
_G[ElvUIKeyRing:GetName().."IconTexture"]:SetTexture("Interface\\ContainerFrame\\KeyRing-Bag-Icon")
_G[ElvUIKeyRing:GetName().."IconTexture"]:SetTexCoord(unpack(E.TexCoords))

local function OnEnter()
	if E.db.bags.bagBar.mouseover ~= true then return; end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 1);
end

local function OnLeave()
	if E.db.bags.bagBar.mouseover ~= true then return; end
	E:UIFrameFadeOut(ElvUIBags, 0.2, ElvUIBags:GetAlpha(), 0);
end

function B:SkinBag(bag)
	local icon = _G[bag:GetName().."IconTexture"];
	bag.oldTex = icon:GetTexture();

	bag:StripTextures();
	bag:CreateBackdrop("Default", true);
	bag.backdrop:SetAllPoints();
	bag:StyleButton(true);
	icon:SetTexture(bag.oldTex);
	icon:SetInside();
	icon:SetTexCoord(unpack(E.TexCoords));
end

function B:SizeAndPositionBagBar()
	if not ElvUIBags then return; end

	local buttonSpacing = E.db.bags.bagBar.spacing
	local backdropSpacing = E.db.bags.bagBar.backdropSpacing

	if E.db.bags.bagBar.mouseover then
		ElvUIBags:SetAlpha(0);
	else
		ElvUIBags:SetAlpha(1);
	end

	if E.db.bags.bagBar.showBackdrop then
		ElvUIBags.backdrop:Show();
	else
		ElvUIBags.backdrop:Hide();
	end

	ElvUIKeyRingButton:Size(E.db.bags.bagBar.size);
	ElvUIKeyRingButton:ClearAllPoints();

	for i=1, #ElvUIBags.buttons do
		local button = ElvUIBags.buttons[i];
		local prevButton = ElvUIBags.buttons[i-1];
		button:Size(E.db.bags.bagBar.size);
		button:ClearAllPoints();
		if E.db.bags.bagBar.growthDirection == "HORIZONTAL" and E.db.bags.bagBar.sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("LEFT", ElvUIBags, "LEFT", (E.db.bags.bagBar.showBackdrop and (backdropSpacing + E.Border) or 0), 0);
			elseif prevButton then
				button:Point("LEFT", prevButton, "RIGHT", buttonSpacing, 0);
			end
		elseif E.db.bags.bagBar.growthDirection == "VERTICAL" and E.db.bags.bagBar.sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("TOP", ElvUIBags, "TOP", 0, -(E.db.bags.bagBar.showBackdrop and (backdropSpacing + E.Border) or 0));
			elseif prevButton then
				button:Point("TOP", prevButton, "BOTTOM", 0, -buttonSpacing);
			end
		elseif E.db.bags.bagBar.growthDirection == "HORIZONTAL" and E.db.bags.bagBar.sortDirection == "DESCENDING" then
			if i == 1 then
				button:Point("RIGHT", ElvUIBags, "RIGHT", -(E.db.bags.bagBar.showBackdrop and (backdropSpacing + E.Border) or 0), 0);
			elseif prevButton then
				button:Point("RIGHT", prevButton, "LEFT", -buttonSpacing, 0);
			end
		else
			if i == 1 then
				button:Point("BOTTOM", ElvUIBags, "BOTTOM", 0, (E.db.bags.bagBar.showBackdrop and (backdropSpacing + E.Border) or 0));
			elseif prevButton then
				button:Point("BOTTOM", prevButton, "TOP", 0, buttonSpacing);
			end
		end
	end

	if E.db.bags.bagBar.growthDirection == "HORIZONTAL" then
		ElvUIBags:Width(E.db.bags.bagBar.size*(TOTAL_BAGS) + buttonSpacing*(TOTAL_BAGS-1) + ((E.db.bags.bagBar.showBackdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2));
		ElvUIBags:Height(E.db.bags.bagBar.size + ((E.db.bags.bagBar.showBackdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2));
	else
		ElvUIBags:Height(E.db.bags.bagBar.size*(TOTAL_BAGS) + buttonSpacing*(TOTAL_BAGS-1) + ((E.db.bags.bagBar.showBackdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2));
		ElvUIBags:Width(E.db.bags.bagBar.size + ((E.db.bags.bagBar.showBackdrop == true and (E.Border + backdropSpacing) or E.Spacing)*2));
	end
end

function B:LoadBagBar()
	if not E.private.bags.bagBar then
		return
	end

	local ElvUIBags = CreateFrame("Frame", "ElvUIBags", E.UIParent);
	ElvUIBags:SetPoint("TOPRIGHT", RightChatPanel, "TOPLEFT", -4, 0);
	ElvUIBags.buttons = {};
	ElvUIBags:CreateBackdrop();
	ElvUIBags.backdrop:SetAllPoints();
	ElvUIBags:EnableMouse(true);
	ElvUIBags:SetScript("OnEnter", OnEnter);
	ElvUIBags:SetScript("OnLeave", OnLeave);

	MainMenuBarBackpackButton:SetParent(ElvUIBags);
	MainMenuBarBackpackButton.SetParent = E.dummy;
	MainMenuBarBackpackButton:ClearAllPoints();
	MainMenuBarBackpackButtonCount:FontTemplate(nil, 10);
	MainMenuBarBackpackButtonCount:ClearAllPoints();
	MainMenuBarBackpackButtonCount:Point("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4);
	MainMenuBarBackpackButton:HookScript("OnEnter", OnEnter);
	MainMenuBarBackpackButton:HookScript("OnLeave", OnLeave);
	tinsert(ElvUIBags.buttons, MainMenuBarBackpackButton);
	self:SkinBag(MainMenuBarBackpackButton);

	for i=0, NUM_BAG_FRAMES-1 do
		local b = _G["CharacterBag"..i.."Slot"];
		b:SetParent(ElvUIBags);
		b.SetParent = E.dummy;
		b:HookScript("OnEnter", OnEnter);
		b:HookScript("OnLeave", OnLeave);

		self:SkinBag(b);
		tinsert(ElvUIBags.buttons, b);
	end

	ElvUIKeyRingButton:CreateBackdrop();
	ElvUIKeyRingButton.backdrop:SetAllPoints();
	ElvUIKeyRingButton:SetParent(ElvUIBags);
	ElvUIKeyRingButton.SetParent = E.dummy;
	ElvUIKeyRingButton:HookScript("OnEnter", OnEnter);
	ElvUIKeyRingButton:HookScript("OnLeave", OnLeave);
	tinsert(ElvUIBags.buttons, ElvUIKeyRingButton);

	self:SizeAndPositionBagBar();
	E:CreateMover(ElvUIBags, "BagsMover", L["Bags"]);
end