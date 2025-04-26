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

-- Main Draggable Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = baseColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Selectable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 8)
mainFrameCorner.Parent = mainFrame

-- Title Bar at the top
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(32, 34, 37) -- Darker than base
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 8)
titleBarCorner.Parent = titleBar

-- Only round the top corners of the title bar
local titleBarFix = Instance.new("Frame")
titleBarFix.Name = "TitleBarFix"
titleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
titleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
titleBarFix.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
titleBarFix.BorderSizePixel = 0
titleBarFix.Parent = titleBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -20, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.SourceSansBold
titleText.TextColor3 = textColor
titleText.TextSize = 18
titleText.Text = "Obsidian Hub | Universal Scripts"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Left Sidebar for Categories
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 180, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40) -- Below title bar
sidebar.BackgroundColor3 = Color3.fromRGB(35, 37, 42) -- Slightly lighter than base
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

-- Content Area Frame
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -180, 1, -40) -- Full size minus sidebar and title
contentArea.Position = UDim2.new(0, 180, 0, 40) -- Right of sidebar, below title
contentArea.BackgroundColor3 = baseColor
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true
contentArea.Parent = mainFrame

-- Tab Management
local tabs = {}
local tabButtons = {}
local currentTab = nil

-- Function to create tab button with icon and text
local function createTabButton(name, displayName, iconId, order)
    local tabButton = Instance.new("Frame")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.Position = UDim2.new(0, 0, 0, 10 + (order * 50))
    tabButton.BackgroundColor3 = lighterBaseColor
    tabButton.BackgroundTransparency = 1 -- Start transparent
    tabButton.BorderSizePixel = 0
    tabButton.Parent = sidebar
    
    local tabButtonCorner = Instance.new("UICorner")
    tabButtonCorner.CornerRadius = UDim.new(0, 6)
    tabButtonCorner.Parent = tabButton
    
    -- Tab Icon
    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Name = "Icon"
    tabIcon.Size = UDim2.new(0, 20, 0, 20)
    tabIcon.Position = UDim2.new(0, 15, 0.5, -10)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Image = iconId
    tabIcon.ImageColor3 = iconColor
    tabIcon.Parent = tabButton
    
    -- Tab Text
    local tabText = Instance.new("TextLabel")
    tabText.Name = "Text"
    tabText.Size = UDim2.new(1, -50, 1, 0)
    tabText.Position = UDim2.new(0, 45, 0, 0)
    tabText.BackgroundTransparency = 1
    tabText.Font = Enum.Font.SourceSansSemibold
    tabText.TextColor3 = mutedTextColor
    tabText.TextSize = 16
    tabText.Text = displayName
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    tabText.Parent = tabButton
    
    -- Indicator for active tab
    local activeIndicator = Instance.new("Frame")
    activeIndicator.Name = "ActiveIndicator"
    activeIndicator.Size = UDim2.new(0, 3, 0, 20)
    activeIndicator.Position = UDim2.new(0, 0, 0.5, -10)
    activeIndicator.BackgroundColor3 = accentColor
    activeIndicator.BorderSizePixel = 0
    activeIndicator.Visible = false
    activeIndicator.Parent = tabButton
    
    -- Click Detection (using TextButton overlay)
    local clickDetector = Instance.new("TextButton")
    clickDetector.Name = "ClickDetector"
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = tabButton
    
    clickDetector.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    -- Hover Effects
    clickDetector.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
            tabText.TextColor3 = textColor
        end
    end)
    
    clickDetector.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            tabText.TextColor3 = mutedTextColor
        end
    end)
    
    tabButtons[name] = {
        frame = tabButton,
        icon = tabIcon,
        text = tabText,
        indicator = activeIndicator
    }
    
    return tabButton
end

-- Function to create content frame for each tab
local function createContentFrame(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name .. "Content"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    frame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    frame.Visible = false
    frame.Parent = contentArea
    
    -- Padding for content
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.PaddingBottom = UDim.new(0, 15)
    padding.PaddingLeft = UDim.new(0, 20)
    padding.PaddingRight = UDim.new(0, 20)
    padding.Parent = frame
    
    -- Auto-size the scrolling content
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 10)
    listLayout.Parent = frame
    
    -- Set canvas size based on content
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 30)
    end)
    
    tabs[name] = frame
    return frame
end

-- Function to switch between tabs
local function switchTab(tabName)
    if currentTab == tabName then return end
    
    for name, tab in pairs(tabs) do
        tab.Visible = (name == tabName)
    end
    
    for name, elements in pairs(tabButtons) do
        if name == tabName then
            elements.frame.BackgroundTransparency = 0
            elements.text.TextColor3 = textColor
            elements.icon.ImageColor3 = iconActiveColor
            elements.indicator.Visible = true
        else
            elements.frame.BackgroundTransparency = 1
            elements.text.TextColor3 = mutedTextColor
            elements.icon.ImageColor3 = iconColor
            elements.indicator.Visible = false
        end
    end
    
    currentTab = tabName
end

--[[ Create Tabs ]]--

-- Home Tab
local homeTabName = "Home"
createTabButton(homeTabName, "Home", "rbxassetid://3926305904", 0) -- Using Roblox's home icon
local homeContent = createContentFrame(homeTabName)

-- Heading for Home
local homeHeading = Instance.new("TextLabel")
homeHeading.Name = "Heading"
homeHeading.Size = UDim2.new(1, 0, 0, 40)
homeHeading.BackgroundTransparency = 1
homeHeading.Font = Enum.Font.SourceSansBold
homeHeading.TextColor3 = textColor
homeHeading.TextSize = 24
homeHeading.Text = "Welcome to Obsidian Hub"
homeHeading.TextXAlignment = Enum.TextXAlignment.Left
homeHeading.LayoutOrder = 1
homeHeading.Parent = homeContent

-- Description
local homeDescription = Instance.new("TextLabel")
homeDescription.Name = "Description"
homeDescription.Size = UDim2.new(1, 0, 0, 120)
homeDescription.BackgroundTransparency = 1
homeDescription.Font = Enum.Font.SourceSans
homeDescription.TextColor3 = mutedTextColor
homeDescription.TextSize = 16
homeDescription.Text = "This is a universal script hub with various tools and functions for Roblox games. Navigate using the sidebar to access different features.\n\nThe hub is designed with a clean, dark interface inspired by modern applications like Discord and Obsidian MD."
homeDescription.TextWrapped = true
homeDescription.TextXAlignment = Enum.TextXAlignment.Left
homeDescription.LayoutOrder = 2
homeDescription.Parent = homeContent

-- Version Info
local versionInfo = Instance.new("TextLabel")
versionInfo.Name = "VersionInfo"
versionInfo.Size = UDim2.new(1, 0, 0, 30)
versionInfo.BackgroundTransparency = 1
versionInfo.Font = Enum.Font.SourceSansSemibold
versionInfo.TextColor3 = accentColor
versionInfo.TextSize = 16
versionInfo.Text = "Version 1.0.0 | Last Updated: July 2023"
versionInfo.TextXAlignment = Enum.TextXAlignment.Left
versionInfo.LayoutOrder = 3
versionInfo.Parent = homeContent

-- Credits Section
local creditsHeading = Instance.new("TextLabel")
creditsHeading.Name = "CreditsHeading"
creditsHeading.Size = UDim2.new(1, 0, 0, 30)
creditsHeading.BackgroundTransparency = 1
creditsHeading.Font = Enum.Font.SourceSansBold
creditsHeading.TextColor3 = textColor
creditsHeading.TextSize = 18
creditsHeading.Text = "Credits"
creditsHeading.TextXAlignment = Enum.TextXAlignment.Left
creditsHeading.LayoutOrder = 4
creditsHeading.Parent = homeContent

local creditsText = Instance.new("TextLabel")
creditsText.Name = "CreditsText"
creditsText.Size = UDim2.new(1, 0, 0, 60)
creditsText.BackgroundTransparency = 1
creditsText.Font = Enum.Font.SourceSans
creditsText.TextColor3 = mutedTextColor
creditsText.TextSize = 16
creditsText.Text = "Created by: YourName\nSpecial thanks to the Roblox Scripting Community"
creditsText.TextWrapped = true
creditsText.TextXAlignment = Enum.TextXAlignment.Left
creditsText.LayoutOrder = 5
creditsText.Parent = homeContent

-- Features Tab
local featuresTabName = "Features"
createTabButton(featuresTabName, "Features", "rbxassetid://3926305904", 1) -- Using Roblox's features icon
local featuresContent = createContentFrame(featuresTabName)

-- Features Heading
local featuresHeading = Instance.new("TextLabel")
featuresHeading.Name = "Heading"
featuresHeading.Size = UDim2.new(1, 0, 0, 40)
featuresHeading.BackgroundTransparency = 1
featuresHeading.Font = Enum.Font.SourceSansBold
featuresHeading.TextColor3 = textColor
featuresHeading.TextSize = 24
featuresHeading.Text = "Available Features"
featuresHeading.TextXAlignment = Enum.TextXAlignment.Left
featuresHeading.LayoutOrder = 1
featuresHeading.Parent = featuresContent

-- Features Description
local featuresDescription = Instance.new("TextLabel")
featuresDescription.Name = "Description"
featuresDescription.Size = UDim2.new(1, 0, 0, 60)
featuresDescription.BackgroundTransparency = 1
featuresDescription.Font = Enum.Font.SourceSans
featuresDescription.TextColor3 = mutedTextColor
featuresDescription.TextSize = 16
featuresDescription.Text = "This hub includes the following features which can be accessed from their respective tabs:"
featuresDescription.TextWrapped = true
featuresDescription.TextXAlignment = Enum.TextXAlignment.Left
featuresDescription.LayoutOrder = 2
featuresDescription.Parent = featuresContent

-- Feature List Function
local function addFeature(name, description, order)
    local featureFrame = Instance.new("Frame")
    featureFrame.Name = name .. "Feature"
    featureFrame.Size = UDim2.new(1, 0, 0, 70)
    featureFrame.BackgroundColor3 = lighterBaseColor
    featureFrame.BorderSizePixel = 0
    featureFrame.LayoutOrder = order + 2
    featureFrame.Parent = featuresContent
    
    local featureCorner = Instance.new("UICorner")
    featureCorner.CornerRadius = UDim.new(0, 6)
    featureCorner.Parent = featureFrame
    
    local featureName = Instance.new("TextLabel")
    featureName.Name = "FeatureName"
    featureName.Size = UDim2.new(1, -20, 0, 30)
    featureName.Position = UDim2.new(0, 10, 0, 5)
    featureName.BackgroundTransparency = 1
    featureName.Font = Enum.Font.SourceSansSemibold
    featureName.TextColor3 = textColor
    featureName.TextSize = 16
    featureName.Text = name
    featureName.TextXAlignment = Enum.TextXAlignment.Left
    featureName.Parent = featureFrame
    
    local featureDesc = Instance.new("TextLabel")
    featureDesc.Name = "FeatureDescription"
    featureDesc.Size = UDim2.new(1, -20, 0, 30)
    featureDesc.Position = UDim2.new(0, 10, 0, 35)
    featureDesc.BackgroundTransparency = 1
    featureDesc.Font = Enum.Font.SourceSans
    featureDesc.TextColor3 = mutedTextColor
    featureDesc.TextSize = 14
    featureDesc.Text = description
    featureDesc.TextWrapped = true
    featureDesc.TextXAlignment = Enum.TextXAlignment.Left
    featureDesc.Parent = featureFrame
    
    return featureFrame
end

-- Add some example features
addFeature("ESP", "See players through walls with customizable options", 1)
addFeature("Aimbot", "Automatic aiming assistance with various settings", 2)
addFeature("Speed Modifier", "Change your character's movement speed", 3)
addFeature("Teleport", "Teleport to various locations or players", 4)

-- Settings Tab
local settingsTabName = "Settings"
createTabButton(settingsTabName, "Settings", "rbxassetid://3926307971", 2) -- Using Roblox's settings icon
local settingsContent = createContentFrame(settingsTabName)

-- Settings Heading
local settingsHeading = Instance.new("TextLabel")
settingsHeading.Name = "Heading"
settingsHeading.Size = UDim2.new(1, 0, 0, 40)
settingsHeading.BackgroundTransparency = 1
settingsHeading.Font = Enum.Font.SourceSansBold
settingsHeading.TextColor3 = textColor
settingsHeading.TextSize = 24
settingsHeading.Text = "Settings"
settingsHeading.TextXAlignment = Enum.TextXAlignment.Left
settingsHeading.LayoutOrder = 1
settingsHeading.Parent = settingsContent

-- Keybind section
local keybindSection = Instance.new("Frame")
keybindSection.Name = "KeybindSection"
keybindSection.Size = UDim2.new(1, 0, 0, 80)
keybindSection.BackgroundColor3 = lighterBaseColor
keybindSection.BorderSizePixel = 0
keybindSection.LayoutOrder = 2
keybindSection.Parent = settingsContent

local keybindCorner = Instance.new("UICorner")
keybindCorner.CornerRadius = UDim.new(0, 6)
keybindCorner.Parent = keybindSection

local keybindTitle = Instance.new("TextLabel")
keybindTitle.Name = "KeybindTitle"
keybindTitle.Size = UDim2.new(1, -20, 0, 30)
keybindTitle.Position = UDim2.new(0, 10, 0, 5)
keybindTitle.BackgroundTransparency = 1
keybindTitle.Font = Enum.Font.SourceSansSemibold
keybindTitle.TextColor3 = textColor
keybindTitle.TextSize = 16
keybindTitle.Text = "Keyboard Shortcuts"
keybindTitle.TextXAlignment = Enum.TextXAlignment.Left
keybindTitle.Parent = keybindSection

local keybindLabel = Instance.new("TextLabel")
keybindLabel.Name = "KeybindLabel"
keybindLabel.Size = UDim2.new(1, -20, 0, 30)
keybindLabel.Position = UDim2.new(0, 10, 0, 35)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = Enum.Font.SourceSans
keybindLabel.TextColor3 = mutedTextColor
keybindLabel.TextSize = 14
keybindLabel.Text = "Toggle GUI Visibility: " .. toggleKeybind.Name
keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
keybindLabel.Parent = keybindSection

-- Unload Button Section
local unloadSection = Instance.new("Frame")
unloadSection.Name = "UnloadSection"
unloadSection.Size = UDim2.new(1, 0, 0, 100)
unloadSection.BackgroundColor3 = lighterBaseColor
unloadSection.BorderSizePixel = 0
unloadSection.LayoutOrder = 3
unloadSection.Parent = settingsContent

local unloadCorner = Instance.new("UICorner")
unloadCorner.CornerRadius = UDim.new(0, 6)
unloadCorner.Parent = unloadSection

local unloadTitle = Instance.new("TextLabel")
unloadTitle.Name = "UnloadTitle"
unloadTitle.Size = UDim2.new(1, -20, 0, 30)
unloadTitle.Position = UDim2.new(0, 10, 0, 5)
unloadTitle.BackgroundTransparency = 1
unloadTitle.Font = Enum.Font.SourceSansSemibold
unloadTitle.TextColor3 = textColor
unloadTitle.TextSize = 16
unloadTitle.Text = "Script Management"
unloadTitle.TextXAlignment = Enum.TextXAlignment.Left
unloadTitle.Parent = unloadSection

local unloadDescription = Instance.new("TextLabel")
unloadDescription.Name = "UnloadDescription"
unloadDescription.Size = UDim2.new(1, -20, 0, 30)
unloadDescription.Position = UDim2.new(0, 10, 0, 35)
unloadDescription.BackgroundTransparency = 1
unloadDescription.Font = Enum.Font.SourceSans
unloadDescription.TextColor3 = mutedTextColor
unloadDescription.TextSize = 14
unloadDescription.Text = "Click the button below to completely remove the script from the game."
unloadDescription.TextXAlignment = Enum.TextXAlignment.Left
unloadDescription.Parent = unloadSection

local unloadButton = Instance.new("TextButton")
unloadButton.Name = "UnloadButton"
unloadButton.Size = UDim2.new(0, 160, 0, 36)
unloadButton.Position = UDim2.new(0, 10, 0, 65)
unloadButton.BackgroundColor3 = Color3.fromRGB(219, 68, 55)  -- Google-style red
unloadButton.BorderSizePixel = 0
unloadButton.Font = Enum.Font.SourceSansSemibold
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.TextSize = 14
unloadButton.Text = "Unload Script"
unloadButton.Parent = unloadSection

local unloadButtonCorner = Instance.new("UICorner")
unloadButtonCorner.CornerRadius = UDim.new(0, 4)
unloadButtonCorner.Parent = unloadButton

-- Unload Button Hover Effect
unloadButton.MouseEnter:Connect(function()
    TweenService:Create(unloadButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(190, 50, 40)}):Play()
end)

unloadButton.MouseLeave:Connect(function()
    TweenService:Create(unloadButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(219, 68, 55)}):Play()
end)

-- Theme Section
local themeSection = Instance.new("Frame")
themeSection.Name = "ThemeSection"
themeSection.Size = UDim2.new(1, 0, 0, 120)
themeSection.BackgroundColor3 = lighterBaseColor
themeSection.BorderSizePixel = 0
themeSection.LayoutOrder = 4
themeSection.Parent = settingsContent

local themeCorner = Instance.new("UICorner")
themeCorner.CornerRadius = UDim.new(0, 6)
themeCorner.Parent = themeSection

local themeTitle = Instance.new("TextLabel")
themeTitle.Name = "ThemeTitle"
themeTitle.Size = UDim2.new(1, -20, 0, 30)
themeTitle.Position = UDim2.new(0, 10, 0, 5)
themeTitle.BackgroundTransparency = 1
themeTitle.Font = Enum.Font.SourceSansSemibold
themeTitle.TextColor3 = textColor
themeTitle.TextSize = 16
themeTitle.Text = "Theme Settings"
themeTitle.TextXAlignment = Enum.TextXAlignment.Left
themeTitle.Parent = themeSection

local themeDescription = Instance.new("TextLabel")
themeDescription.Name = "ThemeDescription"
themeDescription.Size = UDim2.new(1, -20, 0, 30)
themeDescription.Position = UDim2.new(0, 10, 0, 35)
themeDescription.BackgroundTransparency = 1
themeDescription.Font = Enum.Font.SourceSans
themeDescription.TextColor3 = mutedTextColor
themeDescription.TextSize = 14
themeDescription.Text = "Change the appearance of the user interface."
themeDescription.TextXAlignment = Enum.TextXAlignment.Left
themeDescription.Parent = themeSection

-- About Tab
local aboutTabName = "About"
createTabButton(aboutTabName, "About", "rbxassetid://3926307971", 3) -- Using Roblox's info icon
local aboutContent = createContentFrame(aboutTabName)

-- About Heading
local aboutHeading = Instance.new("TextLabel")
aboutHeading.Name = "Heading"
aboutHeading.Size = UDim2.new(1, 0, 0, 40)
aboutHeading.BackgroundTransparency = 1
aboutHeading.Font = Enum.Font.SourceSansBold
aboutHeading.TextColor3 = textColor
aboutHeading.TextSize = 24
aboutHeading.Text = "About Obsidian Hub"
aboutHeading.TextXAlignment = Enum.TextXAlignment.Left
aboutHeading.LayoutOrder = 1
aboutHeading.Parent = aboutContent

--[[ Event Connections ]]--

-- Unload Button Action
unloadButton.MouseButton1Click:Connect(function()
    print("Unloading Obsidian Hub...")
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

print("Obsidian Hub Loaded Successfully")
print("Press " .. toggleKeybind.Name .. " to toggle GUI visibility.")
