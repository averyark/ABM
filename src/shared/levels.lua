return {
    --[[ Data
        Reference Equation Used: f(n) = (n*1000)^1.1 + 10
        V2 RE Used: f(n) = 2000 + ((3000)*(n-1)^2)
        Level Requirement Offset
        1     2.00K
        2     4.28K       2.28K
        3     6.69K       2.40K
        4     9.17K       2.48K
        5     11.72K      2.55K
        6     14.33K      2.60K
        7     16.97K      2.64K
        8     19.66K      2.68K
        9     22.38K      2.71K
        10    25.12K      2.74K


    --]]
    [0] = {
        requirement = 2000,
        multiplier = 1,
    },
    [1] = {
        requirement = 2000,
        multiplier = 1.2,
    },
    [2] = {
        requirement = 6000,
        multiplier = 1.4,
    },
    [3] = {
        requirement = 21000,
        multiplier = 1.7,
    },
    [4] = {
        requirement = 42000,
        multiplier = 2,
    },
    [5] = {
        requirement = 69000,
        multiplier = 2.4,
    },
    [6] = {
        requirement = 138000,
        multiplier = 2.8,
    },
    [7] = {
        requirement = 213000,
        multiplier = 3.3,
    },
    [8] = {
        requirement = 426000,
        multiplier = 3.8,
    },
    [9] = {
        requirement = 1170000,
        multiplier = 4.2,
    },
    [10] = {
        requirement = 1638000,
        multiplier = 4.8,
    },

    --[[ Data
        Reference Equation Used: f(n) = ((n-8)*1200)^1.3
        Level Requirement Offset
        11    41.99K      16.86K (You see this significant bump because new areas
        12    61.04K      19.04K  often have higher xp drop)
        13    81.58K      20.54K
        14    103.40K     21.82K
        15    126.34K     22.94K
        16    150.29K     23.95K
        17    175.16K     24.86K
        18    200.88K     25.71K
        19    227.37K     26.49K
        20    254.60K     27.23K
    --]]
    [11] = {
        requirement = 41994,
        multiplier = 0,
    },
    [12] = {
        requirement = 61039,
        multiplier = 0,
    },
    [13] = {
        requirement = 81582,
        multiplier = 0,
    },
    [14] = {
        requirement = 103402,
        multiplier = 0,
    },
    [15] = {
        requirement = 126346,
        multiplier = 0,
    },
    [16] = {
        requirement = 150297,
        multiplier = 0,
    },
    [17] = {
        requirement = 175166,
        multiplier = 0,
    },
    [18] = {
        requirement = 200879,
        multiplier = 0,
    },
    [19] = {
        requirement = 227376,
        multiplier = 0,
    },
    [20] = {
        requirement = 254607,
        multiplier = 0,
    },

     --[[ Data
        Reference Equation Used = f(n) = ((n-17)*1600)^1.45
        Level Requirement Offset
        21    330.34K     75.73K
        22    456.54K     126.20K
        23    594.69K     138.15K
        24    743.64K     148.95K
        25    902.51K     158.86K
        26    1.07M       168.08K
        27    1.24M       176.71K
        28    1.43M       184.85K
        29    1.62M       192.58K
        30    1.82M       199.95K
    --]]
    [21] = {
        requirement = 330339,
        multiplier = 0,
    },
    [22] = {
        requirement = 456541,
        multiplier = 0,
    },
    [23] = {
        requirement = 594693,
        multiplier = 0,
    },
    [24] = {
        requirement = 743645,
        multiplier = 0,
    },
    [25] = {
        requirement = 902515,
        multiplier = 0,
    },
    [26] = {
        requirement = 1070595,
        multiplier = 0,
    },
    [27] = {
        requirement = 1247308,
        multiplier = 0,
    },
    [28] = {
        requirement = 1432166,
        multiplier = 0,
    },
    [29] = {
        requirement = 1624750,
        multiplier = 0,
    },
    [30] = {
        requirement = 1824701,
        multiplier = 0,
    },

    --[[ Data
        Reference Equation Used: f(n) = ((n-26)*1250)^1.7
        Level Requirement Offset
        31    2.83M       1.01M
        32    3.86M       1.03M
        33    5.02M       1.15M
        34    6.30M       1.28M
        35    7.70M       1.39M
        36    9.22M       1.51M
        37    10.84M      1.62M
        38    12.57M      1.72M
        39    14.40M      1.83M
        40    16.33M      1.93M
    --]]
    [31] = {
        requirement = 2837893,
        multiplier = 0,
    },
    [32] = {
        requirement = 3869048,
        multiplier = 0,
    },
    [33] = {
        requirement = 5028213,
        multiplier = 0,
    },
    [34] = {
        requirement = 6309573,
        multiplier = 0,
    },
    [35] = {
        requirement = 7708312,
        multiplier = 0,
    },
    [36] = {
        requirement = 9220341,
        multiplier = 0,
    },
    [37] = {
        requirement = 10842129,
        multiplier = 0,
    },
    [38] = {
        requirement = 12570574,
        multiplier = 0,
    },
    [39] = {
        requirement = 14402925,
        multiplier = 0,
    },
    [40] = {
        requirement = 16336713,
        multiplier = 0,
    },

    --[[ Data
        Reference Equation Used: f(n) = ((n-32)*1000)^1.85
        Level Requirement Offset
        41    20.67M      4.33M
        42    25.11M      4.44M
        43    29.96M      4.84M
        44    35.19M      5.23M
        45    40.81M      5.61M
        46    46.80M      5.99M
        47    53.18M      6.37M
        48    59.92M      6.74M
        49    67.03M      7.11M
        50    74.51M      7.47M
    --]]
    [41] = {
        requirement = 20670388,
        multiplier = 0,
    },
    [42] = {
        requirement = 25118864,
        multiplier = 0,
    },
    [43] = {
        requirement = 29962391,
        multiplier = 0,
    },
    [44] = {
        requirement = 35195351,
        multiplier = 0,
    },
    [45] = {
        requirement = 40812688,
        multiplier = 0,
    },
    [46] = {
        requirement = 46809808,
        multiplier = 0,
    },
    [47] = {
        requirement = 53182509,
        multiplier = 0,
    },
    [48] = {
        requirement = 59926921,
        multiplier = 0,
    },
    [49] = {
        requirement = 67039459,
        multiplier = 0,
    },
    [50] = {
        requirement = 74516789,
        multiplier = 0,
    },
}