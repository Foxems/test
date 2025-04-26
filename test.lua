-- NOTE: This script requires a working Roblox exploit executor
--       and is designed for Bubble Gum Simulator with enhanced remote exploration

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
    Title = "Bubble Gum Sim Explorer",
    Footer = "Remote Scanner Pro | GUI by s.eths / Obsidian",
    NotifySide = "Right",
    ShowCustomCursor = not isMobile, -- Disable custom cursor on mobile
    MinSize = isMobile and Vector2.new(400, 450) or Vector2.new(600, 650), -- Smaller on mobile
})

-- === Define Tabs ===
local Tabs = {
    RemoteExplorer = Window:AddTab("Remote Explorer", "search"),
    RemoteLogger = Window:AddTab("Remote Logger", "activity"),
    FireTests = Window:AddTab("Fire Remotes", "zap"),
    AutoFarm = Window:AddTab("Auto Farm", "repeat"),
    UISettings = Window:AddTab("UI Settings", "settings"),
}

-- === Utility Functions ===
local function shortenPath(path)
    -- Shorten path for display while keeping important parts
    local parts = path:split(".")
    if #parts <= 3 then return path end
    
    -- Always show the first two and last two parts
    return parts[1] .. "." .. parts[2] .. "..." .. parts[#parts-1] .. "." .. parts[#parts]
end

local function formatRemoteInfo(remote)
    return {
        Type = remote.ClassName,
        Name = remote.Name,
        Path = remote:GetFullName(),
        ShortPath = shortenPath(remote:GetFullName()),
        Instance = remote
    }
end

-- Global storage for found remotes
local foundRemotes = {}
local filteredRemotes = {}
local selectedRemote = nil
local remoteListeners = {}
local isLogging = false

-- === Remote Explorer Tab Content ===
local FilterGroupbox = Tabs.RemoteExplorer:AddLeftGroupbox("Filters")
local RemoteListGroupbox = Tabs.RemoteExplorer:AddRightGroupbox("Found Remotes")
local RemoteDetailsGroupbox = Tabs.RemoteExplorer:AddLeftGroupbox("Remote Details")

-- Filter options
FilterGroupbox:AddInput("SearchFilter", {
    Text = "Search Remotes",
    Placeholder = "Enter name or path...",
    Callback = function(text)
        if text == "" then
            filteredRemotes = foundRemotes
        else
            text = text:lower()
            filteredRemotes = {}
            for _, remote in ipairs(foundRemotes) do
                if remote.Name:lower():find(text) or remote.Path:lower():find(text) then
                    table.insert(filteredRemotes, remote)
                end
            end
        end
        updateRemoteListDisplay()
    end
})

-- Exclude Roblox system remotes by default
local excludeRobloxRemotes = FilterGroupbox:AddToggle("ExcludeRobloxRemotes", {
    Text = "Exclude Roblox System Remotes",
    Default = true,
    Callback = function(value)
        updateFilters()
    end
})

-- Only show game-specific remotes
local onlyGameRemotes = FilterGroupbox:AddToggle("OnlyGameRemotes", {
    Text = "Only Game Remotes",
    Default = true, 
    Callback = function(value)
        updateFilters()
    end
})

-- Filter by remote type
local showRemoteEvents = FilterGroupbox:AddToggle("ShowRemoteEvents", {
    Text = "Show RemoteEvents",
    Default = true,
    Callback = function(value)
        updateFilters()
    end
})

local showRemoteFunctions = FilterGroupbox:AddToggle("ShowRemoteFunctions", {
    Text = "Show RemoteFunctions",
    Default = true,
    Callback = function(value)
        updateFilters()
    end
})

-- Deep scan toggle - look for remotes in player scripts and local scripts
local deepScan = FilterGroupbox:AddToggle("DeepScan", {
    Text = "Deep Scan (Player/Local Scripts)",
    Default = false,
})

-- Remote list with scrolling
-- We'll use buttons as list items
local remoteListItems = {}
local listHeight = isMobile and 300 or 400

-- Function to update filters
function updateFilters()
    local searchText = Options.SearchFilter.Value:lower()
    local excludeRoblox = Toggles.ExcludeRobloxRemotes.Value
    local onlyGame = Toggles.OnlyGameRemotes.Value
    local showEvents = Toggles.ShowRemoteEvents.Value
    local showFunctions = Toggles.ShowRemoteFunctions.Value
    
    filteredRemotes = {}
    
    for _, remote in ipairs(foundRemotes) do
        local include = true
        
        -- Filter by type
        if (remote.Type == "RemoteEvent" and not showEvents) or
           (remote.Type == "RemoteFunction" and not showFunctions) then
            include = false
        end
        
        -- Filter by name/path
        if searchText ~= "" and not (remote.Name:lower():find(searchText) or remote.Path:lower():find(searchText)) then
            include = false
        end
        
        -- Exclude Roblox system remotes
        if excludeRoblox and remote.Path:match("^RobloxReplicatedStorage") then
            include = false
        end
        
        -- Only game remotes (not in RobloxReplicatedStorage and not in CoreGui/CoreScripts)
        if onlyGame and (
            remote.Path:match("^RobloxReplicatedStorage") or
            remote.Path:match("^CoreGui") or
            remote.Path:match("^CoreScripts")
        ) then
            include = false
        end
        
        if include then
            table.insert(filteredRemotes, remote)
        end
    end
    
    updateRemoteListDisplay()
end

-- Function to update the remote list display
function updateRemoteListDisplay()
    -- Clear existing buttons
    for _, item in ipairs(remoteListItems) do
        item:Destroy()
    end
    remoteListItems = {}
    
    -- Add status label
    local statusText = #filteredRemotes .. " / " .. #foundRemotes .. " Remotes"
    if #filteredRemotes == 0 then
        statusText = statusText .. " (No remotes match filters)"
    end
    
    RemoteListGroupbox:AddLabel(statusText)
    
    -- Create buttons for each remote (limited to avoid lag)
    local maxDisplay = math.min(100, #filteredRemotes)
    for i = 1, maxDisplay do
        local remote = filteredRemotes[i]
        local buttonText = "[" .. remote.Type:sub(7,7) .. "] " .. remote.Name
        
        local button = RemoteListGroupbox:AddButton({
            Text = buttonText,
            Tooltip = remote.Path,
            Func = function()
                selectedRemote = remote
                updateRemoteDetails()
            end
        })
        
        table.insert(remoteListItems, button)
    end
    
    if #filteredRemotes > maxDisplay then
        RemoteListGroupbox:AddLabel("... and " .. (#filteredRemotes - maxDisplay) .. " more (use search to narrow results)")
    end
end

-- Function to update the remote details panel
function updateRemoteDetails()
    RemoteDetailsGroupbox:ClearChildren()
    
    if not selectedRemote then
        RemoteDetailsGroupbox:AddLabel("Select a remote to view details")
        return
    end
    
    RemoteDetailsGroupbox:AddLabel("Selected Remote:")
    RemoteDetailsGroupbox:AddLabel(selectedRemote.Name)
    RemoteDetailsGroupbox:AddLabel("Type: " .. selectedRemote.Type)
    
    local pathLabel = RemoteDetailsGroupbox:AddLabel("Path:")
    pathLabel:SetText(selectedRemote.Path)
    
    RemoteDetailsGroupbox:AddDivider()
    
    -- Add button to copy path
    RemoteDetailsGroupbox:AddButton({
        Text = "Copy Path",
        Func = function()
            if setclipboard then
                setclipboard(selectedRemote.Path)
                Notifications({
                    Title = "Copied!",
                    Description = "Path copied to clipboard",
                    Time = 2
                })
            else
                Notifications({
                    Title = "Error",
                    Description = "setclipboard not supported",
                    Time = 2,
                    Type = "Error"
                })
            end
        end
    })
    
    -- Add button to copy Lua reference
    RemoteDetailsGroupbox:AddButton({
        Text = "Copy Lua Reference",
        Func = function()
            if setclipboard then
                setclipboard("game:GetService(\"" .. selectedRemote.Path:match("^([^.]+)") .. "\")." .. selectedRemote.Path:match("^[^.]+.(.+)"))
                Notifications({
                    Title = "Copied!",
                    Description = "Lua reference copied to clipboard",
                    Time = 2
                })
            end
        end
    })
    
    -- Add button to test fire (if it's a RemoteEvent)
    if selectedRemote.Type == "RemoteEvent" then
        RemoteDetailsGroupbox:AddButton({
            Text = "Monitor This Remote",
            Func = function()
                toggleRemoteLogging(selectedRemote)
            end
        })
        
        RemoteDetailsGroupbox:AddButton({
            Text = "Test Fire (No Args)",
            Func = function()
                local remote = selectedRemote.Instance
                local success, err = pcall(function()
                    remote:FireServer()
                end)
                
                if success then
                    Notifications({
                        Title = "Remote Fired",
                        Description = selectedRemote.Name .. " fired successfully",
                        Time = 2
                    })
                else
                    Notifications({
                        Title = "Error",
                        Description = "Failed to fire remote: " .. tostring(err),
                        Time = 3,
                        Type = "Error"
                    })
                end
            end
        })
    end
    
    -- Add button to test call (if it's a RemoteFunction)
    if selectedRemote.Type == "RemoteFunction" then
        RemoteDetailsGroupbox:AddButton({
            Text = "Test Call (No Args)",
            Func = function()
                local remote = selectedRemote.Instance
                local success, result = pcall(function()
                    return remote:InvokeServer()
                end)
                
                if success then
                    Notifications({
                        Title = "Remote Called",
                        Description = "Result: " .. tostring(result),
                        Time = 3
                    })
                else
                    Notifications({
                        Title = "Error",
                        Description = "Failed to call remote: " .. tostring(result),
                        Time = 3,
                        Type = "Error"
                    })
                end
            end
        })
    end
end

-- Function to toggle logging for a specific remote
function toggleRemoteLogging(remote)
    local path = remote.Path
    
    if remoteListeners[path] then
        remoteListeners[path]:Disconnect()
        remoteListeners[path] = nil
        Notifications({
            Title = "Logging Stopped",
            Description = "No longer monitoring " .. remote.Name,
            Time = 2
        })
        return
    end
    
    Notifications({
        Title = "Logging Started",
        Description = "Now monitoring " .. remote.Name,
        Time = 2
    })
    
    local instance = remote.Instance
    
    if remote.Type == "RemoteEvent" then
        remoteListeners[path] = instance.OnClientEvent:Connect(function(...)
            local args = {...}
            local argStr = ""
            
            -- Convert args to string representation
            for i, arg in ipairs(args) do
                local argType = typeof(arg)
                if argType == "table" then
                    argStr = argStr .. "table[" .. (table.getn(arg) or 0) .. "], "
                else
                    argStr = argStr .. tostring(arg) .. ", "
                end
            end
            
            if argStr ~= "" then
                argStr = argStr:sub(1, -3) -- Remove trailing comma and space
            end
            
            addLogEntry(remote.Name, remote.Path, "Event", argStr)
        end)
    elseif remote.Type == "RemoteFunction" then
        -- For RemoteFunction we need to use hookfunction which may not be available in all exploits
        if hookfunction then
            local oldInvoke = instance.InvokeClient
            remoteListeners[path] = true -- Just mark that we're listening
            
            hookfunction(instance.InvokeClient, function(self, player, ...)
                local args = {...}
                local argStr = ""
                
                for i, arg in ipairs(args) do
                    argStr = argStr .. tostring(arg) .. ", "
                end
                
                if argStr ~= "" then
                    argStr = argStr:sub(1, -3)
                end
                
                addLogEntry(remote.Name, remote.Path, "Function Call", argStr)
                return oldInvoke(self, player, ...)
            end)
        else
            Notifications({
                Title = "Not Supported",
                Description = "Your exploit doesn't support hooking RemoteFunctions",
                Time = 3,
                Type = "Error"
            })
        end
    end
end

-- === Remote Logger Tab ===
local LoggerControls = Tabs.RemoteLogger:AddLeftGroupbox("Logger Controls")
local LogDisplay = Tabs.RemoteLogger:AddRightGroupbox("Remote Logs")

local logEntries = {}
local maxLogs = 100
local autoScroll = true

LoggerControls:AddToggle("EnableLogging", {
    Text = "Enable Remote Logging",
    Default = false,
    Callback = function(value)
        isLogging = value
        if value then
            startGlobalRemoteLogging()
        else
            stopGlobalRemoteLogging()
        end
    end
})

LoggerControls:AddToggle("AutoScroll", {
    Text = "Auto-Scroll Logs",
    Default = true,
    Callback = function(value)
        autoScroll = value
    end
})

LoggerControls:AddButton({
    Text = "Clear Logs",
    Func = function()
        logEntries = {}
        updateLogDisplay()
    end
})

LoggerControls:AddButton({
    Text = "Copy All Logs",
    Func = function()
        if not setclipboard then
            Notifications({
                Title = "Error",
                Description = "Your exploit doesn't support clipboard functions",
                Time = 3,
                Type = "Error"
            })
            return
        end
        
        local logText = ""
        for _, entry in ipairs(logEntries) do
            logText = logText .. entry.time .. " | " .. entry.type .. " | " .. entry.name .. " | " .. entry.args .. "\n"
        end
        
        setclipboard(logText)
        Notifications({
            Title = "Copied",
            Description = "Logs copied to clipboard",
            Time = 2
        })
    end
})

-- Function to add a log entry
function addLogEntry(name, path, type, args)
    local time = os.date("%H:%M:%S")
    table.insert(logEntries, {
        time = time,
        name = name,
        path = path,
        type = type,
        args = args or "None"
    })
    
    -- Trim logs if they exceed max
    if #logEntries > maxLogs then
        table.remove(logEntries, 1)
    end
    
    updateLogDisplay()
end

-- Function to update the log display
function updateLogDisplay()
    LogDisplay:ClearChildren()
    
    if #logEntries == 0 then
        LogDisplay:AddLabel("No remote activity logged yet")
        return
    end
    
    -- Display logs (most recent first)
    for i = #logEntries, 1, -1 do
        local entry = logEntries[i]
        local logText = entry.time .. " | " .. entry.type .. " | " .. entry.name
        
        local logLabel = LogDisplay:AddLabel(logText)
        local argsLabel = LogDisplay:AddLabel("   Args: " .. entry.args)
        
        -- Add divider between log entries
        if i > 1 then
            LogDisplay:AddDivider()
        end
    end
end

-- Functions to start/stop global remote logging
function startGlobalRemoteLogging()
    stopGlobalRemoteLogging() -- Clear any existing hooks
    
    -- Log all RemoteEvent firings
    for _, remote in ipairs(foundRemotes) do
        if remote.Type == "RemoteEvent" and not remoteListeners[remote.Path] then
            local instance = remote.Instance
            remoteListeners[remote.Path] = instance.OnClientEvent:Connect(function(...)
                if not isLogging then return end
                
                local args = {...}
                local argStr = ""
                
                for i, arg in ipairs(args) do
                    local argType = typeof(arg)
                    if argType == "table" then
                        argStr = argStr .. "table[" .. (table.getn(arg) or 0) .. "], "
                    else
                        argStr = argStr .. tostring(arg) .. ", "
                    end
                end
                
                if argStr ~= "" then
                    argStr = argStr:sub(1, -3)
                end
                
                addLogEntry(remote.Name, remote.Path, "Event", argStr)
            end)
        end
    end
    
    Notifications({
        Title = "Logger Enabled",
        Description = "Monitoring all remote events",
        Time = 2
    })
end

function stopGlobalRemoteLogging()
    for path, connection in pairs(remoteListeners) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    remoteListeners = {}
    
    Notifications({
        Title = "Logger Disabled",
        Description = "Stopped monitoring remotes",
        Time = 2
    })
end

-- === Scan Button & Functionality ===
FilterGroupbox:AddButton({
    Text = "Scan / Refresh Remotes",
    Tooltip = "Scan the game for RemoteEvents and RemoteFunctions",
    Func = function()
        foundRemotes = {}
        
        -- Show scanning notification
        Notifications({
            Title = "Scanning...",
            Description = "Searching for remotes",
            Time = 2
        })
        
        task.spawn(function()
            -- Scan for remotes
            for _, instance in ipairs(game:GetDescendants()) do
                if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                    table.insert(foundRemotes, formatRemoteInfo(instance))
                end
            end
            
            -- If deep scan is enabled, look for hidden remotes
            if Toggles.DeepScan.Value then
                -- Additional scanning logic for finding hidden remotes
                local hidden = scanForHiddenRemotes()
                for _, remote in ipairs(hidden) do
                    table.insert(foundRemotes, remote)
                end
            end
            
            -- Sort remotes by path for easier browsing
            table.sort(foundRemotes, function(a, b)
                return a.Path < b.Path
            end)
            
            -- Update the interface
            updateFilters()
            
            Notifications({
                Title = "Scan Complete",
                Description = "Found " .. #foundRemotes .. " remotes",
                Time = 3
            })
        end)
    end
})

FilterGroupbox:AddButton({
    Text = "Advanced Scan for Bubble Gum Sim",
    Tooltip = "Specialized scan for Bubble Gum Simulator remotes",
    Func = function()
        Notifications({
            Title = "Specialized Scan",
            Description = "Scanning for Bubble Gum Simulator remotes...",
            Time = 3
        })
        
        task.spawn(function()
            local gameRemotes = scanForBubbleGumSimRemotes()
            
            if #gameRemotes > 0 then
                -- Add these to our foundRemotes collection
                for _, remote in ipairs(gameRemotes) do
                    table.insert(foundRemotes, remote)
                end
                
                -- Sort and update
                table.sort(foundRemotes, function(a, b)
                    return a.Path < b.Path
                end)
                
                updateFilters()
                
                Notifications({
                    Title = "Game Scan Complete",
                    Description = "Found " .. #gameRemotes .. " game-specific remotes",
                    Time = 3
                })
            else
                Notifications({
                    Title = "Scan Result",
                    Description = "No additional game-specific remotes found",
                    Time = 3
                })
            end
        end)
    end
})

-- Function to scan for Bubble Gum Simulator specific remotes
function scanForBubbleGumSimRemotes()
    local gameRemotes = {}
    
    -- Check common locations where Bubble Gum Simulator stores remotes
    local targetContainers = {
        game:GetService("ReplicatedStorage").Events,
        game:GetService("ReplicatedStorage").Remotes,
        game:GetService("ReplicatedStorage").Network,
        game:GetService("ReplicatedStorage").Modules
    }
    
    -- Check key methods that might contain remotes
    local keyMethods = {
        "blow", "sell", "collect", "upgrade", "buy", "hatch", "equip", 
        "unequip", "teleport", "claim", "rebirth", "craft"
    }
    
    -- Scan each container
    for _, container in pairs(targetContainers) do
        if typeof(container) == "Instance" then
            for _, instance in pairs(container:GetDescendants()) do
                if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                    table.insert(gameRemotes, formatRemoteInfo(instance))
                end
            end
        end
    end
    
    -- Look for specific remotes by name pattern
    for _, instance in pairs(game:GetDescendants()) do
        if (instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction")) then
            local name = instance.Name:lower()
            for _, method in ipairs(keyMethods) do
                if name:match(method) then
                    table.insert(gameRemotes, formatRemoteInfo(instance))
                    break
                end
            end
        end
    end
    
    return gameRemotes
end

-- Function to scan for hidden remotes
function scanForHiddenRemotes()
    local hiddenRemotes = {}
    
    -- Specifically look in player scripts
    local ps = game:GetService("Players").LocalPlayer.PlayerScripts
    if ps then
        for _, script in pairs(ps:GetDescendants()) do
            if script:IsA("LocalScript") then
                -- We can't directly access LocalScript contents, but we can check for children
                for _, child in pairs(script:GetChildren()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        table.insert(hiddenRemotes, formatRemoteInfo(child))
                    end
                end
            end
        end
    end
    
    return hiddenRemotes
end

-- === Fire Remotes Tab ===
local FireControlsBox = Tabs.FireTests:AddLeftGroupbox("Fire Controls")
local CommonRemotesBox = Tabs.FireTests:AddRightGroupbox("Common Bubble Gum Sim Remotes")

FireControlsBox:AddLabel("Test Common Bubble Gum Simulator Functions")

FireControlsBox:AddButton({
    Text = "Auto-Detect Game Remotes",
    Func = function()
        task.spawn(function()
            CommonRemotesBox:ClearChildren()
            CommonRemotesBox:AddLabel("Scanning for game remotes...")
            
            local gameRemotes = scanForBubbleGumSimRemotes()
            
            if #gameRemotes == 0 then
                CommonRemotesBox:ClearChildren()
                CommonRemotesBox:AddLabel("No game-specific remotes found")
                return
            end
            
            CommonRemotesBox:ClearChildren()
            CommonRemotesBox:AddLabel("Found " .. #gameRemotes .. " game remotes")
            
            -- Add buttons for each remote
            for _, remote in ipairs(gameRemotes) do
                CommonRemotesBox:AddButton({
                    Text = remote.Name,
                    Tooltip = remote.Path,
                    Func = function()
                        if remote.Type == "RemoteEvent" then
                            local success, err = pcall(function()
                                remote.Instance:FireServer()
                            end)
                            
                            if success then
                                Notifications({
                                    Title = "Remote Fired",
                                    Description = remote.Name .. " fired successfully",
                                    Time = 2
                                })
                            else
                                Notifications({
                                    Title = "Error",
                                    Description = "Failed: " .. tostring(err),
                                    Time = 3,
                                    Type = "Error"
                                })
                            end
                        else
                            local success, result = pcall(function()
                                return remote.Instance:InvokeServer()
                            end)
                            
                            if success then
                                Notifications({
                                    Title = "Remote Called",
                                    Description = "Result: " .. tostring(result),
                                    Time = 3
                                })
                            else
                                Notifications({
                                    Title = "Error",
                                    Description = "Failed: " .. tostring(result),
                                    Time = 3,
                                    Type = "Error"
                                })
                            end
                        end
                    end
                })
            end
        end)
    end
})

-- Common actions for Bubble Gum Simulator
local commonActions = {
    {name = "Blow Bubble", func = function() fireRemoteByPattern("blow") end},
    {name = "Sell Bubbles", func = function() fireRemoteByPattern("sell") end},
    {name = "Collect Coins", func = function() fireRemoteByPattern("collect") end},
    {name = "Open Egg", func = function() fireRemoteByPattern("hatch|open|egg") end},
}

-- Add common action buttons
for _, action in ipairs(commonActions) do
    FireControlsBox:AddButton({
        Text = action.name,
        Func = action.func
    })
end

-- Function to find and fire a remote by pattern
function fireRemoteByPattern(pattern)
    local found = false
    
    for _, remote in ipairs(foundRemotes) do
        if remote.Name:lower():match(pattern) and remote.Type == "RemoteEvent" then
            found = true
            
            local success, err = pcall(function()
                remote.Instance:FireServer()
            end)
            
            if success then
                Notifications({
                    Title = "Action Performed",
                    Description = "Fired remote: " .. remote.Name,
                    Time = 2
                })
            else
                Notifications({
                    Title = "Error",
                    Description = "Failed to fire " .. remote.Name .. ": " .. tostring(err),
                    Time = 3,
                    Type = "Error"
                })
            end
        end
    end
    
    if not found then
        Notifications({
            Title = "No Matching Remote",
            Description = "Couldn't find a remote matching: " .. pattern,
            Time = 3,
            Type = "Warning"
        })
    end
end

-- === Auto Farm Tab ===
local AutoFarmBox = Tabs.AutoFarm:AddLeftGroupbox("Auto Farm Settings")
local AutoFarmStatus = Tabs.AutoFarm:AddRightGroupbox("Status")

-- Auto farm toggles
local autoBlowEnabled = false
local autoSellEnabled = false
local autoCollectEnabled = false

AutoFarmBox:AddToggle("AutoBlow", {
    Text = "Auto Blow Bubbles",
    Default = false,
    Callback = function(value)
        autoBlowEnabled = value
        updateAutoFarmStatus()
    end
})

AutoFarmBox:AddToggle("AutoSell", {
    Text = "Auto Sell Bubbles",
    Default = false,
    Callback = function(value)
        autoSellEnabled = value
        updateAutoFarmStatus()
    end
})

AutoFarmBox:AddToggle("AutoCollect", {
    Text = "Auto Collect Items",
    Default = false,
    Callback = function(value)
        autoCollectEnabled = value
        updateAutoFarmStatus()
    end
})

AutoFarmBox:AddSlider("BlowDelay", {
    Text = "Blow Delay (ms)",
    Min = 100,
    Max = 2000,
    Default = 500,
    Rounding = 0,
})

AutoFarmStatus:AddLabel("Auto Farm Status: Inactive")
local statusLabel = AutoFarmStatus:AddLabel("No actions running")

-- Auto farm functionality
function updateAutoFarmStatus()
    local status = "Auto Farm Status: "
    if autoBlowEnabled or autoSellEnabled or autoCollectEnabled then
        status = status .. "Active"
        
        local actions = {}
        if autoBlowEnabled then table.insert(actions, "Blowing") end
        if autoSellEnabled then table.insert(actions, "Selling") end
        if autoCollectEnabled then table.insert(actions, "Collecting") end
        
        statusLabel:SetText(table.concat(actions, ", ") .. " active")
        
        -- Start the auto farm loop if not already running
        if not getgenv().autoFarmRunning then
            startAutoFarm()
        end
    else
        status = status .. "Inactive"
        statusLabel:SetText("No actions running")
        
        -- Stop the auto farm loop
        getgenv().autoFarmRunning = false
    end
    
    -- Update the status label
    AutoFarmStatus:FindFirstChild("Auto Farm Status: Inactive").Text = status
end

function startAutoFarm()
    getgenv().autoFarmRunning = true
    
    task.spawn(function()
        while getgenv().autoFarmRunning and wait(Options.BlowDelay.Value / 1000) do
            if not (autoBlowEnabled or autoSellEnabled or autoCollectEnabled) then
                getgenv().autoFarmRunning = false
                break
            end
            
            if autoBlowEnabled then
                fireRemoteByPattern("blow")
            end
            
            if autoSellEnabled and wait(0.5) then
                fireRemoteByPattern("sell")
            end
            
            if autoCollectEnabled and wait(0.5) then
                fireRemoteByPattern("collect")
            end
        end
    end)
end

-- === UI Settings Tab ===
-- Similar to original script

-- === Initial Scan on Load ===
task.spawn(function()
    task.wait(1) -- Wait a bit for the game to load
    FilterGroupbox:FindFirstChild("Scan / Refresh Remotes").Func()
end)

-- Set keybind
Library.ToggleKeybind = Options.MenuKeybind

-- Final notification
Notifications({
    Title = "Remote Explorer Loaded",
    Description = "Press RightShift to toggle the UI",
    Time = 5
})
