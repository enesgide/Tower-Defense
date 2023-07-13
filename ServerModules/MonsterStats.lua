local NPCs = {
	--Bosses
	["Boss1"] = {maxhealth = 350000, speed = 2, hud = 1.5, reward = 4*10^6, hipheight = 3.3, face = nil};
	["Boss2"] = {maxhealth = 40000000, speed = 1, hud = 1.5, reward = 3*10^9, hipheight = 2.2, face = nil};
	["Boss3"] = {maxhealth = 7000000000, speed = 1, hud = 1.5, reward = 1*10^12, hipheight = 2.65, face = nil};
	["Boss4"] = {maxhealth = 360000000000, speed = 1, hud = 1.5, reward = 9*10^12, hipheight = 3.5, face = nil};
	["Boss5"] = {maxhealth = 14000000000000, speed = 1, hud = 1.5, reward = 120*10^12, hipheight = 3.2, face = nil};
	["Boss6"] = {maxhealth = 400*(10^12), speed = 1, hud = 1.5, reward = 4*10^15, hipheight = 3.35, face = nil};
	["Boss7"] = {maxhealth = 13*(10^15), speed = 1, hud = 1.5, reward = 300*10^15, hipheight = 3.5, face = nil};
	
	--Normals
	["Noob"] = {maxhealth = 5, speed = 5, hud = 1, reward = 0, hipheight = 1.05, face = "rbxassetid://149816692"};
	["Angry Noob"] = {maxhealth = 15, speed = 3, hud = 1, reward = 0, hipheight = 1.5, face = "rbxassetid://1349592985"};

	["Mummy"] = {maxhealth = 30, speed = 5, hud = 1, reward = 0, hipheight = 1.25, face = nil};
	["Anubis"] = {maxhealth = 100, speed = 3, hud = 1, reward = 0, hipheight = 1.85, face = nil};

	["Alien"] = {maxhealth = 200, speed = 6, hud = 1, reward = 0, hipheight = 1.1, face = nil};
	["Alien Leader"] = {maxhealth = 600, speed = 4, hud = 1, reward = 0, hipheight = 2.35, face = nil};

	["Skeleton"] = {maxhealth = 1600, speed = 6, hud = 1, reward = 0, hipheight = 1.65, face = nil};
	["Agrynoth"] = {maxhealth = 4500, speed = 4, hud = 1, reward = 0, hipheight = 2.45, face = nil};

	["Ninja"] = {maxhealth = 8200, speed = 8, hud = 1, reward = 0, hipheight = 1.45, face = "rbxassetid://2506788845"}; 
	["Master Ninja"] = {maxhealth = 20000, speed = 8, hud = 1, reward = 0, hipheight = 2.25, face = nil};

	["Polar Bear"] = {maxhealth = 45000, speed = 5, hud = 1, reward = 0, hipheight = 1.15, face = nil}; 
	["Yeti"] = {maxhealth = 130000, speed = 4, hud = 1, reward = 0, hipheight = 1.7, face = nil};

	["Doombringer"] = {maxhealth = 350000, speed = 6, hud = 1, reward = 0, hipheight = 1.15, face = nil}; 
	["Fire Bull"] = {maxhealth = 1200000, speed = 5, hud = 1, reward = 0, hipheight = 2.1, face = nil};

	["Gladiator"] = {maxhealth = 3200000, speed = 6, hud = 1, reward = 0, hipheight = 1.2, face = "rbxassetid://2493587489"};  
	["Harbringer"] = {maxhealth = 8000000, speed = 5, hud = 1, reward = 0, hipheight = 2.45, face = "rbxassetid://2514587317"};

	["Junkbot"] = {maxhealth = 24000000, speed = 6, hud = 1, reward = 0, hipheight = 1.5, face = nil};  
	["Steampunk Bot"] = {maxhealth = 70000000, speed = 4, hud = 1, reward = 0, hipheight = 1.9, face = nil};

	["Mech Wasp"] = {maxhealth = 190000000, speed = 5, hud = 1, reward = 0, hipheight = 1.65, face = nil};  
	["Reptilian"] = {maxhealth = 620000000, speed = 4, hud = 1, reward = 0, hipheight = 2.4, face = nil};

	["Sun Slayer"] = {maxhealth = 1700000000, speed = 6, hud = 1, reward = 0, hipheight = 1.35, face = nil};  
	["Griffin"] = {maxhealth = 5800000000, speed = 4, hud = 1, reward = 0, hipheight = 2.6, face = nil};

	["Crook"] = {maxhealth = 14000000000, speed = 6, hud = 1, reward = 0, hipheight = 1.35, face = "rbxassetid://133867453"};  
	["Scammer"] = {maxhealth = 45000000000, speed = 4, hud = 1, reward = 0, hipheight = 1.85, face = "rbxassetid://25975157"};

	["Gargoyle"] = {maxhealth = 110000000000, speed = 5, hud = 1, reward = 0, hipheight = 1.5, face = nil};  
	["Guardian Lion"] = {maxhealth = 330000000000, speed = 4, hud = 1, reward = 0, hipheight = 2, face = nil};

	["Overseer Assassin"] = {maxhealth = 1100000000000, speed = 7, hud = 1, reward = 0, hipheight = 1.73, face = "rbxassetid://2761366151"};  
	["Overseer"] = {maxhealth = 4000000000000, speed = 5, hud = 1, reward = 0, hipheight = 1.9, face = nil};
	
	["Jester"] = {maxhealth = 15000000000000, speed = 6, hud = 1, reward = 0, hipheight = 1.7, face = "rbxassetid://2962660233"};  
	["Crazy Clown"] = {maxhealth = 70000000000000, speed = 4, hud = 1, reward = 0, hipheight = 2.05, face = nil};
	
	["Redcliff Paladin"] = {maxhealth = 250000000000000, speed = 6, hud = 1, reward = 0, hipheight = 1.7, face = "rbxassetid://2492950480"};  
	["Redcliff Commander"] = {maxhealth = 1000000000000000, speed = 4, hud = 1, reward = 0, hipheight = 2, face = nil};
}

return NPCs
