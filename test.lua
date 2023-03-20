local zone1wep = {27, 8, 18, 7, 1}
local zone1enemies = {1, 2, 3, 4, 5}
local weapons = require(game.ReplicatedStorage.shared.weapons)
local entities = require(game.ServerScriptService.server.entities.entities)

local find = function(id, tb)
	for _, object in pairs(tb) do
		if object.id == id then
			return object
		end
	end
end

for _, id in pairs(zone1wep) do
	local wepDat = find(id, weapons)
	local avgCrit = (wepDat.critMultiplication[1] + wepDat.critMultiplication[2])/2
	local crit = wepDat.power * wepDat.critChance * avgCrit
	print(wepDat.name .. "|" .. wepDat.power .. "|" .. wepDat.critChance .. "|" .. avgCrit .. "|" .. wepDat.power + math.round(crit))
end

local a = ""

for _, id in pairs(zone1enemies) do
	local enemyData = find(id, entities)
	local swords = ""

	for _, wepId in pairs(zone1wep) do
		local wepDat = find(wepId, weapons)
		local avgCrit = (wepDat.critMultiplication[1] + wepDat.critMultiplication[2])/2
		local crit = wepDat.power * wepDat.critChance * avgCrit
		swords = swords .. ("<td>%s</td><td>%s</td><tbody>"):format(wepDat.name, string.format("%.0f", math.max(enemyData.maxHealth/(wepDat.power + crit), 1)) .. "</tbody>")
	end
	a = a .. string.format("%s|%s|%s", enemyData.name, enemyData.maxHealth, "<table><th>Sword</th><th>Hits (AVG)</th><tbody>" .. swords .. "</table>\n")
end

print(a)