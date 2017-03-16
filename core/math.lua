local E, L, V, P, G = unpack(select(2, ...));

local select, unpack, assert, tonumber, type, pairs = select, unpack, assert, tonumber, type, pairs;
local tinsert, tremove = tinsert, tremove;
local abs, ceil, floor, modf, mod = math.abs, math.ceil, math.floor, math.modf, mod;
local format, sub, upper, split, utf8sub = string.format, string.sub, string.upper, string.split, string.utf8sub;

local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight;
local CreateFrame = CreateFrame;

function E:ShortValue(v)
	if(E.db.general.numberPrefixStyle == "METRIC") then
		if(abs(v) >= 1e9) then
			return format("%.1fG", v / 1e9);
		elseif(abs(v) >= 1e6) then
			return format("%.1fM", v / 1e6);
		elseif(abs(v) >= 1e3) then
			return format("%.1fk", v / 1e3);
		else
			return format("%d", v);
		end
	elseif(E.db.general.numberPrefixStyle == "CHINESE") then
		if(abs(v) >= 1e8) then
			return format("%.1fY", v / 1e8);
		elseif(abs(v) >= 1e4) then
			return format("%.1fW", v / 1e4);
		else
			return format("%d", v);
		end
	else
		if(abs(v) >= 1e9) then
			return format("%.1fB", v / 1e9);
		elseif(abs(v) >= 1e6) then
			return format("%.1fM", v / 1e6);
		elseif(abs(v) >= 1e3) then
			return format("%.1fK", v / 1e3);
		else
			return format("%d", v);
		end
	end
end

function E:IsEvenNumber(num)
	return num % 2 == 0;
end

function E:ColorGradient(perc, ...)
	if(perc >= 1) then
		local r, g, b = select(select("#", ...) - 2, ...);
		return r, g, b;
	elseif(perc <= 0) then
		local r, g, b = ...;
		return r, g, b;
	end

	local num = select("#", ...) / 3;
	local segment, relperc = modf(perc*(num-1));
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...);

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc;
end

function E:Round(num, idp)
	if(idp and idp > 0) then
		local mult = 10 ^ idp;
		return floor(num * mult + 0.5) / mult;
	end
	return floor(num + 0.5);
end

function E:Truncate(v, decimals)
	return v - (v % (0.1 ^ (decimals or 0)));
end

function E:RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0;
	g = g <= 1 and g >= 0 and g or 0;
	b = b <= 1 and b >= 0 and b or 0;
	return format("|cff%02x%02x%02x", r*255, g*255, b*255);
end

function E:HexToRGB(hex)
	local rhex, ghex, bhex = sub(hex, 1, 2), sub(hex, 3, 4), sub(hex, 5, 6);
	return tonumber(rhex, 16), tonumber(ghex, 16), tonumber(bhex, 16);
end

function E:FramesOverlap(frameA, frameB)
	if(not frameA or not frameB) then return; end

	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale();
	if(not sA or not sB) then return; end

	local frameALeft = frameA:GetLeft();
	local frameARight = frameA:GetRight();
	local frameABottom = frameA:GetBottom();
	local frameATop = frameA:GetTop();

	local frameBLeft = frameB:GetLeft();
	local frameBRight = frameB:GetRight();
	local frameBBottom = frameB:GetBottom();
	local frameBTop = frameB:GetTop();

	if(not frameALeft or not frameARight or not frameABottom or not frameATop) then return; end
	if(not frameBLeft or not frameBRight or not frameBBottom or not frameBTop) then return; end

	return ((frameALeft*sA) < (frameBRight*sB))
		and ((frameBLeft*sB) < (frameARight*sA))
		and ((frameABottom*sA) < (frameBTop*sB))
		and ((frameBBottom*sB) < (frameATop*sA));
end

function E:GetScreenQuadrant(frame)
	local x, y = frame:GetCenter();
	local screenWidth = GetScreenWidth();
	local screenHeight = GetScreenHeight();
	local point;

	if(not frame:GetCenter()) then
		return "UNKNOWN", frame:GetName();
	end

	if (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y > (screenHeight / 3)*2 then
		point = "TOP";
	elseif x < (screenWidth / 3) and y > (screenHeight / 3)*2 then
		point = "TOPLEFT";
	elseif x > (screenWidth / 3)*2 and y > (screenHeight / 3)*2 then
		point = "TOPRIGHT";
	elseif (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y < (screenHeight / 3) then
		point = "BOTTOM";
	elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
		point = "BOTTOMLEFT";
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3) then
		point = "BOTTOMRIGHT";
	elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3)*2) then
		point = "LEFT";
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3)*2 and y > (screenHeight / 3) then
		point = "RIGHT";
	else
		point = "CENTER";
	end
	return point;
end

function E:GetXYOffset(position, override)
	local default = E.Spacing;
	local x, y = override or default, override or default;

	if(position == "TOP")then
		return 0, y;
	elseif(position == "TOPLEFT") then
		return x, y;
	elseif(position == "TOPRIGHT") then
		return -x, y;
	elseif(position == "BOTTOM") then
		return 0, -y;
	elseif(position == "BOTTOMLEFT") then
		return x, -y;
	elseif(position == "BOTTOMRIGHT") then
		return -x, -y;
	elseif(position == "LEFT") then
		return -x, 0;
	elseif(position == "RIGHT") then
		return x, 0;
	elseif(position == "CENTER") then
		return 0, 0;
	end
end

local styles = {
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] = "%s - %.1f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.1f%%",
	["PERCENT"] = "%.1f%%",
	["DEFICIT"] = "-%s"
};

function E:GetFormattedText(style, min, max)
	assert(styles[style], "Invalid format style: "..style);
	assert(min, "You need to provide a current value. Usage: E:GetFormattedText(style, min, max)");
	assert(max, "You need to provide a maximum value. Usage: E:GetFormattedText(style, min, max)");

	if(max == 0) then max = 1; end

	local useStyle = styles[style];

	if(style == "DEFICIT") then
		local deficit = max - min;
		if(deficit <= 0) then
			return "";
		else
			return format(useStyle, E:ShortValue(deficit));
		end
	elseif(style == "PERCENT") then
		local s = format(useStyle, min / max * 100);
		return s;
	elseif(style == "CURRENT" or ((style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max)) then
		return format(styles["CURRENT"], E:ShortValue(min));
	elseif(style == "CURRENT_MAX") then
		return format(useStyle, E:ShortValue(min), E:ShortValue(max));
	elseif(style == "CURRENT_PERCENT") then
		local s = format(useStyle, E:ShortValue(min), min / max * 100);
		return s;
	elseif(style == "CURRENT_MAX_PERCENT") then
		local s = format(useStyle, E:ShortValue(min), E:ShortValue(max), min / max * 100);
		return s;
	end
end

function E:AbbreviateString(string, allUpper)
	local newString = ""
	local words = {split(" ", string)}
	for _, word in pairs(words) do
		word = utf8sub(word, 1, 1)
		if(allUpper) then
			word = word:upper()
		end
		newString = newString .. word
	end

	return newString
end

function E:ShortenString(string, numChars, dots)
	local bytes = string:len();
	if(bytes <= numChars) then
		return string;
	else
		local len, pos = 0, 1;
		while(pos <= bytes) do
			len = len + 1;
			local c = string:byte(pos)
			if(c > 0 and c <= 127) then
				pos = pos + 1;
			elseif(c >= 192 and c <= 223) then
				pos = pos + 2;
			elseif(c >= 224 and c <= 239) then
				pos = pos + 3;
			elseif(c >= 240 and c <= 247) then
				pos = pos + 4;
			end
			if(len == numChars) then break; end
		end

		if(len == numChars and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "");
		else
			return string;
		end
	end
end

local waitTable = {};
local waitFrame;
function E:Delay(delay, func, ...)
	if(type(delay) ~= "number" or type(func) ~= "function") then
		return false;
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame","WaitFrame", E.UIParent);
		waitFrame:SetScript("onUpdate",function (_, elapse)
			local count = #waitTable;
			local i = 1;
			while(i <= count) do
				local waitRecord = tremove(waitTable, i);
				local d = tremove(waitRecord, 1);
				local f = tremove(waitRecord, 1);
				local p = tremove(waitRecord, 1);
				if(d > elapse) then
					tinsert(waitTable, i, {d-elapse, f, p});
					i = i + 1;
				else
					count = count - 1;
					f(unpack(p));
				end
			end
		end);
	end
	tinsert(waitTable, {delay, func, {...}});
	return true;
end

function E:StringTitle(str)
	return str:gsub("(.)", upper, 1);
end

E.TimeColors = {
	[0] = "|cffeeeeee",
	[1] = "|cffeeeeee",
	[2] = "|cffeeeeee",
	[3] = "|cffeeeeee",
	[4] = "|cfffe0000"
};

E.TimeFormats = {
	[0] = { "%dd", "%dd" },
	[1] = { "%dh", "%dh" },
	[2] = { "%dm", "%dm" },
	[3] = { "%ds", "%d" },
	[4] = { "%.1fs", "%.1f" }
};

local DAY, HOUR, MINUTE = 86400, 3600, 60;
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5;
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5;

function E:GetTimeInfo(s, threshhold)
	if(s < MINUTE) then
		if(s >= threshhold) then
			return floor(s), 3, 0.51;
		else
			return s, 4, 0.051;
		end
	elseif(s < HOUR) then
		local minutes = floor((s/MINUTE)+.5);
		return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH);
	elseif(s < DAY) then
		local hours = floor((s/HOUR)+.5);
		return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH);
	else
		local days = floor((s/DAY)+.5);
		return ceil(s / DAY), 0, days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH);
	end
end

local COLOR_COPPER = "|cffeda55f";
local COLOR_SILVER = "|cffc7c7cf";
local COLOR_GOLD = "|cffffd700";
local ICON_COPPER = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12|t";
local ICON_SILVER = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12|t";
local ICON_GOLD = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12|t";

function E:FormatMoney(amount, style, textonly)
	local coppername = textonly and L.copperabbrev or ICON_COPPER;
	local silvername = textonly and L.silverabbrev or ICON_SILVER;
	local goldname = textonly and L.goldabbrev or ICON_GOLD;

	local value = abs(amount);
	local gold = floor(value / 10000);
	local silver = floor(mod(value / 100, 100));
	local copper = floor(mod(value, 100));

	if(not style or style == "SMART") then
		local str = "";
		if(gold > 0) then
			str = format("%d%s%s", gold, goldname, (silver > 0 or copper > 0) and " " or "");
		end
		if(silver > 0) then
			str = format("%s%d%s%s", str, silver, silvername, copper > 0 and " " or "");
		end
		if(copper > 0 or value == 0) then
			str = format("%s%d%s", str, copper, coppername);
		end
		return str;
	end

	if(style == "FULL") then
		if(gold > 0) then
			return format("%d%s %d%s %d%s", gold, goldname, silver, silvername, copper, coppername);
		elseif(silver > 0) then
			return format("%d%s %d%s", silver, silvername, copper, coppername);
		else
			return format("%d%s", copper, coppername);
		end
	elseif(style == "SHORT") then
		if(gold > 0) then
			return format("%.1f%s", amount / 10000, goldname);
		elseif(silver > 0) then
			return format("%.1f%s", amount / 100, silvername);
		else
			return format("%d%s", amount, coppername);
		end
	elseif(style == "SHORTINT") then
		if(gold > 0) then
			return format("%d%s", gold, goldname);
		elseif(silver > 0) then
			return format("%d%s", silver, silvername);
		else
			return format("%d%s", copper, coppername);
		end
	elseif(style == "CONDENSED") then
		if(gold > 0) then
			return format("%s%d|r.%s%02d|r.%s%02d|r", COLOR_GOLD, gold, COLOR_SILVER, silver, COLOR_COPPER, copper);
		elseif(silver > 0) then
			return format("%s%d|r.%s%02d|r", COLOR_SILVER, silver, COLOR_COPPER, copper);
		else
			return format("%s%d|r", COLOR_COPPER, copper);
		end
	elseif(style == "BLIZZARD") then
		if(gold > 0) then
			return format("%s%s %d%s %d%s", gold, goldname, silver, silvername, copper, coppername);
		elseif(silver > 0) then
			return format("%d%s %d%s", silver, silvername, copper, coppername);
		else
			return format("%d%s", copper, coppername);
		end
	end

	return self:FormatMoney(amount, "SMART");
end