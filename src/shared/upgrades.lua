return {
    contents = {
        [1] = {
            {
                type = "Power Gain",
                getTxt = function(v)
                     return ("+%d%% Power"):format(v*100)
                end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    4500,
                    54000,
                    350000,
                    2100000,
                    9200000,
                }
            },
            {
                type = "Agility",
                getTxt = function(v)
                    return ("+%d Walk Speed"):format(v)
                end,
                values = {
                    1,
                    1.5,
                    2,
                    2.5,
                    3
                },
                cost = {
                    7200,
                    69000,
                    400000,
                    2700000,
                    11000000,
                }
            },
            {
                type = "Coin Magnet",
                getTxt = function(v)
                    return ("+%d%% Coin Gain"):format(v*100)
                end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    4500,
                    54000,
                    350000,
                    2100000,
                    9200000,
                }
            },
            {
                type = "Fast Learner",
                getTxt = function(v)
                    return ("+%d%% EXP Gain"):format(v*100)
               end,
                values = {
                    0.1,
                    0.15,
                    0.2,
                    0.25,
                    0.3
                },
                cost = {
                    45000,
                    380000,
                    1200000,
                    5700000,
                    14000000,
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
                    7200,
                    69000,
                    400000,
                    2700000,
                    11000000,
                }
            },
        },
        [2] = {
            {
                type = "Power Gain",
                getTxt = function(v)
                     return ("+%d%% Power"):format(v*100)
                end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    12000000,
                    144000000,
                    1000000000,
                    12700000000,
                    75000000000,
                }
            },
            {
                type = "Armored",
                getTxt = function(v)
                    return ("+%d Defence"):format(v)
                end,
                values = {
                    10,
                    20,
                    30,
                    40,
                    50,
                },
                cost = {
                    24000000,
                    85000000,
                    340000000,
                    3600000000,
                    50000000000,
                }
            },
            {
                type = "Coin Magnet",
                getTxt = function(v)
                    return ("+%d%% Coin Gain"):format(v*100)
                end,
                values = {
                    0.1,
                    0.2,
                    0.3,
                    0.4,
                    0.5
                },
                cost = {
                    12000000,
                    144000000,
                    1000000000,
                    12700000000,
                    75000000000,
                }
            },
            {
                type = "Fast Learner",
                getTxt = function(v)
                    return ("+%d%% EXP Gain"):format(v*100)
               end,
                values = {
                    0.1,
                    0.15,
                    0.2,
                    0.25,
                    0.3
                },
                cost = {
                    12000000,
                    144000000,
                    1000000000,
                    12700000000,
                    75000000000,
                }
            },
            {
                type = "Storage",
                getTxt = function(v)
                    return ("+%d%% Slots"):format(v)
               end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    47000000,
                    240000000,
                    1500000000,
                    27000000000,
                    490000000000,
                }
            },
        },
        [3] = {
            {
                type = "Power Gain",
                getTxt = function(v)
                     return ("+%d%% Power"):format(v*100)
                end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    4000000000,
                    9200000000,
                    34400000000,
                    300000000000,
                    8000000000000,
                }
            },
            {
                type = "Armored",
                getTxt = function(v)
                    return ("+%d Defence"):format(v)
                end,
                values = {
                    10,
                    20,
                    30,
                    40,
                    50
                },
                cost = {
                    5000000000,
                    12500000000,
                    52500000000,
                    500000000000,
                    3000000000000,
                }
            },
            {
                type = "Agility",
                getTxt = function(v)
                    return ("+%d Walk Speed"):format(v)
                end,
                values = {
                    1,
                    1.5,
                    2,
                    2.5,
                    3
                },
                cost = {
                    5000000000,
                    12500000000,
                    52500000000,
                    500000000000,
                    3000000000000,
                }
            },
            {
                type = "Critical Hit",
                getTxt = function(v)
                    return ("+%d%% Crit Dmg"):format(v*100)
               end,
                values = {
                    0.1,
                    0.2,
                    0.3,
                    0.4,
                    0.5
                },
                cost = {
                    4000000000,
                    9200000000,
                    34400000000,
                    300000000000,
                    8000000000000,
                }
            },
            {
                type = "Storage",
                getTxt = function(v)
                    return ("+%d Slots"):format(v)
               end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    25000000000,
                    105000000000,
                    34400000000,
                    1000000000000,
                    6500000000000,
                }
            },
        },
        [4] = {
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
                    8500000000,
                    25000000000,
                    650000000000,
                    4000000000000,
                    24000000000000,
                }
            },
            {
                type = "Armored",
                getTxt = function(v)
                    return ("+%d Defence"):format(v)
                end,
                values = {
                    10,
                    20,
                    30,
                    40,
                    50
                },
                cost = {
                    12000000000,
                    75000000000,
                    980000000000,
                    6000000000000,
                    32000000000000,
                }
            },
            {
                type = "Coin Magnet",
                getTxt = function(v)
                    return ("+%d%% Coin Gain"):format(v*100)
                end,
                values = {
                    0.2,
                    0.3,
                    0.4,
                    0.5,
                    0.6
                },
                cost = {
                    8500000000,
                    25000000000,
                    650000000000,
                    4000000000000,
                    24000000000000,
                }
            },
            {
                type = "Fast Learner",
                getTxt = function(v)
                    return ("+%d%% EXP Gain"):format(v*100)
               end,
                values = {
                    0.1,
                    0.2,
                    0.3,
                    0.4,
                    0.5
                },
                cost = {
                    8500000000,
                    25000000000,
                    650000000000,
                    4000000000000,
                    24000000000000,
                }
            },
            {
                type = "Luck",
                getTxt = function(v)
                    return ("+%d%% Drop Rate"):format(v*100)
               end,
                values = {
                    0.01,
                    0.02,
                    0.03,
                    0.04,
                    0.05
                },
                cost = {
                    15000000000,
                    85000000000,
                    110000000000,
                    8000000000000,
                    54000000000000,
                }
            },
        },
        [5] = {
            {
                type = "Power Gain",
                getTxt = function(v)
                     return ("+%d%% Power"):format(v*100)
                end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    12000000000000,
                    144000000000000,
                    950000000000000,
                    5700000000000000,
                    25000000000000000,
                }
            },
            {
                type = "Armored",
                getTxt = function(v)
                    return ("+%d Defence"):format(v)
                end,
                values = {
                    10,
                    20,
                    30,
                    40,
                    50
                },
                cost = {
                    36000000000000,
                    432000000000000,
                    2850000000000000,
                    17100000000000000,
                    75000000000000000,
                }
            },
            {
                type = "Agility",
                getTxt = function(v)
                    return ("+%d Walk Speed"):format(v*100)
                end,
                values = {
                    1,
                    2,
                    3,
                    4,
                    5
                },
                cost = {
                    40000000000000,
                    450000000000000,
                    3000000000000000,
                    19000000000000000,
                    100000000000000000,
                }
            },
            {
                type = "Critical Hit",
                getTxt = function(v)
                    return ("+%d%% Crit Dmg"):format(v*100)
               end,
                values = {
                    0.1,
                    0.2,
                    0.3,
                    0.2,
                    0.25
                },
                cost = {
                    12000000000000,
                    144000000000000,
                    950000000000000,
                    5700000000000000,
                    25000000000000000,
                }
            },
            {
                type = "Coin Magnet",
                getTxt = function(v)
                    return ("+%d%% Coin Gain"):format(v*100)
               end,
                values = {
                    0.1,
                    0.2,
                    0.3,
                    0.4,
                    0.5
                },
                cost = {
                    12000000000000,
                    144000000000000,
                    950000000000000,
                    5700000000000000,
                    25000000000000000,
                }
            },
        },
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