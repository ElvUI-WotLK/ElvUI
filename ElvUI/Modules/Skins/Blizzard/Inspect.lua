local E, L, V, P, G = unpack(select(2, ...)) -- Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

S:AddCallbackForAddon("Blizzard_InspectUI", "Skin_Blizzard_InspectUI", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.inspect then return end

	InspectFrame:StripTextures(true)
	InspectFrame:CreateBackdrop("Transparent")
	InspectFrame.backdrop:Point("TOPLEFT", 11, -12)
	InspectFrame.backdrop:Point("BOTTOMRIGHT", -32, 76)

	S:SetUIPanelWindowInfo(InspectFrame, "width")

	S:SetBackdropHitRect(InspectFrame)
	S:SetBackdropHitRect(InspectPVPFrame, InspectFrame.backdrop)
	S:SetBackdropHitRect(InspectTalentFrame, InspectFrame.backdrop)

	InspectPVPFrameHonor:SetHitRectInsets(0, 120, 0, 0)
	InspectPVPFrameArena:SetHitRectInsets(0, 120, 0, 0)

	S:HandleCloseButton(InspectFrameCloseButton, InspectFrame.backdrop)

	S:HandleTab(InspectFrameTab1)
	S:HandleTab(InspectFrameTab2)
	S:HandleTab(InspectFrameTab3)

	InspectPaperDollFrame:StripTextures()

	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot"
	}

	for _, slot in ipairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		local frame = _G["Inspect"..slot]

		frame:StripTextures()
		frame:SetFrameLevel(frame:GetFrameLevel() + 2)
		frame:CreateBackdrop("Default")
		frame.backdrop:SetAllPoints()

		frame:StyleButton()

		icon:SetTexCoord(unpack(E.TexCoords))
		icon:SetInside()
	end

	local styleButton
	do
		local function awaitCache(button)
			if InspectFrame.unit then
				styleButton(button)
			end
		end

		styleButton = function(button)
			if button.hasItem then
				local itemID = GetInventoryItemID(InspectFrame.unit, button:GetID())
				if itemID then
					local _, _, quality = GetItemInfo(itemID)

					if not quality then
						E:Delay(0.1, awaitCache, button)
						return
					elseif quality then
						button.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
						return
					end
				end
			end

			button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", styleButton)

	S:HandleRotateButton(InspectModelRotateLeftButton)
	S:HandleRotateButton(InspectModelRotateRightButton)

	InspectPVPFrame:StripTextures()

	for i = 1, MAX_ARENA_TEAMS do
		local frame = _G["InspectPVPTeam"..i]
		frame:StripTextures()
		frame:CreateBackdrop("Transparent")
		frame.backdrop:Point("TOPLEFT", 9, -6)
		frame.backdrop:Point("BOTTOMRIGHT", -24, -5)
	--	_G["InspectPVPTeam"..i.."StandardBar"]:Kill()
		S:SetBackdropHitRect(frame)
	end

	InspectTalentFrame:StripTextures()

	S:HandleCloseButton(InspectTalentFrameCloseButton, InspectFrame.backdrop)

	for i = 1, MAX_TALENT_TABS do
		local headerTab = _G["InspectTalentFrameTab"..i]

		headerTab:StripTextures()
		headerTab:CreateBackdrop("Default", true)
		headerTab.backdrop:Point("TOPLEFT", 2, -7)
		headerTab.backdrop:Point("BOTTOMRIGHT", 1, -1)
		S:SetBackdropHitRect(headerTab)

		headerTab:Width(i == 2 and 101 or 102)
		headerTab.SetWidth = E.noop

		headerTab:HookScript("OnEnter", S.SetModifiedBackdrop)
		headerTab:HookScript("OnLeave", S.SetOriginalBackdrop)
	end

	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["InspectTalentFrameTalent"..i]

		if talent then
			local icon = _G["InspectTalentFrameTalent"..i.."IconTexture"]
			local rank = _G["InspectTalentFrameTalent"..i.."Rank"]

			talent:StripTextures()
			talent:SetTemplate("Default")
			talent:StyleButton()

			icon:SetInside()
			icon:SetTexCoord(unpack(E.TexCoords))
			icon:SetDrawLayer("ARTWORK")

			rank:SetFont(E.LSM:Fetch("font", E.db.general.font), 12, "OUTLINE")
		end
	end

	InspectHeadSlot:Point("TOPLEFT", 19, -76)
	InspectHandsSlot:Point("TOPLEFT", 307, -76)
	InspectMainHandSlot:Point("TOPLEFT", InspectPaperDollFrame, "BOTTOMLEFT", 121, 131)

	InspectModelFrame:Size(237, 324)
	InspectModelFrame:Point("TOPLEFT", 63, -76)

	InspectModelRotateLeftButton:Point("TOPLEFT", 4, -4)

	InspectTalentFrameScrollFrame:StripTextures()
	InspectTalentFrameScrollFrame:CreateBackdrop("Transparent")
	InspectTalentFrameScrollFrame.backdrop:Point("TOPLEFT", -1, 1)
	InspectTalentFrameScrollFrame.backdrop:Point("BOTTOMRIGHT", 5, -4)

	InspectTalentFramePointsBar:StripTextures()

	InspectModelRotateRightButton:Point("TOPLEFT", InspectModelRotateLeftButton, "TOPRIGHT", 3, 0)

	InspectFrameTab1:Point("CENTER", InspectFrame, "BOTTOMLEFT", 54, 62)
	InspectFrameTab2:Point("LEFT", InspectFrameTab1, "RIGHT", -15, 0)
	InspectFrameTab3:Point("LEFT", InspectFrameTab2, "RIGHT", -15, 0)

	InspectTalentFrameBackgroundTopLeft:Point("TOPLEFT", 21, -77)

	InspectTalentFrameTab1:Point("TOPLEFT", 17, -40)

	InspectTalentFrameScrollFrame:Width(298)
	InspectTalentFrameScrollFrame:Point("TOPRIGHT", -66, -77)

	S:HandleScrollBar(InspectTalentFrameScrollFrameScrollBar)
	InspectTalentFrameScrollFrameScrollBar:Point("TOPLEFT", InspectTalentFrameScrollFrame, "TOPRIGHT", 8, -18)
	InspectTalentFrameScrollFrameScrollBar:Point("BOTTOMLEFT", InspectTalentFrameScrollFrame, "BOTTOMRIGHT", 8, 15)
end)