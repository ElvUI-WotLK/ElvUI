local parent, ns = ...;
local oUF = ns.oUF;

local hiddenParent = CreateFrame("Frame");
hiddenParent:Hide();

local HandleFrame = function(baseName)
	local frame;
	if(type(baseName) == "string") then
		frame = _G[baseName];
	else
		frame = baseName;
	end
	
	if(frame) then
		frame:UnregisterAllEvents();
		frame:Hide();
		
		frame:SetParent(hiddenParent);

		local health = frame.healthbar;
		if(health) then
			health:UnregisterAllEvents();
		end
		
		local power = frame.manabar;
		if(power) then
			power:UnregisterAllEvents();
		end
		
		local spell = frame.spellbar;
		if(spell) then
			spell:UnregisterAllEvents();
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return; end
	
	if(unit == "player") then
		HandleFrame(PlayerFrame);
		
		PlayerFrame:RegisterEvent("UNIT_ENTERING_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_EXITING_VEHICLE");
		PlayerFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
	elseif(unit == "pet") then
		HandleFrame(PetFrame);
	elseif(unit == "target") then
		HandleFrame(TargetFrame);
		HandleFrame(ComboFrame);
	elseif(unit == "focus") then
		HandleFrame(FocusFrame);
		HandleFrame(TargetofFocusFrame);
	elseif(unit == "targettarget") then
		HandleFrame(TargetFrameToT);
	elseif(unit:match("(boss)%d?$") == "boss") then
		local id = unit:match("boss(%d)");
		if(id) then
			HandleFrame("Boss" .. id .. "TargetFrame");
		else
			for i = 1, 4 do
				HandleFrame(("Boss%dTargetFrame"):format(i));
			end
		end
	elseif(unit:match("(party)%d?$") == "party") then
		local id = unit:match("party(%d)");
		if(id) then
			HandleFrame("PartyMemberFrame" .. id);
		else
			for i = 1, 4 do
				HandleFrame(("PartyMemberFrame%d"):format(i));
			end
		end
	elseif(unit:match("(arena)%d?$") == "arena") then
		local id = unit:match("arena(%d)");
		if(id) then
			HandleFrame("ArenaEnemyFrame" .. id);
		else
			for i = 1, 4 do
				HandleFrame(("ArenaEnemyFrame%d"):format(i));
			end
		end
		
		Arena_LoadUI = function() end
	end
end
