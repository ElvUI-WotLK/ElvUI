local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule("ActionBars");

local split = string.split;

function AB:CreateBar5()
	local bar = CreateFrame("Frame", "ElvUI_Bar5", E.UIParent, "SecureHandlerStateTemplate");
	local point, anchor, attachTo, x, y = split(",", self["barDefaults"]["bar5"].position);
	bar:Point(point, anchor, attachTo, x, y);
	bar.id = "5";
	bar:SetFrameStrata("LOW");
	bar:CreateBackdrop("Default");
	local offset = E.Spacing;
	bar.backdrop:SetPoint("TOPLEFT", bar, "TOPLEFT", offset, -offset);
	bar.backdrop:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -offset, offset);
	bar.buttons = {};
	self:HookScript(bar, "OnEnter", "Bar_OnEnter");
	self:HookScript(bar, "OnLeave", "Bar_OnLeave");
	
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = _G["MultiBarRightButton" .. i];
		bar.buttons[i] = button;
		bar:SetFrameRef("MultiBarRightButton" .. i, button);
		self:HookScript(button, "OnEnter", "Button_OnEnter");
		self:HookScript(button, "OnLeave", "Button_OnLeave");
	end
	
	bar:Execute([[
		buttons = table.new();
		for i = 1, 12 do
			table.insert(buttons, self:GetFrameRef("MultiBarRightButton" .. i));
		end
	]]);
	
	bar:SetAttribute("_onstate-page", [[ 
		for i, button in ipairs(buttons) do
			button:SetAttribute("actionpage", tonumber(newstate));
		end
	]]);
	
	bar:SetAttribute("_onstate-show", [[		
		if(newstate == "hide") then
			self:Hide();
		else
			self:Show();
		end
	]])
	
	self["handledBars"]["bar5"] = bar;
	E:CreateMover(bar, "ElvAB_5", L["Bar "] .. "5", nil, nil, nil,"ALL,ACTIONBARS");
	self:PositionAndSizeBar("bar5");
end