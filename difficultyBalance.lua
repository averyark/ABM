local number = require(game.ReplicatedStorage.shared.number)
local rebirth = require(game.ReplicatedStorage.shared.ascension)

local generateResult = function(parameters)
	local l4power = parameters[5][4]
	local req = parameters[1]*l4power*parameters[4]

	local STATS = {
		heroMultipliers = {},
		ascensionMultipliers = {},
		levelMultipliers = {},
		enemyHealth = {},
		asecnsionPrices = {},
		swordPowers = parameters[5],
		portalPurchasePrice = req,
		questXpRewards = {},
		xpToLevelUp = {},
	}

	local heroInfluence = parameters[4]*parameters[3][2]

	for index, a in pairs(parameters[7]) do
		local n = math.round((heroInfluence/a)*1000)/1000
		STATS.heroMultipliers[index] = n
	end

	-- rebirth
	local rebirthInfluence = parameters[4]*parameters[3][1]
	local add = rebirthInfluence/(#parameters[2]-parameters[8])

	for index = #parameters[2], 1, -1 do
		local projectedMultiMax = index*add
		local n = math.round((projectedMultiMax)*1000)/1000
		local price = l4power*(projectedMultiMax*(parameters[2][index]))
		STATS.ascensionMultipliers[index + parameters[8]] = n
		STATS.asecnsionPrices[index + parameters[8]] = price
	end

	local levelInfluence = parameters[4]*parameters[3][3]

	for index = 10, 1, -1 do
		local n = (levelInfluence/10)*index
		STATS.levelMultipliers[index] = n
	end

	for index = 1, #parameters[6] do
		local health = math.round(parameters[6][index]*((50*0.1)*l4power)*1.462)
		STATS.enemyHealth[index] = health
	end
	
	local num = {}

	local skip  = false
	for index = 1, #parameters[10] do
		if skip then
			skip = false
		else
			table.insert(num, parameters[10][index] + parameters[10][index+1])

			skip = true
		end
	end

	for index, a in pairs(num) do
		STATS.questXpRewards[index] = parameters[9] + (a*(parameters[1]+parameters[11])/5*index)
	end

	for index, a in pairs(parameters[10]) do
		STATS.xpToLevelUp[index] = STATS.questXpRewards[math.round(index/2)]*a
	end

	return STATS
end

-- L4 Stands for fourth sword from weakest to strongest
-- LD Stands for Level Done In this case going to the next world
-- Balance% determines an element's overall influence on progress

--[[
print(generateResult({
			[1] = 10000,                              -- Primary Control Variable> Clicks to achieve LD price at L4 + ref multi
			[2] = {1000, 6000},                       -- Control Variable> (Clicks to achieve ascension)
			[3] = {0.3, 0.3, 0.4},                    -- Control Variable> Balance% 1=Ascension, 2=heros, 3=level
			[4] = 50,                                 -- Control Variable> Reference multi
			[5] = {27, 63, 180, 439, 1745},           -- Primary Control Variable> Sword powers
			[6] = {.1, 1, 8, 17, 34, 100},            -- Control Variable> Hits needed to be slain with L4 + 10% of ref multi
			[7] = {10, 8, 5, 2.5, 1.5},               -- Control Variable> Number of equipped heros needed to achieve balance%
			[8] = 0,                                  -- Offset> Last ascension index
			[9] = 1000000                             -- Offset> Last Xp Quest Reward
			[10] = {1, 2, 3, 3.5, 4, 5, 6, 7, 8, 8.5} -- Control Variable> Number of quests to complete to level up
			[11] = 1000                               -- Offset> Last Clicks to achieve LD price at L4 + ref multi
		}))
]]

print(generateResult({
    [1] = 5000,                      -- Primary Control Variable> Clicks to achieve LD price at L4 + ref multi
    [2] = {1000, 1500},               -- Control Variable> (Clicks to achieve ascension)
    [3] = {0.3, 0.3, 0.4},            -- Control Variable> Balance% 1=Ascension, 2=heros, 3=level
    [4] = 50,                         -- Control Variable> Reference multi
    [5] = {27, 63, 180, 439, 1745},   -- Primary Control Variable> Sword powers
    [6] = {.1, 1, 8, 17, 34, 100},    -- Control Variable> Hits needed to be slain with L4 + 10% of ref multi
    [7] = {10, 8, 5, 2.5, 1.5},       -- Control Variable> Number of equipped heros needed to achieve balance%
    [8] = 0,                          -- Offset> Last ascension index
}))

return {
    generateResult = function()
        -- L4 Stands for fourth sword from weakest to strongest
        -- LD Stands for Level Done In this case going to the next world
        -- Balance% determines an element's overall influence on progress

        print(generateResult({
            [1] = 10000,                      -- Primary Control Variable> Clicks to achieve LD price at L4 + ref multi
            [2] = {1000, 6000},               -- Control Variable> (Clicks to achieve ascension)
            [3] = {0.3, 0.3, 0.4},            -- Control Variable> Balance% 1=Ascension, 2=heros, 3=level
            [4] = 50,                         -- Control Variable> Reference multi
            [5] = {27, 63, 180, 439, 1745},   -- Primary Control Variable> Sword powers
            [6] = {.1, 1, 8, 17, 34, 100},    -- Control Variable> Hits needed to be slain with L4 + 10% of ref multi
            [7] = {10, 8, 5, 2.5, 1.5},       -- Control Variable> Number of equipped heros needed to achieve balance%
            [8] = 0,                          -- Offset> Last ascension index
        }))
    end
}

-- 2, 4, 7, 11, 16

--[[	local retrieveHitsFromStats = function(statTable: {level: number, ascension: number, hero: {number?}, sword: number})
    
		local m1 = statTable.level or 0
		local m2 = statTable.ascension or 0
	    local m3 = 0

	    for _, index in pairs(statTable.hero) do
			m3 += index
	    end

	    local multi = (
	        m1 + m2 + m3
	    )
		local power = statTable.sword * (multi > 0 and multi or 1)

	    local STATSTABLE = {}

	    for index, health in pairs(STATS.enemyHealth) do
	        STATSTABLE[index] = (math.round((health/power)*1000))/1000
	    end

		print(STATSTABLE)
	end
	
	retrieveHitsFromStats(
		{
			level = 20, 
			ascension = 15, 
			hero = {5, 5}, 
			sword = 439
		}
	)


print(STATS)
local dump = {}

--[[for i = 1, #weapons do
    dump[i] = retrieveHitsFromStats({
        level = 9,
        ascension = 2,
        sword = i,
        hero = {4, 4}
    })
end

print(dump)]]


--[[print("\n\n STATS> SwordMultiRequirement")

for index, power in pairs(weapons) do
    local n = math.round((req/(power*clicksMax)*1000))/1000
    
    print(`index>{index}; minMulti>{n}`)
end

print("\n\nCost>", number.abbreviate(req)) --number.abbreviate()]]