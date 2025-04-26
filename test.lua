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
local Notifications = Library.Notify

local UserInputService = game:GetService("UserInputService")
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
-- Add Auto Farm controls here later


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
    Library:Unload();
    print("Library unloaded.")
end);

if ThemeManager and SaveManager then
     ThemeManager:ApplyToTab(Tabs.UISettings)
     SaveManager:BuildConfigSection(Tabs.UISettings)
     SaveManager:SetFolder("AutoFarm Settings")
     SaveManager:IgnoreThemeSettings();
     SaveManager:SetIgnoreIndexes({"MenuKeybind"});
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
