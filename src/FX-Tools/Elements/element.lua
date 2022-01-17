local element = {}
function element.new(name, icon, window)
	local self = setmetatable({
		Name = name,
		Icon = icon,
		Window = window
	}, {__index = element})
	return self
end

return element