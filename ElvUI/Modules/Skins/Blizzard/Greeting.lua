local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")

--Lua functions
local _G = _G
local find, gsub = string.find, string.gsub
--WoW API / Variables

local function LoadSkin()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.greeting then return end

	QuestFrameGreetingPanel:StripTextures(true)

	S:HandleButton(QuestFrameGreetingGoodbyeButton, true)
	QuestFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -37, 4)

	QuestGreetingFrameHorizontalBreak:Kill()

	QuestGreetingScrollFrame:Height(403)

	S:HandleScrollBar(QuestGreetingScrollFrameScrollBar)

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		GreetingText:SetTextColor(1, 1, 1)
		CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
		AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

		for i = 1, MAX_NUM_QUESTS do
			local button = _G["QuestTitleButton"..i]
			if button:GetFontString() then
				if button:GetFontString():GetText() and find(button:GetFontString():GetText(), "|cff000000") then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
end

S:AddCallback("Skin_Greeting", LoadSkin)