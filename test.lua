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
    AutoClaimPlaytime = false;
    
    -- Misc Features
    AutoMysteryBox = false;
    
    -- Egg Features
    AutoHatch = false;
    SelectedEgg = "Common Egg";
    HatchAmount = 1;
    
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

local function ClaimAllGifts()
    for i, v in next, game:GetService("Workspace").Rendered.Gifts:GetChildren() do
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer("ClaimGift", v.Name);
        task.wait();
        v:Destroy();
    end;
end;

local function CraftMaxPotion(potionType)
    -- Craft potions from tier 1 to tier 5
    for tier = 1, 5 do
        local args = {
            [1] = "CraftPotion",
            [2] = potionType,
            [3] = tier,
            [4] = false
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
        task.wait(0.5); -- Wait a bit between crafting
    end
    
    Library:Notify({
        Title = "Potion Crafted",
        Description = "Max level " .. potionType .. " potion has been crafted.",
        Time = 3
    });
end;

local function ClaimAllPlaytimeRewards()
    local claimedCount = 0;
    
    -- Try to claim all 9 playtime rewards
    for i = 1, 9 do
        local success = game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Function:InvokeServer("ClaimPlaytime", i);
        if success then
            claimedCount = claimedCount + 1;
        end
        task.wait(0.1);
    end
    
    return claimedCount;
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
    Eggs = Window:AddTab("Eggs", "egg"),
    Potions = Window:AddTab("Potions", "vial"),
    Misc = Window:AddTab("Misc", "list"),
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

TabsMainFunctions:AddToggle("AutoClaimPlaytime", {
    Text = "Auto Claim Playtime Rewards";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoClaimPlaytime = Value;
        task.spawn(function()
            while Functions.AutoClaimPlaytime do
                local claimed = ClaimAllPlaytimeRewards();
                if claimed > 0 then
                    Library:Notify({
                        Title = "Playtime Rewards",
                        Description = claimed .. " playtime rewards have been claimed.",
                        Time = 3
                    });
                end
                task.wait(60); -- Check every minute
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
        Toggles.AutoClaimPlaytime:SetValue(false);
        Toggles.AutoMysteryBox:SetValue(false);
        Toggles.AutoHatch:SetValue(false);
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
        -- Try to find code module first
        local codeModule = nil
        local success, result = pcall(function()
            -- Look in common locations for code storage
            return ReplicatedStorage:FindFirstChild("Shared"):FindFirstChild("Framework"):FindFirstChild("Modules"):FindFirstChild("Codes")
        end)
        
        local codesToTry = {}
        
        -- If we found a module, try to get codes from it
        if success and result then
            codeModule = require(result)
            if type(codeModule) == "table" then
                for code, _ in pairs(codeModule) do
                    table.insert(codesToTry, code)
                end
            end
        end
        
        -- If we couldn't find codes in modules, use common codes
        if #codesToTry == 0 then
            codesToTry = {"throwback", "easter", "RELEASE", "Lucky", "Thanks", "Update1", "Valentines", 
                          "Summer", "500M", "Halloween", "xmas", "Million", "Update", "Launch", "Free",
                          "Winter", "Holiday", "Spring", "Egg", "Code", "Twitter"}
        end
        
        -- Try each code
        local redeemedCount = 0
        for _, code in ipairs(codesToTry) do
            local success = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
                :WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote")
                :WaitForChild("Function"):InvokeServer("RedeemCode", code)
            
            if success then
                redeemedCount = redeemedCount + 1
                print("Redeemed code:", code)
            end
            task.wait(0.5)
        end
        
        Library:Notify({
            Title = "Codes Redeemed",
            Description = redeemedCount .. " codes have been successfully redeemed.",
            Time = 3
        })
    end
});

TabsOtherFunctions:AddButton({
    Text = "Claim Playtime Rewards";
    Func = function()
        local claimed = ClaimAllPlaytimeRewards();
        Library:Notify({
            Title = "Playtime Rewards",
            Description = claimed .. " playtime rewards have been claimed.",
            Time = 3
        });
    end;
});

--[[ Eggs Tab ]]--
local TabsEggFunctions = Tabs.Eggs:AddLeftGroupbox("Egg Hatching");

-- Egg selection dropdown
TabsEggFunctions:AddDropdown("EggSelection", {
    Values = {"Common Egg", "Spotted Egg", "Iceshard Egg", "Spikey Egg", "Magma Egg", 
              "Crystal Egg", "Lunar Egg", "Void Egg", "Hell Egg", "Nightmare Egg", 
              "Rainbow Egg", "Infinity Egg", "Throwback Egg"},
    Default = "Common Egg",
    Text = "Select Egg",
    Callback = function(Value)
        getgenv().Functions.SelectedEgg = Value;
    end;
});

-- Egg hatch amount dropdown
TabsEggFunctions:AddDropdown("HatchAmount", {
    Values = {"1", "Max"},
    Default = "1",
    Text = "Hatch Amount",
    Callback = function(Value)
        if Value == "1" then
            getgenv().Functions.HatchAmount = 1;
        else
            getgenv().Functions.HatchAmount = 4; -- "Max" typically allows hatching 3 eggs at once
        end
    end;
});

-- Auto hatch toggle
TabsEggFunctions:AddToggle("AutoHatch", {
    Text = "Auto Hatch Eggs",
    Default = false,
    Callback = function(Value)
        getgenv().Functions.AutoHatch = Value;
        task.spawn(function()
            while Functions.AutoHatch do
                local args = {
                    [1] = "HatchEgg",
                    [2] = Functions.SelectedEgg,
                    [3] = Functions.HatchAmount
                }
                game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
                task.wait(2); -- Wait between hatches
            end;
        end);
    end;
});

-- Manual hatch button
TabsEggFunctions:AddButton({
    Text = "Hatch Egg Once",
    Func = function()
        local args = {
            [1] = "HatchEgg",
            [2] = Functions.SelectedEgg,
            [3] = Functions.HatchAmount
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
        Library:Notify({
            Title = "Egg Hatched",
            Description = "Hatched " .. Functions.SelectedEgg .. " " .. Functions.HatchAmount .. " time(s).",
            Time = 3
        });
    end;
});

--[[ Potions Tab ]]--
local TabsPotions = Tabs.Potions:AddLeftGroupbox("Craft Potions");

TabsPotions:AddButton({
    Text = "Craft Max Lucky Potion",
    Func = function()
        CraftMaxPotion("Lucky");
    end;
});

TabsPotions:AddButton({
    Text = "Craft Max Mythic Potion",
    Func = function()
        CraftMaxPotion("Mythic");
    end;
});

TabsPotions:AddButton({
    Text = "Craft Max Speed Potion",
    Func = function()
        CraftMaxPotion("Speed");
    end;
});

local TabsPotionTier = Tabs.Potions:AddRightGroupbox("Craft Specific Tier");

-- Lucky Potions
TabsPotionTier:AddButton({
    Text = "Craft Lucky Potion I",
    Func = function()
        local args = {
            [1] = "CraftPotion",
            [2] = "Lucky",
            [3] = 1,
            [4] = false
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsPotionTier:AddButton({
    Text = "Craft Lucky Potion II",
    Func = function()
        local args = {
            [1] = "CraftPotion",
            [2] = "Lucky",
            [3] = 2,
            [4] = false
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsPotionTier:AddButton({
    Text = "Craft Lucky Potion III",
    Func = function()
        local args = {
            [1] = "CraftPotion",
            [2] = "Lucky",
            [3] = 3,
            [4] = false
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsPotionTier:AddButton({
    Text = "Craft Lucky Potion IV",
    Func = function()
        local args = {
            [1] = "CraftPotion",
            [2] = "Lucky",
            [3] = 4,
            [4] = false
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

TabsPotionTier:AddButton({
    Text = "Craft Lucky Potion V",
    Func = function()
        local args = {
            [1] = "CraftPotion",
            [2] = "Lucky",
            [3] = 5,
            [4] = false
        }
        game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
    end;
});

--[[ Misc Tab ]]--
local TabsMiscFunctions = Tabs.Misc:AddLeftGroupbox("Misc Functions");

TabsMiscFunctions:AddToggle("AutoMysteryBox", {
    Text = "Auto Open Mystery Boxes";
    Default = false;
    Callback = function(Value)
        getgenv().Functions.AutoMysteryBox = Value;
        task.spawn(function()
            while Functions.AutoMysteryBox do
                -- Open 10 mystery boxes at once
                for i = 1, 10 do
                    local args = {
                        [1] = "UseGift",
                        [2] = "Mystery Box",
                        [3] = 1
                    }
                    game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
                    task.wait(0.1);
                end
                
                -- Wait a moment for the gifts to spawn
                task.wait(1);
                
                -- Claim all the gifts that spawned
                ClaimAllGifts();
                
                -- Wait before the next batch
                task.wait(2);
            end;
        end);
    end;
});

TabsMiscFunctions:AddButton({
    Text = "Open 10 Mystery Boxes";
    Func = function()
        -- Open 10 mystery boxes
        for i = 1, 10 do
            local args = {
                [1] = "UseGift",
                [2] = "Mystery Box",
                [3] = 1
            }
            game:GetService("ReplicatedStorage").Shared.Framework.Network.Remote.Event:FireServer(unpack(args));
            task.wait(0.1);
        end
        
        -- Wait a moment for the gifts to spawn
        task.wait(1);
        
        -- Claim all the gifts that spawned
        ClaimAllGifts();
        
        Library:Notify({
            Title = "Mystery Boxes";
            Description = "10 Mystery Boxes have been opened and claimed.";
            Time = 3;
        });
    end;
});

TabsMiscFunctions:AddButton({
    Text = "Claim All Gifts";
    Func = function()
        ClaimAllGifts();
        Library:Notify({
            Title = "Gifts Claimed";
            Description = "All available gifts have been claimed.";
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
