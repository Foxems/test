local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

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

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

local Window = Library:CreateWindow({
    Title = "Remote Explorer",
    Footer = "Remote Scanner by AI | GUI by s.eths / Obsidian",
    NotifySide = "Right",
    ShowCustomCursor = not isMobile,
})

local Tabs = {
    RemoteExplorer = Window:AddTab("Remote Explorer", "search"),
    UISettings = Window:AddTab("UI Settings", "settings"),
}

local FilterGroupbox = Tabs.RemoteExplorer:AddLeftGroupbox("Filters")
local RemoteListGroupbox = Tabs.RemoteExplorer:AddRightGroupbox("Found Remotes")

local allRemotes = {}
local filteredRemotes = {}
local foundPaths = {} -- To prevent duplicates efficiently

FilterGroupbox:AddInput("SearchFilter", {
    Text = "Search Remotes",
    Placeholder = "Enter name or path...",
    Callback = function(text)
        applyFilters()
    end
})

local excludeRobloxRemotes = FilterGroupbox:AddToggle("ExcludeRobloxRemotes", {
    Text = "Exclude Roblox System Remotes",
    Default = true,
    Callback = function(value)
        applyFilters()
    end
})

local onlyGameRemotes = FilterGroupbox:AddToggle("OnlyGameRemotes", {
    Text = "Only Game Remotes",
    Default = true,
    Callback = function(value)
        applyFilters()
    end
})

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

local RemoteListLabel = RemoteListGroupbox:AddLabel("Click 'Scan Remotes' to start.")

local bgsKeywords = {"blow", "sell", "collect", "upgrade", "buy", "hatch", "equip",
                     "unequip", "teleport", "claim", "rebirth", "craft", "click", "autoclick",
                     "open", "reward", "interact", "network", "remote", "event"}

local function addRemote(instance)
    if not (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then return end

    local path = instance:GetFullName()
    if foundPaths[path] then return end

    foundPaths[path] = true
    table.insert(allRemotes, {
        Type = instance.ClassName,
        Name = instance.Name,
        Path = path,
        Instance = instance
    })
end

local function findRemotesIn(container, containerName)
    if typeof(container) ~= "Instance" then return end
    RemoteListLabel:SetText("Scanning " .. containerName .. "...")
    local success, err = pcall(function()
        for _, instance in ipairs(container:GetDescendants()) do
            addRemote(instance)
            task.wait() -- Add a small yield to prevent freezing on huge containers
        end
    end)
    if not success then
        warn("Error scanning " .. containerName .. ":", err)
        Notifications({ Title = "Scan Warning", Description = "Error scanning " .. containerName .. ". Some remotes might be missed.", Type = "Warning", Time = 5 })
    end
end

local function performScan()
    allRemotes = {}
    foundPaths = {}

    RemoteListLabel:SetText("Starting scan...")
    task.wait(0.1)

    local commonLocations = {
        {game:GetService("ReplicatedStorage"), "ReplicatedStorage"},
        {game:GetService("Workspace"), "Workspace"},
        {game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"), "PlayerGui"},
        {game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts"), "PlayerScripts"},
        {game:GetService("StarterPlayer") and game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts"), "StarterPlayerScripts"},
        {game:GetService("StarterGui"), "StarterGui"}
    }

    for _, data in ipairs(commonLocations) do
        findRemotesIn(data[1], data[2])
        task.wait(0.1)
    end

    RemoteListLabel:SetText("Performing final deep scan (may take a moment)...")
    task.wait(0.1)
    local success, err = pcall(function()
        for _, instance in ipairs(game:GetDescendants()) do
            addRemote(instance)
            if #allRemotes % 100 == 0 then task.wait() end -- Yield occasionally during deep scan
        end
    end)
     if not success then
        warn("Error during deep scan:", err)
        Notifications({ Title = "Scan Warning", Description = "Error during deep scan. Some remotes might be missed.", Type = "Warning", Time = 5 })
    end

    RemoteListLabel:SetText("Searching by keywords...")
    task.wait(0.1)
    local successKeywords, errKeywords = pcall(function()
        for _, instance in ipairs(game:GetDescendants()) do
             if (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then
                 local name = instance.Name:lower()
                 for _, keyword in ipairs(bgsKeywords) do
                     if name:match(keyword) then
                         addRemote(instance)
                         break
                     end
                 end
             end
             if #allRemotes % 100 == 0 then task.wait() end -- Yield occasionally
        end
    end)
    if not successKeywords then
        warn("Error during keyword scan:", errKeywords)
        Notifications({ Title = "Scan Warning", Description = "Error during keyword scan. Some remotes might be missed.", Type = "Warning", Time = 5 })
    end


    table.sort(allRemotes, function(a, b)
        return a.Path < b.Path
    end)

    return true
end

FilterGroupbox:AddButton({
    Text = "Scan / Refresh Remotes",
    Tooltip = "Scans the game for RemoteEvents and RemoteFunctions.",
    Func = function()
        RemoteListLabel:SetText("Initiating scan...")

        task.spawn(function()
            local scanSuccess, scanError = pcall(performScan)

            if not scanSuccess then
                RemoteListLabel:SetText("Scan failed: " .. tostring(scanError))
                Notifications({
                    Title = "Scan Failed",
                    Description = "An error occurred during scanning: " .. tostring(scanError),
                    Time = 5,
                    Type = "Error"
                })
                return
            end

            applyFilters()

            Notifications({
                Title = "Scan Complete",
                Description = "Found " .. #allRemotes .. " total remotes. Displaying " .. #filteredRemotes .. " based on filters.",
                Time = 4
            })
        end)
    end
})

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

function formatRemotesForCopy(remotesList)
    if #remotesList == 0 then return "" end

    local text = "Found " .. #remotesList .. " Remotes:\n"

    for _, remote in ipairs(remotesList) do
        text = text .. remote.Type .. ": " .. remote.Name .. " (" .. remote.Path .. ")\n"
    end

    return text
end

function applyFilters()
    local searchText = Options.SearchFilter.Value:lower()
    local excludeRoblox = Toggles.ExcludeRobloxRemotes.Value
    local onlyGame = Toggles.OnlyGameRemotes.Value
    local showEvents = Toggles.ShowRemoteEvents.Value
    local showFunctions = Toggles.ShowRemoteFunctions.Value

    filteredRemotes = {}

    for _, remote in ipairs(allRemotes) do
        local include = true

        if (remote.Type == "RemoteEvent" and not showEvents) or
           (remote.Type == "RemoteFunction" and not showFunctions) then
            include = false
        end

        if searchText ~= "" and not (remote.Name:lower():find(searchText) or remote.Path:lower():find(searchText)) then
            include = false
        end

        if excludeRoblox and (remote.Path:match("^Instance%.RobloxReplicatedStorage") or
                             remote.Path:match("^Instance%.RobloxGui") or
                             remote.Path:match("^Instance%.CoreGui") or
                             remote.Path:match("^CoreGui") or -- Added just in case
                             remote.Path:match("^RobloxGui") ) then -- Added just in case
            include = false
        end

        if onlyGame and (remote.Path:match("^Instance%.RobloxReplicatedStorage") or
                        remote.Path:match("^Instance%.CoreGui") or
                        remote.Path:match("^Instance%.CoreScripts") or
                        remote.Path:match("^CoreGui") or
                        remote.Path:match("^RobloxGui") or
                        remote.Path:match("^CoreScripts")) then -- Added just in case
            include = false
        end

        if include then
            table.insert(filteredRemotes, remote)
        end
    end

    updateRemoteList()
end

function updateRemoteList()
    local listText

    if #filteredRemotes == 0 then
        if #allRemotes == 0 then
            listText = "No remotes found. Try scanning first."
        else
            listText = "No remotes match your filters (" .. #allRemotes .. " total found)."
        end
    else
        listText = "Found " .. #filteredRemotes .. " / " .. #allRemotes .. " Remotes:\n\n" -- Added total count

        for i, remote in ipairs(filteredRemotes) do
             -- Add numbering and slightly better formatting
            listText = listText .. i .. ". [" .. remote.Type:sub(1, 6) .. "] " .. remote.Name .. "\n   Path: " .. remote.Path .. "\n"
            if i > 200 then -- Limit displayed remotes to prevent lag with huge lists
                 listText = listText .. "\n... (list truncated for performance) ..."
                 break
            end
        end
    end

    RemoteListLabel:SetText(listText)
end

local successTM, ThemeManager = pcall(function()
    return loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))()
end)
local successSM, SaveManager = pcall(function()
    return loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))()
end)

if not successTM then warn("Failed to load ThemeManager:", ThemeManager) end
if not successSM then warn("Failed to load SaveManager:", SaveManager) end

local TabsUISettingsLeft = Tabs.UISettings:AddLeftGroupbox("Menu")
local TabsUISettingsRight = Tabs.UISettings:AddRightGroupbox("Appearance & Saving")

TabsUISettingsLeft:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible;
    Text = "Open Keybind Menu";
    Callback = function(value)
        Library.KeybindFrame.Visible = value;
    end;
});
TabsUISettingsLeft:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor";
    Default = not isMobile;
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

task.spawn(function()
    task.wait(2)
    local scanButton = FilterGroupbox:FindFirstChildWhichIsA("Button", true)
    while not scanButton or scanButton.Text ~= "Scan / Refresh Remotes" do
        task.wait(0.5)
        scanButton = FilterGroupbox:FindFirstChildWhichIsA("Button", true)
    end
    if scanButton and scanButton.Func then
         scanButton.Func()
    else
        warn("Could not find Scan button to trigger initial scan.")
        RemoteListLabel:SetText("Ready. Click 'Scan / Refresh Remotes'.")
    end
end)
