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
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

local Window = Library:CreateWindow({
    Title = "Auto Farm",
    Footer = "GUI by s.eths / Obsidian",
    NotifySide = "Right",
    ShowCustomCursor = not isMobile,
})

local Tabs = {
    AutoFarm = Window:AddTab("Auto Farm", "play"),
    UISettings = Window:AddTab("UI Settings", "settings"),
}

-- === Auto Farm Tab Content ===
local AutoFarmGroupbox = Tabs.AutoFarm:AddLeftGroupbox("Farming Options")

local autoCollectActive = false
local autoBubbleActive = false
local autoSellActive = false

local collectRemote = ReplicatedStorage:FindFirstChild("Remotes", true) and ReplicatedStorage.Remotes:FindFirstChild("Pickups", true) and ReplicatedStorage.Remotes.Pickups:FindFirstChild("CollectPickup", true)
local frameworkEvent = ReplicatedStorage:FindFirstChild("Shared", true) and ReplicatedStorage.Shared:FindFirstChild("Framework", true) and ReplicatedStorage.Shared.Framework:FindFirstChild("Network", true) and ReplicatedStorage.Shared.Framework.Network:FindFirstChild("Remote", true) and ReplicatedStorage.Shared.Framework.Network.Remote:FindFirstChild("Event", true)

if not collectRemote or not collectRemote:IsA("RemoteEvent") then
    AutoFarmGroupbox:AddLabel("Error: Collect Remote not found!")
    warn("Could not find ReplicatedStorage.Remotes.Pickups.CollectPickup")
end

if not frameworkEvent or not frameworkEvent:IsA("RemoteEvent") then
    AutoFarmGroupbox:AddLabel("Error: Framework Event not found!")
    warn("Could not find ReplicatedStorage.Shared.Framework.Network.Remote.Event")
end

AutoFarmGroupbox:AddToggle("AutoCollectCoins", {
    Text = "Auto Collect Coins/Orbs",
    Default = false,
    Callback = function(value)
        autoCollectActive = value
        if value and not collectRemote then
             Notifications({ Title = "Error", Description = "Cannot start Auto Collect: Remote not found.", Type = "Error", Time = 5 })
             Toggles.AutoCollectCoins:SetValue(false)
             autoCollectActive = false
        elseif value then
             Notifications({ Title = "Auto Collect", Description = "Started collecting coins/orbs.", Type = "Info", Time = 3 })
        else
             Notifications({ Title = "Auto Collect", Description = "Stopped collecting coins/orbs.", Type = "Info", Time = 3 })
        end
    end
})

AutoFarmGroupbox:AddToggle("AutoBlowBubble", {
    Text = "Auto Blow Bubble",
    Default = false,
    Callback = function(value)
        autoBubbleActive = value
         if value and not frameworkEvent then
             Notifications({ Title = "Error", Description = "Cannot start Auto Bubble: Remote not found.", Type = "Error", Time = 5 })
             Toggles.AutoBlowBubble:SetValue(false)
             autoBubbleActive = false
        elseif value then
             Notifications({ Title = "Auto Bubble", Description = "Started blowing bubbles.", Type = "Info", Time = 3 })
        else
             Notifications({ Title = "Auto Bubble", Description = "Stopped blowing bubbles.", Type = "Info", Time = 3 })
        end
    end
})

AutoFarmGroupbox:AddToggle("AutoSellBubble", {
    Text = "Auto Sell Bubble",
    Default = false,
    Callback = function(value)
        autoSellActive = value
         if value and not frameworkEvent then
             Notifications({ Title = "Error", Description = "Cannot start Auto Sell: Remote not found.", Type = "Error", Time = 5 })
             Toggles.AutoSellBubble:SetValue(false)
             autoSellActive = false
        elseif value then
             Notifications({ Title = "Auto Sell", Description = "Started selling bubbles.", Type = "Info", Time = 3 })
        else
             Notifications({ Title = "Auto Sell", Description = "Stopped selling bubbles.", Type = "Info", Time = 3 })
        end
    end
})

-- Auto Collect Loop
task.spawn(function()
    while task.wait(0.75) do -- Check slightly less frequently for pickups
        if autoCollectActive and collectRemote then
            local pickupsFolder = Workspace:FindFirstChild("Pickups")
            if pickupsFolder then
                for _, item in ipairs(pickupsFolder:GetChildren()) do
                    -- Assuming the GUID is the Name of the item instance within Workspace.Pickups
                    local guid = item.Name
                    if typeof(guid) == "string" and guid ~= "" then
                         local success, err = pcall(function()
                             collectRemote:FireServer(guid)
                         end)
                         if not success then
                             warn("Error firing CollectPickup for", guid, ":", err)
                             -- Optional: Stop auto-collect on error?
                             -- autoCollectActive = false
                             -- Toggles.AutoCollectCoins:SetValue(false)
                             -- Notifications({ Title = "Collect Error", Description = "Error: "..tostring(err), Type = "Error", Time = 4 })
                         end
                         task.wait(0.05) -- Small delay between firing for multiple items
                    end
                end
            else
                warn("Could not find Workspace.Pickups folder for Auto Collect.")
                -- Optional: Stop if the folder isn't found
                -- autoCollectActive = false
                -- Toggles.AutoCollectCoins:SetValue(false)
                -- Notifications({ Title = "Collect Error", Description = "Workspace.Pickups not found.", Type = "Error", Time = 4 })
            end
        end
    end
end)

-- Auto Bubble Loop
task.spawn(function()
    while task.wait(0.15) do -- Adjust wait time as needed
        if autoBubbleActive and frameworkEvent then
             local success, err = pcall(function()
                 frameworkEvent:FireServer("BlowBubble")
             end)
             if not success then
                 warn("Error firing BlowBubble:", err)
             end
        end
    end
end)

-- Auto Sell Loop
task.spawn(function()
    while task.wait(1) do -- Sell less frequently
        if autoSellActive and frameworkEvent then
             local success, err = pcall(function()
                 frameworkEvent:FireServer("SellBubble")
             end)
             if not success then
                 warn("Error firing SellBubble:", err)
             end
        end
    end
end)


-- === UI Settings Tab Content ===
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
    print("Unload requested.")
    -- Set toggles to false visually and functionally before unloading
    if Toggles.AutoCollectCoins then Toggles.AutoCollectCoins:SetValue(false) end
    if Toggles.AutoBlowBubble then Toggles.AutoBlowBubble:SetValue(false) end
    if Toggles.AutoSellBubble then Toggles.AutoSellBubble:SetValue(false) end
    autoCollectActive = false
    autoBubbleActive = false
    autoSellActive = false
    task.wait(0.1) -- Give loops a moment to stop
    Library:Unload();
    print("Library unloaded.")
end);

if ThemeManager and SaveManager then
     ThemeManager:ApplyToTab(Tabs.UISettings)
     SaveManager:BuildConfigSection(Tabs.UISettings)
     SaveManager:SetFolder("AutoFarm Settings") -- Changed folder name
     SaveManager:IgnoreThemeSettings();
     SaveManager:SetIgnoreIndexes({"MenuKeybind"}); -- Keep ignoring keybind
     -- Add farm toggles to save config if desired
     SaveManager:AddSaveableElements({
         Options.AutoCollectCoins,
         Options.AutoBlowBubble,
         Options.AutoSellBubble
     })
     SaveManager:LoadAutoloadConfig();

     Notifications({
        Title = "Auto Farm Loaded",
        Description = "Press '" .. tostring(Library.ToggleKeybind) .. "' to toggle menu visibility.",
        Time = 5
     })
else
    TabsUISettingsRight:AddLabel("Theme/Save Managers not loaded.")
     Notifications({
        Title = "Auto Farm Loaded",
        Description = "Press RightShift (default) to toggle menu. Theme/Save managers failed.",
        Time = 6,
        Type = "Warning"
     })
end

print("Auto Farm script loaded.")
