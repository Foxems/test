-- NOTE: This script requires a working Roblox exploit executor
--       and assumes the Obsidian library URL is valid and the library is accessible.
--       It is designed for Bubble Gum Simulator (or any Roblox game) but uses
--       a GUI library popular in the exploit community.

-- Repository URL for the Obsidian Library
-- You might need to adjust this if the original one doesn't work
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

-- === Load the GUI Library ===
-- Use pcall to safely attempt loading the library
local success, Library = pcall(function()
    return loadstring(game:HttpGet(Repository .. "Library.lua"))()
end)

if not success or type(Library) ~= 'table' then
    warn("Failed to load Obsidian Library! Check the Repository URL or your internet connection.")
    warn("Error:", Library) -- Print the error message if pcall failed
    -- You might want to stop script execution here if the library is essential
    return -- Stop the script if the library didn't load
end

-- Get the Library's core components
local Options = Library.Options
local Toggles = Library.Toggles
local Notifications = Library.Notify -- Get the notify function

-- === Create the Main Window ===
local Window = Library:CreateWindow({
    Title = "Remote Explorer",
    Footer = "Remote Scanner by AI | GUI by s.eths / Obsidian",
    NotifySide = "Right", -- Default notification side
    ShowCustomCursor = true, -- Default cursor setting
    -- You can add a default keybind here, or set it via the UI Settings tab
    -- Keybind = Enum.KeyCode.RightShift; -- Example default keybind
})

-- === Define Tabs ===
local Tabs = {
    RemoteExplorer = Window:AddTab("Remote Explorer", "search"), -- Add the main Remote Explorer tab
    UISettings = Window:AddTab("UI Settings", "settings"),     -- Add the UI Settings tab
    -- Add other tabs here if you combine this with farming functions from your original script
    -- Main = Window:AddTab("Main", "user"),
    -- Potions = Window:AddTab("Potions", "beer"),
    -- Rifts = Window:AddTab("Rifts", "atom"),
    -- Teleports = Window:AddTab("Teleports", "globe"),
    -- CPUSettings = Window:AddTab("CPU Settings", "cpu"),
}

-- === Remote Explorer Tab Content ===
local RemoteExplorerGroupbox = Tabs.RemoteExplorer:AddLeftGroupbox("Found Remotes")

-- Label to display the remote list - will be updated by the scanning function
local RemoteListLabel = RemoteExplorerGroupbox:AddLabel("Click 'Scan Remotes' or 'Refresh List' to start.")

-- Button to trigger the scan
local ScanButton = RemoteExplorerGroupbox:AddButton({
    Text = "Scan / Refresh List",
    Tooltip = "Scans the entire game for RemoteEvents and RemoteFunctions.",
    Func = function()
        -- Clear previous text and update label to show scanning is in progress
        RemoteListLabel:SetText("Scanning for remotes...")
        
        -- Use task.spawn to run the scan asynchronously, preventing UI freeze
        task.spawn(function()
            local remoteEntries = {} -- Store results in a table first
            local foundCount = 0

            -- Iterate through all descendants of the game
            for i, instance in ipairs(game:GetDescendants()) do
                -- Check if the instance is a RemoteEvent or RemoteFunction
                if instance:IsA("RemoteEvent") or instance:IsA("RemoteFunction") then
                    -- Add its information to the table
                    table.insert(remoteEntries, {
                        ClassName = instance.ClassName,
                        Name = instance.Name,
                        Path = instance:GetFullName()
                    })
                    foundCount = foundCount + 1
                end
            end

            -- Format the table entries into a single string for the label
            local remoteText = "Found " .. foundCount .. " Remotes:\n"
            if foundCount > 0 then
                -- Sort alphabetically by path for easier reading
                table.sort(remoteEntries, function(a, b)
                    return a.Path < b.Path
                end)
                
                for _, remoteInfo in ipairs(remoteEntries) do
                    remoteText = remoteText .. remoteInfo.ClassName .. ": " .. remoteInfo.Name .. " (" .. remoteInfo.Path .. ")\n"
                end
                -- Remove the last newline if any
                remoteText = remoteText:sub(1, -2)
            else
                remoteText = "No RemoteEvents or RemoteFunctions found."
            end

            -- Update the label text
            RemoteListLabel:SetText(remoteText)
            
            -- Notify user scan is complete
            Notifications({
                Title = "Scan Complete",
                Description = "Found " .. foundCount .. " remotes.",
                Time = 3
            })
        end)
    end;
})

-- Button to copy the current list text to clipboard
local CopyButton = RemoteExplorerGroupbox:AddButton({
    Text = "Copy List to Clipboard",
    Tooltip = "Copies the currently displayed list of remotes to your clipboard.",
    Func = function()
        local textToCopy = RemoteListLabel.Text -- Get the current text from the label

        if textToCopy and textToCopy ~= "" and textToCopy ~= "Scanning for remotes..." and textToCopy ~= "Click 'Scan Remotes' or 'Refresh List' to start." and textToCopy ~= "No RemoteEvents or RemoteFunctions found." then
            -- Check if the exploit provides setclipboard
            if setclipboard then
                setclipboard(textToCopy)
                Notifications({
                    Title = "Copied!",
                    Description = "Remote list copied to clipboard.",
                    Time = 3
                })
            else
                 Notifications({
                    Title = "Copy Failed",
                    Description = "Your exploit does not support 'setclipboard'.",
                    Time = 4,
                    Type = "Error" -- Use an error notification style if available
                })
            end
        else
            Notifications({
                Title = "Nothing to Copy",
                Description = "The list is empty or still scanning.",
                Time = 3,
                Type = "Warning" -- Use a warning notification style if available
            })
        end
    end;
})

-- === Initial Scan on Script Load ===
-- Trigger a scan automatically when the script is first executed
-- Use task.delay(0, ...) or similar if the GUI needs a moment to render first,
-- but task.spawn usually suffices.
task.spawn(function()
    -- Small delay to ensure UI is somewhat ready (optional, can remove if not needed)
    -- task.wait(0.1)
    ScanButton.Func() -- Call the function of the scan button
end)


-- === UI Settings Tab Content (Optional, from your original script) ===
-- This section configures the GUI library itself (keybind, DPI, saving, etc.)
-- You need the ThemeManager and SaveManager if you want saving/theming

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
    Default = Library.KeybindFrame.Visible; -- Read initial visibility
    Text = "Open Keybind Menu";
    Callback = function(value)
        Library.KeybindFrame.Visible = value;
    end;
});
TabsUISettingsLeft:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor";
    Default = Window.ShowCustomCursor; -- Read initial setting from Window
    Callback = function(Value)
        -- Update both the library property and the window property
        Library.ShowCustomCursor = Value;
        Window.ShowCustomCursor = Value;
    end;
});
-- Notification Side is usually set on the Window/Library directly, add a dropdown for user choice
TabsUISettingsLeft:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"};
    Default = "Right"; -- Match the Window default
    Text = "Notification Side";
    Callback = function(Value)
        Library:SetNotifySide(Value); -- Library function to change side
    end;
});
TabsUISettingsLeft:AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"};
    Default = "100%"; -- Match the Window default scale
    Text = "DPI Scale";
    Callback = function(Value)
        Value = Value:gsub("%%", ""); -- Remove the '%'
        local DPI = tonumber(Value);
        if DPI then
            Library:SetDPIScale(DPI / 100); -- Library SetDPIScale expects a multiplier (e.g., 0.5 for 50%)
        end
    end;
});
TabsUISettingsLeft:AddDivider()
-- Keybind Picker (NoUI means the picker is the text next to the label)
local MenuKeyPicker = TabsUISettingsLeft:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {Default = "RightShift", NoUI = true, Text = "Menu keybind"});

-- Set the library's toggle keybind to the value from the picker
-- Need to do this *after* the picker is created and potentially loaded from save
Library.ToggleKeybind = Options.MenuKeybind;
-- Also need to connect the picker's callback to update the Library keybind
Options.MenuKeybind:OnChanged(function(newValue)
    Library.ToggleKeybind = newValue
end)

TabsUISettingsLeft:AddButton("Unload Script", function()
    Library:Unload(); -- Unload the GUI and cleanup
    -- Add any other script-specific cleanup here if needed
end);

-- Appearance & Saving Groupbox
if ThemeManager and SaveManager then
     -- Theme Selection (Dropdown added by ThemeManager)
     ThemeManager:ApplyToTab(Tabs.UISettings) -- ThemeManager adds its controls to this tab

     -- Saving/Loading Buttons (Added by SaveManager)
     SaveManager:BuildConfigSection(Tabs.UISettings) -- SaveManager adds its controls to this tab

     -- Configure SaveManager
     SaveManager:SetFolder("Remote Explorer Settings") -- Use a unique folder name for this script's saves
     SaveManager:IgnoreThemeSettings(); -- Don't save theme settings with the main config
     SaveManager:SetIgnoreIndexes({"MenuKeybind"}); -- Ignore the keybind from default saving, as it's handled separately by the picker? (This part might need testing based on how Obsidian saves)

     -- Load saved settings automatically
     SaveManager:LoadAutoloadConfig();

     Notifications({
        Title = "GUI Loaded",
        Description = "Press '" .. tostring(Library.ToggleKeybind) .. "' to toggle menu visibility.",
        Time = 5
     })

else
    TabsUISettingsRight:AddLabel("Theme/Save Managers not loaded.")
end

-- --- End UI Settings ---


-- The GUI should now be visible. The keybind (default Right Shift) will toggle its visibility.
-- The Remote Explorer tab is active initially (as it's the first one added after the default Main tab).
-- The initial scan should run shortly after the script starts.