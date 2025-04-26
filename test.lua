--[[ Anti-AFK ]]--
for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    v:Disable();
end;

--[[ Service Variables ]]--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--[[ Main Configuration ]]--
getgenv().Functions = {
    -- Main Features
    AutoBubble = false;
    AutoSell = false;
    AutoCollect = false;
    
    -- Settings
    Disable3DRendering = false;
    BlackOutScreen = false;
};

--[[ Utility Functions ]]--
local function CollectPickups()
    for i, v in next, game:GetService("Workspace").Rendered:GetChildren() do
        if v.Name == "Chunker" then
            for i2, v2 in next, v:GetChildren() do
                local Part, HasMeshPart = v2:FindFirstChild("Part"), v2:FindFirstChildWhichIsA("MeshPart");
                local HasStars = Part and Part:FindFirstChild("Stars");
                local HasPartMesh = Part and Part:FindFirstChild("Mesh");
                if HasMeshPart or HasStars or HasPartMesh then
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pickups"):WaitForChild("CollectPickup"):FireServer(v2.Name);
                    v2:Destroy();
                end;
            end;
        end;
    end;
end;

--[[ Load Obsidian Library ]]--
local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/";
local Library = loadstring(game:HttpGet(Repository .. "Library.lua"))();
local ThemeManager = loadstring(game:HttpGet(Repository .. "addons/ThemeManager.lua"))();
local SaveManager = loadstring(game:HttpGet(Repository .. "addons/SaveManager.lua"))();
local Options = Library.Options;
local Toggles = Library.Toggles;

--[[ Create Main Window ]]--
local Window = Library:CreateWindow({
    Title = "Bubble Gum Simulator";
    Footer = "Made by @cody | v1.0";
    NotifySide = "Right";
    ShowCustomCursor = true;
});

--[[ Create Tabs ]]--
local Tabs = {
    Main = Window:AddTab("Main", "user"),
    Teleports = Window:AddTab("Teleports", "globe"),
    CPUSettings = Window:AddTab("CPU Settings", "cpu"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
};

--[[ Main Tab ]]--
local TabsMainFunctions = Tabs.Main:AddLeftGroupbox("Main Functions");

TabsMainFunctions:AddToggle("AutoBubble", {
    Text = "Auto Blow Bubbles";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoBubble = Value;
        task.spawn(function()
            while Functions.AutoBubble do
                task.wait(0.1);
                local args = {
                    [1] = "BlowBubble"
                }
                game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
            end;
        end);
    end;
});

TabsMainFunctions:AddToggle("AutoSell", {
    Text = "Auto Sell Bubbles";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoSell = Value;
        task.spawn(function()
            while Functions.AutoSell do
                task.wait(0.1);
                local args = {
                    [1] = "SellBubble"
                }
                game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
            end;
        end);
    end;
});

TabsMainFunctions:AddToggle("AutoCollect", {
    Text = "Auto Collect Pickups";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoCollect = Value;
        task.spawn(function()
            while Functions.AutoCollect do
                CollectPickups();
                task.wait(1);
            end;
        end);
    end;
});

local TabsUntoggle = Tabs.Main:AddLeftGroupbox("Untoggle");

local UntoggleAll = TabsUntoggle:AddButton({
    Text = "Untoggle All";
    Func = function()
        Toggles.AutoBubble:SetValue(false);
        Toggles.AutoSell:SetValue(false);
        Toggles.AutoCollect:SetValue(false);
        Toggles.Disable3DRendering:SetValue(false);
        Toggles.BlackOutScreen:SetValue(false);
    end;
    Tooltip = "WARNING: This will untoggle EVERY toggle in the script.";
    Risky = true;
});

local TabsOtherFunctions = Tabs.Main:AddRightGroupbox("Other Functions");

TabsOtherFunctions:AddButton({
    Text = "Redeem All Codes";
    Func = function()
        local Codes = {"easter", "RELEASE", "Lucky", "Thanks"};
        for i, v in next, Codes do
            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer("RedeemCode", v);
        end;
        Library:Notify({
            Title = "Codes Redeemed";
            Description = "All available codes have been redeemed.";
            Time = 3;
        });
    end;
});

--[[ Teleport Tab ]]--
local TabsTeleport = Tabs.Teleports:AddLeftGroupbox("Islands");

TabsTeleport:AddButton({
    Text = "Teleport to The Overworld";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.FastTravel.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsTeleport:AddButton({
    Text = "Teleport to Floating Island";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsTeleport:AddButton({
    Text = "Teleport to Outer Space";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsTeleport:AddButton({
    Text = "Teleport to Twilight";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsTeleport:AddButton({
    Text = "Teleport to The Void";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsTeleport:AddButton({
    Text = "Teleport to Zen";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

local TabsSpecialTeleport = Tabs.Teleports:AddRightGroupbox("Special Locations");

TabsSpecialTeleport:AddButton({
    Text = "Teleport to Event";
    Func = function()
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Event.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsSpecialTeleport:AddButton({
    Text = "Teleport to Coin Farm Area";
    Func = function()
        -- First teleport to Zen
        local args = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
        
        -- Wait for teleport to complete
        task.wait(1);
        
        -- Then move to the specific coin farm area
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(4, 15973, 44)
        end
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

ThemeManager:SetFolder("BubbleGumSimulator");
SaveManager:BuildConfigSection(Tabs["UI Settings"]);
ThemeManager:ApplyToTab(Tabs["UI Settings"]);
SaveManager:LoadAutoloadConfig();

--[[ Initialization ]]--
Library:Notify({
    Title = "Script Loaded";
    Description = "Bubble Gum Simulator script has loaded successfully!";
    Time = 3;
});

print("Bubble Gum Simulator script loaded successfully")
print("Press RightShift to toggle menu visibility.")
