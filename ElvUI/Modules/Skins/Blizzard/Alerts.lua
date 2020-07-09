local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
local tonumber = tonumber
local match = string.match
--WoW API / Variables

S:AddCallback("Skin_Alerts", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.alertframes then return end

	S:RawHook("AchievementAlertFrame_GetAlertFrame", function()
		local frame = S.hooks.AchievementAlertFrame_GetAlertFrame()

		if frame and not frame.isSkinned then
			local name = frame:GetName()

			frame:DisableDrawLayer("OVERLAY")

			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, 0, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, 0, 6)

			S:SetBackdropHitRect(frame)

			_G[name.."Background"]:SetTexture(nil)
			_G[name.."Unlocked"]:SetTextColor(1, 1, 1)

			local icon = _G[name.."Icon"]
			icon:DisableDrawLayer("BACKGROUND")
			icon:DisableDrawLayer("OVERLAY")

			icon.texture:ClearAllPoints()
			icon.texture:Point("LEFT", frame, 13, 0)
			icon.texture:SetTexCoord(unpack(E.TexCoords))

			icon:CreateBackdrop("Default")
			icon.backdrop:SetOutside(icon.texture)

			frame.isSkinned = true

			if tonumber(match(name, ".+(%d+)")) == MAX_ACHIEVEMENT_ALERTS then
				S:Unhook("AchievementAlertFrame_GetAlertFrame")
			end
		end

		return frame
	end, true)

	local frame = DungeonCompletionAlertFrame1
	frame:DisableDrawLayer("BORDER")
	frame:DisableDrawLayer("OVERLAY")

	frame:CreateBackdrop("Transparent")
	frame.backdrop:Point("TOPLEFT", frame, 0, -6)
	frame.backdrop:Point("BOTTOMRIGHT", frame, 0, 6)

	S:SetBackdropHitRect(frame)

	frame.dungeonTexture:ClearAllPoints()
	frame.dungeonTexture:Point("LEFT", frame, 13, 0)
	frame.dungeonTexture:Size(42)
	frame.dungeonTexture:SetTexCoord(unpack(E.TexCoords))

	frame.dungeonTexture.backdrop = CreateFrame("Frame", "$parentDungeonTextureBackground", frame)
	frame.dungeonTexture.backdrop:SetTemplate("Default")
	frame.dungeonTexture.backdrop:SetOutside(frame.dungeonTexture)
	frame.dungeonTexture.backdrop:SetFrameLevel(0)

	frame.glowFrame:DisableDrawLayer("OVERLAY")
end)