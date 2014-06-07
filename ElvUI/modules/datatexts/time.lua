local E, L, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM };
local europeDisplayFormat = '';
local ukDisplayFormat = '';
local europeDisplayFormat_nocolor = string.join("", "%02d", ":|r%02d");
local ukDisplayFormat_nocolor = string.join("", "", "%d", ":|r%02d", " %s|r");
local timerLongFormat = "%d:%02d:%02d";
local timerShortFormat = "%d:%02d";
local lockoutInfoFormat = "%s |cfff04000(%s%s)";
local lockoutColorExtended, lockoutColorNormal = { r = 0.3, g = 1, b = 0.3 }, { r = .8,g = .8,b = .8 };
local difficultyInfo = { "N", "N", "H", "H" };
local lockoutFormatString = { "%dd %02dh %02dm", "%dd %dh %02dm", "%02dh %02dm", "%dh %02dm", "%dh %02dm", "%dm" };
local curHr, curMin, curAmPm;

local Update, lastPanel;
local function ValueColorUpdate(hex, r, g, b)
	europeDisplayFormat = string.join("", "%02d", hex, ":|r%02d ", format("%s", date(hex.."%x|r")));
	ukDisplayFormat = string.join("", "", "%d", hex, ":|r%02d", hex, " %s|r ", format("%s", date(hex.."%x|r")));
	
	if lastPanel ~= nil then
		Update(lastPanel, 20000);
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

local function CalculateTimeValues(tt)
	local Hr, Min, AmPm;
	if tt and tt == true then
		if E.db.datatexts.localtime == true then
			Hr, Min = GetGameTime();
			if E.db.datatexts.time24 == true then
				return Hr, Min, -1;
			else
				if Hr>=12 then
					if Hr>12 then Hr = Hr - 12; end
					AmPm = 1;
				else
					if Hr == 0 then Hr = 12; end
					AmPm = 2;
				end
				return Hr, Min, AmPm;
			end			
		else
			local Hr24 = tonumber(date("%H"))
			Hr = tonumber(date("%I"));
			Min = tonumber(date("%M"));
			if E.db.datatexts.time24 == true then
				return Hr24, Min, -1;
			else
				if Hr24>=12 then AmPm = 1; else AmPm = 2; end
				return Hr, Min, AmPm;
			end
		end
	else
		if E.db.datatexts.localtime == true then
			local Hr24 = tonumber(date("%H"));
			Hr = tonumber(date("%I"));
			Min = tonumber(date("%M"));
			if E.db.datatexts.time24 == true then
				return Hr24, Min, -1;
			else
				if Hr24>=12 then AmPm = 1; else AmPm = 2; end
				return Hr, Min, AmPm;
			end
		else
			Hr, Min = GetGameTime();
			if E.db.datatexts.time24 == true then
				return Hr, Min, -1;
			else
				if Hr>=12 then
					if Hr>12 then Hr = Hr - 12; end
					AmPm = 1;
				else
					if Hr == 0 then Hr = 12; end
					AmPm = 2;
				end
				return Hr, Min, AmPm;
			end
		end	
	end
end

local function CalculateTimeLeft(time)
	local hour = floor(time / 3600);
	local min = floor(time / 60 - (hour*60));
	local sec = time - (hour * 3600) - (min * 60);
	
	return hour, min, sec;
end

local function formatResetTime(sec)
	local table = table or {};
	local d,h,m,s = ChatFrame_TimeBreakDown(floor(sec));
	local string = gsub(gsub(format(" %dd %dh %dm "..((d==0 and h==0) and "%ds" or ""),d,h,m,s)," 0[dhms]"," "),"%s+"," ");
	local string = strtrim(gsub(string, "([dhms])", {d=table.days or "d",h=table.hours or "h",m=table.minutes or "m",s=table.seconds or "s"})," ");
	return strmatch(string,"^%s*$") and "0"..(table.seconds or L"s") or string;
end

local function Click()
	GameTimeFrame:Click();
end

local function OnLeave(self)
	DT.tooltip:Hide();
	enteredFrame = false;
end

local function OnEnter(self)
	DT:SetupTooltip(self);
	enteredFrame = true;
	
	local wgtime = GetWintergraspWaitTime() or nil;
	inInstance, instanceType = IsInInstance();
	if not ( instanceType == "none" ) then
		wgtime = QUEUE_TIME_UNAVAILABLE;
	elseif wgtime == nil then
		wgtime = WINTERGRASP_IN_PROGRESS;
	else
		local h, m, s = CalculateTimeLeft(wgtime);
		if h > 0 then 
			wgtime = format(timerLongFormat, h, m, s);
		else 
			wgtime = format(timerShortFormat, m, s);
		end
	end
	DT.tooltip:AddDoubleLine(L['Wintergrasp'], wgtime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);
	DT.tooltip:AddLine(' ');
	
	local timeText;
	local Hr, Min, AmPm = CalculateTimeValues(true);

	timeText = E.db.datatexts.localtime == true and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME;
	if AmPm == -1 then
		DT.tooltip:AddDoubleLine(timeText, string.format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);
	else
		DT.tooltip:AddDoubleLine(timeText, string.format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b);
	end

	local oneraid, lockoutColor;
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, difficulty, locked, extended, _, isRaid, maxPlayers  = GetSavedInstanceInfo(i);
		if isRaid and (locked or extended) then
			local tr,tg,tb,diff;
			if not oneraid then
				DT.tooltip:AddLine(" ");
				DT.tooltip:AddLine(L["Saved Raid(s)"]);
				oneraid = true;
			end
			if extended then lockoutColor = lockoutColorExtended; else lockoutColor = lockoutColorNormal; end
			DT.tooltip:AddDoubleLine(format(lockoutInfoFormat,name, maxPlayers, difficultyInfo[difficulty] ), formatResetTime(reset), 1,1,1, lockoutColor.r,lockoutColor.g,lockoutColor.b);
		end
	end
	DT.tooltip:Show();
end

local int = 1;
function Update(self, t)
	int = int - t;
	
	if enteredFrame then
		OnEnter(self);
	end
	
	if GameTimeFrame.flashInvite then
		E:Flash(self, 0.53);
	else
		E:StopFlash(self);
	end
	
	if int > 0 then return end
	
	local Hr, Min, AmPm = CalculateTimeValues(false);

	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 2;
		return;
	end
	
	curHr = Hr;
	curMin = Min;
	curAmPm = AmPm;
	
	if AmPm == -1 then
		self.text:SetFormattedText(europeDisplayFormat, Hr, Min);
	else
		self.text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm]);
	end
	lastPanel = self;
	int = 2;
end

DT:RegisterDatatext(L['Time'], nil, nil, Update, Click, OnEnter, OnLeave)