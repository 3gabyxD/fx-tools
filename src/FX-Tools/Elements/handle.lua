
local SetWaypoint = script.Parent.Parent.SetWaypoint
local UserInputService = game:GetService("UserInputService")

local Theme = require(script.Parent.Parent.Theme)
local Instantiate = require(script.Parent.Parent.Utility.Instantiate)
local map = require(script.Parent.Parent.Utility.map)

local handle = {}
function handle.new(parent, pos, lock, clamp, hide, callback, onclick)
	local self = setmetatable({
		Parent = parent,
		Anchor = pos,
		Handle0 = pos - Vector2.new(0.25, 0),
		Handle1 = pos + Vector2.new(0.25, 0),
		Lock = lock,
		Clamp = clamp,
		Align = true,
		Hide = hide,
		Callback = callback,
		OnClick = onclick,
		Instance = Instantiate("ImageButton", {
			Parent = parent,
			BackgroundColor3 = Theme:Get("main"),
			Position = UDim2.fromScale(pos.X, map(0, 1, 1, 0, pos.Y)),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(10, 10),
			AnchorPoint = Vector2.new(.5, .5)
		}, {
			Instantiate("UICorner", {
				CornerRadius = UDim.new(1, 0)
			})
		})
	}, {__index = handle})

	self.Handle0Inst = Instantiate("ImageButton", {
		Parent = self.Parent,
		Visible = self.Hide[1] == 0 and true or false,
		BackgroundColor3 = Theme:Get("main"),
		Position = UDim2.fromScale(self.Handle0.X, map(0, 1, 1, 0, self.Handle0.Y)),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(7, 7),
		AnchorPoint = Vector2.new(.5, .5)
	}, {
		Instantiate("UICorner", {
			CornerRadius = UDim.new(1, 0)
		})
	})

	self.Handle1Inst = Instantiate("ImageButton", {
		Parent = self.Parent,
		Visible = self.Hide[2] == 0 and true or false,
		BackgroundColor3 = Theme:Get("main"),
		Position = UDim2.fromScale(self.Handle1.X, map(0, 1, 1, 0, self.Handle1.Y)),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(7, 7),
		AnchorPoint = Vector2.new(.5, .5)
	}, {
		Instantiate("UICorner", {
			CornerRadius = UDim.new(1, 0)
		})
	})

	self.Handle0Line = Instantiate("Frame", {
		Parent = self.Parent,
		Name = "Line",
		Visible = self.Hide[1] == 0 and true or false,
		BackgroundColor3 = Theme:Get("highlight"),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.fromScale(
			(self.Anchor.X + self.Handle0.X) / 2,
			map(0, 1, 1, 0, (self.Anchor.Y + self.Handle0.Y) / 2)
		),
		Rotation = math.deg(math.atan2(
			self.Handle0.Y - self.Anchor.Y,
			self.Handle0.X - self.Anchor.X
			)),
		Size = UDim2.new((self.Anchor - self.Handle0).Magnitude, 0, 0, 1),
		ZIndex = -1,
	})

	self.Handle1Line = Instantiate("Frame", {
		Parent = self.Parent,
		Name = "Line",
		Visible = self.Hide[2] == 0 and true or false,
		BackgroundColor3 = Theme:Get("highlight"),
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.fromScale(
			(self.Anchor.X + self.Handle1.X) / 2,
			map(0, 1, 1, 0, (self.Anchor.Y + self.Handle1.Y) / 2)
		),
		Rotation = math.deg(math.atan2(
			self.Handle1.Y - self.Anchor.Y,
			self.Handle1.X - self.Anchor.X
			)),
		Size = UDim2.new((self.Anchor - self.Handle1).Magnitude, 0, 0, 1),
		ZIndex = -1,
	})

	self.Instance.MouseButton1Down:Connect(function()
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			task.wait()

			--> Get Offset from display and mouse
			local offset = 
				UserInputService:GetMouseLocation()
			- self.Parent.AbsolutePosition

			local old = self.Anchor

			-- Reposition anchor point
			local anchor = Vector2.new(
				offset.X/180, map(1, 0, 0, 1, offset.Y/180)
			)
			local anchor = Vector2.new(
				self.Clamp[1] == 0 and anchor.X or math.clamp(anchor.X, 0, 1),
				self.Clamp[2] == 0 and anchor.Y or math.clamp(anchor.Y, 0, 1)
			)
			self.Anchor = Vector2.new(
				self.Lock[1] == 0 and anchor.X or self.Anchor.X,
				self.Lock[2] == 0 and anchor.Y or self.Anchor.Y
			)

			-- Move along handles
			local delta = self.Anchor - old
			self.Handle0 += delta
			self.Handle1 += delta

			self:Redraw()

			--TODO: callback
			if self.Callback then
				self.Callback(false)
			end
		end

		if self.Callback then
			self.Callback(true)
		end
		
	end)

	self.Instance.MouseButton1Click:Connect(function()
		local old = self.Anchor

		local anchor = self.OnClick(self.Anchor)
		if not anchor then return end
		local anchor = Vector2.new(
			self.Clamp[1] == 0 and anchor.X or math.clamp(anchor.X, 0, 1),
			self.Clamp[2] == 0 and anchor.Y or math.clamp(anchor.Y, 0, 1)
		)
		self.Anchor = Vector2.new(
			self.Lock[1] == 0 and anchor.X or self.Anchor.X,
			self.Lock[2] == 0 and anchor.Y or self.Anchor.Y
		)

		local delta = self.Anchor - old
		self.Handle0 += delta
		self.Handle1 += delta

		self:Redraw()
		if self.Callback then
			self.Callback(true)
		end
	end)

	self.Handle0Inst.MouseButton1Down:Connect(function()
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			task.wait()
			local offset = 
				UserInputService:GetMouseLocation()
			- self.Parent.AbsolutePosition
			self.Handle0 = Vector2.new(
				math.min(offset.X/180, self.Anchor.X - 0.01), map(1, 0, 0, 1, offset.Y/180)
			)

			if self.Align then
				local rot = math.atan2(
					self.Anchor.Y - self.Handle0.Y,
					self.Anchor.X - self.Handle0.X
				)

				local dist1 = (self.Handle1 - self.Anchor).Magnitude

				self.Handle1 = self.Anchor + Vector2.new(
					math.cos(rot), math.sin(rot)
				) * dist1
			end

			self:Redraw()

			--TODO: callback
			if self.Callback then
				self.Callback(false)
			end
		end

		if self.Callback then
			self.Callback(true)
		end
	end)

	self.Handle0Inst.MouseButton1Click:Connect(function()
		local vector = self.OnClick(self.Handle0)
		if not vector then return end
		self.Handle0 = Vector2.new(
			math.min(vector.X, self.Anchor.X - 0.01), vector.Y
		)
		
		if self.Align then
			local rot = math.atan2(
				self.Anchor.Y - self.Handle0.Y,
				self.Anchor.X - self.Handle0.X
			)

			local dist1 = (self.Handle1 - self.Anchor).Magnitude
			
			self.Handle1 = self.Anchor + Vector2.new(
				math.cos(rot), math.sin(rot)
			) * dist1
		end

		self:Redraw()
		
		if self.Callback then
			self.Callback(true)
		end
	end)

	self.Handle1Inst.MouseButton1Down:Connect(function()
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			task.wait()
			local offset = 
				UserInputService:GetMouseLocation()
			- self.Parent.AbsolutePosition
			self.Handle1 = Vector2.new(
				math.max(offset.X/180, self.Anchor.X + 0.01), map(1, 0, 0, 1, offset.Y/180)
			)

			if self.Align then
				local rot = math.atan2(
					self.Anchor.Y - self.Handle1.Y,
					self.Anchor.X - self.Handle1.X
				)

				local dist0 = (self.Handle0 - self.Anchor).Magnitude
				self.Handle0 = self.Anchor + Vector2.new(
					math.cos(rot), math.sin(rot)
				) * dist0
			end

			self:Redraw()

			--TODO: callback
			if self.Callback then
				self.Callback(false)
			end
		end

		if self.Callback then
			self.Callback(true)
		end
	end)

	self.Handle1Inst.MouseButton1Click:Connect(function()
		local vector = self.OnClick(self.Handle1)
		if not vector then return end
		self.Handle1 = Vector2.new(
			math.max(vector.X, self.Anchor.X + 0.01), vector.Y
		)
		
		if self.Align then
			local rot = math.atan2(
				self.Anchor.Y - self.Handle1.Y,
				self.Anchor.X - self.Handle1.X
			)
			
			local dist0 = (self.Handle0 - self.Anchor).Magnitude

			self.Handle0 = self.Anchor + Vector2.new(
				math.cos(rot), math.sin(rot)
			) * dist0
		end
		
		self:Redraw()
		
		if self.Callback then
			self.Callback(true)
		end
	end)

	return self
end

function handle:Redraw()

	--> Points
	self.Instance.Position = UDim2.fromScale(
		self.Anchor.X, map(0, 1, 1, 0, self.Anchor.Y)
	)

	self.Handle0Inst.Position = UDim2.fromScale(
		self.Handle0.X, map(0, 1, 1, 0, self.Handle0.Y)
	)

	self.Handle1Inst.Position = UDim2.fromScale(
		self.Handle1.X, map(0, 1, 1, 0, self.Handle1.Y)
	)

	--> Lines
	self.Handle0Line.Position = UDim2.fromScale(
		(self.Anchor.X + self.Handle0.X) / 2,
		map(0, 1, 1, 0, (self.Anchor.Y + self.Handle0.Y) / 2)
	)
	self.Handle0Line.Rotation = -math.deg(math.atan2(
		self.Handle0.Y - self.Anchor.Y,
		self.Handle0.X - self.Anchor.X
		))

	self.Handle0Line.Size = UDim2.new((self.Anchor - self.Handle0).Magnitude, 0, 0, 1)

	self.Handle1Line.Position = UDim2.fromScale(
		(self.Anchor.X + self.Handle1.X) / 2,
		map(0, 1, 1, 0, (self.Anchor.Y + self.Handle1.Y) / 2)
	)
	self.Handle1Line.Rotation = -math.deg(math.atan2(
		self.Handle1.Y - self.Anchor.Y,
		self.Handle1.X - self.Anchor.X
		))

	self.Handle1Line.Size = UDim2.new((self.Anchor - self.Handle1).Magnitude, 0, 0, 1)

end

function handle:Destroy()
	
	self.Instance:Destroy()
	
	self.Handle0Inst:Destroy()
	self.Handle1Inst:Destroy()
	
	self.Handle0Line:Destroy()
	self.Handle1Line:Destroy()
end

function handle:Get()
	return {self.Handle0, self.Anchor, self.Handle1}
end

return handle