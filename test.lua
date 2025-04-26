--[[ Service Variables ]]--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--[[ GUI Configuration ]]--
local guiVisible = true
local toggleKeybind = Enum.KeyCode.RightControl -- Keybind to toggle GUI

-- Darker Color Palette
local accentColor = Color3.fromRGB(88, 101, 242) -- Blurple accent
local baseColor = Color3.fromRGB(30, 32, 36)     -- Very dark background
local lighterBaseColor = Color3.fromRGB(40, 42, 47) -- Slightly lighter for panels/buttons
local lightestBaseColor = Color3.fromRGB(50, 53, 59) -- Even lighter for hover/active
local textColor = Color3.fromRGB(230, 230, 230)   -- Primary text color
local mutedTextColor = Color3.fromRGB(160, 160, 165) -- Secondary text color
local iconColor = Color3.fromRGB(160, 160, 165)   -- Default icon color
local iconActiveColor = Color3.fromRGB(255, 255, 255) -- Active icon color
local unloadColor = Color3.fromRGB(200, 50, 50) -- Red for unload

--[[ Main GUI Creation ]]--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JustBGSIGui"
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
mainFrame.Active = true -- Still useful for desktop drag
mainFrame.Draggable = true -- Keep for desktop convenience
mainFrame.Selectable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainFrameCorner = Instance.new("UICorner")
mainFrameCorner.CornerRadius = UDim.new(0, 8)
mainFrameCorner.Parent = mainFrame

-- Title Bar at the top (Used for mobile drag)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 37, 42) -- Darker than base
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 8)
titleBarCorner.Parent = titleBar

-- Only round the top corners of the title bar visually
local titleBarFix = Instance.new("Frame")
titleBarFix.Name = "TitleBarFix"
titleBarFix.Size = UDim2.new(1, 0, 0.5, 0)
titleBarFix.Position = UDim2.new(0, 0, 0.5, 0)
titleBarFix.BackgroundColor3 = Color3.fromRGB(35, 37, 42)
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
titleText.Text = "JustBGSI" -- Renamed title
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Left Sidebar for Categories
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 180, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40) -- Below title bar
sidebar.BackgroundColor3 = Color3.fromRGB(38, 40, 45) -- Slightly lighter than base
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
    tabIcon.Image = iconId -- Using placeholder IDs
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
    frame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85) -- Darker scrollbar
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
-- Using a common placeholder home icon
createTabButton(homeTabName, "Home", "rbxassetid://3926305904", 0)
local homeContent = createContentFrame(homeTabName)

-- Heading for Home
local homeHeading = Instance.new("TextLabel")
homeHeading.Name = "Heading"
homeHeading.Size = UDim2.new(1, 0, 0, 40)
homeHeading.BackgroundTransparency = 1
homeHeading.Font = Enum.Font.SourceSansBold
homeHeading.TextColor3 = textColor
homeHeading.TextSize = 24
homeHeading.Text = "Welcome to JustBGSI"
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
homeDescription.Text = "This is a basic GUI structure for your script. Use the sidebar to navigate between sections.\n\nCustomize the content area for each tab to add your script features."
homeDescription.TextWrapped = true
homeDescription.TextXAlignment = Enum.TextXAlignment.Left
homeDescription.LayoutOrder = 2
homeDescription.Parent = homeContent

-- Settings Tab
local settingsTabName = "Settings"
-- Using a common placeholder settings icon
createTabButton(settingsTabName, "Settings", "rbxassetid://3926307971", 1)
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
unloadButton.BackgroundColor3 = unloadColor
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
    TweenService:Create(unloadButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(170, 40, 40)}):Play() -- Darker red
end)

unloadButton.MouseLeave:Connect(function()
    TweenService:Create(unloadButton, TweenInfo.new(0.15), {BackgroundColor3 = unloadColor}):Play()
end)


--[[ Mobile Drag Implementation ]]--
local dragging = false
local dragStartPos = Vector2.zero
local frameStartPos = UDim2.new(0,0,0,0)

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    -- Check for GUI toggle keybind
    if input.KeyCode == toggleKeybind then
        guiVisible = not guiVisible
        screenGui.Enabled = guiVisible
        print("GUI Visibility Toggled:", guiVisible)
    end

    -- Check if the input is a touch or mouse click on the title bar
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Check if the click/touch is within the bounds of the titleBar
        local guiObjects = titleBar:GetGuiObjectsAtPosition(input.Position)
        local isClickOnTitleBar = false
        for _, obj in ipairs(guiObjects) do
            if obj == titleBar or obj.Parent == titleBar then -- Check titleBar or its direct children
                isClickOnTitleBar = true
                break
            end
        end

        if isClickOnTitleBar then
            dragging = true
            dragStartPos = input.Position
            frameStartPos = mainFrame.Position
            -- Capture the input to prevent other UI elements from receiving it
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end
end

local function onInputChanged(input, gameProcessedEvent)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartPos
        local newPosition = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                                       frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)

        -- Optional: Clamp the position to keep it on screen
        local maxX = screenGui.AbsoluteSize.X - mainFrame.AbsoluteSize.X
        local maxY = screenGui.AbsoluteSize.Y - mainFrame.AbsoluteSize.Y
        newPosition = UDim2.new(0, math.clamp(newPosition.X.Offset, 0, maxX),
                                 0, math.clamp(newPosition.Y.Offset, 0, maxY))

        mainFrame.Position = newPosition
    end
end

local function onInputEnded(input, gameProcessedEvent)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragging = false
        -- Release the mouse capture
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

--[[ Event Connections ]]--

-- Unload Button Action
unloadButton.MouseButton1Click:Connect(function()
    print("Unloading JustBGSI...")
    screenGui:Destroy()
    -- Add any other cleanup logic needed for your script here
end)

-- GUI Toggle Keybind Listener
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)


--[[ Initialization ]]--

-- Set Parent to PlayerGui
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
screenGui.Parent = playerGui

-- Switch to the default tab (Home)
switchTab(homeTabName)

print("JustBGSI Loaded Successfully")
print("Press " .. toggleKeybind.Name .. " to toggle GUI visibility.")
