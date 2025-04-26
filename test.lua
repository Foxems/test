--[[ Service Variables ]]--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--[[ GUI Configuration ]]--
local guiVisible = true
local toggleKeybind = Enum.KeyCode.RightControl -- Keybind to toggle GUI
local accentColor = Color3.fromRGB(88, 101, 242) -- A Discord-like blurple for accents
local baseColor = Color3.fromRGB(44, 47, 51)     -- Dark background
local lighterBaseColor = Color3.fromRGB(54, 57, 63) -- Slightly lighter background
local lightestBaseColor = Color3.fromRGB(70, 74, 80) -- Even lighter for hover/active
local textColor = Color3.fromRGB(220, 221, 222)   -- Primary text color
local mutedTextColor = Color3.fromRGB(185, 187, 190) -- Secondary text color
local iconColor = Color3.fromRGB(185, 187, 190)   -- Default icon color
local iconActiveColor = Color3.fromRGB(255, 255, 255) -- Active icon color

--[[ Main GUI Creation ]]--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObsidianStyleGuiV2"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Enabled = guiVisible

-- Main Draggable Frame (Slightly larger, different color)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = baseColor
mainFrame.BorderSizePixel = 0 -- No border, use shadows/layers
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Selectable = true
mainFrame.ClipsDescendants = true -- Important for rounded corners
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 8)
mainFrameCorner.Parent = mainFrame

-- Left Sidebar for Tab Icons (Darker)
local tabSidebar = Instance.new("Frame")
tabSidebar.Name = "TabSidebar"
tabSidebar.Size = UDim2.new(0, 70, 1, 0) -- Slightly wider for icons
tabSidebar.BackgroundColor3 = Color3.fromRGB(32, 34, 37) -- Darker sidebar
tabSidebar.BorderSizePixel = 0
tabSidebar.Parent = mainFrame

-- Right Content Area Frame
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -70, 1, 0) -- Fill remaining space
contentArea.Position = UDim2.new(0, 70, 0, 0)
contentArea.BackgroundColor3 = baseColor -- Match main background
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame

-- Tab Management
local tabs = {}
local tabButtons = {}
local currentTab = nil
local activeIndicator = Instance.new("Frame") -- Visual indicator for active tab

-- Active Tab Indicator Setup
activeIndicator.Name = "ActiveIndicator"
activeIndicator.Size = UDim2.new(0, 4, 0, 40) -- Thin bar on the left
activeIndicator.BackgroundColor3 = iconActiveColor -- White or accent color
activeIndicator.BorderSizePixel = 0
activeIndicator.Position = UDim2.new(0, -10, 0, 0) -- Initially hidden off-screen
activeIndicator.Visible = false
activeIndicator.Parent = tabSidebar
local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 4)
indicatorCorner.Parent = activeIndicator

local function switchTab(tabName)
	if currentTab == tabName then return end

	local targetButton = tabButtons[tabName]
	if not targetButton then return end

	for name, frame in pairs(tabs) do
		frame.Visible = (name == tabName)
	end

	for name, button in pairs(tabButtons) do
		button.ImageColor3 = iconColor -- Reset all icons to default color
		button.BackgroundColor3 = Color3.fromRGB(32, 34, 37) -- Reset background
	end

	targetButton.ImageColor3 = iconActiveColor -- Highlight active icon
	targetButton.BackgroundColor3 = lightestBaseColor -- Highlight background slightly

	-- Animate the active indicator
	local targetY = targetButton.AbsolutePosition.Y - tabSidebar.AbsolutePosition.Y + (targetButton.AbsoluteSize.Y / 2) - (activeIndicator.AbsoluteSize.Y / 2)
	local targetPosition = UDim2.new(0, 5, 0, targetY) -- Position slightly inset

	activeIndicator.Visible = true
	TweenService:Create(activeIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = targetPosition }):Play()

	currentTab = tabName
end

-- Function to create a standard tab button (Icon)
local function createTabButton(name, iconId, order)
	local button = Instance.new("ImageButton")
	button.Name = name .. "Button"
	button.Size = UDim2.new(1, -20, 0, 50) -- Size for icon area
	button.Position = UDim2.new(0.5, -((button.Size.X.Offset)/2), 0, 15 + (order * 60)) -- Centered with spacing
	button.BackgroundColor3 = Color3.fromRGB(32, 34, 37) -- Match sidebar
	button.BorderSizePixel = 0
	button.Image = iconId
	button.ImageColor3 = iconColor
	button.ScaleType = Enum.ScaleType.Fit
	button.BackgroundTransparency = 0 -- Start opaque
	button.Parent = tabSidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		switchTab(name)
	end)

	-- Hover Effects
	button.MouseEnter:Connect(function()
		if currentTab ~= name then
			TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = lighterBaseColor }):Play()
			TweenService:Create(button.ImageColor3, TweenInfo.new(0.15), {Value = iconActiveColor}):Play() -- Doesnt work directly, need proxy
            button.ImageColor3 = iconActiveColor -- Simple change for now
		end
	end)
	button.MouseLeave:Connect(function()
		if currentTab ~= name then
			TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(32, 34, 37) }):Play()
            button.ImageColor3 = iconColor -- Simple change for now
		end
	end)

	tabButtons[name] = button
	return button
end

-- Function to create a standard content frame
local function createContentFrame(name)
	local frame = Instance.new("Frame")
	frame.Name = name .. "Frame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = contentArea

	-- Add padding using UI Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 15)
	padding.PaddingBottom = UDim.new(0, 15)
	padding.PaddingLeft = UDim.new(0, 15)
	padding.PaddingRight = UDim.new(0, 15)
	padding.Parent = frame

	tabs[name] = frame
	return frame
end

--[[ Home Tab ]]--
local homeTabName = "Home"
-- IMPORTANT: Replace with a real Home icon Asset ID
createTabButton(homeTabName, "rbxassetid://YOUR_HOME_ICON_ID", 0) -- Order 0 (Top)
local homeFrame = createContentFrame(homeTabName)

-- Home Content Example
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Name = "WelcomeLabel"
welcomeLabel.Size = UDim2.new(1, -30, 0, 50) -- Use padding offset
welcomeLabel.Position = UDim2.new(0, 15, 0, 15) -- Use padding offset
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Font = Enum.Font.SourceSansSemibold
welcomeLabel.TextColor3 = textColor
welcomeLabel.TextSize = 24
welcomeLabel.Text = "Welcome!"
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.TextYAlignment = Enum.TextYAlignment.Top
welcomeLabel.Parent = homeFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, -30, 0, 100)
infoLabel.Position = UDim2.new(0, 15, 0, 70) -- Below welcome
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.SourceSans
infoLabel.TextColor3 = mutedTextColor
infoLabel.TextSize = 16
infoLabel.Text = "Select a category from the left sidebar to get started."
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = homeFrame


--[[ Settings Tab ]]--
local settingsTabName = "Settings"
-- IMPORTANT: Replace with a real Gear icon Asset ID
createTabButton(settingsTabName, "rbxassetid://YOUR_GEAR_ICON_ID", 1) -- Order 1 (Below Home)
local settingsFrame = createContentFrame(settingsTabName)

-- Settings: Title Label
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Name = "SettingsTitle"
settingsTitle.Size = UDim2.new(1, -30, 0, 30)
settingsTitle.Position = UDim2.new(0, 15, 0, 15)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Font = Enum.Font.SourceSansBold
settingsTitle.TextColor3 = textColor
settingsTitle.TextSize = 20
settingsTitle.Text = "Settings"
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsFrame

-- Settings: Keybind Label (Improved Styling)
local keybindLabel = Instance.new("TextLabel")
keybindLabel.Name = "KeybindLabel"
keybindLabel.Size = UDim2.new(1, -30, 0, 30)
keybindLabel.Position = UDim2.new(0, 15, 0, 55) -- Position below title
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = Enum.Font.SourceSans
keybindLabel.TextColor3 = mutedTextColor
keybindLabel.TextSize = 16
keybindLabel.Text = "Zobrazit/Skrýt GUI: " .. toggleKeybind.Name
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = settingsFrame

-- Settings: Unload Button (Improved Styling)
local unloadButton = Instance.new("TextButton")
unloadButton.Name = "UnloadButton"
unloadButton.Size = UDim2.new(0, 160, 0, 40) -- Slightly larger
unloadButton.Position = UDim2.new(0, 15, 0, 95) -- Position below keybind label
unloadButton.BackgroundColor3 = Color3.fromRGB(219, 68, 55) -- Google-like Red
unloadButton.BorderSizePixel = 0 -- No border
unloadButton.Font = Enum.Font.SourceSansSemibold
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.TextSize = 16
unloadButton.Text = "Unload Script"
unloadButton.Parent = settingsFrame

local unloadButtonCorner = Instance.new("UICorner")
unloadButtonCorner.CornerRadius = UDim.new(0, 5)
unloadButtonCorner.Parent = unloadButton

-- Unload Button Hover Effect
unloadButton.MouseEnter:Connect(function()
	TweenService:Create(unloadButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(190, 50, 40) }):Play() -- Darken on hover
end)
unloadButton.MouseLeave:Connect(function()
	TweenService:Create(unloadButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(219, 68, 55) }):Play() -- Return to original
end)


--[[ Event Connections ]]--

-- Unload Button Action
unloadButton.MouseButton1Click:Connect(function()
	print("Unloading GUI...")
	screenGui:Destroy()
	-- Add any other cleanup logic needed for your script here
end)

-- GUI Toggle Keybind Listener
local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end

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

-- Switch to the default tab (Home)
switchTab(homeTabName)

print("Obsidian-Style GUI V2 Loaded")
print("Press " .. toggleKeybind.Name .. " to toggle GUI visibility.")
