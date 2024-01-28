Config = {}

Config.Cooldown = 2 -- in hours

Config.Colors = {
    ['cartel'] = 83,
    ['families'] = 2,
    ['camorra'] = 25,
    ['polekai'] = 85,
    ['neoficiali'] = 56,
    ['guminukai'] = 56,
    ['neoficiali1'] = 1,
    ['komandax'] = 26,
    ['barbes'] = 30,
    ['francizai'] = 13, 
    ['syndicates'] = 50, 
    ['cosa'] = 1,
    ['neoficiali2'] = 38
}

Config.GangNames = {
    ["neoficiali2"] = "EMIGRANTAI",
    ["families"] = "FAMILIES",
    ["neoficiali1"] = "United Blood Nation ",
    ["cosa"] = "COSA NOSTRA",
    ["cartel"] = "CARTEL",
    ["komandax"] = "KOMANDA X",
    ["camorra"] = "CAMORRA",
    ["neoficiali"] = "PRINCAI",
    ["guminukai"] = "JAMAGUCI GUMI",
    ["francizai"] = "FRANCIZAI",
    ["syndicates"] = "SYNDICATES",
    ["barbes"] = "BARBES",
    ["polekai"] = "KOMANDORAI",
}

Config.MoneyBox = {
    ['model'] = `ex_prop_crate_money_bc`,
    ['rewards'] = {
        {name = 'ammo-9', amount = math.random(50, 400)},
        {name = 'black_money', amount = math.random(35000, 60000)},
        {name = 'black_money', amount = math.random(35000, 60000)},
        {name = 'black_money', amount = math.random(35000, 60000)},
        {name = 'WEAPON_PISTOL', amount = 1 },
        {name = 'WEAPON_PISTOL', amount = 1 },
        {name = 'meth', amount = math.random(55, 78)},
        {name = 'meth', amount = math.random(55, 78)},
        {name = 'auksas', amount = math.random(9, 15)},
        {name = 'sidabras', amount = math.random(10, 20)},
        {name = 'ammo-smg', amount = math.random(60, 350)}
    }
}

Config.Debug = true