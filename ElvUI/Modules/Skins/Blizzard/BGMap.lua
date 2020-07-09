local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_BattlefieldMinimap", "Skin_Blizzard_BattlefieldMinimap", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgmap then return end

	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()

	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimap:SetFrameStrata("LOW")
	BattlefieldMinimap:CreateBackdrop("Default")
	BattlefieldMinimap.backdrop:Point("BOTTOMRIGHT", E.Border - E:Scale(6), -(E.Border - E:Scale(4)))

	S:SetBackdropHitRect(BattlefieldMinimap, nil, true)

	S:HandleCloseButton(BattlefieldMinimapCloseButton, BattlefieldMinimap.backdrop)
	BattlefieldMinimapCloseButton:SetFrameLevel(BattlefieldMinimap:GetFrameLevel() + 5)

	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)

	BattlefieldMinimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapTab._moved then
				BattlefieldMinimapTab:StopMovingOrSizing()
				BattlefieldMinimapTab._moved = nil
			end
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
		end
	end)

	BattlefieldMinimap:SetScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked then return end

			BattlefieldMinimapTab._moved = true
			BattlefieldMinimapTab:StartMoving()
		end
	end)

	hooksecurefunc("BattlefieldMinimap_UpdateOpacity", function()
		BattlefieldMinimap.backdrop:SetAlpha(1.0 - BattlefieldMinimapOptions.opacity)
	end)

	local oldAlpha
	BattlefieldMinimap:HookScript("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimap:HookScript("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)

	BattlefieldMinimapCloseButton:HookScript("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimapCloseButton:HookScript("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)
end)