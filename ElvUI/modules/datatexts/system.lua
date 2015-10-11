local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule('DataTexts');

local format, sort = string.format, table.sort;

local MemoryTable = {};
local CPUTable = {};

local int, int2 = 6, 5;
local StatusColors = {
	'|cff0CD809',
	'|cffE8DA0F',
	'|cffFF9000',
	'|cffD80909'
}

local EnteredFrame = false;

local function FormatMem(Memory)
	local Mult = 10^1;
	
	if ( Memory > 999 ) then
		local Mem = ((Memory / 1024) * Mult) / Mult;
		return format('%.2f mb', Mem);
	else
		local Mem = (Memory * Mult) / Mult;
		return format('%d kb', Mem);
	end
end

local function RebuildAddonList()
	local AddOnCount = GetNumAddOns();
	
	if ( AddOnCount == #MemoryTable ) then return; end
	
	MemoryTable = {};
	CPUTable = {};
	
	for i = 1, AddOnCount do
		MemoryTable[i] = { i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i) };
		CPUTable[i] = { i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i) };
	end
end

local function UpdateMemory()
	local AddOnMem, TotalMemory = 0, 0;
	
	UpdateAddOnMemoryUsage();
	
	for i = 1, #MemoryTable do
		AddOnMem = GetAddOnMemoryUsage(MemoryTable[i][1]);
		MemoryTable[i][3] = AddOnMem;
		TotalMemory = TotalMemory + AddOnMem;
	end
	
	sort(MemoryTable, function(A, B)
		if ( A and B ) then
			return A[3] > B[3];
		end
	end);
	
	return TotalMemory;
end

local function UpdateCPU()
	local AddOnCPU, TotalCPU = 0, 0;
	
	UpdateAddOnCPUUsage();
	
	for i = 1, #CPUTable do
		AddOnCPU = GetAddOnCPUUsage(CPUTable[i][1]);
		CPUTable[i][3] = AddOnCPU;
		TotalCPU = TotalCPU + AddOnCPU;
	end
	
	sort(CPUTable, function(a, b)
		if ( a and b ) then
			return a[3] > b[3];
		end
	end);
	
	return TotalCPU;
end

local function Click()
	collectgarbage('collect');
	ResetCPUUsage();
end

local function OnEnter(self)
	local HomeLatencyString = '%d ms';
	local CPUProfiling = GetCVar('scriptProfile') == '1';
	local HomeLatency = select(3, GetNetStats());
	
	local TotalMemory, TotalCPU = UpdateMemory(), nil;
	
	EnteredFrame = true;
	
	DT:SetupTooltip(self)

	DT.tooltip:AddDoubleLine(L['Home Latency:'], format(HomeLatencyString, HomeLatency), 0.69, 0.31, 0.31,0.84, 0.75, 0.65);
	DT.tooltip:AddDoubleLine(L['Total Memory:'], FormatMem(TotalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65);
	
	if CPUProfiling then
		TotalCPU = UpdateCPU();
		DT.tooltip:AddDoubleLine(L['Total CPU:'], format(HomeLatencyString, TotalCPU), 0.69, 0.31, 0.31,0.84, 0.75, 0.65);
	end
	
	if ( IsShiftKeyDown() ) or ( not CPUProfiling ) then
		DT.tooltip:AddLine(' ');
		
		for i = 1, #MemoryTable do
			if ( MemoryTable[i][4] ) then
				local Red = MemoryTable[i][3] / TotalMemory;
				local Green = 1 - Red;
				
				DT.tooltip:AddDoubleLine(MemoryTable[i][2], FormatMem(MemoryTable[i][3]), 1, 1, 1, Red, Green + .5, 0);
			end
		end
	end
	
	if ( CPUProfiling ) and ( not IsShiftKeyDown() ) then
		DT.tooltip:AddLine(' ');
		
		for i = 1, #CPUTable do
			if ( CPUTable[i][4] ) then
				local Red = CPUTable[i][3] / TotalCPU;
				local Green = 1 - Red;
				
				DT.tooltip:AddDoubleLine(CPUTable[i][2], format(HomeLatencyString, CPUTable[i][3]), 1, 1, 1, Red, Green + .5, 0);
			end
		end
		
		DT.tooltip:AddLine(' ');
		DT.tooltip:AddLine(L['(Hold Shift) Memory Usage']);
	end
	
	DT.tooltip:Show();
end

local function OnLeave(self)
	EnteredFrame = false;
	DT.tooltip:Hide();
end

local function Update(self, t)
	local DisplayFormat;
	
	int = int - t
	int2 = int2 - t
	
	if ( int < 0 ) then
		RebuildAddonList();
		int = 10;
	end
	
	if ( int2 < 0 ) then
		local Framerate, FramerateColor = floor(GetFramerate()), 4;
		local Latency, LatencyColor = select(3, GetNetStats()), 4;
		
		if ( Latency < 150 ) then
			LatencyColor = 1;
		elseif ( Latency >= 150 and Latency < 300 ) then
			LatencyColor = 2;
		elseif ( Latency >= 300 and Latency < 500 ) then
			LatencyColor = 3;
		end
		
		if ( Framerate >= 30 ) then
			FramerateColor = 1;
		elseif ( Framerate >= 20 and Framerate < 30 ) then
			FramerateColor = 2;
		elseif ( Framerate >= 10 and Framerate < 20 ) then
			FramerateColor = 3;
		end
		
		DisplayFormat = string.join('', 'FPS: ', StatusColors[FramerateColor], '%d|r MS: ', StatusColors[LatencyColor], '%d|r');
		self.text:SetFormattedText(DisplayFormat, Framerate, Latency);
		
		int2 = 1;
		
		if ( EnteredFrame ) then
			OnEnter(self);
		end
	end
end

DT:RegisterDatatext(L['System'], nil, nil, Update, Click, OnEnter, OnLeave);