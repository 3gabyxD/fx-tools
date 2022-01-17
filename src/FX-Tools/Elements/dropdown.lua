
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Parent.Theme)
local Instantiate = require(script.Parent.Parent.Utility.Instantiate)

local window = require(script.Parent.window)

local dropdown = {}
function dropdown.new(parent, pos, anchor, size, elements)
	local self = setmetatable({
		Parent = parent,
		Pos = pos,
		Anchor = anchor,
		Size = size,
		Elements = elements,
		Active = false,
		Instance = Instantiate("Frame", {
			Parent = parent,
			Visible = false,
			Position = pos,
			AnchorPoint = anchor,
			Size = size,
			BackgroundColor3 = Theme:Get("background"),
			ClipsDescendants = true,
		}, {
			Instantiate("ImageButton", {
				Name = "Button",
				Image = "rbxassetid://7068878280",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Size = size
			}),
			
			Instantiate("UICorner", {
				CornerRadius = UDim.new(0, Theme:Get("corner"))
			}), Instantiate("UIStroke", {
				Color = Theme:Get("border"),
				Thickness = Theme:Get("bordersize"),
			})
		}),
		Text = Instantiate("TextLabel", {
			Parent = parent,
			Name = "Credits!!",
			Position = UDim2.new(1, 0, 1, 10),
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.fromOffset(100, 30),
			BackgroundTransparency = 1,
			Font = Theme:Get("font"),
			TextSize = 15,
			TextColor3 = Theme:Get("main"),
			Text = 'gaby',
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
	}, {__index = dropdown})

	RunService.RenderStepped:Connect(function()
		self.Text.Position = UDim2.fromOffset(
			self.Instance.AbsolutePosition.X
			+ self.Instance.AbsoluteSize.X,
			self.Instance.AbsolutePosition.Y
			+ self.Instance.AbsoluteSize.Y
			+ 5
		)
	end)

	for i, element in pairs(self.Elements) do
		local button = Instantiate("ImageButton", {
			Parent = self.Instance,
			Name = element.Name,
			Position = UDim2.fromOffset(0, self.Size.X.Offset * i),
			Size = self.Size,

			Image = element.Icon,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Instantiate("Frame", {
				Name = "Tooltip",
				Visible = false,
				Size = UDim2.fromOffset(100, 30),
				AnchorPoint = Vector2.new(1, .5),
				Position = UDim2.new(0, -10, 0.5, 0),
				BackgroundColor3 = Theme:Get("background"),
			}, {
				Instantiate("TextLabel", {
					Size = UDim2.new(1, -10, 1, -10),
					Position = UDim2.fromOffset(5, 5),
					Text = element.Name,

					BackgroundTransparency = 1,
					TextSize = 15,
					Font = Theme:Get("font"),
					TextColor3 = Theme:Get("main"),
					TextXAlignment = Enum.TextXAlignment.Center,
				}),

				Instantiate("UICorner", {
					CornerRadius = UDim.new(0, Theme:Get("corner"))
				}), Instantiate("UIStroke", {
					Color = Theme:Get("border"),
					Thickness = Theme:Get("bordersize"),
				})
			})
		})

		local hover = false
		local tipActive = false
		button.MouseLeave:Connect(function()
			hover = false
			if tipActive then
				button.Tooltip.Visible = false
				tipActive = false
			end
		end)
		button.MouseEnter:Connect(function()
			hover = true
			task.delay(1, function()
				if hover then
					if not tipActive then
						button.Tooltip.Visible = true
						tipActive = true
					end
				end
			end)
		end)

		button.MouseButton1Click:Connect(function()
			if element.Window.Active == false then
				local pos = button.AbsolutePosition
				window.closeAll(element.Window)
				element.Window:reveal(UDim2.fromOffset(pos.X - 10, pos.Y))
			else
				element.Window:hide()
			end
		end)
	end

	self.Instance.Button.MouseButton1Click:Connect(function()
		self.Active = not self.Active
		if self.Active then
			local t = TweenService:Create(
				self.Instance,
				TweenInfo.new(Theme:Get("transition")),
				{Size = UDim2.fromOffset(
					self.Size.X.Offset,
					self.Size.Y.Offset * (#self.Elements + 1)
					)}
			)
			t:Play()
			local state = t.Completed:Wait()
			if state == Enum.PlaybackState.Completed then
				self.Instance.ClipsDescendants = false
			end
		else
			local t = TweenService:Create(
				self.Instance,
				TweenInfo.new(Theme:Get("transition")),
				{Size = self.Size}
			)
			t:Play()
			self.Instance.ClipsDescendants = true
			local state = t.Completed:Wait()
			if state == Enum.PlaybackState.Completed then
				
			end
			window.closeAll()
		end
	end)

	return self
end

function dropdown:reveal()
	if self.Instance.Visible ~= true then
		self.Instance.Visible = true
		self.Text.Visible = true
	end
end

function dropdown:hide()
	if self.Instance.Visible ~= false then
		self.Instance.Visible = false
		self.Text.Visible = false
		window.closeAll()
	end
end

return dropdown