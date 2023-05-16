--[[
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
local dependency = {
    [0] = {
        requirement = 2500,
        multiplier = 1,
    },
    [1] = {
        requirement = 5000,
        multiplier = 2,
    },
    [2] = {
        requirement = 30000,
        multiplier = 4,
    },
    [3] = {
        requirement = 45000,
        multiplier = 6,
    },
    [4] = {
        requirement = 180000,
        multiplier = 8,
    },
    [5] = {
        requirement = 225000,
        multiplier = 10,
    },
    [6] = {
        requirement = 630000,
        multiplier = 12,
    },
    [7] = {
        requirement = 735000,
        multiplier = 14,
    },
    [8] = {
        requirement = 1640000,
        multiplier = 16,
    },
    [9] = {
        requirement = 1845000,
        multiplier = 18,
    },
    [10] = {
        requirement = 3550000,
        multiplier = 20,
    },

    [11] = {
        requirement = 5346000,
        multiplier = 36,
    },
    [12] = {
        requirement = 21384000,
        multiplier = 42,
    },
    [13] = {
        requirement = 37422000,
        multiplier = 68,
    },
    [14] = {
        requirement = 120285000,
        multiplier = 84,
    },
    [15] = {
        requirement = 160380000,
        multiplier = 100,
    },
    [16] = {
        requirement = 392931000,
        multiplier = 116,
    },
    [17] = {
        requirement = 486486000,
        multiplier = 132,
    },
    [18] = {
        requirement = 986337000,
        multiplier = 148,
    },
    [19] = {
        requirement = 1095930000,
        multiplier = 164,
    },
    [20] = {
        requirement = 2024352000,
        multiplier = 180,
    },


    [21] = {
        requirement = 3795690000,
        multiplier = 324,
    },
    [22] = {
        requirement = 15182760000,
        multiplier = 468,
    },
    [23] = {
        requirement = 26569830000,
        multiplier = 612,
    },
    [24] = {
        requirement = 85403025000,
        multiplier = 756,
    },
    [25] = {
        requirement = 113870700000,
        multiplier = 900,
    },
    [26] = {
        requirement = 278983215000,
        multiplier = 1044,
    },
    [27] = {
        requirement = 345407790000,
        multiplier = 1188,
    },
    [28] = {
        requirement = 700304805000,
        multiplier = 1332,
    },
    [29] = {
        requirement = 778116450000,
        multiplier = 1476,
    },
    [30] = {
        requirement = 1437301280000,
        multiplier = 1620,
    },

    [31] = {
        requirement = 8084819784000,
        multiplier = 2020,
    },
    [32] = {
        requirement = 28296869244000,
        multiplier = 2420,
    },
    [33] = {
        requirement = 40424098920000,
        multiplier = 2820,
    },
    [34] = {
        requirement = 127335911598000,
        multiplier = 3220,
    },
    [35] = {
        requirement = 157653985788000,
        multiplier = 3620,
    },
    [36] = {
        requirement = 382007734794000,
        multiplier = 4020,
    },
    [37] = {
        requirement = 452749907904000,
        multiplier = 4420,
    },
    [38] = {
        requirement = 911563430646000,
        multiplier = 4820,
    },
    [39] = {
        requirement = 994432833432000,
        multiplier = 5220,
    },
    [40] = {
        requirement = 1817736981436000,
        multiplier = 5620,
    },

    [41] = {
        requirement = 1.5e+16,
        multiplier = 7220,
    },
    [42] = {
        requirement = 5e+16,
        multiplier = 8820,
    },
    [43] = {
        requirement = 9e+16,
        multiplier = 10420,
    },
    [44] = {
        requirement = 3e+17,
        multiplier = 12020,
    },
    [45] = {
        requirement = 6e+17,
        multiplier = 13620,
    },
    [46] = {
        requirement = 8e+17,
        multiplier = 15220,
    },
    [47] = {
        requirement = 2e+18,
        multiplier = 16820,
    },
    [48] = {
        requirement = 5e+18,
        multiplier = 18420,
    },
    [49] = {
        requirement = 9e+18,
        multiplier = 20020,
    },
    [50] = {
        requirement = 2e+19,
        multiplier = 21620,
    },
}

local newtable = ""
local cache = {}

local map = {0.1, 0.2, 0.3, 0.4}

for level, data in pairs(dependency) do
    if level > 0 then
        for i = 1, #map do
            local n1 = (data.requirement*map[i]/4 + if cache[(level-1)*4 + i-1] then cache[(level-1)*4 + i-1].requirement else 0)
            local n2 = data.multiplier*map[i] + dependency[level].multiplier
            newtable = `{newtable}\t[{(level-1)*4 + i}] = ` .. "{\n" .. `\t\trequirement = {n1},\n\t\tmultiplier = {n2}\n\t},\n`
            table.insert(cache, {
                requirement = n1,
                multiplier = n2
            })
        end
    end
end

print(newtable)
]]

return {
    [0] = {
        requirement = 0,
        multiplier = 1,
    },
	[1] = {
		requirement = 125,
		multiplier = 2.2
	},
	[2] = {
		requirement = 375,
		multiplier = 2.4
	},
	[3] = {
		requirement = 750,
		multiplier = 2.6
	},
	[4] = {
		requirement = 1250,
		multiplier = 2.8
	},
	[5] = {
		requirement = 2000,
		multiplier = 4.4
	},
	[6] = {
		requirement = 3500,
		multiplier = 4.8
	},
	[7] = {
		requirement = 5750,
		multiplier = 5.2
	},
	[8] = {
		requirement = 8750,
		multiplier = 5.6
	},
	[9] = {
		requirement = 9875,
		multiplier = 6.6
	},
	[10] = {
		requirement = 12125,
		multiplier = 7.2
	},
	[11] = {
		requirement = 15500,
		multiplier = 7.8
	},
	[12] = {
		requirement = 20000,
		multiplier = 8.4
	},
	[13] = {
		requirement = 24500,
		multiplier = 8.8
	},
	[14] = {
		requirement = 33500,
		multiplier = 9.6
	},
	[15] = {
		requirement = 47000,
		multiplier = 10.4
	},
	[16] = {
		requirement = 65000,
		multiplier = 11.2
	},
	[17] = {
		requirement = 70625,
		multiplier = 11
	},
	[18] = {
		requirement = 81875,
		multiplier = 12
	},
	[19] = {
		requirement = 98750,
		multiplier = 13
	},
	[20] = {
		requirement = 121250,
		multiplier = 14
	},
	[21] = {
		requirement = 137000,
		multiplier = 13.2
	},
	[22] = {
		requirement = 168500,
		multiplier = 14.4
	},
	[23] = {
		requirement = 215750,
		multiplier = 15.6
	},
	[24] = {
		requirement = 278750,
		multiplier = 16.8
	},
	[25] = {
		requirement = 297125,
		multiplier = 15.4
	},
	[26] = {
		requirement = 333875,
		multiplier = 16.8
	},
	[27] = {
		requirement = 389000,
		multiplier = 18.2
	},
	[28] = {
		requirement = 462500,
		multiplier = 19.6
	},
	[29] = {
		requirement = 503500,
		multiplier = 17.6
	},
	[30] = {
		requirement = 585500,
		multiplier = 19.2
	},
	[31] = {
		requirement = 708500,
		multiplier = 20.8
	},
	[32] = {
		requirement = 872500,
		multiplier = 22.4
	},
	[33] = {
		requirement = 918625,
		multiplier = 19.8
	},
	[34] = {
		requirement = 1010875,
		multiplier = 21.6
	},
	[35] = {
		requirement = 1149250,
		multiplier = 23.4
	},
	[36] = {
		requirement = 1333750,
		multiplier = 25.2
	},
	[37] = {
		requirement = 1422500,
		multiplier = 22
	},
	[38] = {
		requirement = 1600000,
		multiplier = 24
	},
	[39] = {
		requirement = 1866250,
		multiplier = 26
	},
	[40] = {
		requirement = 2221250,
		multiplier = 28
	},
	[41] = {
		requirement = 2354900,
		multiplier = 39.6
	},
	[42] = {
		requirement = 2622200,
		multiplier = 43.2
	},
	[43] = {
		requirement = 3023150,
		multiplier = 46.8
	},
	[44] = {
		requirement = 3557750,
		multiplier = 50.4
	},
	[45] = {
		requirement = 4092350,
		multiplier = 46.2
	},
	[46] = {
		requirement = 5161550,
		multiplier = 50.4
	},
	[47] = {
		requirement = 6765350,
		multiplier = 54.6
	},
	[48] = {
		requirement = 8903750,
		multiplier = 58.8
	},
	[49] = {
		requirement = 9839300,
		multiplier = 74.8
	},
	[50] = {
		requirement = 11710400,
		multiplier = 81.6
	},
	[51] = {
		requirement = 14517050,
		multiplier = 88.4
	},
	[52] = {
		requirement = 18259250,
		multiplier = 95.2
	},
	[53] = {
		requirement = 21266375,
		multiplier = 92.4
	},
	[54] = {
		requirement = 27280625,
		multiplier = 100.8
	},
	[55] = {
		requirement = 36302000,
		multiplier = 109.2
	},
	[56] = {
		requirement = 48330500,
		multiplier = 117.6
	},
	[57] = {
		requirement = 52340000,
		multiplier = 110
	},
	[58] = {
		requirement = 60359000,
		multiplier = 120
	},
	[59] = {
		requirement = 72387500,
		multiplier = 130
	},
	[60] = {
		requirement = 88425500,
		multiplier = 140
	},
	[61] = {
		requirement = 98248775,
		multiplier = 127.6
	},
	[62] = {
		requirement = 117895325,
		multiplier = 139.2
	},
	[63] = {
		requirement = 147365150,
		multiplier = 150.8
	},
	[64] = {
		requirement = 186658250,
		multiplier = 162.4
	},
	[65] = {
		requirement = 198820400,
		multiplier = 145.2
	},
	[66] = {
		requirement = 223144700,
		multiplier = 158.4
	},
	[67] = {
		requirement = 259631150,
		multiplier = 171.6
	},
	[68] = {
		requirement = 308279750,
		multiplier = 184.8
	},
	[69] = {
		requirement = 332938175,
		multiplier = 162.8
	},
	[70] = {
		requirement = 382255025,
		multiplier = 177.6
	},
	[71] = {
		requirement = 456230300,
		multiplier = 192.4
	},
	[72] = {
		requirement = 554864000,
		multiplier = 207.2
	},
	[73] = {
		requirement = 582262250,
		multiplier = 180.4
	},
	[74] = {
		requirement = 637058750,
		multiplier = 196.8
	},
	[75] = {
		requirement = 719253500,
		multiplier = 213.2
	},
	[76] = {
		requirement = 828846500,
		multiplier = 229.60000000000002
	},
	[77] = {
		requirement = 879455300,
		multiplier = 198
	},
	[78] = {
		requirement = 980672900,
		multiplier = 216
	},
	[79] = {
		requirement = 1132499300,
		multiplier = 234
	},
	[80] = {
		requirement = 1334934500,
		multiplier = 252
	},
	[81] = {
		requirement = 1429826750,
		multiplier = 356.4
	},
	[82] = {
		requirement = 1619611250,
		multiplier = 388.8
	},
	[83] = {
		requirement = 1904288000,
		multiplier = 421.2
	},
	[84] = {
		requirement = 2283857000,
		multiplier = 453.6
	},
	[85] = {
		requirement = 2663426000,
		multiplier = 514.8
	},
	[86] = {
		requirement = 3422564000,
		multiplier = 561.6
	},
	[87] = {
		requirement = 4561271000,
		multiplier = 608.4
	},
	[88] = {
		requirement = 6079547000,
		multiplier = 655.2
	},
	[89] = {
		requirement = 6743792750,
		multiplier = 673.2
	},
	[90] = {
		requirement = 8072284250,
		multiplier = 734.4
	},
	[91] = {
		requirement = 10065021500,
		multiplier = 795.6
	},
	[92] = {
		requirement = 12722004500,
		multiplier = 856.8
	},
	[93] = {
		requirement = 14857080125,
		multiplier = 831.6
	},
	[94] = {
		requirement = 19127231375,
		multiplier = 907.2
	},
	[95] = {
		requirement = 25532458250,
		multiplier = 982.8
	},
	[96] = {
		requirement = 34072760750,
		multiplier = 1058.4
	},
	[97] = {
		requirement = 36919528250,
		multiplier = 990
	},
	[98] = {
		requirement = 42613063250,
		multiplier = 1080
	},
	[99] = {
		requirement = 51153365750,
		multiplier = 1170
	},
	[100] = {
		requirement = 62540435750,
		multiplier = 1260
	},
	[101] = {
		requirement = 69515016125,
		multiplier = 1148.4
	},
	[102] = {
		requirement = 83464176875,
		multiplier = 1252.8
	},
	[103] = {
		requirement = 104387918000,
		multiplier = 1357.2
	},
	[104] = {
		requirement = 132286239500,
		multiplier = 1461.6
	},
	[105] = {
		requirement = 140921434250,
		multiplier = 1306.8
	},
	[106] = {
		requirement = 158191823750,
		multiplier = 1425.6
	},
	[107] = {
		requirement = 184097408000,
		multiplier = 1544.4
	},
	[108] = {
		requirement = 218638187000,
		multiplier = 1663.2
	},
	[109] = {
		requirement = 236145807125,
		multiplier = 1465.2
	},
	[110] = {
		requirement = 271161047375,
		multiplier = 1598.4
	},
	[111] = {
		requirement = 323683907750,
		multiplier = 1731.6
	},
	[112] = {
		requirement = 393714388250,
		multiplier = 1864.8000000000002
	},
	[113] = {
		requirement = 413167299500,
		multiplier = 1623.6
	},
	[114] = {
		requirement = 452073122000,
		multiplier = 1771.2
	},
	[115] = {
		requirement = 510431855750,
		multiplier = 1918.8
	},
	[116] = {
		requirement = 588243500750,
		multiplier = 2066.4
	},
	[117] = {
		requirement = 624176032750,
		multiplier = 1782
	},
	[118] = {
		requirement = 696041096750,
		multiplier = 1944
	},
	[119] = {
		requirement = 803838692750,
		multiplier = 2106
	},
	[120] = {
		requirement = 947568820750,
		multiplier = 2268
	},
	[121] = {
		requirement = 1149689315350,
		multiplier = 2222
	},
	[122] = {
		requirement = 1553930304550,
		multiplier = 2424
	},
	[123] = {
		requirement = 2160291788350,
		multiplier = 2626
	},
	[124] = {
		requirement = 2968773766750,
		multiplier = 2828
	},
	[125] = {
		requirement = 3676195497850,
		multiplier = 2662
	},
	[126] = {
		requirement = 5091038960050,
		multiplier = 2904
	},
	[127] = {
		requirement = 7213304153350,
		multiplier = 3146
	},
	[128] = {
		requirement = 10042991077750,
		multiplier = 3388
	},
	[129] = {
		requirement = 11053593550750,
		multiplier = 3102
	},
	[130] = {
		requirement = 13074798496750,
		multiplier = 3384
	},
	[131] = {
		requirement = 16106605915750,
		multiplier = 3666
	},
	[132] = {
		requirement = 20149015807750,
		multiplier = 3948
	},
	[133] = {
		requirement = 23332413597700,
		multiplier = 3542
	},
	[134] = {
		requirement = 29699209177600,
		multiplier = 3864
	},
	[135] = {
		requirement = 39249402547450,
		multiplier = 4186
	},
	[136] = {
		requirement = 51982993707250,
		multiplier = 4508
	},
	[137] = {
		requirement = 55924343351950,
		multiplier = 3982
	},
	[138] = {
		requirement = 63807042641350,
		multiplier = 4344
	},
	[139] = {
		requirement = 75631091575450,
		multiplier = 4706
	},
	[140] = {
		requirement = 91396490154250,
		multiplier = 5068
	},
	[141] = {
		requirement = 100946683524100,
		multiplier = 4422
	},
	[142] = {
		requirement = 120047070263800,
		multiplier = 4824
	},
	[143] = {
		requirement = 148697650373350,
		multiplier = 5226
	},
	[144] = {
		requirement = 186898423852750,
		multiplier = 5628
	},
	[145] = {
		requirement = 198217171550350,
		multiplier = 4862
	},
	[146] = {
		requirement = 220854666945550,
		multiplier = 5304
	},
	[147] = {
		requirement = 254810910038350,
		multiplier = 5746
	},
	[148] = {
		requirement = 300085900828750,
		multiplier = 6188
	},
	[149] = {
		requirement = 322874986594900,
		multiplier = 5302
	},
	[150] = {
		requirement = 368453158127200,
		multiplier = 5784
	},
	[151] = {
		requirement = 436820415425650,
		multiplier = 6266
	},
	[152] = {
		requirement = 527976758490250,
		multiplier = 6748
	},
	[153] = {
		requirement = 552837579326050,
		multiplier = 5742
	},
	[154] = {
		requirement = 602559220997650,
		multiplier = 6264
	},
	[155] = {
		requirement = 677141683505050,
		multiplier = 6786
	},
	[156] = {
		requirement = 776584966848250,
		multiplier = 7308
	},
	[157] = {
		requirement = 822028391384150,
		multiplier = 6182
	},
	[158] = {
		requirement = 912915240455950,
		multiplier = 6744
	},
	[159] = {
		requirement = 1049245514063650,
		multiplier = 7306
	},
	[160] = {
		requirement = 1231019212207250,
		multiplier = 7868
	},
	[161] = {
		requirement = 1606019212207250,
		multiplier = 7942
	},
	[162] = {
		requirement = 2356019212207250,
		multiplier = 8664
	},
	[163] = {
		requirement = 3481019212207250,
		multiplier = 9386
	},
	[164] = {
		requirement = 4981019212207250,
		multiplier = 10108
	},
	[165] = {
		requirement = 6231019212207250,
		multiplier = 9702
	},
	[166] = {
		requirement = 8731019212207250,
		multiplier = 10584
	},
	[167] = {
		requirement = 12481019212207250,
		multiplier = 11466
	},
	[168] = {
		requirement = 17481019212207250,
		multiplier = 12348
	},
	[169] = {
		requirement = 19731019212207250,
		multiplier = 11462
	},
	[170] = {
		requirement = 24231019212207250,
		multiplier = 12504
	},
	[171] = {
		requirement = 30981019212207250,
		multiplier = 13546
	},
	[172] = {
		requirement = 39981019212207250,
		multiplier = 14588
	},
	[173] = {
		requirement = 47481019212207250,
		multiplier = 13222
	},
	[174] = {
		requirement = 62481019212207250,
		multiplier = 14424
	},
	[175] = {
		requirement = 84981019212207250,
		multiplier = 15626
	},
	[176] = {
		requirement = 114981019212207250,
		multiplier = 16828
	},
	[177] = {
		requirement = 129981019212207250,
		multiplier = 14982
	},
	[178] = {
		requirement = 159981019212207230,
		multiplier = 16344
	},
	[179] = {
		requirement = 204981019212207230,
		multiplier = 17706
	},
	[180] = {
		requirement = 264981019212207230,
		multiplier = 19068
	},
	[181] = {
		requirement = 284981019212207230,
		multiplier = 16742
	},
	[182] = {
		requirement = 324981019212207200,
		multiplier = 18264
	},
	[183] = {
		requirement = 384981019212207200,
		multiplier = 19786
	},
	[184] = {
		requirement = 464981019212207200,
		multiplier = 21308
	},
	[185] = {
		requirement = 514981019212207200,
		multiplier = 18502
	},
	[186] = {
		requirement = 614981019212207200,
		multiplier = 20184
	},
	[187] = {
		requirement = 764981019212207200,
		multiplier = 21866
	},
	[188] = {
		requirement = 964981019212207200,
		multiplier = 23548
	},
	[189] = {
		requirement = 1089981019212207200,
		multiplier = 20262
	},
	[190] = {
		requirement = 1339981019212207000,
		multiplier = 22104
	},
	[191] = {
		requirement = 1714981019212207000,
		multiplier = 23946
	},
	[192] = {
		requirement = 2214981019212207000,
		multiplier = 25788
	},
	[193] = {
		requirement = 2439981019212207000,
		multiplier = 22022
	},
	[194] = {
		requirement = 2889981019212207000,
		multiplier = 24024
	},
	[195] = {
		requirement = 3564981019212207000,
		multiplier = 26026
	},
	[196] = {
		requirement = 4464981019212207000,
		multiplier = 28028
	},
	[197] = {
		requirement = 4964981019212207000,
		multiplier = 23782
	},
	[198] = {
		requirement = 5964981019212207000,
		multiplier = 25944
	},
	[199] = {
		requirement = 7464981019212207000,
		multiplier = 28106
	},
	[200] = {
		requirement = 9464981019212206000,
		multiplier = 30268
	},
}