--Lua functions
local pairs, type = pairs, type
local setmetatable, getmetatable = setmetatable, getmetatable
--WoW API / Variables

local function table_copy(t, deep, seen)
	if type(t) ~= "table" then return nil end

	if not seen then
		seen = {}
	elseif seen[t] then
		return seen[t]
	end

	local nt = {}
	for k, v in pairs(t) do
		if deep and type(v) == "table" then
			nt[k] = table_copy(v, deep, seen)
		else
			nt[k] = v
		end
	end

	setmetatable(nt, table_copy(getmetatable(t), deep, seen))
	seen[t] = nt

	return nt
end

table.copy = table_copy