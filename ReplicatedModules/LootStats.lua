local loot = {}

-- For alwaysShow, add those items in leaderboard (after load data) to the player's inventory if they are not present
loot.Materials = {
	-- Random crates
	["Basic Skin Crate"] = {
		materialType = "Skin Crate",
		alwaysShow = true,
		price = 10,		
		coinSell = 2/5,
		gemSell = 2,
		img = "rbxassetid://9667944051",
		choices = {
			{towerName = "Armored Cannon", skinName = "Glorious"},
			{towerName = "Armored Cannon", skinName = "Steel"},
			{towerName = "Frozen Pillar", skinName = "Monochromatic"},
			{towerName = "Frozen Pillar", skinName = "Toxic"},
			{towerName = "Future's Blast", skinName = "Crimson"},
			{towerName = "Future's Blast", skinName = "Lime"},
			{towerName = "Heaven's Vision", skinName = "Furious"},
			{towerName = "Magmar's Mesa", skinName = "Teal"},
			{towerName = "Mantle Spiker", skinName = "Electric"},
			{towerName = "Mantle Spiker", skinName = "Teal"},
			{towerName = "Solar Scorch", skinName = "Corrupt"},	
			{towerName = "Solar Scorch", skinName = "Crimson"},			
			{towerName = "Triadic Corruption", skinName = "Magenta"},
			{towerName = "Triadic Corruption", skinName = "Molten"},
		}
	};
	["Rare Skin Crate"] = {
		materialType = "Skin Crate",
		alwaysShow = true,	
		price = 25,
		coinSell = 1,
		gemSell = 5,
		img = "rbxassetid://9667943523",
		choices = {		
			{towerName = "Acidic Powerplant", skinName = "Corrupt"},
			{towerName = "Acidic Powerplant", skinName = "Volcanic"},
			{towerName = "Armored Cannon", skinName = "Bee"},
			{towerName = "Armored Cannon", skinName = "Lava"},
			{towerName = "Frozen Pillar", skinName = "Firey"},
			{towerName = "Future's Blast", skinName = "Energized"},
			{towerName = "Future's Blast", skinName = "Spider"},
			--{towerName = "Heaven's Vision", skinName = "Frosty"},
			{towerName = "Heaven's Vision", skinName = "Corrupt"},
			--{towerName = "Magmar's Mesa", skinName = "Snowy"},
			{towerName = "Magmar's Mesa", skinName = "Spider"},
			{towerName = "Solar Scorch", skinName = "Alien"},
			{towerName = "Triadic Corruption", skinName = "Glorious"},
		}
	};
	["Premium Skin Crate"] = {
		materialType = "Skin Crate",
		alwaysShow = false,		
		img = "rbxassetid://9667943922",
		choices = {
		}
	};
	
	-- Skin line crates
	["Phantom Skin Crate"] = {
		materialType = "Skin Crate",
		alwaysShow = true,	
		price = 50,
		coinSell = 2,
		gemSell = 10,
		img = "rbxassetid://10472070885",
		choices = {		
			{towerName = "Acidic Powerplant", skinName = "Phantom"},
			{towerName = "Armored Cannon", skinName = "Phantom"},
			{towerName = "Frozen Pillar", skinName = "Phantom"},
			{towerName = "Future's Blast", skinName = "Phantom"},
			{towerName = "Heaven's Vision", skinName = "Phantom"},
			{towerName = "Magmar's Mesa", skinName = "Phantom"},
			{towerName = "Mantle Spiker", skinName = "Phantom"},
			{towerName = "Solar Scorch", skinName = "Phantom"},
			{towerName = "Triadic Corruption", skinName = "Phantom"},
		}
	};
	
	-- Limited time crates
	["Winter Skin Crate"] = {
		materialType = "Skin Crate",
		alwaysShow = true,	
		price = 50,
		coinSell = 2,
		gemSell = 10,
		img = "rbxassetid://11775385390",
		choices = {		
			{towerName = "Acidic Powerplant", skinName = "Frosty"},
			{towerName = "Armored Cannon", skinName = "Snowy"},			
			{towerName = "Frozen Pillar", skinName = "Snowy"},
			{towerName = "Future's Blast", skinName = "Snowy"},
			{towerName = "Heaven's Vision", skinName = "Frosty"},
			--{towerName = "Hell's Vision", skinName = "Winter"}, PURCHASE ONLY (EVENT TOWER) 
			{towerName = "Magmar's Mesa", skinName = "Snowy"},
			{towerName = "Mantle Spiker", skinName = "Frosty"},
			{towerName = "Solar Scorch", skinName = "Frosty"},
			--{towerName = "The Eggsecutor", skinName = "Winter"}, PURCHASE ONLY (EVENT TOWER)
			{towerName = "Triadic Corruption", skinName = "Frosty"},
		}
	};
}

loot.Skins = {
	["Acidic Powerplant"] = {
		["Default"] = {
			img = "rbxassetid://10230959135",
		},	
		["Corrupt"] = {
			id = 1290914234,
			price = 200,
			img = "rbxassetid://10387923992",
		},
		["Frosty"] = {
			id = 1344557389,
			price = 400,
			img = "rbxassetid://11775279593",
		},
		["Phantom"] = {
			id = 1294431485,
			price = 400,
			img = "rbxassetid://10472518357",
		},
		["Volcanic"] = {
			id = 1290914171,
			price = 200,
			img = "rbxassetid://10387923678",
		},
	},
	["Armored Cannon"] = {
		["Default"] = {
			img = "rbxassetid://9059869542",
		},	
		["Bee"] = {
			id = 1263610765,
			price = 200,
			img = "rbxassetid://9575519445",
		},
		["Glorious"] = {
			id = 1290913986,
			price = 80,
			img = "rbxassetid://10387923401",
		},
		["Lava"] = {
			id = 1263610738,
			price = 200,
			img = "rbxassetid://9575475823",
		},
		["Phantom"] = {
			id = 1294431673,
			price = 400,
			img = "rbxassetid://10472518114",
		},
		["Snowy"] = {
			id = 1344557657,
			price = 400,
			img = "rbxassetid://11775279427",
		},
		["Steel"] = {
			id = 1267459570,
			price = 80,
			img = "rbxassetid://9738666645",
		},
	},
	["Festive Turret"] = {
		["Default"] = {
			img = "rbxassetid://8223136695",
		},
	},	
	["Frozen Pillar"] = {
		["Default"] = {
			img = "rbxassetid://8269641000",
		},
		["Firey"] = {
			id = 1277979648,
			price = 200,
			img = "rbxassetid://10049710363",
		},
		["Monochromatic"] = {
			id = 1267458511,
			price = 80,
			img = "rbxassetid://9738666230",
		},
		["Phantom"] = {
			id = 1294432000,
			price = 400,
			img = "rbxassetid://10472517919",
		},
		["Snowy"] = {
			id = 1344557752,
			price = 400,
			img = "rbxassetid://11775279074",
		},
		["Toxic"] = {
			id = 1267458439,
			price = 80,
			img = "rbxassetid://9738665821",
		},
	},
	["Future's Blast"] = {
		["Default"] = {
			img = "rbxassetid://9411052473",
		},
		["Crimson"] = {
			id = 1267458333,
			price = 80,
			img = "rbxassetid://9738665528",
		},
		["Energized"] = {
			id = 1267342562,
			price = 200,
			img = "rbxassetid://9735971785",
		},
		["Lime"] = {
			id = 1267458227,
			price = 80,
			img = "rbxassetid://9738665033",
		},
		["Phantom"] = {
			id = 1294432097,
			price = 400,
			img = "rbxassetid://10472517686",
		},
		["Snowy"] = {
			id = 1344557823,
			price = 400,
			img = "rbxassetid://11775278912",
		},
		["Spider"] = {
			id = 1267458125,
			price = 200,
			img = "rbxassetid://9738664590",
		},
	},
	["Heaven's Vision"] = {
		["Default"] = {
			img = "rbxassetid://8269640672",
		},
		["Corrupt"] = {
			id = 1267342987,
			price = 200,
			img = "rbxassetid://9735971608",
		},
		["Frosty"] = {
			id = 1277979296,
			price = 200,
			img = "rbxassetid://10049710054",
		},
		["Furious"] = {
			id = 1267342946,
			price = 80,
			img = "rbxassetid://9735971315",
		},
		["Phantom"] = {
			id = 1294432240,
			price = 400,
			img = "rbxassetid://10472517350",
		},
	},
	["Hell's Vision"] = {
		["Default"] = {
			img = "rbxassetid://11186099088",
		},
		["Winter"] = {
			id = 1344557882,
			price = 400,
			img = "rbxassetid://11775278785",
		},
	},
	["Ice Dragon"] = {
		["Default"] = {
			img = "rbxassetid://11897312748",
		},
	},
	["Magmar's Mesa"] = {
		["Default"] = {
			img = "rbxassetid://8178378066",
		},
		["Phantom"] = {
			id = 1294432393,
			price = 400,
			img = "rbxassetid://10472517039",
		},
		["Snowy"] = {
			id = 1267342879,
			price = 400,
			img = "rbxassetid://9735971117",
		},
		["Spider"] = {
			id = 1290913858,
			price = 200,
			img = "rbxassetid://10387922914",
		},
		["Teal"] = {
			id = 1267456625,
			price = 80,
			img = "rbxassetid://9738664259",
		},
	},
	["Mantle Spiker"] = {
		["Default"] = {
			img = "rbxassetid://9747023997",
		},
		["Electric"] = {
			id = 1277979488,
			price = 80,
			img = "rbxassetid://10049721713",
		},
		["Frosty"] = {
			id = 1344558016,
			price = 400,
			img = "rbxassetid://11775278667",
		},
		["Phantom"] = {
			id = 1294432519,
			price = 400,
			img = "rbxassetid://10472516735",
		},		
		["Teal"] = {
			id = 1277979551,
			price = 80,
			img = "rbxassetid://10049709818",
		},
	},
	["Solar Scorch"] = {
		["Default"] = {
			img = "rbxassetid://8269640413",
		},
		["Alien"] = {
			id = 1267343060,
			price = 200,
			img = "rbxassetid://9735970885",
		},
		["Corrupt"] = {
			id = 1277979380,
			price = 80,
			img = "rbxassetid://10049709389",
		},
		["Crimson"] = {
			id = 1267343120,
			price = 80,
			img = "rbxassetid://9735970749",
		},
		["Frosty"] = {
			id = 1344558090,
			price = 400,
			img = "rbxassetid://11775278513",
		},
		["Phantom"] = {
			id = 1294432627,
			price = 400,
			img = "rbxassetid://10472537868",
		},		
	},
	["The Eggsecutor"] = {
		["Default"] = {
			img = "rbxassetid://9168171192",
		},
		["Winter"] = {
			id = 1344557708,
			price = 400,
			img = "rbxassetid://11775279271",
		},
	},
	["Triadic Corruption"] = {
		["Default"] = {
			img = "rbxassetid://8269640016",
		},
		["Frosty"] = {
			id = 1344558148,
			price = 400,
			img = "rbxassetid://11775278352",
		},
		["Glorious"] = {
			id = 1267457966,
			price = 200,
			img = "rbxassetid://9798221066",
		},
		["Magenta"] = {
			id = 1267457473,
			price = 80,
			img = "rbxassetid://9738663652",
		},
		["Molten"] = {
			id = 1267457379,
			price = 80,
			img = "rbxassetid://9738663293",
		},
		["Phantom"] = {
			id = 1294432723,
			price = 400,
			img = "rbxassetid://10472516397",
		},
	},
}

return loot
