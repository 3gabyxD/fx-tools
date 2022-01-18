
local UserInputService = game:GetService("UserInputService")
local Theme = require(script.Parent.Parent.Theme)
local Instantiate = require(script.Parent.Parent.Utility.Instantiate)

local window = require(script.Parent.window)

--|| Moving Window ||--
local moving = setmetatable({}, window)
moving.__index = moving
function moving.new(parent, anchor, pos, size, elements)
	local self = setmetatable(
		window.new(parent, anchor, size, elements),
		moving
	)
	self.Type = "moving"
	self.Position = pos or UDim2.new()

	self.Button = Instantiate("ImageButton", {
		Parent = self,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = -50
	})

	self.HoldStart = Vector2.new()
	self.Button.MouseButton1Down:Connect(function(x, y)
		self.HoldStart = Vector2.new(x, y)
		local onHoldStart = self.Position
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			task.wait()
			local delt = UserInputService:GetMouseLocation() - self.HoldStart
			self.Position = onHoldStart
			+ UDim2.fromOffset(delt.X, delt.Y)
			self.Instance.Position = self.Position
		end
		local delt = UserInputService:GetMouseLocation() - self.HoldStart
		self.Position = onHoldStart
		+ UDim2.fromOffset(delt.X, delt.Y)
		self.Instance.Position = self.Position
	end)

	return self
end

function moving:reveal()
	window.reveal(self, self.Position)
end

return moving