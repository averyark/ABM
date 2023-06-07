return {
    getCost = function(r)
        return (r^13*9) + 25e6
    end,
    getCoinMultiplier = function(r)
        return r == 1 and 1 or r + 1
    end,
    getPowerMultiplier = function(r)
        return r == 1 and 1 or 2*r + 1
    end,
    getShardReward = function(r)
        return 800*r
    end
}