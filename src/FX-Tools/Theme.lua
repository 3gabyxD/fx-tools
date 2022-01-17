local default = {

	-- Colors
	background = Color3.fromRGB(30, 31, 44),
	border = Color3.fromRGB(7, 9, 17),
	highlight = Color3.fromRGB(255, 219, 15),
	main = Color3.fromRGB(193, 198, 225),
	down = Color3.fromRGB(66, 70, 75),
	active = Color3.fromRGB(52, 140, 255),

	-- Config
	bordersize = 1,
	corner = 5,
	transition = .3,
	font = Enum.Font.RobotoMono
}

local theme = {}
function theme.new(data)
	local self = setmetatable({
		Data = data
	}, {__index = theme})
	return self
end

function theme:Get(id)
	return self.Data[id]
end

--TODO: this thing...
-- i still dont know how ill do this one.
function theme:Hook(properties)

end

local Theme = theme.new(default)

return Theme