local E, L, V, P, G = unpack(select(2, ...));
local mod = E:NewModule("DataBars", "AceEvent-3.0");
E.DataBars = mod;

local _G = _G;

local GetExpansionLevel = GetExpansionLevel;
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE;

function mod:OnLeave()
	if((self == ElvUI_ExperienceBar and mod.db.experience.mouseover) or (self == ElvUI_ReputationBar and mod.db.reputation.mouseover) or (self == ElvUI_HonorBar and mod.db.honor.mouseover)) then
		E:UIFrameFadeOut(self, 1, self:GetAlpha(), 0);
	end
	GameTooltip:Hide();
end

function mod:CreateBar(name, onEnter, onClick, ...)
	local bar = CreateFrame("Button", name, E.UIParent);
	bar:Point(...);
	bar:SetScript("OnEnter", onEnter);
	bar:SetScript("OnLeave", mod.OnLeave);
	bar:SetScript("OnClick", onClick)
	bar:SetFrameStrata("LOW");
	bar:SetTemplate("Transparent");
	bar:Hide();

	bar.statusBar = CreateFrame("StatusBar", nil, bar);
	bar.statusBar:SetInside();
	bar.statusBar:SetStatusBarTexture(E.media.normTex);
	E:RegisterStatusBar(bar.statusBar);
	bar.text = bar.statusBar:CreateFontString(nil, "OVERLAY");
	bar.text:FontTemplate();
	bar.text:Point("CENTER");

	E.FrameLocks[name] = true;

	return bar;
end

function mod:UpdateDataBarDimensions()
	self:UpdateExperienceDimensions();
	self:UpdateReputationDimensions();
end

function mod:PLAYER_LEVEL_UP(level)
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()];
	if((level ~= maxLevel or not self.db.experience.hideAtMaxLevel) and self.db.experience.enable) then
		self:UpdateExperience("PLAYER_LEVEL_UP", level);
	else
		self.expBar:Hide();
	end
end

function mod:Initialize()
	self.db = E.db.databars;

	self:LoadExperienceBar();
	self:LoadReputationBar();
	self:RegisterEvent("PLAYER_LEVEL_UP");
end

E:RegisterModule(mod:GetName());