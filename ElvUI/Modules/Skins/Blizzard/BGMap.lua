local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bgmap ~= true then return end

	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()

	BattlefieldMinimap:CreateBackdrop("Default")
	BattlefieldMinimap.backdrop:SetPoint("BOTTOMRIGHT", E.Border - E:Scale(6), -(E.Border - E:Scale(4)))
	BattlefieldMinimap:SetFrameStrata("LOW")
	BattlefieldMinimapCloseButton:ClearAllPoints()
	BattlefieldMinimapCloseButton:Point("TOPRIGHT", -6, 0)
	S:HandleCloseButton(BattlefieldMinimapCloseButton)
	BattlefieldMinimapCloseButton:SetFrameLevel(BattlefieldMinimap:GetFrameLevel() + 5)

	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)

	BattlefieldMinimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			BattlefieldMinimapTab:StopMovingOrSizing()
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
		end
	end)

	BattlefieldMinimap:SetScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked then
				return
			else
				BattlefieldMinimapTab:StartMoving()
			end
		end
	end)

	hooksecurefunc("BattlefieldMinimap_UpdateOpacity", function()
		local alpha = 1.0 - BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap.backdrop:SetAlpha(alpha)
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
end

S:AddCallbackForAddon("Blizzard_BattlefieldMinimap", "BattlefieldMinimap", LoadSkin)