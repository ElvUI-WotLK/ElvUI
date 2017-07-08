local E, L, V, P, G = unpack(select(2, ...));
local M = E:GetModule("Misc");

local CursorOnUpdate = CursorOnUpdate
local DressUpItemLink = DressUpItemLink
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetLootRollTimeLeft = GetLootRollTimeLeft
local IsModifiedClick = IsModifiedClick
local IsShiftKeyDown = IsShiftKeyDown
local ResetCursor = ResetCursor
local RollOnLoot = RollOnLoot
local ShowInspectCursor = ShowInspectCursor
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS;
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS;
local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

local find = string.find;
local pairs, unpack, ipairs, next, tonumber = pairs, unpack, ipairs, next, tonumber;
local tinsert = table.insert;

local pos = "TOP";
local cancelled_rolls = {};
local FRAME_WIDTH, FRAME_HEIGHT = 328, 28;
M.RollBars = {};

local locale = GetLocale()
local rollpairs = locale == "deDE" and {
	["(.*) passt automatisch bei (.+), weil [ersi]+ den Gegenstand nicht benutzen kann.$"] = "pass",
	["(.*) würfelt nicht für: (.+|r)$"] = "pass",
	["(.*) hat für (.+) 'Gier' ausgewählt"] = "greed",
	["(.*) hat für (.+) 'Bedarf' ausgewählt"] = "need",
	["(.*) hat für '(.+)' Entzauberung gewählt."] = "disenchant",
} or locale == "frFR" and {
	["(.*) a passé pour : (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"] = "pass",
	["(.*) a passé pour : (.+)"] = "pass",
	["(.*) a choisi Cupidité pour : (.+)"] = "greed",
	["(.*) a choisi Besoin pour : (.+)"] = "need",
	["(.*) a choisi Désenchantement pour : (.+)"] = "disenchant",
} or locale == "zhTW" and {
	["(.*)自動放棄:(.+)，因為他無法拾取該物品$"] = "pass",
	["(.*)自動放棄:(.+)，因為她無法拾取該物品$"] = "pass",
	["(.*)放棄了:(.+)"] = "pass",
	["(.*)選擇了貪婪:(.+)"] = "greed",
	["(.*)選擇了需求:(.+)"] = "need",
	["(.*)選擇了分解:(.+)"] = "disenchant",
} or locale == "ruRU" and {
	["(.*) автоматически передает предмет (.+), поскольку не может его забрать"] = "pass",
	["(.*) пропускает розыгрыш предмета \"(.+)\", поскольку не может его забрать"] = "pass",
	["(.*) отказывается от предмета (.+)%."] = "pass",
	["Разыгрывается: (.+)%. (.*): \"Не откажусь\""] = "greed",
	["Разыгрывается: (.+)%. (.*): \"Мне это нужно\""] = "need",
	["Разыгрывается: (.+)%. (.*): \"Распылить\""] = "disenchant",
} or locale == "koKR" and {
	["(.*)님이 획득할 수 없는 아이템이어서 자동으로 주사위 굴리기를 포기했습니다: (.+)"] = "pass",
	["(.*)님이 주사위 굴리기를 포기했습니다: (.+)"] = "pass",
	["(.*)님이 차비를 선택했습니다: (.+)"] = "greed",
	["(.*)님이 입찰을 선택했습니다: (.+)"] = "need",
	["(.*)님이 마력 추출을 선택했습니다: (.+)"] = "disenchant",
} or locale == "esES" and {
	["^(.*) pasó automáticamente de: (.+) porque no puede despojar este objeto.$"] = "pass",
	["^(.*) pasó de: (.+|r)$"] = "pass",
	["(.*) eligió Codicia para: (.+)"] = "greed",
	["(.*) eligió Necesidad para: (.+)"] = "need",
	["(.*) eligió Desencantar para: (.+)"] = "disenchant",
} or locale == "esMX" and {
	["^(.*) pasó automáticamente de: (.+) porque no puede despojar este objeto.$"] = "pass",
	["^(.*) pasó de: (.+|r)$"] = "pass",
	["(.*) eligió Codicia para: (.+)"] = "greed",
	["(.*) eligió Necesidad para: (.+)"] = "need",
	["(.*) eligió Desencantar para: (.+)"] = "disenchant",
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = "pass",
	["^(.*) passed on: (.+|r)$"] = "pass",
	["(.*) has selected Greed for: (.+)"] = "greed",
	["(.*) has selected Need for: (.+)"] = "need",
	["(.*) has selected Disenchant for: (.+)"] = "disenchant"
}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype);
end

local function HideTip() GameTooltip:Hide(); end
local function HideTip2() GameTooltip:Hide(); ResetCursor(); end

local rolltypes = {"need", "greed", "disenchant", [0] = "pass"};
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
	GameTooltip:SetText(frame.tiptext);
	if(frame:IsEnabled() == 0) then
		GameTooltip:AddLine("|cffff3333"..L["Can't Roll"]);
	end

	for name, tbl in pairs(frame.parent.rolls) do
		if(tbl[1] == rolltypes[frame.rolltype] and tbl[2]) then
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[tbl[2]] or RAID_CLASS_COLORS[tbl[2]];
			GameTooltip:AddLine(name, classColor.r, classColor.g, classColor.b);
		end
	end
	GameTooltip:Show();
end

local function SetItemTip(frame)
	if(not frame.link) then return; end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT");
	GameTooltip:SetHyperlink(frame.link);
	if(IsShiftKeyDown()) then
		GameTooltip_ShowCompareItem();
	end
	if(IsModifiedClick("DRESSUP")) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

local function ItemOnUpdate(self)
	if(IsShiftKeyDown()) then
		GameTooltip_ShowCompareItem();
	end
	CursorOnUpdate(self);
end

local function LootClick(frame)
	if(IsControlKeyDown()) then
		DressUpItemLink(frame.link);
	elseif(IsShiftKeyDown()) then
		ChatEdit_InsertLink(frame.link);
	end
end

local function OnEvent(frame, _, rollID)
	cancelled_rolls[rollID] = true;
	if(frame.rollID ~= rollID) then return; end

	frame.rollID = nil;
	frame.time = nil;
	frame:Hide();
end

local function StatusUpdate(frame)
	if(not frame.parent.rollID) then return; end
	local t = GetLootRollTimeLeft(frame.parent.rollID);
	local perc = t / frame.parent.time;
	frame.spark:Point("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0);
	frame:SetValue(t);

	if(t > 1000000000) then
		frame:GetParent():Hide();
	end
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent);
	f:Point(...);
	f:Size(FRAME_HEIGHT - 4);
	f:SetNormalTexture(ntex);
	if(ptex) then f:SetPushedTexture(ptex); end
	f:SetHighlightTexture(htex);
	f.rolltype = rolltype;
	f.parent = parent;
	f.tiptext = tiptext;
	f:SetScript("OnEnter", SetTip);
	f:SetScript("OnLeave", HideTip);
	f:SetScript("OnClick", ClickRoll);
	f:SetMotionScriptsWhileDisabled(true);
	local txt = f:CreateFontString(nil, nil);
	txt:FontTemplate(nil, nil, "OUTLINE");
	txt:Point("CENTER", 0, rolltype == 2 and 1 or rolltype == 0 and -1.2 or 0);
	return f, txt;
end

function M:CreateRollFrame()
	local frame = CreateFrame("Frame", nil, E.UIParent);
	frame:Size(FRAME_WIDTH, FRAME_HEIGHT);
	frame:SetTemplate("Default");
	frame:SetScript("OnEvent", OnEvent);
	frame:RegisterEvent("CANCEL_LOOT_ROLL");
	frame:Hide();

	local button = CreateFrame("Button", nil, frame);
	button:Point("RIGHT", frame, "LEFT", -(E.Spacing*3), 0);
	button:Size(FRAME_HEIGHT - (E.Border * 2));
	button:CreateBackdrop("Default");
	button:SetScript("OnEnter", SetItemTip);
	button:SetScript("OnLeave", HideTip2);
	button:SetScript("OnUpdate", ItemOnUpdate);
	button:SetScript("OnClick", LootClick);
	frame.button = button;

	button.icon = button:CreateTexture(nil, "OVERLAY");
	button.icon:SetAllPoints();
	button.icon:SetTexCoord(unpack(E.TexCoords));

	local tfade = frame:CreateTexture(nil, "BORDER");
	tfade:Point("TOPLEFT", frame, "TOPLEFT", 4, 0);
	tfade:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0);
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground");
	tfade:SetBlendMode("ADD");
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0);

	local status = CreateFrame("StatusBar", nil, frame);
	status:SetInside();
	status:SetScript("OnUpdate", StatusUpdate);
	status:SetFrameLevel(status:GetFrameLevel() - 1);
	status:SetStatusBarTexture(E["media"].normTex);
	E:RegisterStatusBar(status);
	status:SetStatusBarColor(.8, .8, .8, .9);
	status.parent = frame;
	frame.status = status;

	status.bg = status:CreateTexture(nil, "BACKGROUND");
	status.bg:SetAlpha(0.1);
	status.bg:SetAllPoints();
	local spark = frame:CreateTexture(nil, "OVERLAY");
	spark:Size(14, FRAME_HEIGHT);
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
	spark:SetBlendMode("ADD");
	status.spark = spark;

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1);
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1);
	local de, detext;
	de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, -1);
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 2);
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de;
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext;

	local bind = frame:CreateFontString();
	bind:Point("LEFT", pass, "RIGHT", 3, 1);
	bind:FontTemplate(nil, nil, "OUTLINE");
	frame.fsbind = bind;

	local loot = frame:CreateFontString(nil, "ARTWORK");
	loot:FontTemplate(nil, nil, "OUTLINE");
	loot:Point("LEFT", bind, "RIGHT", 0, 0);
	loot:Point("RIGHT", frame, "RIGHT", -5, 0);
	loot:Size(200, 10);
	loot:SetJustifyH("LEFT");
	frame.fsloot = loot;

	frame.rolls = {};

	return frame;
end

local function GetFrame()
	for i, f in ipairs(M.RollBars) do
		if(not f.rollID) then
			return f;
		end
	end

	local f = M:CreateRollFrame();
	if(pos == "TOP") then
		f:Point("TOP", next(M.RollBars) and M.RollBars[#M.RollBars] or AlertFrameHolder, "BOTTOM", 0, -4);
	else
		f:Point("BOTTOM", next(M.RollBars) and M.RollBars[#M.RollBars] or AlertFrameHolder, "TOP", 0, 4);
	end

	tinsert(M.RollBars, f);

	return f;
end

function M:START_LOOT_ROLL(_, rollID, time)
	if(cancelled_rolls[rollID]) then return; end

	local f = GetFrame();
	f.rollID = rollID;
	f.time = time;
	for i in pairs(f.rolls) do f.rolls[i] = nil; end
	f.need:SetText(0);
	f.greed:SetText(0);
	f.pass:SetText(0);
	f.disenchant:SetText(0);

	local texture, name, _, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID);
	f.button.icon:SetTexture(texture);
	f.button.link = GetLootRollItemLink(rollID);

	if(canNeed) then f.needbutt:Enable(); else f.needbutt:Disable(); end
	if(canGreed) then f.greedbutt:Enable() else f.greedbutt:Disable(); end
	if(canDisenchant) then f.disenchantbutt:Enable(); else f.disenchantbutt:Disable(); end
	SetDesaturation(f.needbutt:GetNormalTexture(), not canNeed);
	SetDesaturation(f.greedbutt:GetNormalTexture(), not canGreed);
	SetDesaturation(f.disenchantbutt:GetNormalTexture(), not canDisenchant);
	if(canNeed) then f.needbutt:SetAlpha(1); else f.needbutt:SetAlpha(0.2); end
	if(canGreed) then f.greedbutt:SetAlpha(1); else f.greedbutt:SetAlpha(0.2); end
	if(canDisenchant) then f.disenchantbutt:SetAlpha(1); else f.disenchantbutt:SetAlpha(0.2); end

	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	local color = ITEM_QUALITY_COLORS[quality];
	f.fsloot:SetText(name);
	f.status:SetStatusBarColor(color.r, color.g, color.b, .7);
	f.status.bg:SetTexture(color.r, color.g, color.b);

	f.status:SetMinMaxValues(0, time);
	f.status:SetValue(time);

	f:SetPoint("CENTER", WorldFrame, "CENTER");
	f:Show();
	AlertFrame_FixAnchors();

	if(E.db.general.autoRoll and UnitLevel("player") == MAX_PLAYER_LEVEL and quality == 2 and not bop) then
		if(canDisenchant) then
			RollOnLoot(rollID, 3);
		else
			RollOnLoot(rollID, 2);
		end
	end
end

function M:ParseRollChoice(msg)
	for i, v in pairs(rollpairs) do
		local _, _, playername, itemname = find(msg, i);
		if(locale == "ruRU" and (v == "greed" or v == "need" or v == "disenchant")) then
			local temp = playername;
			playername = itemname;
			itemname = temp;
		end
		if(playername and itemname and playername ~= "Everyone") then return playername, itemname, v; end
	end
end

function M:CHAT_MSG_LOOT(_, msg)
	local playername, itemname, rolltype = self:ParseRollChoice(msg);
	if(playername and itemname and rolltype) then
		local class = select(2, UnitClass(playername));
		for _, f in ipairs(M.RollBars) do
			if(f.rollID and f.button.link == itemname and not f.rolls[playername]) then
				f.rolls[playername] = { rolltype, class };
				f[rolltype]:SetText(tonumber(f[rolltype]:GetText()) + 1);
				return;
			end
		end
	end
end

function M:LoadLootRoll()
	if(not E.private.general.lootRoll) then return; end

	self:RegisterEvent("CHAT_MSG_LOOT");
	self:RegisterEvent("START_LOOT_ROLL");
	UIParent:UnregisterEvent("START_LOOT_ROLL");
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL");
end