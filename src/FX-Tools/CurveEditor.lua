
local SetWaypoint = script.Parent.SetWaypoint
local Theme = require(script.Parent.Theme)

--|| Utility ||--
local Instantiate = require(script.Parent.Utility.Instantiate)
local map = require(script.Parent.Utility.map)
local colorize = require(script.Parent.Utility.colorize)

--|| Templates ||--
local window = require(script.Parent.Elements.window)
local handle = require(script.Parent.Elements.handle)
local pathRenderer = require(script.Parent.Elements.pathRenderer)

--|| Curve Editor ||--
local curveEditor = {}
function curveEditor.new(parent, config)
	local self = setmetatable({
		Window = window.new(
			parent,
			Vector2.new(1, 0),
			UDim2.fromOffset(200, 390)
		),
		Config = config,
		Min = 0,
		Max = 1,
		Env = 0,
		Handles = {},
		Property = nil,
		Editing = false,
		StopEditing = false,
	}, {__index = curveEditor})
	
	self.Display = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.fromOffset(180, 180),
		BackgroundColor3 = Theme:Get("background"),
		ZIndex = 50,
	}, {
		Instantiate("ImageButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}),	Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})
	
	local function cb(apply)
		if apply then
			self:CurveChanged()
		elseif self.Config:Get("CurveLiveUpdate") then
			self:CurveChanged()
		elseif self.Config:Get("CurveLiveDraw") then
			self.Renderer:Draw()
		end
	end

	local function c(vector)
		if self.Editing then
			self.StopEditing = true
			repeat task.wait() until self.Editing == false
		end
		local x, y = self:OpenHandleEditor(vector)
		return Vector2.new(x, y)
	end
	
	self.Handles[1] = handle.new(self.Display, Vector2.new(0, 0), {1, 0}, {0, 1}, {1, 0}, cb, c)
	self.Handles[2] = handle.new(self.Display, Vector2.new(1, 1), {1, 0}, {0, 1}, {0, 1}, cb, c)
	
	self.Renderer = pathRenderer.new(
		self.Display,
		self.Handles
	)
	
	self.TargetObject = nil
	
	self:DrawUI()
	
	return self
end

function curveEditor:OpenHandleEditor(vector)

	self.Editing = true
	local x, y = vector.X, vector.Y

	local frame = Instantiate("Frame", {
		Parent = self.Window,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromOffset(-10, 0),
		Size = UDim2.fromOffset(120, 70),
		BackgroundColor3 = Theme:Get("background"),
	}, {
		Instantiate("Frame", {
			Name = "X",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 5)
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = "X: ",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Theme:Get("font")
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(25, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				Text = string.format("%.3f", x),
				Font = Theme:Get("font")
			})
		}),

		Instantiate("Frame", {
			Name = "Y",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 25)
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = "Y: ",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Theme:Get("font")
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(25, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				Text = string.format("%.3f", y),
				Font = Theme:Get("font")
			})
		}),

		Instantiate("TextButton", {
			Name = "Apply",
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 45),
			TextColor3 = Theme:Get("main"),
			BackgroundTransparency = 1,
			TextSize = 15,
			Text = "Apply",
			Font = Theme:Get("font")
		}),

		Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})

	colorize{frame}

	local applied = false

	frame.Apply.MouseButton1Click:Connect(function()
		if tonumber(frame.X.Box.Text)
		and tonumber(frame.Y.Box.Text) then
			x = tonumber(frame.X.Box.Text)
			y = tonumber(frame.Y.Box.Text)
			applied = true
		end
	end)

	repeat
		task.wait()
	until applied or self.StopEditing

	self.Editing = false
	frame:Destroy()
	print"Close"
	if self.StopEditing then
		self.StopEditing = false
		return nil
	else
		return x, y
	end
end

function curveEditor:Add()
	local center =
		(self.Handles[#self.Handles-1]:Get()[2]
		+ self.Handles[#self.Handles]:Get()[2]) / 2
	
	self.Handles[#self.Handles + 1] = handle.new(
		self.Display,
		center,
		{0, 0},
		{1, 1},
		{0, 0},
		function(apply)
			if apply then
				self:CurveChanged()
			elseif self.Config:Get("CurveLiveUpdate") then
				self:CurveChanged()
			elseif self.Config:Get("CurveLiveDraw") then
				self.Renderer:Draw()
			end
		end,
		function(vector)
			local x, y = self:OpenHandleEditor(vector)
			return Vector2.new(x, y)
		end
	)
	self:SortHandles()
	self:CurveChanged()
end

function curveEditor:Remove()
	if #self.Handles > 2 then
		local handle = table.remove(self.Handles, (#self.Handles - 1))
		handle:Destroy()
		self:SortHandles()
		self:CurveChanged()
	end
end

function curveEditor:CurveChanged()
	self.Renderer:Draw()
	if self.Property then
		
		for _, ui in pairs(self.UI.Property:GetChildren()) do
			if not ui:IsA("TextButton") then continue end
			if ui.Name == "_" .. self.Property then continue end
			if ui.BackgroundTransparency ~= 1 then
				ui.BackgroundTransparency = 1
			end
		end
		
		if pcall(function()
			self.TargetObject[self.Property] = 
				(self.Renderer:Render(self.Min, self.Max, self.Env))
			SetWaypoint:Fire("Applied " .. self.Property .. "Sequence")
			end) then
			if self.UI.Property["_" .. self.Property].BackgroundTransparency ~= 0 then
				self.UI.Property["_" .. self.Property].BackgroundTransparency = 0
			end
		end
		
	else
		
		for _, ui in pairs(self.UI.Property:GetChildren()) do
			if not ui:IsA("TextButton") then continue end
			if ui.BackgroundTransparency ~= 1 then
				ui.BackgroundTransparency = 1
			end
		end
		
	end
end

-- Return true if the first argument should come first. ('<')
function curveEditor:SortHandles()
	table.sort(self.Handles, function(a, b)
		return a.Anchor.X < b.Anchor.X
	end)
end

function curveEditor:DrawUI()
	self.UI = {}
	
	self.UI.Curve = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 200),
		Size = UDim2.fromOffset(200 - 20, 20*2),
		BackgroundColor3 = Theme:Get("background"),
	}, {
		Instantiate("TextButton", {
			Name = "Add",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.fromOffset(80, 20),
			Position = UDim2.fromOffset(10, 0),
			TextColor3 = Theme:Get("main"),
			TextSize = 15,
			Text = "Add",
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Theme:Get("font")
		}), Instantiate("TextButton", {
			Name = "_Remove",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.fromOffset(80, 20),
			Position = UDim2.fromOffset(100, 0),
			TextColor3 = Theme:Get("main"),
			TextSize = 15,
			Text = "Remove",
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Theme:Get("font")
		}),	Instantiate("Frame", {
			Name = "Steps",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(0, 20)
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = "Steps: ",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Theme:Get("font")
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(60, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				Text = "10",
				Font = Theme:Get("font")
			})
		}), Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})

	
	self.UI.Curve.Add.MouseButton1Click:Connect(function()
		self:Add()
	end)
	
	self.UI.Curve._Remove.MouseButton1Click:Connect(function()
		self:Remove()
	end)
	
	self.UI.Curve.Steps.Box.InputEnded:Connect(function()
		if tonumber(self.UI.Curve.Steps.Box.Text) then
			self.Renderer.Steps = tonumber(self.UI.Curve.Steps.Box.Text)
		end
	end)
	
	self.UI.Range = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 230 + 20),
		Size = UDim2.fromOffset(200 - 20, 60),
		BackgroundColor3 = Theme:Get("background"),
	}, {
		Instantiate("Frame", {
			Name = "Min",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = "Min: ",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Theme:Get("font")
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(50, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				Text = "0",
				Font = Theme:Get("font")
			})
		}), Instantiate("Frame", {
			Name = "Max",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, 0, 0, 20),
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = "Max: ",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Theme:Get("font")
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(50, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				Text = "1",
				Font = Theme:Get("font")
			})
		}),Instantiate("Frame", {
			Name = "Env",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Position = UDim2.fromOffset(0, 40),
			Size = UDim2.new(1, 0, 0, 20),
		}, {
			Instantiate("TextLabel", {
				Name = "Label",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(10, 0),
				TextColor3 = Theme:Get("main"),
				TextSize = 15,
				Text = "Env: ",
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Theme:Get("font")
			}), Instantiate("TextBox", {
				Name = "Box",
				BackgroundTransparency = 1,
				BackgroundColor3 = Theme:Get("active"),
				Size = UDim2.new(1, 0, 0, 20),
				Position = UDim2.fromOffset(50, 0),
				TextColor3 = Theme:Get("main"),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 15,
				Text = "0",
				Font = Theme:Get("font")
			})
		}), Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})
	
	self.UI.Range.Min.Box.InputEnded:Connect(function()
		if tonumber(self.UI.Range.Min.Box.Text) then
			self.Min = tonumber(self.UI.Range.Min.Box.Text)
			self:CurveChanged()
		end
	end)
	
	self.UI.Range.Max.Box.InputEnded:Connect(function()
		if tonumber(self.UI.Range.Max.Box.Text) then
			self.Max = tonumber(self.UI.Range.Max.Box.Text)
			self:CurveChanged()
		end
	end)
	
	self.UI.Range.Env.Box.InputEnded:Connect(function()
		if tonumber(self.UI.Range.Env.Box.Text) then
			self.Env = tonumber(self.UI.Range.Env.Box.Text)
			self:CurveChanged()
		end
	end)
	
	self.UI.Property = Instantiate("Frame", {
		Parent = self.Window,
		Position = UDim2.fromOffset(10, 320),
		Size = UDim2.fromOffset(200 - 20, 60),
		BackgroundColor3 = Theme:Get("background"),
	}, {
		
		-- Particles
		Instantiate("TextButton", {
			Name = "_Transparency",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(10, 0),
			TextColor3 = Theme:Get("main"),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Tranparency",
			Font = Theme:Get("font")
		}),
		Instantiate("TextButton", {
			Name = "_Size",
			Position = UDim2.fromOffset(10, 20*1),
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			TextColor3 = Theme:Get("main"),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Size",
			Font = Theme:Get("font")
		}),
		Instantiate("TextButton", {
			Name = "_Squash",
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(10, 20*2),
			TextColor3 = Theme:Get("main"),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "Squash",
			Font = Theme:Get("font")
		}),
		
		-- Beams
		-- Transparency
		
		-- Trails
		Instantiate("TextButton", {
			Name = "_WidthScale",
			Visible = false,
			BackgroundTransparency = 1,
			BackgroundColor3 = Theme:Get("active"),
			Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.fromOffset(10, 20*1),
			TextColor3 = Theme:Get("main"),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = "WidthScale",
			Font = Theme:Get("font")
		}),
		
		
		Instantiate("UICorner", {
			CornerRadius = UDim.new(0, Theme:Get("corner"))
		}), Instantiate("UIStroke", {
			Color = Theme:Get("border"),
			Thickness = Theme:Get("bordersize"),
		})
	})
	
	self.UI.Property._Size.MouseButton1Click:Connect(function()
		
		if self.TargetObject then
			if self.Property ~= "Size" then
				if self.TargetObject:IsA("ParticleEmitter") then
					self.Property = "Size"
					self:CurveChanged()
				end
			else
				self.Property = nil
				self:CurveChanged()
			end
		end
		
	end)
	
	self.UI.Property._Transparency.MouseButton1Click:Connect(function()
		
		if self.TargetObject then
			if self.Property ~= "Transparency" then
				if self.TargetObject:IsA("ParticleEmitter") 
				or self.TargetObject:IsA("Beam")
					or self.TargetObject:IsA("Trail")
					then
						self.Property = "Transparency"
					self:CurveChanged()
				end
			else
				self.Property = nil
				self:CurveChanged()
			end
		end
		
	end)
	
	self.UI.Property._Squash.MouseButton1Click:Connect(function()
		
		if self.TargetObject then
			if self.Property ~= "Squash" then
				if self.TargetObject:IsA("ParticleEmitter") then
					self.Property = "Squash"
					self:CurveChanged()
				end
			else
				self.Property = nil
				self:CurveChanged()
			end
		end

	end)
	
	self.UI.Property._WidthScale.MouseButton1Click:Connect(function()
		if self.TargetObject then
			if self.Property ~= "WidthScale" then
				if self.TargetObject:IsA("Trail") then
					self.Property = "WidthScale"
					self:CurveChanged()
				end
			else
				self.Property = nil
				self:CurveChanged()
			end
		end
	end)
	colorize(self.UI)
end

function curveEditor:Lock()
	
end

function curveEditor:SetActive(activeObject)
	self.TargetObject = activeObject
	self.Property = nil
	self:CurveChanged()
	if self.TargetObject:IsA("ParticleEmitter") then
		self.UI.Property._Size.Visible = true
		self.UI.Property._Squash.Visible = true
		self.UI.Property._WidthScale.Visible = false
	elseif self.TargetObject:IsA("Beam") then
		self.UI.Property._Size.Visible = false
		self.UI.Property._Squash.Visible = false
		self.UI.Property._WidthScale.Visible = false
	elseif self.TargetObject:IsA("Trail") then
		self.UI.Property._Size.Visible = false
		self.UI.Property._Squash.Visible = false
		self.UI.Property._WidthScale.Visible = true
	end
end

return curveEditor