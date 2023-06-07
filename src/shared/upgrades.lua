return {
    contents = {
        [1] = {
            {
                type = "Power Gain",
                getTxt = function(v)
                     return ("+%d%% Power"):format(v*100)
                end,
                values = {
                    0.15,
                    0.20,
                    0.25,
                    0.30,
                    0.35
                },
                cost = {
                    45000,
                    540000,
                    2250000,
                    28350000,
                    56700000,
                }
            },
            {
                type = "Agility",
                getTxt = function(v)
                    return ("+%d Walk Speed"):format(v)
                end,
                values = {
                    .5,
                    1,
                    1.5,
                    2,
                    2.5
                },
                cost = {
                    45000,
                    540000,
                    2250000,
                    28350000,
                    56700000,
                }
            },
            {
                type = "Coin Magnet",
                getTxt = function(v)
                    return ("+%d%% Coin Gain"):format(v*100)
                end,
                values = {
                    0.05,
                    0.10,
                    0.15,
                    0.20,
                    0.25
                },
                cost = {
                    45000,
                    540000,
                    2250000,
                    28350000,
                    56700000,
                }
            },
            {
                type = "Fast Learner",
                getTxt = function(v)
                    return ("+%d%% EXP Gain"):format(v*100)
               end,
                values = {
                    0.05,
                    0.1,
                    0.15,
                    0.2,
                    0.25
                },
                cost = {
                    45000,
                    540000,
                    2250000,
                    28350000,
                    56700000,
                }
            },
            {
                type = "Luck",
                getTxt = function(v)
                    return ("+%d%% Drop Rate"):format(v*100)
               end,
                values = {
                    0.01,
                    0.015,
                    0.02,
                    0.025,
                    0.03
                },
                cost = {
                    2250000,
                    4050000,
                    40500000,
                    97200000,
                    202500000,
                }
            },
        }
    },
    functions = {
        ["Power Gain"] = function(value)
            return
        end,
        ["Agility"] = function(level)
            
        end,
        ["Coin Magnet"] = function(level)
            
        end,
        ["Fast Learner"] = function(level)
            
        end,
        ["Luck"] = function(level)
            
        end,
    }
}