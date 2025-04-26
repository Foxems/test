-- NOTE: This script requires a working Roblox exploit executor
-- Remote Explorer for Bubble Gum Simulator and other Roblox games

local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

-- === Load the GUI Library ===
local success, Library = pcall(function()
    return loadstring(game:HttpGet(Repository .. "Library.lua"))()
end)

if not success or type(Library) ~= 'table' then
    warn("Failed to load Obsidian Library! Check the Repository URL or your internet connection.")
    warn("Error:", Library)
    return
end

local Options = Library.Options
local Toggles = Library.Toggles
local Notifications = Library.Notify

-- Check if running on mobile
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

-- === Create the Main Window ===
local Window = Library:CreateWindow({
    Title = "Remote Explorer",
    Footer = "Remote Scanner by AI | GUI by s.eths / Obsidian",
    NotifySide = "Right",
    ShowCustomCursor = not isMobile, -- Disable custom cursor on mobile
})

-- === Define Tabs ===
local Tabs = {
    RemoteExplorer = Window:AddTab("Remote Explorer", "search"),
    UISettings = Window:AddTab("UI Settings", "settings"),
}

-- === Remote Explorer Tab Content ===
local FilterGroupbox = Tabs.RemoteExplorer:AddLeftGroupbox("Filters")
local RemoteListGroupbox = Tabs.RemoteExplorer:AddRightGroupbox("Found Remotes")

-- Storage for found remotes
local allRemotes = {}
local filteredRemotes = {}

-- Filter options
FilterGroupbox:AddInput("SearchFilter", {
    Text = "Search Remotes",
    Placeholder = "Enter name or path...",
    Callback = function(text)
        applyFilters()
    end
})

-- Exclude Roblox system remotes by default
local excludeRobloxRemotes = FilterGroupbox:AddToggle("ExcludeRobloxRemotes", {
    Text = "Exclude Roblox System Remotes",
    Default = true,
    Callback = function(value)
        applyFilters()
    end
})

-- Only show game-specific remotes
local onlyGameRemotes = FilterGroupbox:AddToggle("OnlyGameRemotes", {
    Text = "Only Game Remotes",
    Default = true, 
    Callback = function(value)
        applyFilters()
    end
})

-- Filter by remote type
local showRemoteEvents = FilterGroupbox:AddToggle("ShowRemoteEvents", {
    Text = "Show RemoteEvents",
    Default = true,
    Callback = function(value)
        applyFilters()
    end
})

local showRemoteFunctions = FilterGroupbox:AddToggle("ShowRemoteFunctions", {
    Text = "Show RemoteFunctions",
    Default = true,
    Callback = function(value)
        applyFilters()
    end
})

-- Add a label to display the remote list
local RemoteListLabel = RemoteListGroupbox:AddLabel("Click 'Scan Remotes' to start.")

-- Button to scan for remotes
FilterGroupbox:AddButton({
    Text = "Scan / Refresh Remotes",
    Tooltip = "Scans the entire game for RemoteEvents and RemoteFunctions.",
    Func = function()
        RemoteListLabel:SetText("Scanning for remotes...")
        
        task.spawn(function()
            allRemotes = {}
            
            -- Standard scan for all remotes
            for _, instance in ipairs(game:GetDescendants()) do
                if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                    table.insert(allRemotes, {
                        Type = instance.ClassName,
                        Name = instance.Name,
                        Path = instance:GetFullName(),
                        Instance = instance
                    })
                end
            end
            
            -- Specifically look for Bubble Gum Simulator remotes in common locations
            local bgsPaths = {
                game:GetService("ReplicatedStorage").Events,
                game:GetService("ReplicatedStorage").Remotes,
                game:GetService("ReplicatedStorage").Network,
                game:GetService("ReplicatedStorage").Modules
            }
            
            for _, container in pairs(bgsPaths) do
                if typeof(container) == "Instance" then
                    for _, instance in pairs(container:GetDescendants()) do
                        if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                            -- Check if we already found this remote in the standard scan
                            local alreadyFound = false
                            for _, remote in ipairs(allRemotes) do
                                if remote.Path == instance:GetFullName() then
                                    alreadyFound = true
                                    break
                                end
                            end
                            
                            if not alreadyFound then
                                table.insert(allRemotes, {
                                    Type = instance.ClassName,
                                    Name = instance.Name,
                                    Path = instance:GetFullName(),
                                    Instance = instance
                                })
                            end
                        end
                    end
                end
            end
            
            -- Look for key remotes by name patterns common in Bubble Gum Simulator
            local bgsKeywords = {"blow", "sell", "collect", "upgrade", "buy", "hatch", "equip", 
                                "unequip", "teleport", "claim", "rebirth", "craft"}
            
            for _, instance in pairs(game:GetDescendants()) do
                if (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then
                    local name = instance.Name:lower()
                    for _, keyword in ipairs(bgsKeywords) do
                        if name:match(keyword) then
                            -- Check if already found
                            local alreadyFound = false
                            for _, remote in ipairs(allRemotes) do
                                if remote.Path == instance:GetFullName() then
                                    alreadyFound = true
                                    break
                                end
                            end
                            
                            if not alreadyFound then
                                table.insert(allRemotes, {
                                    Type = instance.ClassName,
                                    Name = instance.Name,
                                    Path = instance:GetFullName(),
                                    Instance = instance
                                })
                            end
                            break
                        end
                    end
                end
            end
            
            -- Sort remotes by path for easier reading
            table.sort(allRemotes, function(a, b)
                return a.Path < b.Path
            end)
            
            applyFilters()
            
            Notifications({
                Title = "Scan Complete",
                Description = "Found " .. #allRemotes .. " remotes. Filtered: " .. #filteredRemotes,
                Time = 3
            })
        end)
    end
})

-- Button to copy remotes to clipboard (positioned well for mobile)
local CopyButtonContainer = RemoteListGroupbox:AddDivider()
RemoteListGroupbox:AddButton({
    Text = "Copy Remote List to Clipboard",
    Tooltip = "Copies the currently displayed list of remotes to your clipboard.",
    Func = function()
        local textToCopy = formatRemotesForCopy(filteredRemotes)
        
        if textToCopy ~= "" then
            if setclipboard then
                setclipboard(textToCopy)
                Notifications({
                    Title = "Copied!",
                    Description = #filteredRemotes .. " remotes copied to clipboard",
                    Time = 3
                })
            else
                Notifications({
                    Title = "Copy Failed",
                    Description = "Your exploit does not support 'setclipboard'",
                    Time = 4,
                    Type = "Error"
                })
            end
        else
            Notifications({
                Title = "Nothing to Copy",
                Description = "No remotes found or filtered",
                Time = 3,
                Type = "Warning"
            })
        end
    end
})

-- Function to format remotes for clipboard
function formatRemotesForCopy(remotesList)
    if #remotesList == 0 then return "" end
    
    local text = "Found " .. #remotesList .. " Remotes:\n"
    
    for _, remote in ipairs(remotesList) do
        text = text .. remote.Type .. ": " .. remote.Name .. " (" .. remote.Path .. ")\n"
    end
    
    return text
end

-- Function to update the remote list display based on filters
function applyFilters()
    local searchText = Options.SearchFilter.Value:lower()
    local excludeRoblox = Toggles.ExcludeRobloxRemotes.Value
    local onlyGame = Toggles.OnlyGameRemotes.Value
    local showEvents = Toggles.ShowRemoteEvents.Value
    local showFunctions = Toggles.ShowRemoteFunctions.Value
    
    filteredRemotes = {}
    
    for _, remote in ipairs(allRemotes) do
        local include = true
        
        -- Filter by type
        if (remote.Type == "RemoteEvent" and not showEvents) or
           (remote.Type == "RemoteFunction" and not showFunctions) then
            include = false
        end
        
        -- Filter by search text
        if searchText ~= "" and not (remote.Name:lower():find(searchText) or remote.Path:lower():find(searchText)) then
            include = false
        end
        
        -- Exclude Roblox system remotes
        if excludeRoblox and (remote.Path:match("^RobloxReplicatedStorage") or 
                             remote.Path:match("^RobloxGui") or
                             remote.Path:match("^CoreGui")) then
            include = false
        end
        
        -- Only game remotes (not in RobloxReplicatedStorage, CoreGui or CoreScripts)
        if onlyGame and (remote.Path:match("^RobloxReplicatedStorage") or
                        remote.Path:match("^CoreGui") or
                        remote.Path:match("^CoreScripts")) then
            include = false
        end
        
        if include then
            table.insert(filteredRemotes, remote)
        end
    end
    
    -- Update the display
    updateRemoteList()
end

-- Function to update the remote list display
function updateRemoteList()
    local listText
    
    if #filteredRemotes == 0 then
        if #allRemotes == 0 then
            listText = "No remotes found. Try scanning first."
        else
            listText = "No remotes match your filters. Try adjusting filters or search."
        end
    else
        listText = "Found " .. #filteredRemotes .. " Remotes:\n"
        
        for _, remote in ipairs(filteredRemotes) do
            listText = listText .. remote.Type .. ": " .. remote.Name .. " (" .. remote.Path .. ")\n"
        end
    end
    
    RemoteListLabel:SetText(listText)
end

-- === UI Settings Tab Content (Optional, from your original script) ===
-- This section configures the GUI library itself (keybind, DPI, saving, etc.)

-- Load ThemeManager and SaveManager (assuming they are next to Library.lua)
local successTM, ThemeManager = pcall(function()
    return loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()
end)
local successSM, SaveManager = pcall(function()
    return loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
end)

if not successTM then warn("Failed to load ThemeManager:", ThemeManager) end
if not successSM then warn("Failed to load SaveManager:", SaveManager) end

-- Add UI Settings Groupbox
local TabsUISettingsLeft = Tabs.UISettings:AddLeftGroupbox("Menu")
local TabsUISettingsRight = Tabs.UISettings:AddRightGroupbox("Appearance & Saving")

-- Menu Groupbox
TabsUISettingsLeft:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible;
    Text = "Open Keybind Menu";
    Callback = function(value)
        Library.KeybindFrame.Visible = value;
    end;
});
TabsUISettingsLeft:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor";
    Default = isMobile and false or true; -- Disable on mobile by default
    Callback = function(Value)
        Library.ShowCustomCursor = Value;
        Window.ShowCustomCursor = Value;
    end;
});
TabsUISettingsLeft:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"};
    Default = "Right";
    Text = "Notification Side";
    Callback = function(Value)
        Library:SetNotifySide(Value);
    end;
});
TabsUISettingsLeft:AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"};
    Default = "100%";
    Text = "DPI Scale";
    Callback = function(Value)
        Value = Value:gsub("%%", "");
        local DPI = tonumber(Value);
        if DPI then
            Library:SetDPIScale(DPI / 100);
        end
    end;
});
TabsUISettingsLeft:AddDivider()
local MenuKeyPicker = TabsUISettingsLeft:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "RightShift", NoUI = true, Text = "Menu keybind"});

Library.ToggleKeybind = Options.MenuKeybind;
Options.MenuKeybind:OnChanged(function(newValue)
    Library.ToggleKeybind = newValue
end)

TabsUISettingsLeft:AddButton("Unload Script", function()
    Library:Unload();
end);

-- Appearance & Saving Groupbox
if ThemeManager and SaveManager then
     ThemeManager:ApplyToTab(Tabs.UISettings)
     SaveManager:BuildConfigSection(Tabs.UISettings)
     SaveManager:SetFolder("Remote Explorer Settings")
     SaveManager:IgnoreThemeSettings();
     SaveManager:SetIgnoreIndexes({"MenuKeybind"});
     SaveManager:LoadAutoloadConfig();

     Notifications({
        Title = "Remote Explorer Loaded",
        Description = "Press '" .. tostring(Library.ToggleKeybind) .. "' to toggle menu visibility.",
        Time = 5
     })
else
    TabsUISettingsRight:AddLabel("Theme/Save Managers not loaded.")
end

-- Run initial scan
task.spawn(function()
    task.wait(1) -- Wait a bit for the game to fully load
    FilterGroupbox:FindFirstChild("Scan / Refresh Remotes").Func()
end)
