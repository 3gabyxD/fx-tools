
local Theme = require(script.Parent.Theme)

--|| Utility ||--
local Instantiate = require(script.Parent.Utility.Instantiate)
local colorize = require(script.Parent.Utility.colorize)

--|| Templates ||--
local movingWindow = require(script.Parent.Elements.movingWindow)

--|| Timeline ||--
local timeline = {}
function timeline.new(parent, config)
	local self = setmetatable({
		Window = movingWindow.new(
			parent,
			Vector2.new(.5, .5),
			UDim2.fromScale(.5, .5),
			UDim2.fromOffset(450, 250)
		),
		Config = config
	}, {__index = timeline})

	return self
end

return timeline