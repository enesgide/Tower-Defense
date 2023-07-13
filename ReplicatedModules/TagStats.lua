local gradients = {
	["Player"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255, 170, 127)), 
		ColorSequenceKeypoint.new(1,Color3.fromRGB(255, 170, 127)),
	},
	["Group"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(116, 230, 255)), 
		ColorSequenceKeypoint.new(1,Color3.fromRGB(0, 170, 255)),
	},
	["Tester"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(0, 255, 0)), 
		ColorSequenceKeypoint.new(1,Color3.fromRGB(0, 191, 0)),
	},
	["VIP"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(0, 255, 0)), 
		ColorSequenceKeypoint.new(1,Color3.fromRGB(0, 170, 0)),
	},
	["PRO"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0,Color3.fromRGB(255, 94, 94)), 
		ColorSequenceKeypoint.new(1,Color3.fromRGB(236, 0, 0)),
	},
}

return gradients