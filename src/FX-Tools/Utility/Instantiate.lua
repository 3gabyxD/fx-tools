function Instantiate(class, properties, children)
	local res = Instance.new(class)
	for key, val in pairs(properties) do
		if key == "Parent" then
			continue
		end
		res[key] = val
	end
	if properties.Parent then
		if typeof(properties.Parent) == "Instance" then
			res.Parent = properties.Parent
		elseif type(properties.Parent) == "table" then
			if properties.Parent.Instance then
				res.Parent = properties.Parent.Instance
			end
		end
	end
	if children then for _, child in pairs(children) do
			if typeof(child) == "Instance" then
				child.Parent = res
			elseif type(child) == "table" then
				if child.Instance then
					child.Instance.Parent = res
				end
			end
		end end
	return res
end

return Instantiate