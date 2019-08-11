local E, L = unpack(select(2, ...)); --Import: Engine, Locales
local B = E:GetModule("Blizzard")

--Lua functions
--WoW API / Variables

function B:PositionGMFrames()
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", 250, -5)

	E:CreateMover(TicketStatusFrame, "GMMover", L["GM Ticket Frame"])
end