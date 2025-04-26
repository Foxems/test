--[[ Anti-AFK ]]--
for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    v:Disable();
end;

--[[ Service Variables ]]--
local Players = game:GetService("Players")

--[[ Main Configuration ]]--
getgenv().Functions = {
    -- Main Features
    AutoFeature1 = false;
    AutoFeature2 = false;
    AutoFeature3 = false;
    AutoFeature4 = false;
    
    -- Settings
    Disable3DRendering = false;
    BlackOutScreen = false;
};

--[[ Load Obsidian Library ]]--
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/";
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))();
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))();
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))();
local Options = Library.Options;
local Toggles = Library.Toggles;

--[[ Create Main Window ]]--
local Window = Library:CreateWindow({
    Title = "JustBGSI";
    Footer = "Made by @cody | v1.0";
    NotifySide = "Right";
    ShowCustomCursor = true;
});

--[[ Create Tabs ]]--
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    CPUSettings = Window:AddTab("CPU Settings", "cpu"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
};

--[[ Main Tab ]]--
local TabsMainFunctions = Tabs.Main:AddLeftGroupbox("Main Functions");

TabsMainFunctions:AddToggle("AutoFeature1", {
    Text = "Auto Feature 1";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoFeature1 = Value;
        task.spawn(function()
            while Functions.AutoFeature1 do
                task.wait(1);
                print("Auto Feature 1 Running");
                -- Functionality would go here
            end;
        end);
    end;
});

TabsMainFunctions:AddToggle("AutoFeature2", {
    Text = "Auto Feature 2";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoFeature2 = Value;
        task.spawn(function()
            while Functions.AutoFeature2 do
                task.wait(1);
                print("Auto Feature 2 Running");
                -- Functionality would go here
            end;
        end);
    end;
});

TabsMainFunctions:AddToggle("AutoFeature3", {
    Text = "Auto Feature 3";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoFeature3 = Value;
        task.spawn(function()
            while Functions.AutoFeature3 do
                task.wait(1);
                print("Auto Feature 3 Running");
                -- Functionality would go here
            end;
        end);
    end;
});

TabsMainFunctions:AddToggle("AutoFeature4", {
    Text = "Auto Feature 4";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoFeature4 = Value;
        task.spawn(function()
            while Functions.AutoFeature4 do
                task.wait(1);
                print("Auto Feature 4 Running");
                -- Functionality would go here
            end;
        end);
    end;
});

local TabsUntoggle = Tabs.Main:AddLeftGroupbox("Untoggle");

local UntoggleAll = TabsUntoggle:AddButton({
    Text = "Untoggle All";
    Func = function()
        Toggles.AutoFeature1:SetValue(false);
        Toggles.AutoFeature2:SetValue(false);
        Toggles.AutoFeature3:SetValue(false);
        Toggles.AutoFeature4:SetValue(false);
        Toggles.Disable3DRendering:SetValue(false);
        Toggles.BlackOutScreen:SetValue(false);
    end;
    Tooltip = "WARNING: This will untoggle EVERY toggle in the script.";
    Risky = true;
});

local TabsOtherFunctions = Tabs.Main:AddRightGroupbox("Other Functions");

TabsOtherFunctions:AddButton({
    Text = "Function 1";
    Func = function()
        print("Function 1 Executed");
        -- Functionality would go here
    end;
});

TabsOtherFunctions:AddButton({
    Text = "Function 2";
    Func = function()
        print("Function 2 Executed");
        -- Functionality would go here
    end;
});

TabsOtherFunctions:AddButton({
    Text = "Function 3";
    Func = function()
        print("Function 3 Executed");
        -- Functionality would go here
    end;
});

--[[ CPU Settings Tab ]]--
local TabsCPUSettings = Tabs.CPUSettings:AddLeftGroupbox("CPU Saving");

TabsCPUSettings:AddToggle("Disable3DRendering", {
    Text = "Disable 3D Rendering";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.Disable3DRendering = Value;
        task.spawn(function()
            if Functions.Disable3DRendering then
                game:GetService("RunService"):Set3dRenderingEnabled(false);
            elseif not Functions.Disable3DRendering then
                game:GetService("RunService"):Set3dRenderingEnabled(true);
            end;
        end);
    end;
});

TabsCPUSettings:AddToggle("BlackOutScreen", {
    Text = "Black Out Screen";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.BlackOutScreen = Value;
        task.spawn(function()
            if Functions.BlackOutScreen then
                local ScreenGui = Instance.new("ScreenGui");
                ScreenGui.Name = "BlackoutGui";
                ScreenGui.ResetOnSpawn = false;
                ScreenGui.IgnoreGuiInset = true;
                ScreenGui.Parent = game:GetService("CoreGui");
                local BlackFrame = Instance.new("Frame");
                BlackFrame.Size = UDim2.new(1, 0, 1, 0);
                BlackFrame.Position = UDim2.new(0, 0, 0, 0);
                BlackFrame.BackgroundColor3 = Color3.new(0, 0, 0);
                BlackFrame.BorderSizePixel = 0;
                BlackFrame.Parent = ScreenGui;
            elseif not Functions.BlackOutScreen then
                if game:GetService("CoreGui"):FindFirstChild("BlackoutGui") then
                    game:GetService("CoreGui").BlackoutGui:Destroy();
                end
            end;
        end);
    end;
});

local TabsFPSSettings = Tabs.CPUSettings:AddRightGroupbox("FPS Cap");

local FPSCap3 = TabsFPSSettings:AddButton({
    Text = "Set FPS Cap to 3";
    Func = function()
        setfpscap(3);
    end;
});

local FPSCap10 = TabsFPSSettings:AddButton({
    Text = "Set FPS Cap to 10";
    Func = function()
        setfpscap(10);
    end;
});

local FPSCap30 = TabsFPSSettings:AddButton({
    Text = "Set FPS Cap to 30";
    Func = function()
        setfpscap(30);
    end;
});

local FPSCap60 = TabsFPSSettings:AddButton({
    Text = "Set FPS Cap to 60";
    Func = function()
        setfpscap(60);
    end;
});

TabsFPSSettings:AddSlider("CustomFPSCap", {
    Text = "Custom FPS Cap";
    Default = 60;
    Min = 3;
    Max = 60;
    Rounding = 1;
    Callback = function(Value)
        setfpscap(Value);
    end;
});

local CurrentFPSLabel = TabsFPSSettings:AddLabel("Current FPS: ???");

task.spawn(function()
    local Frames, Last = 0, tick();
    game:GetService("RunService").RenderStepped:Connect(function()
        Frames += 1;
        if tick() - Last >= 1 then
            CurrentFPSLabel:SetText("Current FPS: " .. Frames);
            Frames = 0
            Last = tick();
        end;
    end);
end);

--[[ UI Settings Tab ]]--
local TabsUISettings = Tabs["UI Settings"]:AddLeftGroupbox("Menu");

TabsUISettings:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible;
    Text = "Open Keybind Menu";
    Callback = function(value)
        Library.KeybindFrame.Visible = value;
    end;
});

TabsUISettings:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor";
    Default = true;
    Callback = function(Value)
        Library.ShowCustomCursor = Value;
    end;
});

TabsUISettings:AddDropdown("NotificationSide", {
    Values = {"Left", "Right"};
    Default = "Right";
    Text = "Notification Side";
    Callback = function(Value)
        Library:SetNotifySide(Value);
    end;
});

TabsUISettings:AddDropdown("DPIDropdown", {
    Values = {"50%", "75%", "100%", "125%", "150%", "175%", "200%"};
    Default = "100%";
    Text = "DPI Scale";
    Callback = function(Value)
        Value = Value:gsub("%%", "");
        local DPI = tonumber(Value);
        Library:SetDPIScale(DPI);
    end;
});

TabsUISettings:AddDivider()

TabsUISettings:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift", 
    NoUI = true, 
    Text = "Menu keybind"
});

TabsUISettings:AddButton("Unload", function()
    Library:Unload();
end);

--[[ Configure Library ]]--
Library.ToggleKeybind = Options.MenuKeybind;
ThemeManager:SetLibrary(Library);
SaveManager:SetLibrary(Library);
SaveManager:IgnoreThemeSettings();
SaveManager:SetIgnoreIndexes({"MenuKeybind"});

ThemeManager:SetFolder("JustBGSI");
SaveManager:BuildConfigSection(Tabs["UI Settings"]);
ThemeManager:ApplyToTab(Tabs["UI Settings"]);
SaveManager:LoadAutoloadConfig();

--[[ Initialization ]]--
print("JustBGSI Loaded Successfully")
print("Press RightShift to toggle menu visibility.")
