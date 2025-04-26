-- [[ Existing Code Start ]] --
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
    Title = "Remote Explorer & Spy", -- Updated Title
    Footer = "Scanner/Spy by AI | GUI by s.eths / Obsidian",
    NotifySide = "Right",
    ShowCustomCursor = not isMobile,
})

local Tabs = {
    RemoteExplorer = Window:AddTab("Remote Explorer", "search"),
    RemoteSpy = Window:AddTab("Remote Spy", "eye"), -- New Tab
    UISettings = Window:AddTab("UI Settings", "settings"),
}

-- === Remote Explorer Tab Content (Mostly Unchanged) ===
local FilterGroupbox = Tabs.RemoteExplorer:AddLeftGroupbox("Filters")
local RemoteListGroupbox = Tabs.RemoteExplorer:AddRightGroupbox("Found Remotes")

local allRemotes = {}
local filteredRemotes = {}
local foundPaths = {}

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
        -- Also apply to spy filter if active
        if isSpying then updateSpyLogDisplay() end
    end
})

local onlyGameRemotes = FilterGroupbox:AddToggle("OnlyGameRemotes", {
    Text = "Only Game Remotes",
    Default = true,
    Callback = function(value)
        applyFilters()
        -- Also apply to spy filter if active
        if isSpying then updateSpyLogDisplay() end
    end
})

local showRemoteEvents = FilterGroupbox:AddToggle("ShowRemoteEvents", {
    Text = "Show RemoteEvents",
    Default = true,
    Callback = function(value)
        applyFilters()
        -- Also apply to spy filter if active
        if isSpying then updateSpyLogDisplay() end
    end
})

local showRemoteFunctions = FilterGroupbox:AddToggle("ShowRemoteFunctions", {
    Text = "Show RemoteFunctions",
    Default = true,
    Callback = function(value)
        applyFilters()
        -- Also apply to spy filter if active
        if isSpying then updateSpyLogDisplay() end
    end
})

local RemoteListLabel = RemoteListGroupbox:AddLabel("Click 'Scan Remotes' to start.")

local bgsKeywords = {"blow", "sell", "collect", "upgrade", "buy", "hatch", "equip",
                     "unequip", "teleport", "claim", "rebirth", "craft", "click", "autoclick",
                     "open", "reward", "interact", "network", "remote", "event", "pickup",
                     "bubble", "potion", "rift", "chest", "key", "quest", "market", "shop",
                     "redeem", "code", "gift", "wheel", "playtime"}

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
        return 0
    end
    RemoteListLabel:SetText("Scanning " .. containerName .. "...")
    local foundCount = 0
    local processedCount = 0
    local success, err = pcall(function()
        for _, instance in ipairs(container:GetDescendants()) do
            processedCount = processedCount + 1
            if addRemote(instance) then foundCount = foundCount + 1 end
            if processedCount % 500 == 0 then task.wait() end
        end
    end)
    if not success then
        warn("Error scanning " .. containerName .. ":", err)
        Notifications({ Title = "Scan Warning", Description = "Error scanning " .. containerName .. ". Error: " .. tostring(err), Type = "Warning", Time = 7 })
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
                     if remotePath then totalFound = totalFound + findRemotesIn(remotePath, containerName .. ".Framework.Network.Remote") task.wait(0.05)
                     else warn("Could not find Remote folder in BGS Framework path.") end
                 else warn("Could not find Network folder in BGS Framework path.") end
            elseif containerName == "ReplicatedStorage.Remotes" then
                 totalFound = totalFound + findRemotesIn(container, containerName) task.wait(0.05)
            end
        else warn("Could not find expected BGS container: " .. containerName) end
    end
    task.wait(0.1)
    RemoteListLabel:SetText("Scanning common locations...")
    local commonLocations = {
        {game:GetService("ReplicatedStorage"), "ReplicatedStorage (General)"},
        {game:GetService("Workspace"), "Workspace"},
        {game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"), "PlayerGui"},
        {game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts"), "PlayerScripts"},
        {game:GetService("StarterPlayer") and game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts"), "StarterPlayerScripts"},
        {game:GetService("StarterGui"), "StarterGui"}
    }
    for _, data in ipairs(commonLocations) do totalFound = totalFound + findRemotesIn(data[1], data[2]) task.wait(0.1) end
    RemoteListLabel:SetText("Performing deep scan (may take a moment)...")
    task.wait(0.1)
    local deepScanCount = 0
    local successDeep, errDeep = pcall(function()
        for _, instance in ipairs(game:GetDescendants()) do
            deepScanCount = deepScanCount + 1
            if addRemote(instance) then totalFound = totalFound + 1 end
            if deepScanCount % 500 == 0 then RemoteListLabel:SetText("Deep scan progress: " .. deepScanCount .. " instances checked...") task.wait() end
        end
    end)
     if not successDeep then warn("Error during deep scan:", errDeep) Notifications({ Title = "Scan Warning", Description = "Error during deep scan: " .. tostring(errDeep), Type = "Warning", Time = 7 }) end
    RemoteListLabel:SetText("Deep scan finished checking " .. deepScanCount .. " instances.")
    task.wait(0.1)
    RemoteListLabel:SetText("Searching by keywords...")
    task.wait(0.1)
    local keywordScanCount = 0
    local successKeywords, errKeywords = pcall(function()
        for _, instance in ipairs(game:GetDescendants()) do
             keywordScanCount = keywordScanCount + 1
             if (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then
                 local name = instance.Name:lower()
                 for _, keyword in ipairs(bgsKeywords) do
                     if name:match(keyword) then if addRemote(instance) then totalFound = totalFound + 1 end break end
                 end
             end
             if keywordScanCount % 500 == 0 then RemoteListLabel:SetText("Keyword scan progress: " .. keywordScanCount .. " instances checked...") task.wait() end
        end
    end)
    if not successKeywords then warn("Error during keyword scan:", errKeywords) Notifications({ Title = "Scan Warning", Description = "Error during keyword scan: " .. tostring(errKeywords), Type = "Warning", Time = 7 }) end
    RemoteListLabel:SetText("Keyword scan finished checking " .. keywordScanCount .. " instances.")
    task.wait(0.1)
    table.sort(allRemotes, function(a, b) return a.Path < b.Path end)
    RemoteListLabel:SetText("Scan complete. Found " .. #allRemotes .. " unique remotes.")
    return true
end

FilterGroupbox:AddButton({
    Text = "Scan / Refresh Remotes",
    Tooltip = "Scans the game for RemoteEvents and RemoteFunctions, prioritizing BGS paths.",
    Func = function()
        RemoteListLabel:SetText("Initiating scan...")
        task.spawn(function()
            local scanSuccess, scanError = pcall(performScan)
            if not scanSuccess then
                RemoteListLabel:SetText("Scan failed: " .. tostring(scanError))
                Notifications({ Title = "Scan Failed", Description = "An error occurred during scanning: " .. tostring(scanError), Time = 5, Type = "Error" })
                return
            end
            applyFilters()
            Notifications({ Title = "Scan Complete", Description = "Found " .. #allRemotes .. " total remotes. Displaying " .. #filteredRemotes .. " based on filters.", Time = 4 })
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
                Notifications({ Title = "Copied!", Description = #filteredRemotes .. " remotes copied to clipboard", Time = 3 })
            else
                Notifications({ Title = "Copy Failed", Description = "Your exploit does not support 'setclipboard'", Time = 4, Type = "Error" })
            end
        else
            Notifications({ Title = "Nothing to Copy", Description = "No remotes found or filtered", Time = 3, Type = "Warning" })
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
        if (remote.Type == "RemoteEvent" and not showEvents) or (remote.Type == "RemoteFunction" and not showFunctions) then include = false end
        if include and searchText ~= "" and not (remote.Name:lower():find(searchText) or remote.Path:lower():find(searchText)) then include = false end
        if include and excludeRoblox then
            local pathLower = remote.Path:lower()
            if pathLower:match("^instance%.robloxreplicatedstorage") or pathLower:match("^instance%.robloxgui") or pathLower:match("^instance%.coregui") or pathLower:match("^coregui") or pathLower:match("^robloxgui") or pathLower:match("^players%.player%.playergui%.robloxgui") then include = false end
        end
        if include and onlyGame then
             local pathLower = remote.Path:lower()
             if pathLower:match("^instance%.robloxreplicatedstorage") or pathLower:match("^instance%.coregui") or pathLower:match("^instance%.corescripts") or pathLower:match("^coregui") or pathLower:match("^robloxgui") or pathLower:match("^corescripts") or pathLower:match("^players%.player%.playergui%.robloxgui") then include = false end
        end
        if include then table.insert(filteredRemotes, remote) end
    end
    updateRemoteList()
end

function updateRemoteList()
    local listText
    if #filteredRemotes == 0 then
        if #allRemotes == 0 then listText = "No remotes found. Try scanning first."
        else listText = "No remotes match your filters (" .. #allRemotes .. " total found)." end
    else
        listText = "Found " .. #filteredRemotes .. " / " .. #allRemotes .. " Remotes:\n\n"
        for i, remote in ipairs(filteredRemotes) do
            listText = listText .. i .. ". [" .. remote.Type:sub(1, 6) .. "] " .. remote.Name .. "\n   Path: " .. remote.Path .. "\n"
            if i > 250 then listText = listText .. "\n... (" .. (#filteredRemotes - i) .. " more - list truncated for performance) ..." break end
        end
    end
    RemoteListLabel:SetText(listText)
end

-- === Remote Spy Tab Content ===
local SpyControlGroupbox = Tabs.RemoteSpy:AddLeftGroupbox("Spy Controls")
local SpyLogGroupbox = Tabs.RemoteSpy:AddRightGroupbox("Logged Calls")

local loggedCalls = {}
local isSpying = false
local original_namecall
local namecallHooked = false
local MAX_LOG_ENTRIES = 150 -- Limit log size

local SpyLogLabel = SpyLogGroupbox:AddLabel("Spying is stopped.")

-- Function to format arguments for display
local function formatArgs(...)
    local args = {...}
    local formatted = {}
    for i, v in ipairs(args) do
        local t = type(v)
        if t == "string" then
            table.insert(formatted, '"' .. tostring(v):gsub('"', '\\"') .. '"') -- Enclose strings in quotes, escape inner quotes
        elseif t == "table" then
            -- Basic table representation, could be expanded for deeper inspection
            table.insert(formatted, tostring(v) .. " (table)")
        elseif t == "Instance" then
             table.insert(formatted, tostring(v) .. " [" .. v.ClassName .. "]")
        else
            table.insert(formatted, tostring(v))
        end
    end
    return table.concat(formatted, ", ")
end

-- Function to update the spy log display
function updateSpyLogDisplay()
    local displayText = "Logged Calls (" .. #loggedCalls .. "):\n\n"
    local displayCount = 0

    -- Iterate backwards to show newest first
    for i = #loggedCalls, 1, -1 do
        local call = loggedCalls[i]
        local include = true
        local pathLower = call.Path:lower()

        -- Apply filters similar to the scanner
        if (call.Type == "RemoteEvent" and not Toggles.ShowRemoteEvents.Value) or
           (call.Type == "RemoteFunction" and not Toggles.ShowRemoteFunctions.Value) then
            include = false
        end

        if include and Toggles.ExcludeRobloxRemotes.Value then
             if pathLower:match("^instance%.robloxreplicatedstorage") or pathLower:match("^instance%.robloxgui") or pathLower:match("^instance%.coregui") or pathLower:match("^coregui") or pathLower:match("^robloxgui") or pathLower:match("^players%.player%.playergui%.robloxgui") then include = false end
        end
        if include and Toggles.OnlyGameRemotes.Value then
             if pathLower:match("^instance%.robloxreplicatedstorage") or pathLower:match("^instance%.coregui") or pathLower:match("^instance%.corescripts") or pathLower:match("^coregui") or pathLower:match("^robloxgui") or pathLower:match("^corescripts") or pathLower:match("^players%.player%.playergui%.robloxgui") then include = false end
        end

        if include then
            displayCount = displayCount + 1
            displayText = displayText .. displayCount .. ". [" .. call.Type:sub(1,6) .. "] " .. call.Path .. "\n   Args: " .. call.Args .. "\n   Time: " .. call.Timestamp .. "\n"
            if displayCount >= 50 then -- Limit displayed entries for performance
                 displayText = displayText .. "\n... (display truncated, " .. (#loggedCalls - i + 1) .. " total logged matching filters) ..."
                 break
            end
        end
    end

    if displayCount == 0 and #loggedCalls > 0 then
        displayText = "No logged calls match current filters (" .. #loggedCalls .. " total logged)."
    elseif #loggedCalls == 0 then
         displayText = isSpying and "Spying active... Waiting for calls..." or "Spying is stopped."
    end

    SpyLogLabel:SetText(displayText)
end

-- The replacement __namecall function
local function hooked_namecall(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if isSpying and (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        local path = self:GetFullName()
        local callData = {
            Type = self.ClassName,
            Path = path,
            Args = formatArgs(unpack(args)),
            Timestamp = os.date("%H:%M:%S")
        }

        table.insert(loggedCalls, 1, callData) -- Insert at the beginning for newest first

        -- Limit the log size
        if #loggedCalls > MAX_LOG_ENTRIES then
            table.remove(loggedCalls, #loggedCalls) -- Remove the oldest entry
        end

        -- Update the display (consider debouncing this if performance is an issue)
        task.spawn(updateSpyLogDisplay)
    end

    -- Crucially, call the original function so the remote actually fires/invokes
    -- Use assert to ensure original_namecall is valid before calling
    assert(original_namecall, "Original __namecall method not found or invalid!")
    return original_namecall(self, ...)
end

-- Button to Start/Stop Spying
local spyToggleButton
spyToggleButton = SpyControlGroupbox:AddButton({
    Text = "Start Spying",
    Tooltip = "Starts capturing RemoteEvent/Function calls.",
    Func = function()
        if isSpying then
            -- Stop Spying
            if namecallHooked and original_namecall then
                local success, err = pcall(function()
                    setnamecallmethod(original_namecall)
                end)
                if success then
                    isSpying = false
                    namecallHooked = false
                    spyToggleButton:SetText("Start Spying")
                    spyToggleButton:SetTooltip("Starts capturing RemoteEvent/Function calls.")
                    SpyLogLabel:SetText("Spying stopped. " .. #loggedCalls .. " calls logged.")
                    Notifications({ Title = "Spy Stopped", Description = "Remote call logging disabled.", Time = 3 })
                else
                    warn("Failed to restore original __namecall:", err)
                    Notifications({ Title = "Spy Error", Description = "Failed to stop spying cleanly.", Time = 4, Type = "Error" })
                end
            else
                 isSpying = false -- Force stop even if hook state is weird
                 spyToggleButton:SetText("Start Spying")
                 SpyLogLabel:SetText("Spying stopped (hook state uncertain).")
                 warn("Attempted to stop spying, but hook state was unexpected.")
            end
        else
            -- Start Spying
            if not namecallHooked then
                local success, err = pcall(function()
                    original_namecall = getnamecallmethod() -- Store the original
                    setnamecallmethod(hooked_namecall) -- Set our hook
                end)
                if success then
                    isSpying = true
                    namecallHooked = true
                    spyToggleButton:SetText("Stop Spying")
                    spyToggleButton:SetTooltip("Stops capturing RemoteEvent/Function calls.")
                    SpyLogLabel:SetText("Spying active... Waiting for calls...")
                    Notifications({ Title = "Spy Started", Description = "Logging RemoteEvent/Function calls.", Time = 3 })
                else
                    warn("Failed to hook __namecall:", err)
                    Notifications({ Title = "Spy Error", Description = "Failed to start spying. Hook failed.", Time = 4, Type = "Error" })
                    isSpying = false
                    namecallHooked = false -- Ensure state is correct on failure
                end
            else
                -- Already hooked but wasn't spying? Just enable spying flag.
                isSpying = true
                spyToggleButton:SetText("Stop Spying")
                SpyLogLabel:SetText("Spying active... Waiting for calls...")
                Notifications({ Title = "Spy Resumed", Description = "Logging RemoteEvent/Function calls.", Time = 3 })
            end
        end
    end
})

-- Button to Clear Log
SpyControlGroupbox:AddButton({
    Text = "Clear Log",
    Tooltip = "Clears the captured remote call log.",
    Func = function()
        loggedCalls = {}
        updateSpyLogDisplay()
        Notifications({ Title = "Log Cleared", Description = "Remote spy log has been cleared.", Time = 2 })
    end
})

-- Add a divider
SpyControlGroupbox:AddDivider()

-- Add info label about filters
SpyControlGroupbox:AddLabel("Spy log uses filters from the 'Remote Explorer' tab.")


-- === UI Settings Tab Content (Copied from previous context) ===
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
    -- Attempt to unhook namecall cleanly before unloading
    if namecallHooked and original_namecall then
        pcall(setnamecallmethod, original_namecall)
    end
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
        Title = "Remote Explorer/Spy Loaded",
        Description = "Press '" .. tostring(Library.ToggleKeybind) .. "' to toggle menu visibility.",
        Time = 5
     })
else
    TabsUISettingsRight:AddLabel("Theme/Save Managers not loaded.")
     Notifications({
        Title = "Remote Explorer/Spy Loaded",
        Description = "Press RightShift (default) to toggle menu. Theme/Save managers failed.",
        Time = 6,
        Type = "Warning"
     })
end

-- Initial Scan on Load (Delayed)
task.spawn(function()
    task.wait(2)
    local scanButton = FilterGroupbox:FindFirstChild("Scan / Refresh Remotes")
    if scanButton and scanButton.Func then
         Notifications({ Title = "Auto-Scan", Description = "Performing initial remote scan...", Time = 2})
         scanButton.Func()
    else
        warn("Could not find Scan button to trigger initial scan.")
        RemoteListLabel:SetText("Ready. Click 'Scan / Refresh Remotes'.")
         Notifications({ Title = "Ready", Description = "Click 'Scan / Refresh Remotes' to begin.", Time = 4, Type = "Warning"})
    end
end)

-- Ensure namecall is restored if the script errors or is stopped abruptly (best effort)
local connection
connection = game:GetService("RunService").Stepped:Connect(function()
    -- A simple check; more robust cleanup might be needed depending on the exploit environment
    if not Library or not Library.Loaded then
        if namecallHooked and original_namecall then
             pcall(setnamecallmethod, original_namecall)
             warn("Script unloaded/stopped, attempted to restore __namecall.")
        end
        if connection then connection:Disconnect() end
    end
end)
