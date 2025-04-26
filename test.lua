--[[ Service Variables ]]--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") -- Needed for keybind later

--[[ GUI Configuration ]]--
local guiVisible = true
local toggleKeybind = Enum.KeyCode.RightControl -- Example keybind (Right Ctrl)

--[[ Main GUI Creation ]]--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObsidianStyleGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = guiVisible

-- Main Draggable Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 550, 0, 350) -- Increased size for tabs
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -175) -- Center the frame
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
mainFrame.BorderSizePixel = 1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Selectable = true
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 8)
mainFrameCorner.Parent = mainFrame

-- Left Sidebar for Tabs
local tabSidebar = Instance.new("Frame")
tabSidebar.Name = "TabSidebar"
tabSidebar.Size = UDim2.new(0, 60, 1, 0) -- Width 60, full height
tabSidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Slightly lighter bg
tabSidebar.BorderSizePixel = 0
tabSidebar.Parent = mainFrame

local tabSidebarCorner = Instance.new("UICorner") -- Round only top-left and bottom-left
tabSidebarCorner.CornerRadius = UDim.new(0, 8)
tabSidebarCorner.Parent = tabSidebar

-- Right Content Area Frame
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -60, 1, 0) -- Fill remaining space
contentArea.Position = UDim2.new(0, 60, 0, 0) -- Position next to sidebar
contentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Match main background
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true -- Hide overflowing content
contentArea.Parent = mainFrame

local contentAreaCorner = Instance.new("UICorner") -- Round only top-right and bottom-right
contentAreaCorner.CornerRadius = UDim.new(0, 8)
contentAreaCorner.Parent = contentArea

-- Tab Management
local tabs = {}
local tabButtons = {}
local currentTab = nil

local function switchTab(tabName)
	if currentTab == tabName then return end -- Don't switch if already on this tab

	for name, frame in pairs(tabs) do
		frame.Visible = (name == tabName)
	end

	for name, button in pairs(tabButtons) do
		-- Adjust visual style for active/inactive tabs (e.g., background color)
		if name == tabName then
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 60) -- Active color
		else
			button.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Inactive color (matches sidebar)
		end
	end
	currentTab = tabName
end

--[[ Settings Tab ]]--
local settingsTabName = "Settings"

-- Settings Tab Button (Using ImageButton for Icon)
local settingsButton = Instance.new("ImageButton")
settingsButton.Name = settingsTabName .. "Button"
settingsButton.Size = UDim2.new(1, 0, 0, 50) -- Full width of sidebar, height 50
settingsButton.Position = UDim2.new(0, 0, 0, 10) -- Position with some padding
settingsButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40) -- Matches sidebar initially
settingsButton.BorderSizePixel = 0
settingsButton.Image = "rbxassetid://6027139094" -- Placeholder Gear Icon ID (FIND A REAL ONE)
settingsButton.ImageColor3 = Color3.fromRGB(180, 180, 185)
settingsButton.ScaleType = Enum.ScaleType.Fit -- Fit the icon within the button
settingsButton.Parent = tabSidebar
tabButtons[settingsTabName] = settingsButton

local settingsButtonCorner = Instance.new("UICorner")
settingsButtonCorner.CornerRadius = UDim.new(0, 6)
settingsButtonCorner.Parent = settingsButton

-- Settings Content Frame
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = settingsTabName .. "Frame"
settingsFrame.Size = UDim2.new(1, 0, 1, 0) -- Fill content area
settingsFrame.BackgroundTransparency = 1 -- Transparent background
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false -- Initially hidden
settingsFrame.Parent = contentArea
tabs[settingsTabName] = settingsFrame

-- Settings: Keybind Label
local keybindLabel = Instance.new("TextLabel")
keybindLabel.Name = "KeybindLabel"
keybindLabel.Size = UDim2.new(1, -20, 0, 30)
keybindLabel.Position = UDim2.new(0, 10, 0, 10)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = Enum.Font.SourceSans
keybindLabel.TextColor3 = Color3.fromRGB(210, 210, 215)
keybindLabel.TextSize = 16
keybindLabel.Text = "Zobrazit/Skrýt GUI: " .. toggleKeybind.Name -- Display current keybind
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = settingsFrame

-- Settings: Unload Button
local unloadButton = Instance.new("TextButton")
unloadButton.Name = "UnloadButton"
unloadButton.Size = UDim2.new(0, 150, 0, 35)
unloadButton.Position = UDim2.new(0, 10, 0, 50) -- Position below keybind label
unloadButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40) -- Reddish color for unload/danger
unloadButton.BorderColor3 = Color3.fromRGB(210, 70, 70)
unloadButton.BorderSizePixel = 1
unloadButton.Font = Enum.Font.SourceSansSemibold
unloadButton.TextColor3 = Color3.fromRGB(230, 230, 230)
unloadButton.TextSize = 16
unloadButton.Text = "Unload Script"
unloadButton.Parent = settingsFrame

local unloadButtonCorner = Instance.new("UICorner")
unloadButtonCorner.CornerRadius = UDim.new(0, 5)
unloadButtonCorner.Parent = unloadButton

--[[ Event Connections ]]--

-- Tab Switching
settingsButton.MouseButton1Click:Connect(function()
	switchTab(settingsTabName)
end)

-- Unload Button Action
unloadButton.MouseButton1Click:Connect(function()
	print("Unloading GUI...")
	screenGui:Destroy()
	-- Add any other cleanup logic needed for your script here
end)

-- GUI Toggle Keybind Listener
local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end -- Don't process if chat or other Roblox UI handled it

	if input.KeyCode == toggleKeybind then
		guiVisible = not guiVisible
		screenGui.Enabled = guiVisible
		print("GUI Visibility Toggled:", guiVisible)
	end
end
UserInputService.InputBegan:Connect(onInputBegan)


--[[ Initialization ]]--

-- Set Parent to PlayerGui
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
screenGui.Parent = playerGui

-- Switch to the default tab (Settings)
switchTab(settingsTabName)

print("Obsidian-Style GUI with Settings Tab Loaded")
-- Add a placeholder print for the keybind instruction
print("Press RightControl to toggle GUI visibility.") -- Inform user about the default key
