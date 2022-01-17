local config = {}
function config.new(old)
	local self = setmetatable({
		CurveLiveUpdate = false,
		CurveLiveDraw = true,
		
		AlwaysActive = false,
	}, {__index = config})
	if old then
		for i, v in pairs(old) do
			self[i] = v
		end
	end
	return self
end

function config:Get(key)
	return self[key]
end

function config:Set(key, val)
	self[key] = val
	script.Parent.ExportConfig:Fire(self:Export())
end

function config:Export()
	return self
end

return config