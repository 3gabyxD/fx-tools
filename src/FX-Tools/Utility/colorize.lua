local Theme = require(script.Parent.Parent.Theme)

--|| Services ||--
local TweenService = game:GetService("TweenService")

return function(UI)
	for _, frame in pairs(UI) do
		for _, text: TextButton in pairs(frame:GetDescendants()) do
			if (text:IsA("TextBox")
			or text:IsA("TextButton")
			or text:IsA("TextLabel"))
			and text.Name ~= "Title"
			 then
				text.MouseEnter:Connect(function()
					TweenService:Create(
						text,
						TweenInfo.new(Theme:Get("transition")),
						{TextColor3 = Theme:Get("active")}
					):Play()
				end)
				text.MouseLeave:Connect(function()
					TweenService:Create(
						text,
						TweenInfo.new(Theme:Get("transition")),
						{TextColor3 = Theme:Get("main")}
					):Play()
				end)
				if text:IsA("TextButton") then
					text.MouseButton1Down:Connect(function()
						TweenService:Create(
							text,
							TweenInfo.new(Theme:Get("transition")*.5),
							{TextColor3 = Theme:Get("down")}
						):Play()
					end)
					text.MouseButton1Up:Connect(function()
						TweenService:Create(
							text,
							TweenInfo.new(Theme:Get("transition")),
							{TextColor3 = Theme:Get("main")}
						):Play()
					end)
				end
			end
		end
	end
end