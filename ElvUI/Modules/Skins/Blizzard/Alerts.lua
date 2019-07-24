local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
local tonumber = tonumber

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.alertframes ~= true then return end

	S:RawHook("AchievementAlertFrame_GetAlertFrame", function()
		local frame = S.hooks.AchievementAlertFrame_GetAlertFrame()
		if frame and not frame.isSkinned then
			local name = frame:GetName()

			frame:DisableDrawLayer("OVERLAY")

			frame:CreateBackdrop("Transparent")
			frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
			frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

			_G[name.."Background"]:SetTexture(nil)
			_G[name.."Unlocked"]:SetTextColor(1, 1, 1)

			icon = _G[name.."Icon"]
			icon:DisableDrawLayer("BACKGROUND")
			icon:DisableDrawLayer("OVERLAY")

			icon.texture:ClearAllPoints()
			icon.texture:Point("LEFT", frame, 7, 0)
			icon.texture:SetTexCoord(unpack(E.TexCoords))

			icon:CreateBackdrop("Default")
			icon.backdrop:SetOutside(icon.texture)

			frame.isSkinned = true

			if tonumber(name:match(".+(%d+)")) == MAX_ACHIEVEMENT_ALERTS then
				S:Unhook("AchievementAlertFrame_GetAlertFrame")
			end
		end

		return frame
	end, true)

	local frame = DungeonCompletionAlertFrame1
	frame:DisableDrawLayer("BORDER")
	frame:DisableDrawLayer("OVERLAY")

	frame:CreateBackdrop("Transparent")
	frame.backdrop:Point("TOPLEFT", frame, "TOPLEFT", -2, -6)
	frame.backdrop:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 6)

	frame.dungeonTexture:ClearAllPoints()
	frame.dungeonTexture:Point("LEFT", frame, 7, 0)
	frame.dungeonTexture:SetTexCoord(unpack(E.TexCoords))

	frame.dungeonTexture.backdrop = CreateFrame("Frame", "$parentDungeonTextureBackground", frame)
	frame.dungeonTexture.backdrop:SetTemplate("Default")
	frame.dungeonTexture.backdrop:SetOutside(frame.dungeonTexture)
	frame.dungeonTexture.backdrop:SetFrameLevel(0)

	frame.glowFrame:DisableDrawLayer("OVERLAY")
end

S:AddCallback("Alerts", LoadSkin)