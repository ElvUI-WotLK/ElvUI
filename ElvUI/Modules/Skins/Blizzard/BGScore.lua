local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local format, split = string.format, string.split
--WoW API / Variables
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetBattlefieldScore = GetBattlefieldScore
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

S:AddCallback("Skin_WorldStateScore", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.bgscore then return end

	WorldStateScoreFrame:StripTextures()
	WorldStateScoreFrame:CreateBackdrop("Transparent")
	WorldStateScoreFrame.backdrop:Point("TOPLEFT", 10, -15)
	WorldStateScoreFrame.backdrop:Point("BOTTOMRIGHT", -113, 67)

	WorldStateScoreFrame:EnableMouse(true)
	S:SetBackdropHitRect(WorldStateScoreFrame)

	S:HandleCloseButton(WorldStateScoreFrameCloseButton, WorldStateScoreFrame.backdrop)

	WorldStateScoreScrollFrame:StripTextures()
	S:HandleScrollBar(WorldStateScoreScrollFrameScrollBar)

	WorldStateScoreFrameKB:StyleButton()
	WorldStateScoreFrameDeaths:StyleButton()
	WorldStateScoreFrameHK:StyleButton()
	WorldStateScoreFrameDamageDone:StyleButton()
	WorldStateScoreFrameHealingDone:StyleButton()
	WorldStateScoreFrameHonorGained:StyleButton()
	WorldStateScoreFrameName:StyleButton()
	WorldStateScoreFrameClass:StyleButton()
	WorldStateScoreFrameTeam:StyleButton()
--	WorldStateScoreFrameRatingChange:StyleButton()

	S:HandleButton(WorldStateScoreFrameLeaveButton)

	for i = 1, 3 do
		S:HandleTab(_G["WorldStateScoreFrameTab"..i])
		_G["WorldStateScoreFrameTab"..i.."Text"]:Point("CENTER", 0, 2)
	end

	WorldStateScoreFrameTab2:Point("LEFT", WorldStateScoreFrameTab1, "RIGHT", -15, 0)
	WorldStateScoreFrameTab3:Point("LEFT", WorldStateScoreFrameTab2, "RIGHT", -15, 0)

	WorldStateScoreScrollFrameScrollBar:Point("TOPLEFT", WorldStateScoreScrollFrame, "TOPRIGHT", 8, -21)
	WorldStateScoreScrollFrameScrollBar:Point("BOTTOMLEFT", WorldStateScoreScrollFrame, "BOTTOMRIGHT", 8, 38)

	for i = 1, 5 do
		_G["WorldStateScoreColumn"..i]:StyleButton()
	end

	local myName = format("> %s <", E.myname)

	hooksecurefunc("WorldStateScoreFrame_Update", function()
		local inArena = IsActiveBattlefieldArena()
		local offset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame)

		local _, name, faction, classToken, realm, classTextColor, nameText

		for i = 1, MAX_WORLDSTATE_SCORE_BUTTONS do
			name, _, _, _, _, faction, _, _, _, classToken = GetBattlefieldScore(offset + i)

			if name then
				name, realm = split("-", name, 2)

				if name == E.myname then
					name = myName
				end

				if realm then
					local color

					if inArena then
						if faction == 1 then
							color = "|cffffd100"
						else
							color = "|cff19ff19"
						end
					else
						if faction == 1 then
							color = "|cff00adf0"
						else
							color = "|cffff1919"
						end
					end

					name = format("%s|cffffffff - |r%s%s|r", name, color, realm)
				end

				classTextColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[classToken] or RAID_CLASS_COLORS[classToken]

				nameText = _G["WorldStateScoreButton"..i.."NameText"]
				nameText:SetText(name)
				nameText:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
			end
		end
	end)
end)