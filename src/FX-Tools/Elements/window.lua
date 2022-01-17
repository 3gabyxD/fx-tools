
local Theme = require(script.Parent.Parent.Theme)
local Instantiate = require(script.Parent.Parent.Utility.Instantiate)

local windows = {}

local window = {}
function window.new(parent, anchor, size, elements)
	local self = setmetatable({
		Parent = parent,
		Anchor = anchor,
		Size = size,
		Elements = elements,
		Active = false,
		Instance = Instantiate("Frame", {
			Parent = parent,
			Visible = false,
			AnchorPoint = anchor,
			Size = size,
			BackgroundColor3 = Theme:Get("background"),
			ZIndex = 50,
			-- ClipsDescendants = true,
		}, {
			Instantiate("UICorner", {
				CornerRadius = UDim.new(0, Theme:Get("corner"))
			}), Instantiate("UIStroke", {
				Color = Theme:Get("border"),
				Thickness = Theme:Get("bordersize"),
			}), (elements and unpack(elements))
		})
	}, {__index = window})
	windows[#windows + 1] = self
	return self
end

function window.closeAll(ignore)
	for _, window in pairs(windows) do
		if window ~= ignore then
			window:hide()
		end
	end
end

function window:reveal(pos)
	if self.Instance.Visible ~= true then
		self.Instance.Position = pos
		self.Instance.Visible = true
		self.Active = true
	end
end

function window:hide()
	if self.Instance.Visible ~= false then
		self.Instance.Visible = false
		self.Active = false
	end
end

return window