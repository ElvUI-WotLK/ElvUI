local E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

local _G = _G
local find, gsub = string.find, string.gsub

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.greeting ~= true then return end

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		QuestFrameGreetingPanel:StripTextures()

		S:HandleButton(QuestFrameGreetingGoodbyeButton, true)
		QuestFrameGreetingGoodbyeButton:Point("BOTTOMRIGHT", -37, 4)

		GreetingText:SetTextColor(1, 1, 1)
		CurrentQuestsText:SetTextColor(1, 0.80, 0.10)
		AvailableQuestsText:SetTextColor(1, 0.80, 0.10)

		QuestGreetingFrameHorizontalBreak:Kill()

		QuestGreetingScrollFrame:Height(403)

		S:HandleScrollBar(QuestGreetingScrollFrameScrollBar)

		for i = 1, MAX_NUM_QUESTS do
			local button = _G["QuestTitleButton"..i]
			if button:GetFontString() then
				if button:GetFontString():GetText() and button:GetFontString():GetText():find("|cff000000") then
					button:GetFontString():SetText(gsub(button:GetFontString():GetText(), "|cff000000", "|cffFFFF00"))
				end
			end
		end
	end)
end

S:AddCallback("Greeting", LoadSkin)