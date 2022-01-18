
local Theme = require(script.Parent.Theme)

--|| Utility ||--
local Instantiate = require(script.Parent.Utility.Instantiate)
local colorize = require(script.Parent.Utility.colorize)

--|| Templates ||--
local window = require(script.Parent.Elements.window)

--|| Timeline ||--
local timeline = {}
function timeline.new(parent, config)
	local self = setmetatable({
		Window = window.new(
			parent,
			Vector2.new(1, 0),
			UDim2.fromOffset(200, 390)
		)
	}, {__index = timeline})

	return self
end

return timeline