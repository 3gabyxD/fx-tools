
local SetWaypoint = script.Parent.SetWaypoint
local Theme = require(script.Parent.Theme)

--|| Services ||--
local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")

--|| Utility ||--
local Instantiate = require(script.Parent.Utility.Instantiate)
local map = require(script.Parent.Utility.map)
local colorize = require(script.Parent.Utility.colorize)

--|| Templates ||--
local window = require(script.Parent.Elements.window)

--|| Clipboard ||--
local clipboard = {}
function clipboard.new(parent, config)
	local self = setmetatable({
		Window = window.new(
			parent,
			Vector2.new(1, 0),
			UDim2.fromOffset(200, 310)
		),
		Config = config,
		TargetObject = nil,
		Copied = {},
	}, {__index = clipboard})
	self:DrawUI()
	return self
end

function clipboard:Copy()
	local o = self.TargetObject
	if o then
		if o:IsA("ParticleEmitter") then
			self.Copied = {
				Color = o.Color,
				Size = o.Size,
				Squash = o.Squash,
				Transparency = o.Transparency
			}
		elseif o:IsA("Beam") then
			self.Copied = {
				Color = o.Color,
				Transparency = o.Transparency
			}
		elseif o:IsA("Trail") then
			self.Copied = {
				Color = o.Color,
				Transparency = o.Transparency,
				WidthScale = o.WidthScale
			}
		end
	end
end

function clipboard:Paste(class, prop)
	for _, inst in pairs(Selection:Get()) do
		if inst:IsA(class) then
			if self.Copied[prop] then
				inst[prop] = self.Copied[prop]
			end
		end
	end
	SetWaypoint:Fire("Pasted " .. prop .. " to " .. class .. "s")
end

function clipboard:DrawUI()
	self.UI = {}
	self.UI.Buttons = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(180, 20),
		BackgroundColor3 = Theme:Get("background"),
	}, {
		Instantiate("TextButton", {
			Name = "Copy",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Copy"
		}),

		Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})

	self.UI.Particles = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 10 + 30),
		Size = UDim2.fromOffset(
			180, -- Width
			20 * 4 + 10 * 2
			-- TextSize * Properties + Padding * 2 + Title
		),
		BackgroundColor3 = Theme:Get("background")
	}, {
		Instantiate("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("highlight"),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 12,
			Font = Theme:Get("font"),
			Text = "Particles"
		}),

		Instantiate("TextButton", {
			Name = "_Color",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Color"
		}),

		Instantiate("TextButton", {
			Name = "_Size",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10 + 20),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Size"
		}),

		Instantiate("TextButton", {
			Name = "_Squash",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10 + 20 * 2),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Squash"
		}),

		Instantiate("TextButton", {
			Name = "_Transparency",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10 + 20 * 3),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Transparency"
		}),

		Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})

	self.UI.Beams = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 40 + 100 + 10),
		Size = UDim2.fromOffset(
			180, -- Width
			20 * 2 + 10 * 2
			-- TextSize * Properties + Padding * 2 + Title
		),
		BackgroundColor3 = Theme:Get("background")
	}, {
		Instantiate("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("highlight"),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 12,
			Font = Theme:Get("font"),
			Text = "Beams"
		}),

		Instantiate("TextButton", {
			Name = "_Color",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Color"
		}),

		Instantiate("TextButton", {
			Name = "_Transparency",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10 + 20),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Transparency"
		}),

		Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})

	self.UI.Trails = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 150 + 70),
		Size = UDim2.fromOffset(
			180, -- Width
			20 * 3 + 10 * 2
			-- TextSize * Properties + Padding * 2
		),
		BackgroundColor3 = Theme:Get("background")
	}, {
		Instantiate("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("highlight"),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 12,
			Font = Theme:Get("font"),
			Text = "Trails"
		}),

		Instantiate("TextButton", {
			Name = "_Color",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Color"
		}),

		Instantiate("TextButton", {
			Name = "_Transparency",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10 + 20),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "Transparency"
		}),

		Instantiate("TextButton", {
			Name = "_WidthScale",
			Size = UDim2.new(1, -10, 0, 20),
			Position = UDim2.fromOffset(10, 10 + 20 * 2),
			BackgroundTransparency = 1,
			TextColor3 = Theme:Get("main"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 15,
			Font = Theme:Get("font"),
			Text = "WidthScale"
		}),

		Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})

	colorize(self.UI)

	self.UI.Buttons.Copy.MouseButton1Click:Connect(function()
		self:Copy()
	end)

	self.UI.Particles._Color.MouseButton1Click:Connect(function()
		self:Paste("ParticleEmitter", "Color")
	end)

	self.UI.Particles._Size.MouseButton1Click:Connect(function()
		self:Paste("ParticleEmitter", "Size")
	end)

	self.UI.Particles._Squash.MouseButton1Click:Connect(function()
		self:Paste("ParticleEmitter", "Squash")
	end)

	self.UI.Particles._Transparency.MouseButton1Click:Connect(function()
		self:Paste("ParticleEmitter", "Transparency")
	end)

	self.UI.Beams._Color.MouseButton1Click:Connect(function()
		self:Paste("Beam", "Color")
	end)

	self.UI.Beams._Transparency.MouseButton1Click:Connect(function()
		self:Paste("Beam", "Transparency")
	end)

	self.UI.Trails._Color.MouseButton1Click:Connect(function()
		self:Paste("Beam", "Color")
	end)

	self.UI.Trails._Transparency.MouseButton1Click:Connect(function()
		self:Paste("Beam", "Transparency")
	end)

	self.UI.Trails._WidthScale.MouseButton1Click:Connect(function()
		self:Paste("Beam", "WidthScale")
	end)

end

function clipboard:SetActive(activeObject)
	self.TargetObject = activeObject
end

return clipboard