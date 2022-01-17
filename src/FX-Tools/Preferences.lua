
local Theme = require(script.Parent.Theme)

--|| Utility ||--
local Instantiate = require(script.Parent.Utility.Instantiate)

--|| Templates ||--
local window = require(script.Parent.Elements.window)

--|| Preferences ||--
local preferences = {}
function preferences.new(parent, config)
	local self = setmetatable({
		Window = window.new(
			parent,
			Vector2.new(1, 0),
			UDim2.fromOffset(200, 20 * 2 + 20 + 20 + 10)
		),
		Config = config
	}, {__index = preferences})
	
	self:CreateCategory(
		"Curves",
		UDim2.fromOffset(10, 10),
		{
			"CurveLiveUpdate",
			"CurveLiveDraw"
		}
	).Parent = self.Window.Instance
	
	self:CreateCategory(
		"Menu",
		UDim2.fromOffset(10, 20 + 20*2),
		{
			"AlwaysActive"
		}
	).Parent = self.Window.Instance

	return self
end

function preferences:CreateCategory(title, pos, keys)
	local bars = {}
	for i, key in pairs(keys) do
		local bar = Instantiate("Frame", {
			Name = key,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 20*(i-1))
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = key .. ":",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.RobotoMono
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Right,
				TextSize = 15,
				Text = tostring(self.Config:Get(key)),
				PlaceholderText = tostring(self.Config:Get(key)),
				Font = Enum.Font.RobotoMono
			})
		})
		
		local _type = type(self.Config:Get(key))
		
		bar.Box.InputEnded:Connect(function()
			if _type == "boolean" then
				if bar.Box.Text:lower() == "true" then
					self.Config:Set(key, true)
				elseif bar.Box.Text:lower() == "false" then
					self.Config:Set(key, false)
				else
					bar.Box.Text = ""
				end
			elseif _type == "number" then
				if tonumber(bar.Box.Text) then
					self.Config:Set(key, tonumber(bar.Box.Text))
				else
					bar.Box.Text = ""
				end
			elseif _type == "string" then
				self.Config:Set(key, bar.Box.Text)
			end
		end)
		
		bars[i] = bar
	end
	
	bars[#bars + 1] = Instantiate("UICorner", {
		CornerRadius = UDim.new(0, Theme:Get("corner"))
	})
	
	bars[#bars + 1] = Instantiate("UIStroke", {
		Color = Theme:Get("border"),
		Thickness = Theme:Get("bordersize"),
	})
	
	return Instantiate("Frame", {
		Name = title,
		Position = pos,
		Size = UDim2.new(1, -20, 0, 20*#keys),
		BackgroundColor3 = Theme:Get("background")
	}, bars)
end

return preferences