--|| Services ||--
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")
local History = game:GetService("ChangeHistoryService")

--|| Plugin ||--
local toolbar = plugin:CreateToolbar("FX-Tools")
local toggleButton = toolbar:CreateButton(
	"Toggle", "Toggle Workspace", ""
)

--|| Utility ||--
local Utility = script.Parent.Utility
local Instantiate = require(Utility.Instantiate)
local map = require(Utility.map)
local ease = require(Utility.ease)

--|| Variables ||--
local hidden = false -- hidden on toolbar
local active = false -- no particle or beam selected
local activeObject = nil

local fxClasses = {
	"ParticleEmitter",
	"Beam",
	"Trail"
}

--|| Themes ||--
local Theme = require(script.Parent.Theme)
local ConfigTemplate = require(script.Parent.Config)

local config = plugin:GetSetting("Config")
config = ConfigTemplate.new(config)

--|| Templates ||--
local dropdown = require(script.Parent.Elements.dropdown)
local element = require(script.Parent.Elements.element)
local window = require(script.Parent.Elements.window)
local handle = require(script.Parent.Elements.handle)
local pathRenderer = require(script.Parent.Elements.pathRenderer)

--|| Windows ||--
local curveEditor = require(script.Parent.CurveEditor)
local clipboard = require(script.Parent.Clipboard)
local preferences = require(script.Parent.Preferences)

--|| Elements ||--
if CoreGui:FindFirstChild("FXToolsMain") then
	CoreGui:FindFirstChild("FXToolsMain"):Destroy()
end

local mainScreen = Instantiate("ScreenGui", {
	Parent = CoreGui,
	Name = "FXToolsMain",
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local _curveEditor = curveEditor.new(mainScreen, config)
local _clipboard = clipboard.new(mainScreen, config)
local _preferences = preferences.new(mainScreen, config)

local mainDropdown = dropdown.new(
	mainScreen,
	UDim2.new(1, -5, 0, 5),
	Vector2.new(1, 0),
	UDim2.fromOffset(50, 50),
	{
		element.new(
			"Curve",
			"rbxassetid://8495897332",
			_curveEditor.Window
		),
		element.new(
			"Clipboard",
			"rbxassetid://8502840060",
			_clipboard.Window
		),
		
		element.new(
			"Preferences",
			"rbxassetid://5344465760",
			_preferences.Window
		)
	}
)

 --- mainDropdown:reveal()

--|| Functions ||--

-- UI
function reveal()
	mainDropdown:reveal()
end

function hide()
	_curveEditor.Window:hide()
	mainDropdown:hide()
end

-- Logic
function isFxInst(inst)
	for _, class in pairs(fxClasses) do
		if inst:IsA(class) then
			return true
		end
	end
end

function onToggle()
	hidden = not hidden
	if hidden then
		hide()
	else
		reveal()
	end
	task.wait(.2)
	toggleButton:SetActive(false)
end

function onSelection()
	local sels = Selection:Get()
	local sel = sels[#sels]
	if sel and isFxInst(sel) then
		activeObject = sel
		
		_curveEditor:SetActive(activeObject)
		_clipboard:SetActive(activeObject)
		
		reveal()
		return
	end
	if not config:Get("AlwaysActive") then
		hide()
	end
end

local function onSetWaypoint(str)
	History:SetWaypoint(str)
end

local function onExportConfig(conf)
	plugin:SetSetting("Config", conf)
end

--|| Events ||--

script.Parent.SetWaypoint.Event:Connect(onSetWaypoint)
script.Parent.ExportConfig.Event:Connect(onExportConfig)
toggleButton.Click:Connect(onToggle)
Selection.SelectionChanged:Connect(onSelection)

if config:Get("AlwaysActive") then
	reveal()
end