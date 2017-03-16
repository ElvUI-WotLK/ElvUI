local E, L, V, P, G = unpack(select(2, ...));
local M = E:GetModule("Misc");

local sin, cos, pi = math.sin, math.cos, math.pi;

local CreateFrame = CreateFrame;
local GetNumPartyMembers = GetNumPartyMembers;
local UnitInRaid = UnitInRaid;
local UnitIsPartyLeader = UnitIsPartyLeader;
local UnitIsRaidOfficer = UnitIsRaidOfficer;
local UnitExists, UnitIsDead = UnitExists, UnitIsDead;
local GetCursorPosition = GetCursorPosition;
local PlaySound = PlaySound;
local SetRaidTarget = SetRaidTarget;
local SetRaidTargetIconTexture = SetRaidTargetIconTexture;
local UIErrorsFrame = UIErrorsFrame;

local ButtonIsDown;

function M:RaidMarkCanMark()
	if(not self.RaidMarkFrame) then return false; end

	if(GetNumPartyMembers() > 0) then
		if(UnitIsPartyLeader("player") or (UnitInRaid("player") and UnitIsRaidOfficer("player") and not UnitIsPartyLeader("player"))) then
			return true;
		else
			UIErrorsFrame:AddMessage(L["You don't have permission to mark targets."], 1.0, 0.1, 0.1, 1.0);
			return false;
		end
	else
		return true
	end
end

function M:RaidMarkShowIcons()
	if(not UnitExists("target") or UnitIsDead("target")) then
		return;
	end
	local x, y = GetCursorPosition();
	local scale = E.UIParent:GetEffectiveScale();
	self.RaidMarkFrame:Point("CENTER", E.UIParent, "BOTTOMLEFT", x / scale, y / scale);
	self.RaidMarkFrame:Show();
end

function RaidMark_HotkeyPressed(keystate)
	ButtonIsDown = (keystate == "down") and M:RaidMarkCanMark();
	if(ButtonIsDown and M.RaidMarkFrame) then
		M:RaidMarkShowIcons();
	elseif(M.RaidMarkFrame) then
		M.RaidMarkFrame:Hide();
	end
end

function M:RaidMark_OnEvent()
	if(ButtonIsDown and self.RaidMarkFrame) then
		self:RaidMarkShowIcons();
	end
end
M:RegisterEvent("PLAYER_TARGET_CHANGED", "RaidMark_OnEvent");

function M:RaidMarkButton_OnEnter()
	self.Texture:ClearAllPoints();
	self.Texture:Point("TOPLEFT", -10, 10);
	self.Texture:Point("BOTTOMRIGHT", 10, -10);
end

function M:RaidMarkButton_OnLeave()
	self.Texture:SetAllPoints();
end

function M:RaidMarkButton_OnClick(button)
	PlaySound("UChatScrollButton");
	SetRaidTarget("target", (button ~= "RightButton") and self:GetID() or 0);
	self:GetParent():Hide();
end

function M:LoadRaidMarker()
	local marker = CreateFrame("Frame", nil, E.UIParent);
	marker:EnableMouse(true);
	marker:Size(100);
	marker:SetFrameStrata("DIALOG");

	for i = 1, 8 do
		local button = CreateFrame("Button", "RaidMarkIconButton" .. i, marker);
		button:Size(40);
		button:SetID(i);
		button.Texture = button:CreateTexture(button:GetName() .. "NormalTexture", "ARTWORK");
		button.Texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");
		button.Texture:SetAllPoints();
		SetRaidTargetIconTexture(button.Texture, i);
		button:RegisterForClicks("LeftbuttonUp","RightbuttonUp");
		button:SetScript("OnClick", M.RaidMarkButton_OnClick);
		button:SetScript("OnEnter", M.RaidMarkButton_OnEnter);
		button:SetScript("OnLeave", M.RaidMarkButton_OnLeave);
		if(i == 8) then
			button:Point("CENTER");
		else
			local angle = pi / 0.7 * i;
			button:Point("CENTER", sin(angle) * 60, cos(angle) * 60);
		end
	end

	M.RaidMarkFrame = marker;
end