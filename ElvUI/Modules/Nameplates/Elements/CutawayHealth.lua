local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local NP = E:GetModule("NamePlates")

--Lua functions
--WoW API / Variables

function NP:UpdateElement_CutawayHealthFadeOut(frame)
	local cutawayHealth = frame.CutawayHealth
	cutawayHealth.fading = true
	E:UIFrameFadeOut(cutawayHealth, self.db.cutawayHealthFadeOutTime, cutawayHealth:GetAlpha(), 0)
	cutawayHealth.isPlaying = nil
end

local function CutawayHealthClosure(frame)
	NP:UpdateElement_CutawayHealthFadeOut(frame)
end

function NP:CutawayHealthValueChangeCallback(frame, health, maxHealth)
	if self.db.cutawayHealth then
		frame.CutawayHealth:SetMinMaxValues(0, maxHealth)
		local oldValue = frame.Health:GetValue()
		local change = oldValue - health
		if change > 0 and not frame.CutawayHealth.isPlaying then
			local cutawayHealth = frame.CutawayHealth
			if cutawayHealth.fading then
				E:UIFrameFadeRemoveFrame(cutawayHealth)
			end
			cutawayHealth.fading = false
			cutawayHealth:SetValue(oldValue)
			cutawayHealth:SetAlpha(1)

			E:Delay(self.db.cutawayHealthLength, CutawayHealthClosure, frame)

			cutawayHealth.isPlaying = true
			cutawayHealth:Show()
		end
	else
		if frame.CutawayHealth.isPlaying then
			frame.CutawayHealth.isPlaying = nil
			frame.CutawayHealth:SetScript("OnUpdate", nil)
		end
		frame.CutawayHealth:Hide()
	end
end

function NP:CutawayHealthColorChangeCallback(frame, r, g, b)
	frame.CutawayHealth:SetStatusBarColor(r * 1.5, g * 1.5, b * 1.5, 1)
end

function NP:ConstructElement_CutawayHealth(parent)
	local healthBar = parent.Health

	local cutawayHealth = CreateFrame("StatusBar", "$parentCutawayHealth", healthBar)
	cutawayHealth:SetAllPoints()
	cutawayHealth:SetStatusBarTexture(E.media.blankTex)
	cutawayHealth:SetFrameLevel(healthBar:GetFrameLevel() - 1)

	NP:RegisterHealthBarCallbacks(parent, NP.CutawayHealthValueChangeCallback, NP.CutawayHealthColorChangeCallback)

	return cutawayHealth
end