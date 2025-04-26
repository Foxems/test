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
                     "open", "reward", "interact", "network", "remote", "event", "pickup",
                     "bubble", "potion", "rift", "chest", "key", "quest", "market", "shop",
                     "redeem", "code", "gift", "wheel", "playtime"} -- Added more BGS specific keywords

local function addRemote(instance)
    if not (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then return false end

    local path = instance:GetFullName()
    if foundPaths[path] then return false end

    foundPaths[path] = true
    table.insert(allRemotes, {
        Type = instance.ClassName,
        Name = instance.Name,
        Path = path,
        Instance = instance
    })
    return true
end

local function findRemotesIn(container, containerName)
    if typeof(container) ~= "Instance" then
        warn(containerName .. " is not a valid Instance.")
        return 0 -- Return count of found items
    end

    RemoteListLabel:SetText("Scanning " .. containerName .. "...")
    local foundCount = 0
    local processedCount = 0

    local success, err = pcall(function()
        for _, instance in ipairs(container:GetDescendants()) do
            processedCount = processedCount + 1
            if addRemote(instance) then
                 foundCount = foundCount + 1
            end
            -- Yield occasionally within very large containers, but less often than before
            if processedCount % 500 == 0 then task.wait() end
        end
    end)

    if not success then
        warn("Error scanning " .. containerName .. ":", err)
        Notifications({ Title = "Scan Warning", Description = "Error scanning " .. containerName .. ". Error: " .. tostring(err), Type = "Warning", Time = 7 })
        RemoteListLabel:SetText("Error scanning " .. containerName .. ". Check console (F9).")
    else
        print("Finished scanning " .. containerName .. ", added " .. foundCount .. " new remotes.")
    end
    return foundCount
end

local function performScan()
    allRemotes = {}
    foundPaths = {}
    local totalFound = 0

    RemoteListLabel:SetText("Starting scan...")
    task.wait(0.1)

    -- 1. Scan Specific BGS Infinity Paths First
    RemoteListLabel:SetText("Scanning BGS Framework Remotes...")
    local repStorage = game:GetService("ReplicatedStorage")
    local bgsSpecificPaths = {
        {repStorage:FindFirstChild("Shared"), "ReplicatedStorage.Shared"},
        {repStorage:FindFirstChild("Remotes"), "ReplicatedStorage.Remotes"}
    }
    for _, data in ipairs(bgsSpecificPaths) do
        local container, containerName = data[1], data[2]
        if container then
            local frameworkPath = container:FindFirstChild("Framework")
            if frameworkPath and containerName == "ReplicatedStorage.Shared" then
                 local networkPath = frameworkPath:FindFirstChild("Network")
                 if networkPath then
                     local remotePath = networkPath:FindFirstChild("Remote")
                     if remotePath then
                         totalFound = totalFound + findRemotesIn(remotePath, containerName .. ".Framework.Network.Remote")
                         task.wait(0.05) -- Small yield after scanning this specific path
                     else warn("Could not find Remote folder in BGS Framework path.") end
                 else warn("Could not find Network folder in BGS Framework path.") end
            elseif containerName == "ReplicatedStorage.Remotes" then
                 -- Scan the general Remotes folder if it exists
                 totalFound = totalFound + findRemotesIn(container, containerName)
                 task.wait(0.05)
            end
        else
            warn("Could not find expected BGS container: " .. containerName)
        end
    end
    task.wait(0.1) -- Yield after specific scans

    -- 2. Scan Common Game Locations
    RemoteListLabel:SetText("Scanning common locations...")
    local commonLocations = {
        {game:GetService("ReplicatedStorage"), "ReplicatedStorage (General)"}, -- Scan RS again generally
        {game:GetService("Workspace"), "Workspace"},
        {game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"), "PlayerGui"},
        {game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts"), "PlayerScripts"},
        {game:GetService("StarterPlayer") and game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts"), "StarterPlayerScripts"},
        {game:GetService("StarterGui"), "StarterGui"}
    }

    for _, data in ipairs(commonLocations) do
        totalFound = totalFound + findRemotesIn(data[1], data[2])
        task.wait(0.1) -- Yield BETWEEN scanning major containers
    end

    -- 3. Perform Deep Scan (Yielding Occasionally)
    RemoteListLabel:SetText("Performing deep scan (may take a moment)...")
    task.wait(0.1)
    local deepScanCount = 0
    local successDeep, errDeep = pcall(function()
        for _, instance in ipairs(game:GetDescendants()) do
            deepScanCount = deepScanCount + 1
            if addRemote(instance) then
                totalFound = totalFound + 1
            end
            if deepScanCount % 500 == 0 then -- Yield every 500 instances checked in deep scan
                RemoteListLabel:SetText("Deep scan progress: " .. deepScanCount .. " instances checked...")
                task.wait()
            end
        end
    end)
     if not successDeep then
        warn("Error during deep scan:", errDeep)
        Notifications({ Title = "Scan Warning", Description = "Error during deep scan: " .. tostring(errDeep), Type = "Warning", Time = 7 })
    end
    RemoteListLabel:SetText("Deep scan finished checking " .. deepScanCount .. " instances.")
    task.wait(0.1) -- Yield after deep scan

    -- 4. Keyword Scan (Yielding Occasionally) - Less critical if specific paths worked
    RemoteListLabel:SetText("Searching by keywords...")
    task.wait(0.1)
    local keywordScanCount = 0
    local successKeywords, errKeywords = pcall(function()
        for _, instance in ipairs(game:GetDescendants()) do
             keywordScanCount = keywordScanCount + 1
             if (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then
                 local name = instance.Name:lower()
                 for _, keyword in ipairs(bgsKeywords) do
                     if name:match(keyword) then
                         if addRemote(instance) then -- Use addRemote to avoid duplicates
                            totalFound = totalFound + 1
                         end
                         break -- Move to next instance once a keyword matches
                     end
                 end
             end
             if keywordScanCount % 500 == 0 then -- Yield every 500 instances checked
                 RemoteListLabel:SetText("Keyword scan progress: " .. keywordScanCount .. " instances checked...")
                 task.wait()
             end
        end
    end)
    if not successKeywords then
        warn("Error during keyword scan:", errKeywords)
        Notifications({ Title = "Scan Warning", Description = "Error during keyword scan: " .. tostring(errKeywords), Type = "Warning", Time = 7 })
    end
    RemoteListLabel:SetText("Keyword scan finished checking " .. keywordScanCount .. " instances.")
    task.wait(0.1) -- Yield after keyword scan

    -- 5. Sort and Finalize
    table.sort(allRemotes, function(a, b)
        return a.Path < b.Path
    end)

    RemoteListLabel:SetText("Scan complete. Found " .. #allRemotes .. " unique remotes.")
    return true
end

FilterGroupbox:AddButton({
    Text = "Scan / Refresh Remotes",
    Tooltip = "Scans the game for RemoteEvents and RemoteFunctions, prioritizing BGS paths.",
    Func = function()
        RemoteListLabel:SetText("Initiating scan...")

        task.spawn(function() -- Run scan in a separate thread
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

            applyFilters() -- Apply filters *after* scan completes

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

    local text = "Found " .. #remotesList .. " Remotes:\n\n"

    for i, remote in ipairs(remotesList) do
        text = text .. i .. ". [" .. remote.Type .. "] " .. remote.Name .. "\n   Path: " .. remote.Path .. "\n"
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

        -- Type Filter
        if (remote.Type == "RemoteEvent" and not showEvents) or
           (remote.Type == "RemoteFunction" and not showFunctions) then
            include = false
        end

        -- Search Filter
        if include and searchText ~= "" and not (remote.Name:lower():find(searchText) or remote.Path:lower():find(searchText)) then
            include = false
        end

        -- Exclude Roblox Filter (Improved path matching)
        if include and excludeRoblox then
            local pathLower = remote.Path:lower()
            if pathLower:match("^instance%.robloxreplicatedstorage") or
               pathLower:match("^instance%.robloxgui") or
               pathLower:match("^instance%.coregui") or
               pathLower:match("^coregui") or
               pathLower:match("^robloxgui") or
               pathLower:match("^players%.player%.playergui%.robloxgui") then -- More specific CoreGui path
                include = false
            end
        end

        -- Only Game Filter (Improved path matching)
        if include and onlyGame then
             local pathLower = remote.Path:lower()
             if pathLower:match("^instance%.robloxreplicatedstorage") or
                pathLower:match("^instance%.coregui") or
                pathLower:match("^instance%.corescripts") or
                pathLower:match("^coregui") or
                pathLower:match("^robloxgui") or
                pathLower:match("^corescripts") or
                pathLower:match("^players%.player%.playergui%.robloxgui") then
                 include = false
             end
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
            if i > 250 then -- Limit displayed remotes slightly higher
                 listText = listText .. "\n... (" .. (#filteredRemotes - i) .. " more - list truncated for performance) ..."
                 break
            end
        end
    end

    RemoteListLabel:SetText(listText)
end

-- === UI Settings Tab Content (Mostly unchanged) ===
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
        Window.ShowCustomCursor = Value; -- Ensure window cursor state matches library
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
        Value = Value:gsub("%%", ""); -- Remove percentage sign
        local DPI = tonumber(Value);
        if DPI then
            Library:SetDPIScale(DPI / 100); -- Library expects scale (e.g., 1.0, 1.5)
        end
    end;
});
TabsUISettingsLeft:AddDivider()
local MenuKeyPicker = TabsUISettingsLeft:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "RightShift", NoUI = true, Text = "Menu keybind"});

-- Ensure the library's toggle keybind is linked to the option
Library.ToggleKeybind = Options.MenuKeybind;
Options.MenuKeybind:OnChanged(function(newValue)
    Library.ToggleKeybind = newValue
end)

TabsUISettingsLeft:AddButton("Unload Script", function()
    Library:Unload();
end);

-- Appearance & Saving Groupbox (Right side)
if ThemeManager and SaveManager then
     ThemeManager:ApplyToTab(Tabs.UISettings)
     SaveManager:BuildConfigSection(Tabs.UISettings)
     SaveManager:SetFolder("Remote Explorer Settings") -- Use a specific folder name
     SaveManager:IgnoreThemeSettings(); -- Don't save theme settings with config
     SaveManager:SetIgnoreIndexes({"MenuKeybind"}); -- Don't save the keybind itself, just its value
     SaveManager:LoadAutoloadConfig(); -- Load saved settings

     Notifications({
        Title = "Remote Explorer Loaded",
        Description = "Press '" .. tostring(Library.ToggleKeybind) .. "' to toggle menu visibility.",
        Time = 5
     })
else
    TabsUISettingsRight:AddLabel("Theme/Save Managers not loaded.")
    Notifications({
        Title = "Remote Explorer Loaded",
        Description = "Press RightShift (default) to toggle menu. Theme/Save managers failed.",
        Time = 6,
        Type = "Warning"
     })
end

-- Initial Scan on Load (Delayed)
task.spawn(function()
    task.wait(2) -- Wait a couple of seconds for game assets to load
    local scanButton = FilterGroupbox:FindFirstChild("Scan / Refresh Remotes") -- Find button by name
    if scanButton and scanButton.Func then
         Notifications({ Title = "Auto-Scan", Description = "Performing initial remote scan...", Time = 2})
         scanButton.Func() -- Call the button's function
    else
        warn("Could not find Scan button to trigger initial scan.")
        RemoteListLabel:SetText("Ready. Click 'Scan / Refresh Remotes'.")
         Notifications({ Title = "Ready", Description = "Click 'Scan / Refresh Remotes' to begin.", Time = 4, Type = "Warning"})
    end
end)
