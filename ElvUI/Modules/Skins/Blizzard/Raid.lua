local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local ipairs = ipairs
local unpack = unpack
--WoW API / Variables

S:AddCallbackForAddon("Blizzard_RaidUI", "Skin_Blizzard_RaidUI", function()
	if E.private.skins.blizzard.enable and E.private.skins.blizzard.friends then
		RaidClassButton1:HookScript("OnShow", function()
			S:SetUIPanelWindowInfo(FriendsFrame, "width", nil, 21)
		end)
		RaidClassButton1:HookScript("OnHide", function()
			S:SetUIPanelWindowInfo(FriendsFrame, "width")
		end)
	end

	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.raid then return end

	local StripAllTextures = {
		RaidGroup1,
		RaidGroup2,
		RaidGroup3,
		RaidGroup4,
		RaidGroup5,
		RaidGroup6,
		RaidGroup7,
		RaidGroup8
	}

	for _, object in ipairs(StripAllTextures) do
		object:StripTextures()
	end

	RaidFrameRaidBrowserButton:Point("TOPLEFT", RaidFrame, 45, -33)

	S:HandleButton(RaidFrameRaidBrowserButton)
	S:HandleButton(RaidFrameReadyCheckButton)
--	S:HandleButton(RaidFrameRaidInfoButton)		-- skinned in Friends.lua

	for i = 1, MAX_RAID_GROUPS * 5 do
		S:HandleButton(_G["RaidGroupButton"..i], true)
	end

	for i = 1, 8 do
		for j = 1, 5 do
			local slot = _G["RaidGroup"..i.."Slot"..j]
			slot:StripTextures()
			slot:SetTemplate("Transparent")
		end
	end

	do
		local prevButton
		local button, icon, count, coords

		for index = 1, 13 do
			button = _G["RaidClassButton"..index]
			icon = _G["RaidClassButton"..index.."IconTexture"]
			count = _G["RaidClassButton"..index.."Count"]

			button:StripTextures()
			button:SetTemplate("Default")
			button:Size(22)

			button:ClearAllPoints()
			if index == 1 then
				button:Point("TOPLEFT", RaidFrame, "TOPRIGHT", -33, -44)
			elseif index == 11 then
				button:Point("TOP", prevButton, "BOTTOM", 0, -25)
			else
				button:Point("TOP", prevButton, "BOTTOM", 0, -5)
			end
			prevButton = button

			icon:SetInside()

			if index == 11 then
				icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-Pets")
				icon:SetTexCoord(unpack(E.TexCoords))
			elseif index == 12 then
				icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-MainTank")
				icon:SetTexCoord(unpack(E.TexCoords))
			elseif index == 13 then
				icon:SetTexture("Interface\\RaidFrame\\UI-RaidFrame-MainAssist")
				icon:SetTexCoord(unpack(E.TexCoords))
			else
				coords = CLASS_ICON_TCOORDS[CLASS_SORT_ORDER[index]]
				icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
				icon:SetTexCoord(coords[1] + 0.02, coords[2] - 0.02, coords[3] + 0.02, coords[4] - 0.02)
			end

			count:FontTemplate(nil, 12, "OUTLINE")
		end
	end

	hooksecurefunc("RaidPulloutButton_OnDragStart", function(frame)
		if InCombatLockdown() then return end

		local scale = GetScreenHeightScale()
		local cursorX, cursorY = GetCursorPosition()
		frame:SetPoint("TOP", nil, "BOTTOMLEFT", cursorX * scale, cursorY * scale)
	end)

	local nSkinned = 0
	hooksecurefunc("RaidPullout_GetFrame", function()
		if nSkinned < NUM_RAID_PULLOUT_FRAMES then
			nSkinned = NUM_RAID_PULLOUT_FRAMES

			local pfButton = _G["RaidPullout"..nSkinned]
			pfButton:CreateBackdrop("Transparent")
			pfButton.backdrop:Point("TOPLEFT", 9, -17)
			pfButton.backdrop:Point("BOTTOMRIGHT", -7, 7)

			_G["RaidPullout"..nSkinned.."MenuBackdrop"]:SetBackdrop(nil)
		end
	end)

	local MAX_RAID_AURAS = MAX_RAID_AURAS
	local pfButtonSubFrames = {"HealthBar", "ManaBar", "Target", "TargetTarget"}

	hooksecurefunc("RaidPullout_Update", function(pullOutFrame)
		for _, pfButton in ipairs(pullOutFrame.buttons) do
			if not pfButton.backdrop then
				local pfBName = pfButton:GetName()
				local pfTot = _G[pfBName.."TargetTargetFrame"]

				for _, sName in ipairs(pfButtonSubFrames) do
					local sBar = _G[pfBName..sName]
					sBar:StripTextures()
					sBar:SetStatusBarTexture(E.media.normTex)
				end

				pfButton:CreateBackdrop("Default")
				pfButton.backdrop:Point("TOPLEFT", E.PixelMode and 0 or -1, -(E.PixelMode and 10 or 9))
				pfButton.backdrop:Point("BOTTOMRIGHT", E.PixelMode and 0 or 1, E.PixelMode and -2 or 0)

				pfTot:StripTextures()
				pfTot:CreateBackdrop("Default")
				pfTot.backdrop:Point("TOPLEFT", E.PixelMode and 10 or 9, -(E.PixelMode and 15 or 14))
				pfTot.backdrop:Point("BOTTOMRIGHT", -(E.PixelMode and 10 or 9), E.PixelMode and 8 or 7)

				for i = 1, MAX_RAID_AURAS do
					S:HandleIcon(_G[pfBName.."Aura"..i.."Icon"])
					_G[pfBName.."Aura"..i.."Border"]:Hide()
				end
			end
		end
	end)
end)