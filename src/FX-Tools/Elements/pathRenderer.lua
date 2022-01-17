

local Theme = require(script.Parent.Parent.Theme)

local Instantiate = require(script.Parent.Parent.Utility.Instantiate)
local map = require(script.Parent.Parent.Utility.map)
local ease = require(script.Parent.Parent.Utility.ease)


--TODO: Dont make this destroy each time it
-- redraws

local pathRenderer = {}
function pathRenderer.new(parent, handles)
	local self = setmetatable({
		Parent = parent,
		Handles = handles,
		Frames = {},
		Steps = 20,
	}, {__index = pathRenderer})

	self:Draw()

	return self
end

function pathRenderer:Draw()

	for _, frame in pairs(self.Frames) do
		frame:Destroy()
	end

	for i = 1, #self.Handles - 1 do
		local a0 = self.Handles[i]:Get()
		local a1 = self.Handles[i+1]:Get()

		local p0 = a0[2] -- Left Center
		local p1 = a0[3] -- Left Handle
		local p2 = a1[1] -- Right Handle
		local p3 = a1[2] -- Right Center

		local xDist = p3.X - p0.X
		local yDist = p3.Y - p0.Y

		-- Map points from 0 -> 1

		-- Map bezier output from 0 -> 1 to
		-- p0.Y -> p3.Y

		local bezier = ease.cubicbezier(
			math.clamp(map(p0.X, p3.X, 0, 1, p1.X), 0, 1),
			map(p0.Y, p3.Y, 0, 1, p1.Y),
			math.clamp(map(p0.X, p3.X, 0, 1, p2.X), 0, 1),
			map(p0.Y, p3.Y, 0, 1, p2.Y)
		)

		local steps = 20
		for i = 0, steps-1 do

			local t0 = i/steps
			local t1 = (i+1)/steps

			local x0 = map(0, 1, p0.X, p3.X, t0)
			local x1 = map(0, 1, p0.X, p3.X, t1)

			local y0 = map(0, 1, p0.Y, p3.Y, bezier(t0))
			local y1 = map(0, 1, p0.Y, p3.Y, bezier(t1))

			local dist = Vector2.new(x1, y1) - Vector2.new(x0, y0)

			self.Frames[#self.Frames+1] =
				Instantiate("Frame", {
					Parent = self.Parent,
					AnchorPoint = Vector2.new(.5, .5),
					BackgroundColor3 = Theme:Get("highlight"),
					BorderSizePixel = 0,

					Size = UDim2.new(dist.Magnitude+.01, 0, 0, 2),
					Position = UDim2.fromScale(
						(x0 + x1) / 2,
						map(0, 1, 1, 0, (y0 + y1) / 2)
					),
					Rotation = -math.deg(math.atan2(
						dist.Y,
						dist.X
						))
				})

		end
	end
end

function pathRenderer:Render(min, max, envelope)
	
	local seq = {}
	
	for i = 1, #self.Handles - 1 do
		local a0 = self.Handles[i]:Get()
		local a1 = self.Handles[i+1]:Get()

		local p0 = a0[2] -- Left Center
		local p1 = a0[3] -- Left Handle
		local p2 = a1[1] -- Right Handle
		local p3 = a1[2] -- Right Center

		local xDist = p3.X - p0.X
		local yDist = p3.Y - p0.Y

		-- Map points from 0 -> 1

		-- Map bezier output from 0 -> 1 to
		-- p0.Y -> p3.Y

		local bezier = ease.cubicbezier(
			math.clamp(map(p0.X, p3.X, 0, 1, p1.X), 0, 1),
			map(p0.Y, p3.Y, 0, 1, p1.Y),
			math.clamp(map(p0.X, p3.X, 0, 1, p2.X), 0, 1),
			map(p0.Y, p3.Y, 0, 1, p2.Y)
		)
		
		seq[#seq + 1] = NumberSequenceKeypoint.new(
			p0.X, map(0, 1, min, max, p0.Y), 0
		)
		
		local steps = self.Steps / #self.Handles
		for i = 1, steps-1 do
			local t0 = i/steps

			local x = map(0, 1, p0.X, p3.X, t0)
			local y = map(0, 1, p0.Y, p3.Y, bezier(t0))
			
			seq[#seq + 1] = NumberSequenceKeypoint.new(
				x, map(0, 1, min, max, y), envelope
			)
		end
		
		seq[#seq + 1] = NumberSequenceKeypoint.new(
			p3.X, map(0, 1, min, max, p3.Y), envelope
		)
	end
	
	return NumberSequence.new(seq)
end

return pathRenderer