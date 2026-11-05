
local function startProfessionalLoader()
    local UserInputService = game:GetService("UserInputService")
    -- Deteksi apakah device memiliki layar sentuh (Mobile)
    local isMobile = UserInputService.TouchEnabled

    local asciiArt = ""
    local barFilled = ""
    local barEmpty = ""


    if isMobile then
        -- 🔥 Versi Mobile (Ramping & Aman dari Word Wrap)
        asciiArt = [[
  _                 __ _       _ _         
 | |__   ___  _   _/ _(_)_ __ (_) |_ _   _ 
 | '_ \ / _ \| | | | |_| | '_ \| | __| | | |
 | |_) | (_) | |_| |  _| | | | | | |_| |_| |
 |_.__/ \___/ \__, |_| |_|_| |_|_|\__|\__, |
              |___/                   |___/ 
        ]]
        barFilled = "="
        barEmpty = "-"
    else
        asciiArt = [[
        
    ██████╗  ██████╗ ██╗   ██╗ ███████╗ ██╗ ███╗   ██╗ ██╗ ████████╗ ██╗   ██╗
    ██╔══██╗██╔═══██╗╚██╗ ██╔╝ ██╔════╝ ██║ ████╗  ██║ ██║ ╚══██╔══╝ ╚██╗ ██╔╝
    ██████╔╝██║   ██║ ╚████╔╝  █████╗   ██║ ██╔██╗ ██║ ██║    ██║     ╚████╔╝ 
    ██╔══██╗██║   ██║  ╚██╔╝   ██╔══╝   ██║ ██║╚██╗██║ ██║    ██║      ╚██╔╝  
    ██████╔╝╚██████╔╝   ██║    ██║      ██║ ██║ ╚████║ ██║    ██║       ██║   
    ╚═════╝  ╚═════╝    ╚═╝    ╚═╝      ╚═╝ ╚═╝  ╚═══╝ ╚═╝    ╚═╝       ╚═╝  
        ]]
        barFilled = "█"
        barEmpty = "░"
    end

    print(asciiArt)
    print("---------------------------------------------------------")
    print("System: Boyfinity v3.0.2B")
    print("User: " .. game.Players.LocalPlayer.Name .. "")
    print("---------------------------------------------------------")

    local stages = {
        {percent = 10, status = "Loading Core"},
        {percent = 25, status = "Building UI"},
        {percent = 50, status = "Adding features"},
        {percent = 75, status = "Anti Debug"},
        {percent = 100, status = "Successfully Loaded!"},
    }

    for _, stage in ipairs(stages) do
        local progress = stage.percent / 5
        -- Menggunakan simbol yang sudah disesuaikan dengan platform
        local bar = string.rep(barFilled, progress) .. string.rep(barEmpty, 20 - progress)
        warn(string.format("[%s] %d%%", bar, stage.percent))
        task.wait(0.5) 
    end

end

task.spawn(startProfessionalLoader)



--=====================================================
-- SERVICES
--=====================================================
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
LocalPlayer = Players.LocalPlayer
camera = workspace.CurrentCamera or workspace:WaitForChild("Camera", 5)
local map = workspace:FindFirstChild("Map")
CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


repeat wait() until LocalPlayer
--=====================================================
-- GLOBAL STATE
--=====================================================
_G.SharedState = _G.SharedState or {

    IsPremium = true, -- Set to false if you want to test non-premium features (will show notifications for locked features)
    --Killer Features
    InfiniteLunge = false,
    NoCooldown = false,
    DoubleSwing = false,
    HitboxEnabled = false,
    HitboxSize = 10,
    HitboxTransparency = 0.5,
    AutoBreak = false,
    NoStun = false,
    AntiBlind = false,
    NoSlow = false,
    AttackMode = "Legit",
    SpamHitCount = 10,
    KillAura = false,
    SpearSilentAim = false,
    SpearArcMode = "Auto",
    SpearHighArcThreshold = 120,
    SpearTargetYOffset = -0.6,
    SpearMaxTargetYOffset = -2.2,
    SpearOffsetScaleStart = 120,
    SpearOffsetScaleEnd = 320,
    SpearGravity = 98.1,
    SpearSpeed = 165,
    SpearSmartPrediction = true,
    ThroughTheVeil = true,
    SnapLine = true,
    SpearShowTargetDot = true,
    SpearTracer = true,
    ButcherSilentAim = false,
    ButcherWallCheck = false,
    ButcherSnapLine = true,
    ButcherShowTargetDot = true,
    InvisCam = false,
    AntiSmoothZoom = false,
    ZoomDistance = 25,
    HookSpam = false,
    HookAmount = 10,
    SilentHook = false,
    ForceKillCarried = false,
    Killer = {
        Enabled = false,
        BreakSpeed = 1,
    }
    


    --Survivor
    GeneratorData = {},
    PerfectSkillCheck = false,
    NoSkillCheck = false,
    InstantHeal = false,
    ReceiveHealBypass = false,
    SilentHeal = false,
    ManualSelfHeal = false,
    AntiCampFollow = false,
    FastVault = false,
    NoSlowSurv = false,
    AutoPallet = false,
    -- Survivor (Dagger / Parry Settings)
    AutoParry = false,
    FaceKillerSens = -1.0,
    AimPrediction = true,
    AimStrictness = 2.6,
    FakeParry = false,
    DefensiveReflexDelay = 0,
    ParryMode = "Animation",
    ParryRadius = 15,
    ShowKillerAim = false,
    GodMode = false,
    AutoDodge = false,
    DashDistance = false,
    AutoRepair = false,
    RepairMethod = "Legit",
    PanicEscape = false,
    KillerDistance = 30,
    InstantSelfHeal = false,
    SelfHealKey = Enum.KeyCode.H,
    BypassLever = false,
    ShowKillerAim = false,
    AutoRun = false,

    SelectedEmote = "Wave",
    EmotePlaying = false,
    RainbowTrail = false,
    EmoteKeybind = false,
    GenTPMode = "Nearest", -- "Nearest" or "SafeSpot"
    EnableGenTP = false,


    --Aimbot
    AimbotEnabled = false,
    AimbotThroughWall = false,
    AimbotToggleMode = false,
    AimbotKeybind = Enum.KeyCode.E,
    EnableCrosshair = true,
    FlashlightAimbot = false,
    InfiniteFlashlight = false,
    TwistOfFateAimbot = false,   -- Twist of Fate homing missile aimbot
    ToFSilentAim = false,
    TargetTeam = "Killer",       -- "Killer" or "Survivor"
    ShowFOV = false,
    AimbotFOV = 150,
    FilledFOV = false,
    IgnoreKnocked = false,        -- Abaikan survivor yang sudah terkena hit (knocked)
    TeamCheck = false,           -- Hanya target musuh (misal: survivor hanya target killer)


    --visual
    FullBright = false,
    NoFog = false,
    CustomTime = false,
    SpectatorList = false,
    ESP = {
        Enabled = false,
        Names = false,
        
        Selected = {
            ["Killer"] = true, 
            ["Survivor"] = true, 
            ["Generators"] = true, 
            ["Gates"] = true, 
            ["Pallets"] = true, 
            ["Windows"] = true, 
            ["Hooks"] = true,
            ["Zombies"] = true,
            ["BearTraps"] = true,
            ["Bots"] = true,
            ["Pumpkins"] = true
        },
        Studs = false,
        ShowLevel = false,
        ShowHookPhase = true,
        BearTrapDistance = 500,
        BearTrapColor = Color3.fromRGB(255, 100, 0),
        BotColor = Color3.fromRGB(0, 230, 255),
        PumpkinColor = Color3.fromRGB(255, 140, 0),
    },
    AutoFarmPumpkin = false,
    --Movement
    Movement = {
        -- Speed
        SpeedValue = 16,

        NoClip = false,
        FOVValue = 70,
        FlyEnabled = false,
        FlyKey = Enum.KeyCode.O,
        FlySpeed = 50,
    },

    Misc = {
        AntiAFK = true,
        AntiFling = false,
        TouchFling = false,
        AntiAdmin = false,
        FlingRadius = 10,
    },

    PotatoMode = false,
    DashKey = Enum.KeyCode.Q,
    DashSpeed = 80




}

--=====================================================
-- PC & MOBILE INPUT BRIDGE FUNCTION
--=====================================================

local State = _G.SharedState

Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

-- Fungsi jembatan PC & Mobile
local function TriggerAction(pcKey, mobileButton)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local isMobile = playerGui and playerGui:FindFirstChild("Survivor-mob")

    if isMobile and mobileButton then
        -- [MODE MOBILE] Simulasikan klik pada tombol layar
        if firesignal then
            pcall(function()
                firesignal(mobileButton.MouseButton1Down)
                firesignal(mobileButton.MouseButton1Click)
                firesignal(mobileButton.MouseButton1Up)
            end)
        end
    else
        -- [MODE PC] Pakai Virtual Input Manager (VIM)
        if pcKey then
            VIM:SendKeyEvent(true, pcKey, false, game)
            task.wait(0.01)
            VIM:SendKeyEvent(false, pcKey, false, game)
        end
    end
end

--=====================================================
-- LOGIC: EMOTE SYSTEM DATA & FUNCTIONS
--=====================================================
_G.EmoteData = {
    ["24 Hour Cinderella"] = {anim = "137195203725366", sound = "121099446613414"},
    ["Applause"]           = {anim = "96328361165090",  sound = "115490787020749"},
    ["Arm Swing"]          = {anim = "80552139463944",  sound = "74216458932348"},
    ["California Girls"]   = {anim = "123552803041504", sound = "87899327891544"},
    ["Ghoul"]              = {anim = "130415594909401", sound = "123004139176580"},
    ["Kyoufuu"]            = {anim = "137322894494527", sound = "129064643026442"},
    ["Mannrobics"]         = {anim = "134677515695156", sound = "109596159930017"},
    ["Quick Combo"]        = {anim = "105592621576604", sound = "88505795419631"},
    ["Schadenfreude"]      = {anim = "138303785534052", sound = "92070710839040"},
    ["Static"]             = {anim = "95096724457263",  sound = "70950516511572"},
    ["Thriller"]           = {anim = "99835792883875",  sound = "139985043810748"},
    ["Tor Monitor Ketua"]  = {anim = "81792358514569",  sound = "72665050838808"},
    ["Wave"]               = {anim = "99670106766588",  sound = nil},
    ["Backflip"]           = {anim = "74705617908505",  sound = nil},
    ["Friday Night"]       = {anim = "83229063951016",  sound = "85355610204255"},
    ["Broken Doll"]        = {anim = "131796630104825", sound = "88284355540646"},
    ["OnePlays"]           = {anim = "140625405103474", sound = "94749073728335"},
    ["Pop Off"]            = {anim = "130933486827090", sound = "137966860089117"},
    ["Rambunctious"]       = {anim = "81054496834622",  sound = nil},
    ["Rampage"]            = {anim = "79155929355612",  sound = nil},
    ["The Dab"]            = {anim = "93350677984372",  sound = nil},
    ["Velnurable"]         = {anim = "121773684313913", sound = "135265751184744"},
    ["WarCry"]             = {anim = "82600868380136",  sound = "120101930689931"},
    ["Go0n"]               = {special = "Troll"},
    ["Source"]             = {anim = "122615684039119", sound = nil},
    ["Broken Doll"]        = {anim = "131796630104825", sound = "88284355540646"},
    ["Pop off"]            = {anim = "130933486827090", sound = "137966860089117"},
    ["Kwik flip"]          = {anim = "73896868179198",  sound = "124209794918032"},
    ["Call"]               = {anim = "109403631357242", sound = nil},
    ["Point"]              = {anim = "128634708030376", sound = nil},
    ["Joe Shuffle"]        = {anim = "103792867340851", sound = "115081142141066"},
    ["Jump Style"]         = {anim = "123206327323742", sound = "117263055900573"}
}

local currentTrack = nil
local currentSound = nil
local trollLoop = nil

_G.playCustomEmote = function(name)
    local data = _G.EmoteData[name]
    if not data then return end

    local char = game.Players.LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        if _G.stopEmote then _G.stopEmote() end

        -- Troll Logic
        if data.special == "Troll" then
            local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
            
            trollLoop = task.spawn(function()
                while task.wait() do 
                    local anim = Instance.new("Animation")
                    anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                    currentTrack = animator:LoadAnimation(anim)
                    currentTrack.Priority = Enum.AnimationPriority.Action4
                    
                    currentTrack:Play()
                    currentTrack:AdjustSpeed(isR15 and 0.7 or 0.65)
                    currentTrack.TimePosition = 0.6
                    
                    task.wait(0.1)
                    while currentTrack and currentTrack.TimePosition < (not isR15 and 0.65 or 0.7) do 
                        task.wait(0.1) 
                    end
                    
                    if currentTrack then
                        currentTrack:Stop()
                        currentTrack:Destroy()
                        currentTrack = nil
                    end
                end
            end)
            return 
        end

        -- Normal Animation
        local animInstance = Instance.new("Animation")
        animInstance.AnimationId = "rbxassetid://" .. data.anim
        currentTrack = animator:LoadAnimation(animInstance)
        currentTrack.Priority = Enum.AnimationPriority.Action4
        currentTrack.Looped = true
        currentTrack:Play()

        if data.sound and root then
            currentSound = Instance.new("Sound", root)
            currentSound.SoundId = "rbxassetid://" .. data.sound
            currentSound.Volume = 2
            currentSound.Looped = true
            currentSound:Play()
        end
    end
end

_G.stopEmote = function()
    if trollLoop then task.cancel(trollLoop); trollLoop = nil end
    if currentTrack then currentTrack:Stop(); currentTrack:Destroy(); currentTrack = nil end
    if currentSound then currentSound:Stop(); currentSound:Destroy(); currentSound = nil end
end


--=====================================================
-- HELPER: SYNC VISUALS (SINKRONISASI PC & MOBILE)
--=====================================================
local function UpdateMoonwalkUI()
    if not _G.MoonwalkUI then return end
    local Frame = _G.MoonwalkUI:FindFirstChild("Frame", true)
    if not Frame then return end

    local FaceBtn = Frame:FindFirstChild("FaceUserBtn")
    local NormBtn = Frame:FindFirstChild("NormalBtn")

    if FaceBtn and NormBtn then
        if State.MoonwalkActive then
            -- MJ Mode Aktif: Panah Atas Ungu, Bawah Abu
            FaceBtn.ImageColor3 = Color3.fromRGB(188, 0, 255)
            NormBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        else
            -- Normal Mode Aktif: Panah Bawah Ungu, Atas Abu
            NormBtn.ImageColor3 = Color3.fromRGB(188, 0, 255)
            FaceBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

--=====================================================
-- OPTIMIZATION: DYNAMIC GLOBAL OBJECT CACHE
--=====================================================
local ObjectCache = { Generators = {}, Gates = {}, Pallets = {}, Hooks = {}, Windows = {}, PalletPoints = {}, Zombies = {}, GateTpParts = {}, BearTraps = {}, Pumpkins = {} }

-- Daftar nama SCP yang valid untuk mempermudah deteksi
local validSCPNames = {
    ["scp"] = true, ["scp2"] = true, ["scp3"] = true, ["scp4"] = true,
    ["scp5"] = true, ["scp6"] = true, ["scp7"] = true, ["scp8"] = true
}

task.spawn(function()
    while task.wait(2) do
        local newCache = { Generators = {}, Gates = {}, Pallets = {}, Hooks = {}, Windows = {}, PalletPoints = {}, Zombies = {}, GateTpParts = {}, BearTraps = {}, Pumpkins = {} }
        
        -- 🔥 1. JARING RAKSASA ZOMBIE (DETECT ALL POSSIBLE ZOMBIE TYPES) 🔥
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                
                -- Pastikan bukan player asli
                local isRealPlayer = game.Players:GetPlayerFromCharacter(obj)
                
                if not isRealPlayer then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    
                    if hum then
                        local isSCPName = validSCPNames[obj.Name]
                        -- A. Deteksi Atribut (Standard)
                        local isExplicitZombie = (obj:GetAttribute("Cured") == 3) or (obj:GetAttribute("CorpseCreated0492") ~= nil)
                        
                        -- B. Deteksi Objek Spesifik (RagdollTrigger / MaterialSounds)
                        -- Ini kunci buat NPC kayak scp4 yang lu kasih di ss
                        local hasZombieLogic = obj:FindFirstChild("RagdollTrigger") or obj:FindFirstChild("MaterialSounds")
                        
                        -- Jika memenuhi kriteria, masukkan ke daftar
                        if isSCPName or isExplicitZombie or hasZombieLogic then
                            newCache.Zombies[obj] = true
                        end
                    end
                end
            end
        end

        -- 🛠️ 2. JARING OBJEK MAP NORMAL (Generator, Pallet, BearTrap, dll) 🛠️
        local currentMap = workspace:FindFirstChild("Map")
        if currentMap then

            local pumpkinsFolder = currentMap:FindFirstChild("Pumpkins")
            if pumpkinsFolder then
                for _, pumpkin in ipairs(pumpkinsFolder:GetChildren()) do
                    newCache.Pumpkins[pumpkin] = true
                end
            end

            for _, child in ipairs(currentMap:GetDescendants()) do
                local nama = child.Name:lower()
                local fullPath = child:GetFullName()
                
                local isBlacklisted = fullPath:find("Rooftop.Details.Window") or nama:find("entrance") or fullPath:lower():find("entrance")
                
                -- Deteksi BearTrap:
                -- 1. Nama objek mengandung "beartrap" / "bear_trap" / "trap"
                -- 2. Direct child dari Map bernama "BearTrap" (Folder/Model container)
                -- 3. Child dari folder bernama BearTrap (trap individual di dalam folder)
                -- 4. Attribute IsTrap / TrapType
                local parentName = child.Parent and child.Parent.Name:lower() or ""
        
                local isBearTrap = nama:find("beartrap") or nama:find("bear_trap") or nama == "trap"
                    or child:GetAttribute("IsTrap") == true
                    or child:GetAttribute("TrapType") ~= nil
                    or (child.Parent and child.Parent == currentMap and child.Name == "BearTrap")
                    or (parentName:find("beartrap") or parentName:find("bear_trap"))
                if isBearTrap then
                    newCache.BearTraps[child] = true
                elseif child:IsA("Model") or child:IsA("Folder") then
                    if child:IsA("Model") and child:GetAttribute("RepairProgress") ~= nil then 
                        newCache.Generators[child] = true
                    elseif nama:find("pallet") and not nama:find("crate") and not isBlacklisted then 
                        newCache.Pallets[child] = true
                    elseif nama == "hook" then 
                        newCache.Hooks[child] = true
                    elseif nama:find("window") and not isBlacklisted then 
                        newCache.Windows[child] = true 
                    elseif nama == "gate" then
                        newCache.Gates[child] = true
                    end
                    
                elseif child:IsA("BasePart") then
                    if child.Name == "LeftGate" or child.Name == "RightGate" then 
                        newCache.Gates[child] = true
                    elseif nama == "bottom" and not isBlacklisted then 
                        newCache.Windows[child] = true
                    elseif nama == "palletpoint" or nama == "palletpointslide" then 
                        newCache.PalletPoints[child] = true 
                    elseif child.Name == "Tp" and child.Parent and child.Parent.Name == "ExitLever" then
                        newCache.GateTpParts[child] = true
                    end
                end
            end
        end
        ObjectCache = newCache
    end
end)

--=====================================================
-- OBSIDIAN UI INTEGRATION
--=====================================================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local librarySrc = game:HttpGet(repo .. "Library.lua")
local Library = loadstring(librarySrc)()

if not Library then
    warn("ERROR: Failed to load Obsidian UI Library! The executor might have failed to download or compile it.")
    if type(librarySrc) == "string" and #librarySrc < 100 then
        warn("Response was: " .. librarySrc)
    end
    return
end

local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings() -- Agar tema tidak tertimpa saat ganti config
SaveManager:SetIgnoreIndexes({ "MenuKeybind" }) -- Abaikan keybind menu agar tidak ter-reset
SaveManager:SetFolder("Boyfinity-ViolenceDistrict") -- Nama folder di folder workspace kamu

local Window = Library:CreateWindow({
    Title = "boyfinity",
    Icon = 120508213351603,
    Font = Enum.Font.Gotham,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    ToggleKeybind = Enum.KeyCode.G,
    ShowMobileButtons = true,
    MobileButtonsSide = "Left",
    Footer = "Violence District v3.0.2B | discord.gg/boyfinity" 

})

--=====================================================
-- 1. KILLER TAB
--=====================================================
KillerTab = Window:AddTab("Killer", "sword")

AttackGB = KillerTab:AddLeftGroupbox("Attack","swords")
AttackGB:AddToggle("InfiniteLunge", { 
    Text = "Infinite Lunge", 
    Default = State.InfiniteLunge, 
    Tooltip = "Endless attacks, bypasses animation delay between swings.",
    Callback = function(v) 
        State.InfiniteLunge = v 
        if v then Library:Notify("Infinite Lunge Activated!") end
    end 
})
AttackGB:AddToggle("NoCooldown", { 
    Text = "No Cooldown Attack", 
    Default = State.NoCooldown, 
    Tooltip = "Removes attack cooldown delay (fast swing).",
    Callback = function(v) 
        State.NoCooldown = v 
        if v then Library:Notify("No Cooldown Attack Activated!") end
    end 
})
AttackGB:AddToggle("DoubleSwing", { 
    Text = "Double Swing", 
    Default = State.DoubleSwing, 
    Tooltip = "Doubel tap your attack button to swing 2x",
    Callback = function(v) 
        State.DoubleSwing = v 
        if v then Library:Notify("Double Swing Activated!") end
    end 
})

HitboxGB = KillerTab:AddLeftGroupbox("Hitbox", "target")
HitboxGB:AddSlider("HitboxTransparency", { 
    Text = "Set Transparency", 
    Default = 0.5, Min = 0, Max = 1, Rounding = 1, 
    Tooltip = "Adjusts the transparency of the enemy hitbox.",
    Callback = function(v) State.HitboxTransparency = v end 
})
HitboxGB:AddSlider("HitboxSize", { 
    Text = "Size Hitbox", 
    Default = 10, Min = 2, Max = 50, Rounding = 0, 
    Tooltip = "Adjusts the size of the enemy hitbox.",
    Callback = function(v) State.HitboxSize = v end 
})
HitboxGB:AddToggle("HitboxEnabled", { 
    Text = "Enable Hitbox", 
    Default = State.HitboxEnabled, 
    Tooltip = "Expands the enemy's body area making them much easier to hit.",
    Callback = function(v) 
        State.HitboxEnabled = v 
        if v then Library:Notify("Hitbox Expander Activated!") end
        if not v and State.ResetHitbox then State.ResetHitbox() end
    end 
})

MiscKillerGB = KillerTab:AddLeftGroupbox("Misc", "wrench")

MiscKillerGB:AddSlider("KillerBreakSpeed", { 
    Text = "Killer Break Speed", 
    Default = 1, 
    Min = 1, 
    Max = 5, 
    Rounding = 1, 
    Tooltip = "Mempercepat animasi & durasi hancurin pallet / tendang generator.",
    Callback = function(v) 
        State.Killer.BreakSpeed = v 
    end 
})

MiscKillerGB:AddToggle("AutoBreak", { 
    Text = "Auto Break Generator", 
    Default = State.AutoBreak, 
    Tooltip = "Automatically damages generators near you.",
    Callback = function(v) 
        State.AutoBreak = v 
        if v then Library:Notify("Auto Break Generator Activated!") end
    end 
})
MiscKillerGB:AddToggle("NoStun", { 
    Text = "No Pallet Stun", 
    Default = State.NoStun, 
    Tooltip = "Prevents your character from getting stunned by dropped pallets.",
    Callback = function(v) 
        State.NoStun = v 
        if v then Library:Notify("Anti Pallet Stun Activated!") end
    end 
})
MiscKillerGB:AddToggle("AntiBlind", { 
    Text = "Anti Flashlight", 
    Default = State.AntiBlind, 
    Tooltip = "Removes the white screen (blind) effect from survivor flashlights.",
    Callback = function(v) 
        State.AntiBlind = v 
        if v then Library:Notify("Anti Flashlight Activated!") end
    end 
})
MiscKillerGB:AddToggle("NoSlow", { 
    Text = "Anti Slowdown", 
    Default = State.NoSlow, 
    Tooltip = "Prevents movement speed reduction while attacking or carrying a survivor.",
    Callback = function(v) 
        State.NoSlow = v 
        if v then Library:Notify("Anti Slowdown Activated!") end
    end 
})
MiscKillerGB:AddDivider()

MiscKillerGB:AddButton({ 
    Text = "Destroy All Pallets", 
    Tooltip = "Destroys all pallets on the map locally.",
    Func = function()
        local count = 0
        -- Menghapus pallet dari cache yang sudah kita buat
        for pallet in pairs(ObjectCache.Pallets) do
            if pallet and pallet.Parent then
                pallet:Destroy()
                count = count + 1
            end
        end
        Library:Notify(count .. " The pallets are destroyed locally! Just break through, bro.")
    end 
})
MiscKillerGB:AddDivider()
MiscKillerGB:AddToggle("HookSpam", { 
    Text = "Hook Spam", 
    Default = State.HookSpam, 
    Tooltip = "Repeatedly hooks a survivor extremely fast (remote spam).",
    Callback = function(v) 
        State.HookSpam = v 
        if v then Library:Notify("Hook Spam Activated!") end
    end 
})
MiscKillerGB:AddSlider("HookAmount", { 
    Text = "Hook Amount", 
    Default = 10, Min = 1, Max = 50, Rounding = 0, 
    Tooltip = "Amount of hook events executed per spam.",
    Callback = function(v) State.HookAmount = v end 
})
MiscKillerGB:AddToggle("SilentHook", { 
    Text = "Silent Hook", 
    Default = State.SilentHook, 
    Tooltip = "Forcefully removes the hooking animation for an instant process.",
    Callback = function(v) 
        State.SilentHook = v 
        if v then Library:Notify("Silent Hook Activated!") end
    end 
})
MiscKillerGB:AddToggle("ForceKillCarried", { 
    Text = "Force Kill Carried", 
    Default = State.ForceKillCarried, 
    Tooltip = "Instantly kills the carried survivor by exploiting the hook remote.",
    Callback = function(v) 
        State.ForceKillCarried = v 
        if v then Library:Notify("Force Kill Carried Activated!") end
    end 
})

KillAuraGB = KillerTab:AddRightGroupbox("Kill Aura", "skull")

KillAuraGB:AddToggle("KillAura", { 
    Text = "Kill Aura", 
    Default = false, 
    Tooltip = "Fully automates detecting, attacking, carrying, and hooking nearby survivors.",
    Callback = function(v) 
        State.KillAura = v 
        if v then Library:Notify("Kill Aura Activated!") end
    end 
}):AddKeyPicker("KillAuraKey", { 
    Default = "", 
    SyncToggleState = true, 
    Text = "Kill Aura Bind" 
})

KillAuraGB:AddDropdown("AttackMode", { 
    Text = "Attack Mode", 
    Default = "Legit", 
    Values = {"Legit", "Teleport"}, 
    Tooltip = "Kill Aura attack method. Legit = waits for enemy to get close. Teleport = auto teleports to enemy.",
    Callback = function(v) State.AttackMode = v end 
})

KillAuraGB:AddSlider("SpamHitCount", { 
    Text = "Spam Hit Count", 
    Default = 1, 
    Min = 1, 
    Max = 10, 
    Rounding = 0, 
    Tooltip = "Number of hit signals sent to the server per attack.",
    Callback = function(v) State.SpamHitCount = v end 
})

-- // KILLER SILENT AIM (VEIL SPEAR & BUTCHER CHAIN)
VeilAimGB = KillerTab:AddRightGroupbox("Veil Spear Silent Aim", "crosshair")
VeilAimGB:AddToggle("SpearSilentAim", {
    Text = "Veil Spear Silent Aim",
    Default = State.SpearSilentAim,
    Tooltip = "Silent aim projectile presisi untuk tombak Veil (Auto Arc dan High Mortar Arc).",
    Callback = function(v)
        State.SpearSilentAim = v
        if v then Library:Notify("Veil Spear Silent Aim Activated!") end
    end
})

VeilAimGB:AddToggle("ThroughTheVeil", {
    Text = "Target Through Wall",
    Default = State.ThroughTheVeil,
    Tooltip = "Bisa menarget musuh di balik rintangan / dinding (Wallbang pasif tombak).",
    Callback = function(v)
        State.ThroughTheVeil = v
    end
})

VeilAimGB:AddToggle("SpearPredictMovement", {
    Text = "Predict Movement",
    Default = State.SpearSmartPrediction,
    Tooltip = "Prediksi lari survivor menggunakan kalkulasi waktu tempuh parabola.",
    Callback = function(v)
        State.SpearSmartPrediction = v
    end
})

VeilAimGB:AddDropdown("SpearArcMode", {
    Text = "Arc Mode",
    Default = "Auto",
    Values = {"Auto", "Low", "High"},
    Tooltip = "Auto = jarak dekat Low Arc, jarak jauh High Mortar Arc melompati rintangan rumah/tembok.",
    Callback = function(v)
        State.SpearArcMode = v
    end
})

VeilAimGB:AddSlider("SpearTargetYOffset", {
    Text = "Target Y Offset (Near)",
    Default = -0.6,
    Min = -3,
    Max = 1,
    Rounding = 1,
    Tooltip = "Kalibrasi tinggi sasaran jarak dekat (0-120 studs) agar tepat di badan/torso.",
    Callback = function(v)
        State.SpearTargetYOffset = v
    end
})

VeilAimGB:AddSlider("SpearMaxTargetYOffset", {
    Text = "Target Y Offset (Far)",
    Default = -2.2,
    Min = -5,
    Max = 0,
    Rounding = 1,
    Tooltip = "Kalibrasi tinggi sasaran jarak jauh (250-320+ studs) agar tombak tidak melayang di atas kepala.",
    Callback = function(v)
        State.SpearMaxTargetYOffset = v
    end
})

VeilAimGB:AddCheckbox("SpearSnapLine", {
    Text = "Snap Line (Screen to Target)",
    Default = State.SnapLine,
    Tooltip = "Garis visual ke arah target survivor yang terkunci.",
    Callback = function(v)
        State.SnapLine = v
    end
})

VeilAimGB:AddCheckbox("SpearTargetDot", {
    Text = "Target Dot Indicator",
    Default = State.SpearShowTargetDot ~= false,
    Tooltip = "Titik/lingkaran penanda di tubuh survivor target yang terkunci.",
    Callback = function(v)
        State.SpearShowTargetDot = v
    end
})

VeilAimGB:AddCheckbox("SpearTracer", {
    Text = "Spear Tracer (Trail & Aura)",
    Default = State.SpearTracer ~= false,
    Tooltip = "Mengaktifkan efek trail/tracer neon ungu dan aura visual pada tombak Veil.",
    Callback = function(v)
        State.SpearTracer = v
    end
})

ButcherAimGB = KillerTab:AddRightGroupbox("Butcher Chain Silent Aim", "link")
ButcherAimGB:AddToggle("ButcherSilentAim", {
    Text = "Butcher Chain Silent Aim",
    Default = State.ButcherSilentAim,
    Tooltip = "Mengarahkan lemparan rantai Butcher secara otomatis ke survivor.",
    Callback = function(v)
        State.ButcherSilentAim = v
        if v then Library:Notify("Butcher Chain Silent Aim Activated!") end
    end
})

ButcherAimGB:AddCheckbox("ButcherWallCheck", {
    Text = "Wall Check (Butcher)",
    Default = State.ButcherWallCheck,
    Tooltip = "Hanya mengunci rantai ke survivor yang terlihat di layar (tidak terhalang tembok).",
    Callback = function(v)
        State.ButcherWallCheck = v
    end
})

ButcherAimGB:AddCheckbox("ButcherSnapLine", {
    Text = "Snap Line (Butcher)",
    Default = State.ButcherSnapLine ~= false,
    Tooltip = "Garis visual dari layar ke survivor target rantai Butcher.",
    Callback = function(v)
        State.ButcherSnapLine = v
    end
})

ButcherAimGB:AddCheckbox("ButcherTargetDot", {
    Text = "Target Dot Indicator (Butcher)",
    Default = State.ButcherShowTargetDot ~= false,
    Tooltip = "Titik/lingkaran penanda di tubuh survivor target rantai Butcher.",
    Callback = function(v)
        State.ButcherShowTargetDot = v
    end
})


--=====================================================
-- 2. SURVIVOR TAB
--=====================================================
SurvivorTab = Window:AddTab("Survivor","user")

GenStatusGB = SurvivorTab:AddLeftGroupbox("Generator Status", "activity")

GenStatusGB:AddToggle("ShowGenStatusUI", { 
    Text = "Show Floating Gen Status", 
    Default = false, 
    Tooltip = "Spawns a floating UI that displays the real-time progress of all generators on the map.",
    Callback = function(v) 
        State.ShowGenStatusUI = v 
        if _G.GenStatusGui then 
            _G.GenStatusGui.Enabled = v 
        end
        if v then Library:Notify("Generator Status Floating UI Activated!") end
    end 
})
GenStatusGB:AddToggle("ShowPerksInfoUI", {
    Text = "Show Killer Perks Info",
    Default = false,
    Tooltip = "Displays an animated top slider UI listing all perks currently equipped by the Killer and triggers real-time perk notifications.",
    Callback = function(v)
        State.ShowPerksInfoUI = v
        if _G.PerksInfoToggle then
            _G.PerksInfoToggle(v)
        end
        if v then Library:Notify("Killer Perks Info UI Activated!") end
    end
})


GenStatusGB:AddDivider()

GenStatusLabel = GenStatusGB:AddLabel({
    Text = "Scanning for generators...",
    DoesWrap = true,
})

task.spawn(function()
    while task.wait(1) do
        local data = State.GeneratorData or {}
        if #data == 0 then
            GenStatusLabel:SetText("Waiting for map to load...")
        else
            local content = ""
            -- Loop lompat 2 langkah untuk bikin baris berpasangan
            for i = 1, #data, 2 do
                local g1 = data[i]
                local g2 = data[i+1]

                -- Format Gen pertama
                local str1 = string.format("Gen %d: %d%% %s", i, g1.Progress, g1.Progress >= 100 and "✔️" or "🛠️")
                local line = str1

                -- Kalau ada Gen pasangannya, tambahin di sampingnya
                if g2 then
                    local str2 = string.format(" | Gen %d: %d%% %s", i+1, g2.Progress, g2.Progress >= 100 and "✔️" or "🛠️")
                    line = line .. str2
                end
                content = content .. line .. "\n"
            end
            GenStatusLabel:SetText(content)
        end
    end
end)


SkillCheckGB = SurvivorTab:AddLeftGroupbox("Feature SkillCheck", "vote")

SkillCheckGB:AddToggle("NoSkillCheck", { 
    Text = "No SkillCheck", 
    Default = false, 
    Tooltip = "Automatically succeed all generator and healing skill checks.",
    Callback = function(v) 
        State.NoSkillCheck = v 
        if v then Library:Notify("No SkillCheck Activated!") end
    end 
})


SkillCheckGB:AddToggle("PerfectSkillCheck", { 
    Text = "Auto Perfect SkillCheck", 
    Default = false, 
    Tooltip = "Automatically hits perfect skill checks for both repairing and healing.",
    Callback = function(v) 
        State.PerfectSkillCheck = v 
        if v then Library:Notify("Auto Perfect SkillCheck Activated!") end
    end 
})

SkillCheckGB:AddDropdown("SkillCheckMode", {
    Text = "SkillCheck Mode",
    Default = "Legit",
    Values = {"Legit", "Instant"},
    Tooltip = "Legit = Waits for needle naturally. Instant = Instantly teleports needle to perfect zone",
    Callback = function(v) State.SkillCheckMode = v end
})

SkillCheckGB:AddToggle("InstantScourge", { 
    Text = "Instant King's Scourge", 
    Default = false, 
    Tooltip = "Instantly clears King's Scourge without moving the needle, giving a massive 100% progress boost.",
    Callback = function(v) 
        State.InstantScourge = v 
        if v then Library:Notify("Instant King's Scourge Activated!") end
    end 
})
SkillCheckGB:AddToggle("AutoBearTrap", { 
    Text = "Auto SkillCheck BearTrap", 
    Default = false, 
    Tooltip = "Automatically hits perfect skill checks to escape Butcher's Bear Trap instantly.",
    Callback = function(v) 
        State.AutoBearTrap = v 
        if v then Library:Notify("Auto Escape BearTrap Activated!") end
    end 
})



ToolsGB = SurvivorTab:AddLeftGroupbox("Tools", "hammer")
ToolsGB:AddToggle("ManualSelfHeal", { 
    Text = "Healing Yourself", 
    Default = State.ManualSelfHeal, 
    Tooltip = "Hold the designated key to heal yourself manually anywhere.",
    Callback = function(v) 
        State.ManualSelfHeal = v 
        if v then Library:Notify("Healing Yourself Activated!") end
    end 
}):AddKeyPicker("SelfHealKey", { 
    Default = "H", 
    NoUI = true, 
    Text = "Healing Yourself Key" 
})

-- Letakkan di bawah AutoGenGB atau GenTPGB di SurvivorTab
PumpkinGB = SurvivorTab:AddRightGroupbox("Pumpkin Event", "gift")

PumpkinGB:AddToggle("AutoFarmPumpkin", { 
    Text = "Auto Farm Pumpkin", 
    Default = State.AutoFarmPumpkin, 
    Tooltip = "Otomatis teleport ke seluruh labu di map dan melakukan stomp.",
    Callback = function(v) 
        State.AutoFarmPumpkin = v 
        if v then Library:Notify("Auto Farm Pumpkin Activated!") end
    end 
})

AutoSkillGB = SurvivorTab:AddLeftGroupbox("Survivor Auto Skill", "zap")

AutoSkillGB:AddToggle("AutoRun", { 
    Text = "Auto Sprint", 
    Default = State.AutoRun, 
    Tooltip = "Automatically holds the sprint key for you.",
    Callback = function(v) 
        State.AutoRun = v 
        if v then Library:Notify("Auto Sprint Activated!") end
    end 
})

AutoSkillGB:AddToggle("FastVault", { 
    Text = "Flowstate (Anti-Slow Vault)", 
    Default = State.FastVault, 
    Tooltip = "Forces 100% Fast Vault, blocks slow vault animations, enforces parkour animation ID (83873880822918), and sets fast vault speed attribute to 1.1.",
    Callback = function(v) 
        State.FastVault = v 
        if v then Library:Notify("Flowstate (Anti-Slow Vault) Activated!") end
    end 
})
AutoSkillGB:AddToggle("NoSlowSurv", { 
    Text = "No Slowdown", 
    Default = State.NoSlowSurv, 
    Tooltip = "Prevents any slowdown effects on your survivor.",
    Callback = function(v) 
        State.NoSlowSurv = v 
        if v then Library:Notify("No Slowdown Activated!") end
    end 
})
AutoSkillGB:AddToggle("AutoPallet", { 
    Text = "Auto Pallet", 
    Default = State.AutoPallet, 
    Tooltip = "Automatically drops pallets when the killer is within range.",
    Callback = function(v) 
        State.AutoPallet = v 
        if v then Library:Notify("Auto Pallet Activated!") end
    end 
})
AutoSkillGB:AddToggle("AutoDodge", { 
    Text = "Auto Dodge Abysswalker", 
    Default = State.AutoDodge, 
    Tooltip = "Automatically ducks or dodges specific killer attacks like Abysswalker.",
    Callback = function(v) 
        State.AutoDodge = v 
        if v then Library:Notify("Auto Dodge Activated!") end
    end 
})

--=====================================================
-- DAGGER (AUTO PARRY) GROUPBOX
--=====================================================
DaggerGB = SurvivorTab:AddLeftGroupbox("Dagger", "shield-check")

DaggerGB:AddToggle("AutoParry", { 
    Text = "Auto Parry", 
    Default = State.AutoParry, 
    Tooltip = "Automatically parries incoming killer attacks within range.",
    Callback = function(v) 
        State.AutoParry = v 
        if v then Library:Notify("Auto Parry Activated!") end
    end 
}):AddKeyPicker("AutoParryKey", { 
    Default = "C", 
    SyncToggleState = true,
    Text = "Auto Parry Bind" 
})

DaggerGB:AddSlider("FaceKillerSens", { 
    Text = "Face Killer Sensitivity", 
    Default = State.FaceKillerSens, 
    Min = -1.0, Max = 1.0, Rounding = 1, 
    Tooltip = "Higher value = Must look more directly at killer, 0.1 Standard (~85 degrees), -1.0 = 360 degrees (All directions valid) (Only used when Aim Prediction is OFF)",
    Callback = function(v) State.FaceKillerSens = v end 
})

DaggerGB:AddToggle("AimPrediction", { 
    Text = "Aim Prediction", 
    Default = State.AimPrediction, 
    Tooltip = "Predicts if the killer attack will actually hit you before parrying. More accurate than simple angle check. When OFF, falls back to Face Killer Sensitivity.",
    Callback = function(v) 
        State.AimPrediction = v 
        if v then Library:Notify("Aim Prediction Activated!") end
    end 
})

DaggerGB:AddSlider("AimStrictness", { 
    Text = "Aim Strictness", 
    Default = State.AimStrictness, 
    Min = 1.0, Max = 3.0, Rounding = 1, 
    Tooltip = "How accurately the killer must aim at you to trigger parry. Higher = only parry when attack is aimed directly at you. Lower = parry even if slightly off-target.",
    Callback = function(v) State.AimStrictness = v end 
})

DaggerGB:AddToggle("FakeParry", { 
    Text = "Fake Parry", 
    Default = State.FakeParry, 
    Tooltip = "Enable fake parry. Press keybind to trigger fake parry (killer thinks you parried but you didnt).",
    Callback = function(v) 
        State.FakeParry = v 
        if v then Library:Notify("Fake Parry Activated!") end
    end 
}):AddKeyPicker("FakeParryKey", { 
    Default = "X", 
    Text = "Fake Parry Bind" 
})

DaggerGB:AddSlider("DefensiveReflexDelay", { 
    Text = "Parry Delay", 
    Default = State.DefensiveReflexDelay, 
    Min = 0, Max = 0.5, Rounding = 2, 
    Tooltip = "Delay in seconds before executing the parry after detecting an attack.",
    Callback = function(v) State.DefensiveReflexDelay = v end 
})

DaggerGB:AddDropdown("ParryMode", { 
    Text = "Parry Mode", 
    Default = 1, 
    Values = {"Animation", "No Animation"}, 
    Tooltip = "Toggle between standard parry animation or silent/hidden parry.",
    Callback = function(v) State.ParryMode = v end 
})

DaggerGB:AddSlider("ParryRadius", { 
    Text = "Parry Radius", 
    Default = State.ParryRadius, 
    Min = 1, Max = 50, Rounding = 0, 
    Tooltip = "Maximum distance in studs to detect and parry incoming attacks.",
    Callback = function(v) State.ParryRadius = v end 
})

DaggerGB:AddToggle("ShowKillerAim", { 
    Text = "Show Killer Aim Visualizer", 
    Default = State.ShowKillerAim, 
    Tooltip = "Displays a visual cone indicating the killer's aim direction.",
    Callback = function(v) 
        State.ShowKillerAim = v 
        if v then Library:Notify("Killer Aim Visualizer Activated!") end
    end 
})

GodGB = SurvivorTab:AddLeftGroupbox("Survival", "heart")

GodGB:AddToggle("FakeKnockdown", {      Text = "Fake Knockdown",      Default = false,      Tooltip = "Simulates the knockdown state without actually being downed, tricking killers into thinking you're vulnerable.",     Callback = function(v)          State.FakeKnockdown = v          if v then Library:Notify("Fake Knockdown Activated!") end     end  }):AddKeyPicker("FakeKnockKey", {      Default = "Z",      SyncToggleState = false,     Text = "Fake Knockdown Bind"  }) 
--=====================================================
-- SURVIVOR RIGHT COLUMN: EMOTES
--=====================================================
EmoteGB = SurvivorTab:AddRightGroupbox("Emotes", "smile")

local emoteList = {}
for name, _ in pairs(_G.EmoteData) do table.insert(emoteList, name) end
table.sort(emoteList)

EmoteGB:AddDropdown("SelectedEmote", {
    Text = "Select Emote",
    Default = "Wave",
    Values = emoteList,
    Tooltip = "Choose an emote animation to play.",
    Callback = function(v)
        State.SelectedEmote = v
    end
})

EmoteGB:AddToggle("AutoStopEmote", {
    Text = "Auto Stop on Move",
    Default = true,
    Tooltip = "If enabled, emotes will automatically stop when you move. If disabled, you can emote while walking.",
    Callback = function(v)
        State.AutoStopEmote = v
    end
})

EmoteGB:AddToggle("EmoteKeybind", {
    Text = "Emote Keybind",
    Default = State.EmoteKeybind,
    Tooltip = "Enables playing the selected emote via keybind.",
    Callback = function(v)
        State.EmoteKeybind = v
        if v then Library:Notify("Emote Keybind Activated!") end
    end
}):AddKeyPicker("CustomEmoteKey", { 
    Default = "V",
    Text = "Emote Bind" 
})

EmoteGB:AddDivider("Generator Teleport")
EmoteGB:AddButton({ 
    Text = "Teleport Nearest Generator",
    Tooltip = "Instantly teleports you to the closest generator on the map.",
    Func = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local nearest = nil
        local shortestDistance = math.huge

        for _, info in ipairs(State.GeneratorData) do
            local genPart = info.Instance.PrimaryPart or info.Instance:FindFirstChildWhichIsA("BasePart")
            if genPart then
                local dist = (genPart.Position - hrp.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    nearest = genPart
                end
            end
        end

        if nearest then
            hrp.CFrame = nearest.CFrame + Vector3.new(0, 10, 0)
            Library:Notify("Teleported to Nearest Generator!")
        end
    end })

--=====================================================
-- GENERATOR TELEPORT GROUPBOX (RIGHT)
--=====================================================
GenTPGB = SurvivorTab:AddRightGroupbox("Generator Teleport", "zap")

GenTPGB:AddDropdown("GenTPMode", {
    Text = "Teleport Mode",
    Default = "Nearest",
    Values = {"Nearest", "Random"},
    Tooltip = "Choose whether to teleport to the nearest or a random generator.",
    Callback = function(Value)
        State.GenTPMode = Value
    end
})

GenTPGB:AddToggle("EnableGenTP", {
    Text = "Teleport Keybind",
    Default = State.EnableGenTP,
    Tooltip = "Enable to trigger teleport using the assigned keybind.",
    Callback = function(Value)
        State.EnableGenTP = Value
        if Value then Library:Notify("Gen Teleport Keybind Activated!") end
    end
}):AddKeyPicker("GenTPKeybind", {
    Default = "T", 
    Text = "TP Keybind"
})

--=====================================================
-- AVATAR CHANGER (OUTFIT COPIER) GROUPBOX
--=====================================================
AvatarGB = SurvivorTab:AddRightGroupbox("Avatar Changer", "shirt")

local ActiveAvatarName = game.Players.LocalPlayer.Name
-- FUNGSI HELPER: WELD AKSESORIS MANUAL (ANTI-JATUH/ANTI-GAGAL)
local function ForceAttachAccessory(character, accessory)
    local handle = accessory:FindFirstChild("Handle")
    if not handle then return end

    local accAttachment = handle:FindFirstChildOfClass("Attachment")
    if not accAttachment then return end

    -- Cari titik kait (attachment) yang cocok di badan karakter lu (misal: HatAttachment di Head)
    local charAttachment = nil
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local att = part:FindFirstChild(accAttachment.Name)
            if att and att:IsA("Attachment") then
                charAttachment = att
                break
            end
        end
    end

    -- Jika ketemu titik kaitnya, kita LAS paksa!
    if charAttachment then
        -- Pindahkan aksesoris ke dalam karakter lu
        accessory.Parent = character
        
        -- Sesuaikan posisinya
        handle.CFrame = charAttachment.Parent.CFrame * charAttachment.CFrame * accAttachment.CFrame:Inverse()

        -- Buat sistem las (Weld) buatan sendiri biar nempel permanen
        local weld = Instance.new("Weld")
        weld.Name = "Boyfinity_AccWeld"
        weld.Part0 = charAttachment.Parent
        weld.Part1 = handle
        weld.C0 = charAttachment.CFrame
        weld.C1 = accAttachment.CFrame
        weld.Parent = handle
    end
end

-- 1. FUNGSI INTI GANTI AVATAR
local function ChangeAvatarTo(username)
    task.spawn(function()
        local success, userId = pcall(function()
            return game.Players:GetUserIdFromNameAsync(username)
        end)

        if success and userId then
            local descSuccess, description = pcall(function()
                return game.Players:GetHumanoidDescriptionFromUserId(userId)
            end)

            if descSuccess and description then
                local char = game.Players.LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if char and hum then
                    local rigType = hum.RigType
                    -- Bikin Dummy dari server
                    local dummy = game.Players:CreateHumanoidModelFromDescription(description, rigType)
                    
                    if dummy then
                        -- 🔥 BERSIHKAN AVATAR LAMA TOTAL
                        for _, v in pairs(char:GetChildren()) do
                            if v:IsA("Accessory") or v:IsA("Hat") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") then 
                                v:Destroy() 
                            end
                        end

                        local head = char:FindFirstChild("Head")
                        if head then
                            for _, v in pairs(head:GetChildren()) do
                                if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end
                            end
                        end

                        -- 🔥 COPY WARNA KULIT
                        local dummyColors = dummy:FindFirstChildOfClass("BodyColors")
                        local myColors = char:FindFirstChildOfClass("BodyColors")
                        if dummyColors then
                            if myColors then myColors:Destroy() end
                            dummyColors:Clone().Parent = char
                        end

                        -- 🔥 COPY WAJAH & KEPALA
                        local dummyHead = dummy:FindFirstChild("Head")
                        if head and dummyHead then
                            for _, v in pairs(dummyHead:GetChildren()) do
                                if v:IsA("Decal") or v:IsA("SpecialMesh") then
                                    v:Clone().Parent = head
                                end
                            end
                        end

                        -- 🔥 COPY PAKAIAN & BENTUK BADAN
                        for _, v in pairs(dummy:GetChildren()) do
                            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
                                v:Clone().Parent = char
                            end
                        end

                        -- 🔥 COPY AKSESORIS DENGAN MANUAL WELDING (FIX!)
                        for _, v in pairs(dummy:GetChildren()) do
                            if v:IsA("Accessory") or v:IsA("Hat") then
                                local accClone = v:Clone()
                                -- Panggil fungsi las buatan kita
                                ForceAttachAccessory(char, accClone)
                            end
                        end

                        dummy:Destroy()
                        Library:Notify("Avatar successfully changed to: " .. username)
                    else
                        Library:Notify("Failed to load asset from the Roblox server.")
                    end
                end
            else
                Library:Notify("Failed to fetch outfit from this user.")
            end
        else
            Library:Notify("Username not found!")
        end
    end)
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    -- Jika ActiveAvatarName bukan nama asli kamu, berarti kamu sedang menggunakan avatar custom
    if ActiveAvatarName and ActiveAvatarName ~= game.Players.LocalPlayer.Name then
        -- Tunggu sampai karakter benar-benar ter-load di dunia
        newChar:WaitForChild("HumanoidRootPart", 5)
        newChar:WaitForChild("Humanoid", 5)
        task.wait(1.5) -- Jeda aman agar tidak bentrok dengan loading game
        
        -- Terapkan ulang avatar secara otomatis tanpa perlu klik apa-apa
        ChangeAvatarTo(ActiveAvatarName)
    end
end)

-- 2. DROPDOWN FAMOUS OUTFITS
local famousAvatars = {
    "Pilih Avatar...",
    "mrflimflam",      
    "KreekCraft",      
    "DenisDaily",      
    "Skeletor",        
    "Linkmon99",        
    "TalonMidnight",    
    "The_Emblaze",      
    "loleris",          
    "Wildes",           
    "Cerealboii",       
    "DevNamedDavid",
    "Horrace_Cat"
}

AvatarGB:AddDropdown("FamousAvatarList", {
    Text = "Famous Outfits",
    Default = "Select Avatar...",
    Values = famousAvatars,
    Tooltip = "Copies the outfit of famous Roblox players.",
    Callback = function(Value)
        if Value and Value ~= "Select Avatar..." then
            Library:Notify("Copying outfit " .. tostring(Value) .. "...")
            ChangeAvatarTo(Value)
        end
    end
})

-- 3. INPUT MANUAL USERNAME
AvatarGB:AddInput("CustomAvatarInput", {
    Default = "",
    Numeric = false,
    Tooltip = "Type any Roblox username and press Enter to copy their outfit.",
    Finished = true,
    ClearTextOnFocus = true,
    Text = "Copy by Username",
    Placeholder = "Type roblox username...",
    Callback = function(Value)
        if Value and Value ~= "" then
            Library:Notify("Searching username: " .. Value .. "...")
            ChangeAvatarTo(Value)
        end
    end
})

-- 4. RESET AVATAR (KEMBALI KE ASLI)
AvatarGB:AddButton({ 
    Text = "Reset to Original", 
    Func = function()
        Library:Notify("Resetting to original outfit...")
        ChangeAvatarTo(game.Players.LocalPlayer.Name)
    end 
})

--=====================================================
-- CLIENT STATS CHANGER (FUN ONLY)
--=====================================================
FunStatsGB = SurvivorTab:AddRightGroupbox("Client Stats (Fun Only)", "coins")

FunStatsGB:AddInput("GearsInput", {
    Default = "",
    Numeric = true, 
    Finished = true, -- Hanya update saat kamu tekan Enter
    ClearTextOnFocus = true,
    Text = "Set Gears Amount",
    Placeholder = "Set Gears Amount, example: 999999",
    Tooltip = "Locally fakes your Gears amount (client-side only).",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            LocalPlayer:SetAttribute("Gears", num)
            Library:Notify("Gears are changed locally to: " .. Value)
        end
    end,
})

FunStatsGB:AddInput("LevelInput", {
    Default = "",
    Numeric = true,
    Finished = true,
    ClearTextOnFocus = true,
    Text = "Set Level",
    Placeholder = "Set Level Amount, example: 999999",
    Tooltip = "Locally fakes your Level (client-side only).",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            LocalPlayer:SetAttribute("Level", num)
            Library:Notify("Level is changed locally to: " .. Value)
        end
    end,
})

FunStatsGB:AddInput("ScrewsInput", {
    Default = "",
    Numeric = true,
    Finished = true,
    ClearTextOnFocus = true,
    Text = "Set Screws Amount",
    Placeholder = "Set Screws Amount, example: 999999",
    Tooltip = "Locally fakes your Screws amount (client-side only).",
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            LocalPlayer:SetAttribute("Screws", num)
            Library:Notify("Screws are changed locally to: " .. Value)
        end
    end,
})

AutoGenGB = SurvivorTab:AddRightGroupbox("Auto Generator & Escape","boom-box")

AutoGenGB:AddToggle("AutoRepair", { 
    Text = "Auto Repair", 
    Default = State.AutoRepair, 
    Tooltip = "Automatically repairs generators without any input.",
    Callback = function(v) 
        State.AutoRepair = v 
        
        -- 🔥 LOGIC TAMBAHAN: Jika Auto Repair ON, paksa Gen SkillCheck ON
        if v then
            State.PerfectSkillCheck = true
            
            -- Update visual di UI biar centangnya muncul (Khusus Obsidian/Linoria Library)
            if Library.Toggles and Library.Toggles.PerfectSkillCheck then
                Library.Toggles.PerfectSkillCheck:SetValue(true)
            end
            
            Library:Notify("Auto Repair ON: Perfect SkillCheck Activated!")
        end
    end
}):AddKeyPicker("AutoRepairKey", { 
    Default = "", 
    SyncToggleState = true, 
    Text = "Auto Repair Bind" 
})

AutoGenGB:AddDropdown("RepairMethod", { 
    Text = "Repair Method", 
    Default = "Legit", 
    Values = {"Legit", "Silent"},
    Tooltip = "Method used for auto repairing generators. Legit = performs normal repairs with animations. Silent = repairs without animations or interactions (faster but less legit).", 
    Callback = function(v) State.RepairMethod = v end 
})

AutoGenGB:AddToggle("PanicEscape", { 
    Text = "Panic Escape", 
    Default = State.PanicEscape, 
    Tooltip = "Automatically runs away if the killer gets too close while repairing.", 
    Callback = function(v) State.PanicEscape = v end 
})

AutoGenGB:AddSlider("KillerDistance", { 
    Text = "Killer Distance", 
    Default = 30, 
    Min = 10, 
    Max = 500, 
    Rounding = 0, 
    Tooltip = "Distance at which panic escape triggers.", 
    Callback = function(v) State.KillerDistance = v end 
})

--=====================================================
-- 3. AIMBOT TAB
--=====================================================
AimTab = Window:AddTab("Aimbot","crosshair")
if not State.GlobalAim then State.GlobalAim = {} end

GlobalAimGB = AimTab:AddLeftGroupbox("Global Aimbot", "crosshair")

GlobalAimGB:AddToggle("Aimlock", { 
    Text = "Aimlock (Hold L-Click)", 
    Default = false, 
    Tooltip = "Locks your camera onto the target while holding the aim key.",
    Callback = function(Value) 
        State.GlobalAim.Aimlock = Value 
        if Value then Library:Notify("Global Aimlock Activated!") end
    end 
})

GlobalAimGB:AddSlider("AimFOV", { 
    Text = "Aim FOV", 
    Default = 150, 
    Min = 10, 
    Max = 500, 
    Rounding = 0, 
    Tooltip = "Adjusts the field of view size for the global aimbot.",
    Callback = function(Value) 
        State.GlobalAim.AimFOV = Value 
    end 
})

GlobalAimGB:AddSlider("AimSmoothing", { 
    Text = "Smoothing", 
    Default = 1, 
    Min = 1, 
    Max = 10, 
    Rounding = 1, 
    Tooltip = "Adjusts how smooth the camera movement is. 1 is instant, higher is smoother.",
    Callback = function(Value) 
        State.GlobalAim.Smoothing = Value 
    end 
})

GlobalAimGB:AddDropdown("AimTargetPart", { 
    Text = "Target Part", 
    Default = "Head", 
    Values = {"Head", "HumanoidRootPart", "UpperTorso"}, 
    Tooltip = "Selects the body part the global aimbot will lock onto.",
    Callback = function(Value) 
        State.GlobalAim.TargetPart = Value 
    end 
})

GlobalAimGB:AddCheckbox("VisibilityCheck", {
    Text = "Visibility Check", 
    Default = false,
    Tooltip = "Only aim at visible targets (will not lock onto players behind walls).",
    Callback = function(Value) 
        State.GlobalAim.VisibilityCheck = Value 
        if Value then Library:Notify("Visibility Check Activated!") end
    end
})

GlobalAimGB:AddCheckbox("ShowAimFOV", {
    Text = "Show FOV", 
    Default = true,
    Tooltip = "Displays the FOV circle for the global aimbot.",
    Callback = function(Value) 
        State.GlobalAim.ShowFOV = Value 
        if Value then Library:Notify("Show Global FOV Activated!") end
    end
})

GlobalAimGB:AddCheckbox("ShowTargetIndicator", {
    Text = "Show Target Indicator", 
    Default = true,
    Tooltip = "Displays a visual indicator on the locked target.",
    Callback = function(Value) 
        State.GlobalAim.ShowIndicator = Value 
        if Value then Library:Notify("Show Target Indicator Activated!") end
    end
})

GlobalAimGB:AddCheckbox("ShowAimLine", {
    Text = "Show Aim Line", 
    Default = false,
    Tooltip = "Draws a line from your cursor to the locked target.",
    Callback = function(Value) 
        State.GlobalAim.ShowAimLine = Value 
        if Value then Library:Notify("Show Aim Line Activated!") end
    end
})

AimGB = AimTab:AddLeftGroupbox("Aimbot Setting", "crosshair")
AimGB:AddToggle("EnableCrosshair", { 
    Text = "Crosshair", 
    Default = State.EnableCrosshair, 
    Tooltip = "Displays a custom crosshair in the center of your screen.",
    Callback = function(v) 
        State.EnableCrosshair = v 
        if v then Library:Notify("Custom Crosshair Activated!") end
    end 
})
AimGB:AddToggle("AimbotThroughWall", { 
    Text = "Through Wall", 
    Default = State.AimbotThroughWall, 
    Tooltip = "Allows the aimbot to lock onto targets through walls and obstacles.",
    Callback = function(v) 
        State.AimbotThroughWall = v 
        if v then Library:Notify("Aimbot Through Wall Activated!") end
    end 
})

FlashGB = AimTab:AddLeftGroupbox("Flashlight", "flashlight")
FlashGB:AddToggle("FlashlightAimbot", { 
    Text = "Flashlight Aimbot", 
    Default = State.FlashlightAimbot, 
    Tooltip = "Automatically locks your camera to blind the killer's face while aiming.",
    Callback = function(v) 
        State.FlashlightAimbot = v 
        if v then Library:Notify("Flashlight Aimbot Activated!") end
    end 
})


TOFGB = AimTab:AddRightGroupbox("Twist of Fate", "toggle-right")
TOFGB:AddToggle("TwistOfFateAimbot", { 
    Text = "Twist of Fate", 
    Default = State.TwistOfFateAimbot, 
    Tooltip = "Camera-locking aimbot for the Twist of Fate item.",
    Callback = function(v) 
        State.TwistOfFateAimbot = v 
        if v then Library:Notify("Twist of Fate Aimbot Activated!") end
    end 
})
TOFGB:AddToggle("ToFSilentAim", { 
    Text = "Silent Aim", 
    Default = State.ToFSilentAim, 
    Tooltip = "Silently redirects Twist of Fate bullets to the target without moving your camera.",
    Callback = function(v) 
        State.ToFSilentAim = v 
        if v then Library:Notify("ToF Silent Aim Activated!") end
    end 
})
TOFGB:AddDropdown("TargetTeam", { 
    Text = "Select Target", 
    Default = "Killer", 
    Values = {"Killer", "Survivor"}, 
    Tooltip = "Selects which team the Twist of Fate aimbot will target.",
    Callback = function(v) State.TargetTeam = v end 
})
TOFGB:AddDropdown("TargetPart", { 
    Text = "Select Part", 
    Default = "HumanoidRootPart", 
    Values = {"Head", "UpperTorso", "HumanoidRootPart"}, 
    Tooltip = "Selects the body part the Twist of Fate aimbot will hit.",
    Callback = function(v) State.TargetPart = v end 
})

--=====================================================
-- 1. UI: AIMBOT RIGHT COLUMN (FOV & FILTERING)
--=====================================================
AimRightGB = AimTab:AddRightGroupbox("FOV Setting", "circle")

AimRightGB:AddToggle("ShowFOV", { 
    Text = "Show FOV Circle", 
    Default = State.ShowFOV or false, 
    Tooltip = "Displays the field of view circle for the main aimbot.",
    Callback = function(v) 
        State.ShowFOV = v 
        if v then Library:Notify("Show FOV Circle Activated!") end
    end 
})

AimRightGB:AddSlider("FOVRadius", { 
    Text = "FOV Radius", 
    Default = 150, Min = 10, Max = 800, Rounding = 0, 
    Tooltip = "Adjusts the radius of the main aimbot FOV.",
    Callback = function(v) State.AimbotFOV = v end 
})

AimRightGB:AddLabel("FOV Color"):AddColorPicker("FOVColor", {
    Default = Color3.fromRGB(189, 5, 245),
    Callback = function(v) if _G.FOVCircle then _G.FOVCircle.Color = v end end
})

AimRightGB:AddToggle("FilledFOV", { 
    Text = "Filled FOV", 
    Default = false, 
    Tooltip = "Fills the inside of the FOV circle with a translucent color.",
    Callback = function(v) 
        State.FilledFOV = v 
        if v then Library:Notify("Filled FOV Activated!") end
    end 
})

FilterGB = AimTab:AddRightGroupbox("Target Filtering", "filter")

FilterGB:AddToggle("IgnoreKnocked", { 
    Text = "Ignore Knocked Players", 
    Default = false, 
    Tooltip = "Prevents the aimbot from locking onto downed/knocked players.",
    Callback = function(v) 
        State.IgnoreKnocked = v 
        if v then Library:Notify("Ignore Knocked Players Activated!") end
    end 
})

FilterGB:AddDropdown("TargetPriority", { 
    Text = "Target Priority", 
    Default = "Mouse", 
    Values = {"Mouse", "Distance"}, 
    Tooltip = "Prioritizes targets based on cursor distance (Mouse) or character distance (Distance).",
    Callback = function(v) State.TargetPriority = v end 
})

FilterGB:AddToggle("TeamCheck", { 
    Text = "Team Check", 
    Default = false, 
    Tooltip = "Prevents the aimbot from locking onto your teammates.",
    Callback = function(v) 
        State.TeamCheck = v 
        if v then Library:Notify("Team Check Activated!") end
    end 
})

--=====================================================
-- 3.X BUG EXPLOITS (Added for Wallbang)
--=====================================================


--=====================================================
-- 4. VISUAL TAB
--=====================================================
VisualTab = Window:AddTab("Visual","eye")

ScreenDispGB = VisualTab:AddLeftGroupbox("Screen Display", "monitor")
ScreenDispGB:AddSlider("FullBright", { 
    Text = "Full Bright", 
    Default = 1, Min = 0, Max = 100, Rounding = 0, 
    Tooltip = "Removes all shadows and makes the map fully bright.",
    Callback = function(v) State.FullBright = v end 
})

-- // INVISCAM & ANTI-SMOOTH CAMERA ZOOM
CameraGB = VisualTab:AddLeftGroupbox("Camera & Zoom", "camera")
CameraGB:AddToggle("InvisCam", {
    Text = "InvisCam",
    Default = State.InvisCam,
    Tooltip = "Membuat objek/tembok transparan jika kamera terhalang.",
    Callback = function(v)
        State.InvisCam = v
        if _G.SetInvisCam then _G.SetInvisCam(v) end
        if v then Library:Notify("InvisCam Activated!") end
    end
})

CameraGB:AddToggle("AntiSmoothZoom", {
    Text = "Zoom Out (Free In/Out)",
    Default = State.AntiSmoothZoom,
    Tooltip = "Melepas batasan zoom game dan mematikan SmoothCamera. Bisa zoom in/out bebas hingga jarak slider.",
    Callback = function(v)
        State.AntiSmoothZoom = v
        if _G.SetAntiSmoothZoom then _G.SetAntiSmoothZoom(v) end
        if v then Library:Notify("Zoom Activated! Bebas Zoom In/Out") end
    end
})

CameraGB:AddButton({
    Text = "Snap Zoom x25",
    Tooltip = "Seketika melompatkan kamera ke jarak 25 studs.",
    Func = function()
        if _G.ApplyMaxZoomDistance then
            State.ZoomDistance = 25
            _G.ApplyMaxZoomDistance(25)
            Library:Notify("Snapped to Zoom x35!")
        end
    end
})

CameraGB:AddSlider("ZoomDistance", {
    Text = "Max Zoom Distance",
    Default = State.ZoomDistance or 25,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Tooltip = "Jarak maksimum kamera saat Instant Max Zoom aktif.",
    Callback = function(v)
        State.ZoomDistance = v
        if State.AntiSmoothZoom and _G.ApplyMaxZoomDistance then
            _G.ApplyMaxZoomDistance(v)
        end
    end
})

EspGB = VisualTab:AddLeftGroupbox("Inner Eye", "view")
EspGB:AddDropdown("SelectedEntities", { 
    Text = "Selected Entities", 
    Default = {"Killer", "Survivor", "Generators", "Gates", "Pallets", "Windows", "Hooks", "Zombies", "BearTraps", "Pumpkins"},
    Multi = true, 
    Values = {"Killer", "Survivor", "Generators", "Gates", "Pallets", "Windows", "Hooks", "Zombies", "BearTraps", "Pumpkins"},
    Tooltip = "Select which entities you want to see through walls.",
    Callback = function(v) 
        State.ESP.Selected = v 
    end 
})
EspGB:AddToggle("EnableESP", { 
    Text = "Enable ESP", 
    Default = State.ESP.Enabled, 
    Tooltip = "Displays information about players and objects through walls.",
    Callback = function(v) 
        State.ESP.Enabled = v 
        if v then Library:Notify("ESP Activated!") end
    end 
})
EspGB:AddToggle("ShowNames", { 
    Text = "Show Names", 
    Default = State.ESP.Names, 
    Tooltip = "Displays the names of the players on the ESP.",
    Callback = function(v) 
        State.ESP.Names = v 
        if v then Library:Notify("Show ESP Names Activated!") end
    end 
})
EspGB:AddToggle("ShowDistance", { 
    Text = "Show Distance", 
    Default = State.ESP.Studs, 
    Tooltip = "Displays the distance between you and the entities on the ESP.",
    Callback = function(v) 
        State.ESP.Studs = v 
        if v then Library:Notify("Show ESP Distance Activated!") end
    end 
})
EspGB:AddToggle("ShowLevel", { 
    Text = "Show Level", 
    Default = State.ESP.ShowLevel, 
    Tooltip = "Displays the player's level on the ESP.",
    Callback = function(v) 
        State.ESP.ShowLevel = v 
    end 
})
EspGB:AddToggle("ShowHookPhase", { 
    Text = "Show Hook Phase", 
    Default = State.ESP.ShowHookPhase, 
    Tooltip = "Displays the survivor's hook phase image above their ESP.",
    Callback = function(v) 
        State.ESP.ShowHookPhase = v 
    end 
})

EspGB:AddDivider()

EspGB:AddSlider("GenDistance", { 
    Text = "Generator Max Distance", 
    Default = 500, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Generator is visible.",
    Callback = function(v) State.ESP.GenDistance = v end 
})
EspGB:AddSlider("GateDistance", { 
    Text = "Gate Max Distance", 
    Default = 500, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Gate is visible.",
    Callback = function(v) State.ESP.GateDistance = v end 
})
EspGB:AddSlider("PalletDistance", { 
    Text = "Pallet Max Distance", 
    Default = 500, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Pallet is visible.",
    Callback = function(v) State.ESP.PalletDistance = v end 
})
EspGB:AddSlider("HookDistance", { 
    Text = "Hook Max Distance", 
    Default = 500, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Hook is visible.",
    Callback = function(v) State.ESP.HookDistance = v end 
})
EspGB:AddSlider("WindowDistance", { 
    Text = "Window Max Distance", 
    Default = 500, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Window is visible.",
    Callback = function(v) State.ESP.WindowDistance = v end 
})
EspGB:AddSlider("ZombieDistance", { 
    Text = "Zombie Max Distance", 
    Default = 300, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Zombie is visible.",
    Callback = function(v) State.ESP.ZombieDistance = v end 
})
EspGB:AddSlider("BearTrapDistance", { 
    Text = "BearTrap Max Distance", 
    Default = 500, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP BearTrap is visible.",
    Callback = function(v) State.ESP.BearTrapDistance = v end 
})

EspGB:AddSlider("BotsDistance", {
    Text = "Bots Max Distance",
    Default = 500, Min = 10, Max = 2000, Rounding = 0,
    Tooltip = "Maximum distance the ESP Bots is visible.",
    Callback = function(v) State.ESP.BotsDistance = v end
})

EspGB:AddSlider("PumpkinDistance", { 
    Text = "Pumpkin Max Distance", 
    Default = 70, Min = 10, Max = 2000, Rounding = 0, 
    Tooltip = "Maximum distance the ESP Pumpkin is visible.",
    Callback = function(v) State.ESP.PumpkinDistance = v end 
})

-- Set nilai awal (fallback) agar tidak error saat pertama kali diload
State.ESP.GenDistance = 500
State.ESP.GateDistance = 500
State.ESP.PalletDistance = 500
State.ESP.HookDistance = 500
State.ESP.WindowDistance = 500
State.ESP.ZombieDistance = 300
State.ESP.BearTrapDistance = 500
State.ESP.BotsDistance = 500
State.ESP.PumpkinDistance = 70

-- ==========================================
-- CUSTOM SPECTATOR UI (DI KANAN LAYAR)
-- ==========================================
if _G.SpecGui then _G.SpecGui:Destroy() end

_G.SpecGui = Instance.new("ScreenGui")
_G.SpecGui.Name = "BoyfinitySpectatorUI"
_G.SpecGui.Parent = game:GetService("CoreGui")
_G.SpecGui.Enabled = false 

_G.SpecFrame = Instance.new("Frame")
_G.SpecFrame.Parent = _G.SpecGui
_G.SpecFrame.BackgroundColor3 = Color3.fromRGB(28, 18, 45) 
_G.SpecFrame.BackgroundTransparency = 0.01
_G.SpecFrame.BorderSizePixel = 0
_G.SpecFrame.Position = UDim2.new(1, -160, 0, 50) 
_G.SpecFrame.Size = UDim2.new(0, 150, 0, 45)
_G.SpecFrame.Active = true -- Wajib true biar bisa mendeteksi input mouse/touch
Instance.new("UICorner", _G.SpecFrame).CornerRadius = UDim.new(0, 8)


local SpecStroke = Instance.new("UIStroke")
SpecStroke.Parent = _G.SpecFrame
SpecStroke.Color = Color3.fromRGB(70, 36, 138) -- Warna ungu cerah untuk stroke
SpecStroke.Thickness = 1.5
SpecStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local SpecTitle = Instance.new("TextLabel")
SpecTitle.Parent = _G.SpecFrame
SpecTitle.BackgroundTransparency = 1
SpecTitle.Size = UDim2.new(1, 0, 0, 25)
SpecTitle.Font = Enum.Font.GothamBold
SpecTitle.Text = "Spectators"
SpecTitle.TextColor3 = Color3.fromRGB(188, 0, 255) 
SpecTitle.TextSize = 13

_G.SpecListLabel = Instance.new("TextLabel")
_G.SpecListLabel.Parent = _G.SpecFrame
_G.SpecListLabel.BackgroundTransparency = 1
_G.SpecListLabel.Position = UDim2.new(0, 5, 0, 25)
_G.SpecListLabel.Size = UDim2.new(1, -10, 1, -25)
_G.SpecListLabel.Font = Enum.Font.Gotham
_G.SpecListLabel.Text = "None"
_G.SpecListLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
_G.SpecListLabel.TextSize = 12
_G.SpecListLabel.TextYAlignment = Enum.TextYAlignment.Top

-- LOGIKA DRAGGABLE (Bisa Digeser)
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

_G.SpecFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = _G.SpecFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

_G.SpecFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        _G.SpecFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

SpectatorGB = VisualTab:AddRightGroupbox("Spectator System", "eye")

SpectatorGB:AddToggle("EnableSpectatorList", { 
    Text = "Spectator List", 
    Default = false, 
    Tooltip = "Shows a list of players who are currently spectating you.",
    Callback = function(v) 
        State.SpectatorList = v 
        if _G.SpecGui then _G.SpecGui.Enabled = v end
        if v then Library:Notify("Spectator List Activated!") end
    end 
})

EnvGB = VisualTab:AddRightGroupbox("Environment Tweaks", "sun")

EnvGB:AddToggle("RemoveFog", { 
    Text = "Remove Fog", 
    Default = State.RemoveFog, 
    Tooltip = "Removes the atmospheric fog from the map.",
    Callback = function(v) 
        State.RemoveFog = v 
        if v then Library:Notify("Remove Fog Activated!") end
    end 
})
EnvGB:AddSlider("TimeOfDay", { 
    Text = "Time of Day", 
    Default = 12, Min = 0, Max = 24, Rounding = 1, 
    Tooltip = "Changes the local time of day in the game.",
    Callback = function(v) State.CustomTime = v end 
})

local SkyList = {"Default", "Night City", "Deep Space", "None", "Vaporwave", "Anime Sunset"}
EnvGB:AddDropdown("SkyboxChanger", { 
    Text = "Skybox Changer", 
    Default = "Default", 
    Values = SkyList, 
    Tooltip = "Changes the game's skybox to a custom theme.",
    Callback = function(v) _G.ApplySkybox(v) end 
})

State.CustomAmbience = State.CustomAmbience or false
State.AmbientColor = State.AmbientColor or Color3.fromRGB(100, 100, 100)
State.OutdoorAmbientColor = State.OutdoorAmbientColor or Color3.fromRGB(150, 150, 150)

AmbienceGB = VisualTab:AddRightGroupbox("Custom Ambience", "moon")

AmbienceGB:AddToggle("EnableAmbience", {
    Text = "Custom Ambience",
    Default = State.CustomAmbience,
    Tooltip = "Overrides the game's lighting colors with your custom selections.",
    Callback = function(Value)
        State.CustomAmbience = Value
        if Value then Library:Notify("Custom Ambience Activated!") end
    end
})

AmbienceGB:AddLabel("Indoor/Shadow Ambient"):AddColorPicker("AmbientColorPicker", {
    Default = State.AmbientColor,
    Title = "Ambient Color",
    Callback = function(Value)
        State.AmbientColor = Value
    end
})

AmbienceGB:AddLabel("Outdoor Ambient"):AddColorPicker("OutdoorAmbientPicker", {
    Default = State.OutdoorAmbientColor,
    Title = "Outdoor Ambient Color",
    Callback = function(Value)
        State.OutdoorAmbientColor = Value
    end
})

EnvGB:AddDivider()

EspStyleGB = VisualTab:AddRightGroupbox("ESP Customization", "palette")

EspStyleGB:AddLabel("Killer ESP Color"):AddColorPicker("KillerColor", {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(v) State.ESP.KillerColor = v end
})
EspStyleGB:AddLabel("Survivor ESP Color"):AddColorPicker("SurvivorColor", {
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(v) State.ESP.SurvivorColor = v end
})
EspStyleGB:AddLabel("Generator ESP Color"):AddColorPicker("GenColor", {
    Default = Color3.fromRGB(255, 255, 0),
    Callback = function(v) State.ESP.GenColor = v end
})
EspStyleGB:AddLabel("Gate ESP Color"):AddColorPicker("GateColor", {
    Default = Color3.fromRGB(227, 227, 227), 
    Callback = function(v) State.ESP.GateColor = v end
})
EspStyleGB:AddLabel("Pallet ESP Color"):AddColorPicker("PalletColor", {
    Default = Color3.fromRGB(255, 221, 116),  
    Callback = function(v) State.ESP.PalletColor = v end
})
EspStyleGB:AddLabel("Window ESP Color"):AddColorPicker("WindowColor", {
    Default = Color3.fromRGB(255, 227, 128),  
    Callback = function(v) State.ESP.WindowColor = v end
})
EspStyleGB:AddLabel("Hook ESP Color"):AddColorPicker("HookColor", {
    Default = Color3.fromRGB(255, 45, 45),  
    Callback = function(v) State.ESP.HookColor = v end
})
EspStyleGB:AddLabel("Zombie ESP Color"):AddColorPicker("ZombieColor", {
    Default = Color3.fromRGB(188, 0, 255), -- 🔥 UNGU NEON!
    Callback = function(v) State.ESP.ZombieColor = v end
})
EspStyleGB:AddLabel("BearTrap ESP Color"):AddColorPicker("BearTrapColor", {
    Default = Color3.fromRGB(255, 100, 0), -- Oranye Terang
    Callback = function(v) State.ESP.BearTrapColor = v end
})
EspStyleGB:AddLabel("Bot / AFK ESP Color"):AddColorPicker("BotColor", {
    Default = Color3.fromRGB(0, 230, 255),
    Callback = function(v) State.ESP.BotColor = v end
})
EspStyleGB:AddLabel("Pumpkin ESP Color"):AddColorPicker("PumpkinColor", {
    Default = Color3.fromRGB(255, 140, 0),
    Callback = function(v) State.ESP.PumpkinColor = v end
})

--=====================================================
-- 5. MOVEMENT TAB
--=====================================================
MoveTab = Window:AddTab("Movement","zap")

MoveGB = MoveTab:AddLeftGroupbox("Movement Character", "move")

-- UNIVERSAL WALKSPEED (SLIDER LANGSUNG AKTIF)
MoveGB:AddSlider("SpeedValue", {
    Text = "WalkSpeed",
    Default = State.Movement.SpeedValue or 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Tooltip = "Ubah kecepatan jalan karakter secara langsung",
    Callback = function(v)
        State.Movement.SpeedValue = v
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = v
        end
    end
})

MoveGB:AddDivider()
MoveGB:AddToggle("NoClip", { 
    Text = "No Clip", 
    Default = State.Movement.NoClip, 
    Tooltip = "Allows you to walk through walls and solid objects.",
    Callback = function(v) 
        State.Movement.NoClip = v 
        if v then Library:Notify("No Clip Activated!") end
    end 
})

MoveGB:AddSlider("FOVValue", { 
    Text = "Field of View", 
    Default = 70, 
    Min = 70, 
    Max = 120, 
    Rounding = 0, 
    Tooltip = "Adjusts the field of view for your camera.",
    Callback = function(v) 
        State.Movement.FOVValue = v 
    end 
})
-- // UI FLY (Movement Tab)
MoveGB:AddToggle("FlyEnabled", { 
    Text = "Fly", 
    Default = false, 
    Tooltip = "Allows your character to fly around the map.",
    Callback = function(v) 
        State.Movement.FlyEnabled = v 
        if v then Library:Notify("Fly Activated!") end
        if not v then State.Movement.IsCurrentlyFlying = false end
    end 
}):AddKeyPicker("FlyKey", { 
    Default = "O", 
    SyncToggleState = true, 
    Text = "Fly Key",
    Callback = function(v) State.Movement.IsCurrentlyFlying = not State.Movement.IsCurrentlyFlying end 
})

State.Movement.FlyKey = State.Movement.FlyKey or Enum.KeyCode.O

MoveGB:AddSlider("FlySpeed", { 
    Text = "Fly Speed", 
    Default = 50, Min = 10, Max = 200, Rounding = 0, 
    Tooltip = "Adjusts the speed of your flight.",
    Callback = function(v) State.Movement.FlySpeed = v end 
})



--=====================================================
-- 1. UI: MOVEMENT RIGHT COLUMN
--=====================================================
PhysicsGB = MoveTab:AddRightGroupbox("Physics & Jump", "arrow-up")

PhysicsGB:AddToggle("InfiniteJump", { 
    Text = "Infinite Jump", 
    Default = false, 
    Tooltip = "Allows you to jump endlessly in mid-air.",
    Callback = function(v) 
        State.InfiniteJump = v 
        if v then Library:Notify("Infinite Jump Activated!") end
    end 
})
PhysicsGB:AddSlider("JumpPower", { 
    Text = "Jump Power", 
    Default = 50, Min = 50, Max = 250, Rounding = 0, 
    Tooltip = "Adjusts the height of your jumps.",
    Callback = function(v) State.JumpPower = v end 
})
PhysicsGB:AddSlider("Gravity", { 
    Text = "Gravity Scale", 
    Default = 196.2, Min = 0, Max = 500, Rounding = 1, 
    Tooltip = "Changes the game's gravity affecting your character.",
    Callback = function(v) workspace.Gravity = v end 
})

SpinGB = MoveTab:AddRightGroupbox("Spinbot Settings", "refresh-cw")
SpinGB:AddToggle("EnableSpinbot", { 
    Text = "Spinbot", 
    Default = false, 
    Tooltip = "Spins your character rapidly to confuse others or dodge.",
    Callback = function(v) 
        State.Spinbot = v 
        if v then Library:Notify("Spinbot Activated!") end
    end 
})
SpinGB:AddSlider("SpinSpeed", { 
    Text = "Spin Speed", 
    Default = 50, Min = 10, Max = 300, Rounding = 0, 
    Tooltip = "Adjusts how fast your character spins.",
    Callback = function(v) State.SpinSpeed = v end 
})

MoonwalkGB = MoveTab:AddRightGroupbox("Moonwalk Settings", "user-minus")
MoonwalkGB:AddToggle("EnableMoonwalk", { 
    Text = "Moonwalk", 
    Default = false, 
    Tooltip = "Reverses your character's walking animation to look like a moonwalk.",
    Callback = function(v) 
        State.MoonwalkEnabled = v 
        if _G.MoonwalkUI then _G.MoonwalkUI.Enabled = v end -- Munculkan tombol Mobile
        UpdateMoonwalkUI() -- Pastikan UI langsung update saat toggle
        if not v then State.MoonwalkActive = false end -- Reset jika fitur mati
        if v then Library:Notify("Moonwalk Activated!") end
    end 
})

MoonwalkGB:AddLabel("Face User (MJ)"):AddKeyPicker("FaceBind", { 
    Default = "One", 
    NoUI = true, 
    Text = "Face User", 
    Callback = function() 
        if State.MoonwalkEnabled then 
            State.MoonwalkActive = true 
            UpdateMoonwalkUI() -- Visual panah ikut berubah saat pencet tombol 1
        end 
    end 
})

-- Bind 2 di PC
MoonwalkGB:AddLabel("Normal Position"):AddKeyPicker("NormalBind", { 
    Default = "Two", 
    NoUI = true, 
    Text = "Normal Position", 
    Callback = function() 
        State.MoonwalkActive = false 
        UpdateMoonwalkUI() -- Visual panah ikut berubah saat pencet tombol 2
    end 
})

--=====================================================
-- 6. MISC TAB
--=====================================================
MiscTab = Window:AddTab("Misc","component")

ShieldGB = MiscTab:AddLeftGroupbox("Shield System", "shield-check")
if not State.Misc then State.Misc = {} end

ShieldGB:AddToggle("AntiAFK", { 
    Text = "Anti AFK", 
    Default = State.Misc.AntiAFK, 
    Tooltip = "Prevents you from being kicked by the server for idling.",
    Callback = function(v) 
        State.Misc.AntiAFK = v 
        if v then Library:Notify("Anti AFK Activated!") end
    end 
})

ShieldGB:AddToggle("AntiFling", { 
    Text = "Anti Fling", 
    Default = State.Misc.AntiFling, 
    Tooltip = "Protects you from being flung or pushed away by other players.",
    Callback = function(v) 
        State.Misc.AntiFling = v 
        if v then Library:Notify("Anti Fling Activated!") end
    end 
})

ShieldGB:AddToggle("TouchFling", { 
    Text = "Touch Fling (Lobby Only)", 
    Default = State.Misc.TouchFling, 
    Tooltip = "Instantly flings any player that comes into direct contact with you.",
    Callback = function(v) 
        State.Misc.TouchFling = v 
        if v then Library:Notify("Touch Fling Activated!") end
    end 
})



ShieldGB:AddToggle("AntiAdmin", { 
    Text = "Anti Admin (Auto Leave)", 
    Default = State.Misc.AntiAdmin, 
    Tooltip = "Automatically leaves the game if a group admin or moderator is detected in the server.",
    Callback = function(v) 
        State.Misc.AntiAdmin = v 
        if v then Library:Notify("Anti Admin Activated!") end
    end 
})

ShieldGB:AddButton({ 
    Text = "Rejoin Server", 
    Tooltip = "Instantly rejoins the exact same server you are currently playing in.",
    Func = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end 
})

ShieldGB:AddButton({ 
    Text = "Free Private Server (Hop)", 
    Tooltip = "Searches and hops to a server with very few players.",
    Func = function()
        Library:Notify("Finding small server...")
        local HttpService = game:GetService("HttpService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
        for _, s in pairs(servers) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
    end 
})



if not State.StreamerMode then State.StreamerMode = {} end
StreamerGB = MiscTab:AddRightGroupbox("Streamer Mode", "eye-off")

StreamerGB:AddToggle("HideUsername", {
    Text = "Hide Username",
    Default = State.StreamerMode.HideUsername or false,
    Tooltip = "Locally replaces your Roblox username on the UI to protect your identity.",
    Callback = function(Value)
        State.StreamerMode.HideUsername = Value
        if Value then Library:Notify("Hide Username Activated!") end
    end
})

StreamerGB:AddToggle("HideAvatar", {
    Text = "Hide Avatar",
    Default = State.StreamerMode.HideAvatar or false,
    Tooltip = "Locally replaces your Roblox avatar picture on the UI.",
    Callback = function(Value)
        State.StreamerMode.HideAvatar = Value
        if Value then Library:Notify("Hide Avatar Activated!") end
    end
})

--=====================================================
-- 7. SETTINGS TAB
--=====================================================
SettingsTab = Window:AddTab("Settings", "settings")

-- // 1. MENU SETTINGS (Pindahkan ke Kiri agar tidak bentrok dengan SaveManager)
MenuGB = SettingsTab:AddLeftGroupbox("Menu", "square-menu")

-- Menu Bind (Default G)

MenuGB:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
    Tooltip = "Toggles the visibility of the active keybinds list on your screen.",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
        if value then Library:Notify("Keybind Menu Opened!") end
	end,
})

-- Custom Cursor Toggle
MenuGB:AddToggle('CustomCursor', { 
    Text = 'Custom Cursor', 
    Default = true, 
    Tooltip = "Replaces the default Roblox mouse cursor with a custom one while the UI is open.",
    Callback = function(Value) 
        Library.ShowCustomCursor = Value 
        if Value then Library:Notify("Custom Cursor Activated!") end
    end 
})

-- Notification Side Dropdown
MenuGB:AddDropdown('NotifySide', { 
    Text = 'Notification Side', 
    Default = 'Right', 
    Values = { 'Left', 'Right' }, 
    Tooltip = "Selects whether notifications appear on the left or right side of the screen.",
    Callback = function(Value) 
        Library.NotifySide = Value 
    end 
})

-- DPI Scale Slider
MenuGB:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
    Tooltip = "Adjusts the overall size and scaling of the UI to fit your screen resolution.",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})

MenuGB:AddDivider()

MenuGB:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
    Default = "G",
    NoUI = true, -- Kita tidak perlu tampilkan keybind ini di UI karena sudah jelas di toggle-nya
    Text = "Menu keybind",
})

Library.ToggleKeybind = Library.Options.MenuKeybind

MenuGB:AddButton("Unload", function()
    Library:Unload()
    Library:Notify("Script Unloaded. Thanks for using!")
end)


-- // CLOUD SCRIPT MANAGER & LOADER
CloudManagerGB = SettingsTab:AddLeftGroupbox("Cloud Script Loader", "cloud")
CloudManagerGB:AddInput("CloudApiUrlInput", {
    Default = _G.BoyfinityCustomUrl or "http://localhost:3000/raw",
    Numeric = false,
    Finished = true,
    Text = "Cloud API Raw URL",
    Placeholder = "e.g. https://your-domain.com/raw",
    Tooltip = "Specifies the endpoint for the raw Lua code stream used by the Antigravity dynamic loader.",
    Callback = function(val)
        if val and val ~= "" then
            _G.BoyfinityCustomUrl = val
            Library:Notify("Cloud Script API Endpoint set to: " .. val, 4)
        end
    end
})

CloudManagerGB:AddButton({
    Text = "Copy Roblox Loader One-Liner",
    Tooltip = "Copies the game:HttpGet dynamic loader script to your clipboard to run from your executor.",
    Func = function()
        local url = _G.BoyfinityCustomUrl or "http://localhost:3000/raw"
        local snippet = string.format('local scriptUrl = "%s"\nlocal success, code = pcall(function()\n    return game:HttpGet(scriptUrl)\nend)\n\nif success and code then\n    local executable, err = loadstring(code)\n    if executable then\n        executable()\n    else\n        warn("Format Lua salah:", err)\n    end\nelse\n    warn("Gagal mengambil kode dari API web.")\nend', url)
        setclipboard(snippet)
        Library:Notify("Roblox Loader One-Liner copied to clipboard!", 4)
    end
})

CloudManagerGB:AddButton({
    Text = "Force Live Cloud Reload",
    Tooltip = "Fetches the latest Lua code from your Cloud API and executes updates in real-time.",
    Func = function()
        local url = _G.BoyfinityCustomUrl or "http://localhost:3000/raw"
        Library:Notify("Fetching live script update from cloud...", 3)
        task.spawn(function()
            local success, newCode = pcall(function()
                return game:HttpGet(url)
            end)
            if success and newCode and #newCode > 0 then
                local executable, compileErr = loadstring(newCode)
                if executable then
                    Library:Notify("Script update successfully loaded and executed!", 4)
                    executable()
                else
                    Library:Notify("Failed to compile cloud script: " .. tostring(compileErr), 6)
                end
            else
                Library:Notify("Failed to fetch script from " .. url, 5)
            end
        end)
    end
})

-- // 2. SYSTEM & CREDITS
SystemGB = SettingsTab:AddLeftGroupbox("System", "cpu")
SystemGB:AddButton({ 
    Text = "FPS Boost", 
    Tooltip = "Activates Potato Mode to maximize FPS by aggressively reducing map graphics and textures.",
    Func = function() 
        State.PotatoMode = true 
        Library:Notify("FPS Boost (Potato Mode) Triggered!")
    end 
})

CreditGB = SettingsTab:AddLeftGroupbox("Credits & Info", "info")
CreditGB:AddButton({ 
    Text = "Discord Server", 
    Tooltip = "Copies the official Boyfinity Discord server invite link to your clipboard.",
    Func = function() 
        setclipboard("https://discord.gg/VK4qrGWtF6")
        Library:Notify("Discord link copied to clipboard!", 3) 
    end 
})

-- // 3. TEMA & SAVE MANAGER
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BoyfinityVD")
ThemeManager:ApplyToTab(SettingsTab)

SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

--=====================================================
-- EXPORT / IMPORT CONFIGURATION
--=====================================================
-- Bikin Groupbox di sebelah kanan (dibawah SaveManager)
ConfigShareGB = SettingsTab:AddRightGroupbox("Export / Import Config", "file-text")

-- 1. BUTTON EXPORT CONFIG
ConfigShareGB:AddButton({
    Text = "Export Current Config",
    Tooltip = "Copies your currently selected configuration data to the clipboard for sharing.",
    Func = function()
        local currentConfig = SaveManager.Options.SaveManager_ConfigList and SaveManager.Options.SaveManager_ConfigList.Value
        
        if currentConfig and currentConfig ~= "" then
            local path = "BoyfinityVD/settings/" .. currentConfig .. ".json"
            
            if isfile(path) then
                local configData = readfile(path)
                setclipboard(configData)
                Library:Notify("Config '" .. currentConfig .. "' has been copied to clipboard!")
            else
                Library:Notify("Config file not found!")
            end
        else
            Library:Notify("Please select a config from the list above first!")
        end
    end
})

ConfigShareGB:AddDivider()

-- 2. INPUT IMPORT CONFIG
ConfigShareGB:AddInput("ImportConfigInput", {
    Default = "",
    Numeric = false,
    Finished = false, 
    Text = "Paste Config Here",
    Placeholder = "Paste text JSON config here...",
    Tooltip = "Paste the configuration text (JSON format) that you want to import here.",
    Callback = function(Value)
        State.ImportedConfigText = Value
    end
})

-- 3. BUTTON IMPORT CONFIG
ConfigShareGB:AddButton({
    Text = "Import Config",
    Tooltip = "Saves the pasted text as a new configuration file named 'ImportedConfig'.",
    Func = function()
        local text = State.ImportedConfigText or ""
        
        if text == "" then
            Library:Notify("Paste the text config first in the top field!")
            return
        end
        
        if not isfolder("BoyfinityVD/settings") then
            makefolder("BoyfinityVD/settings")
        end
        
        local path = "BoyfinityVD/settings/ImportedConfig.json"
        local success, err = pcall(function()
            writefile(path, text)
        end)
        
        if success then
            SaveManager:RefreshConfigList()
            Library:Notify("Config imported as 'ImportedConfig'!")
            Library:Notify("Silakan pilih di menu Configuration lalu klik Load.")
        else
            Library:Notify("Failed to import config: " .. tostring(err))
        end
    end
})

Library.Scheme.AccentColor = Color3.fromRGB(188, 0, 255)
Library.Scheme.MainColor = Color3.fromRGB(23, 2, 26)
Library.Scheme.BackgroundColor = Color3.fromRGB(28, 18, 45)
Library.Scheme.OutlineColor = Color3.fromRGB(80, 40, 160)
Library.Scheme.FontColor = Color3.fromRGB(220, 220, 255)

Library:UpdateColorsUsingRegistry()


--=====================================================
-- FINAL SIDEBAR USER PROFILE INJECTOR (SMART SLIDE MOBILE)
--=====================================================
task.spawn(function()
    local MainFrame = Library.ScreenGui:WaitForChild("Main", 10)
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local isMobile = UserInputService.TouchEnabled
    
    if MainFrame then
        local isPremium = State.IsPremium or false
        local isNameVisible = false
        
        local EyeIcon = Library:GetIcon("eye")
        local EyeOffIcon = Library:GetIcon("eye-off")
        local LogoutIcon = Library:GetIcon("log-out")

        -- Container Utama Profil
        local ProfileArea = Instance.new("Frame")
        ProfileArea.Name = "UserProfileContainer"
        ProfileArea.Parent = MainFrame
        ProfileArea.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
        ProfileArea.BorderSizePixel = 0
        ProfileArea.Size = UDim2.new(0, 190, 0, 50)
        ProfileArea.ZIndex = 500

        local ProfileCorner = Instance.new("UICorner", ProfileArea)
        ProfileCorner.CornerRadius = UDim.new(0, 8)

        -- ==========================================
        -- 🌟 LOGIKA SLIDE (MOBILE) & STATIK (PC) 🌟
        -- ==========================================
        if isMobile then
            -- Mode Mobile: Posisi awal disembunyikan (tenggelam di bawah layar menu)
            ProfileArea.Position = UDim2.new(0, 10, 1, 60)
            
            -- Bikin tombol garis panjang kecil (Handle iOS Style)
            local SlideHandle = Instance.new("TextButton")
            SlideHandle.Name = "SlideHandleBtn"
            SlideHandle.Parent = MainFrame
            SlideHandle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            SlideHandle.Position = UDim2.new(0, 85, 1, -15) -- Nangkring manis di bawah
            SlideHandle.Size = UDim2.new(0, 40, 0, 4)
            SlideHandle.Text = ""
            SlideHandle.ZIndex = 501
            Instance.new("UICorner", SlideHandle).CornerRadius = UDim.new(1, 0)

            local isExpanded = false
            
            -- Efek Animasi Slide Up & Down
            SlideHandle.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                
                -- Tentukan titik tujuan animasi
                local targetProfilePos = isExpanded and UDim2.new(0, 10, 1, -75) or UDim2.new(0, 10, 1, 60)
                local targetHandlePos = isExpanded and UDim2.new(0, 85, 1, -85) or UDim2.new(0, 85, 1, -15)
                
                -- Setting seberapa mulus dan gaya animasinya (Quart Out = kencang di awal, ngerem di akhir)
                local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                
                TweenService:Create(ProfileArea, tweenInfo, {Position = targetProfilePos}):Play()
                TweenService:Create(SlideHandle, tweenInfo, {Position = targetHandlePos}):Play()
                
                -- Ubah warna garis biar interaktif
                SlideHandle.BackgroundColor3 = isExpanded and Color3.fromRGB(188, 0, 255) or Color3.fromRGB(150, 150, 150)
            end)
        else
            -- Mode PC: Statik, langsung kelihatan di posisi asli tanpa garis handle
            ProfileArea.Position = UDim2.new(0, 10, 1, -75)
        end
        -- ==========================================

        -- 1. Gambar Avatar (Bulat)
        local Avatar = Instance.new("ImageLabel")
        Avatar.Name = "UserAvatar"
        Avatar.Parent = ProfileArea
        Avatar.BackgroundTransparency = 1
        Avatar.Position = UDim2.new(0, 8, 0.5, -18)
        Avatar.Size = UDim2.new(0, 36, 0, 36)
        Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Players.LocalPlayer.UserId .. "&w=150&h=150"
        Avatar.ZIndex = 501
        Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

        -- 2. Label Nama
        local UserName = Instance.new("TextLabel")
        UserName.Name = "UserNameLabel"
        UserName.Parent = ProfileArea
        UserName.BackgroundTransparency = 1
        UserName.Position = UDim2.new(0, 52, 0, 8)
        UserName.Size = UDim2.new(0, 80, 0, 15)
        UserName.Font = Enum.Font.GothamBold
        UserName.Text = Players.LocalPlayer.Name:sub(1,3) .. "*******" 
        UserName.TextColor3 = Color3.new(1, 1, 1)
        UserName.TextSize = 12
        UserName.TextXAlignment = Enum.TextXAlignment.Left
        UserName.ZIndex = 501

        -- 3. Label Tag Status
        local TagLabel = Instance.new("TextLabel")
        TagLabel.Name = "UserStatusTag"
        TagLabel.Parent = ProfileArea
        TagLabel.Position = UDim2.new(0, 52, 0, 26)
        TagLabel.Size = UDim2.new(0, 65, 0, 16)
        TagLabel.Font = Enum.Font.GothamBold
        TagLabel.TextSize = 10
        TagLabel.ZIndex = 501
        Instance.new("UICorner", TagLabel).CornerRadius = UDim.new(0, 4)

        if isPremium then
            TagLabel.Text = "PREMIUM"
            TagLabel.BackgroundColor3 = Color3.fromRGB(188, 0, 255) 
            TagLabel.TextColor3 = Color3.new(1, 1, 1)
        else
            TagLabel.Text = "FREE"
            TagLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            TagLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end

        -- 4. Tombol Intip Nama (Eye Icon)
        local EyeButton = Instance.new("ImageButton")
        EyeButton.Name = "ToggleNameBtn"
        EyeButton.Parent = ProfileArea
        EyeButton.BackgroundTransparency = 1
        EyeButton.Position = UDim2.new(1, -60, 0.5, -10)
        EyeButton.Size = UDim2.new(0, 20, 0, 20)
        EyeButton.Image = EyeIcon.Url
        EyeButton.ImageRectOffset = EyeIcon.ImageRectOffset
        EyeButton.ImageRectSize = EyeIcon.ImageRectSize
        EyeButton.ImageColor3 = Color3.fromRGB(150, 150, 150)
        EyeButton.ZIndex = 502

        EyeButton.MouseButton1Click:Connect(function()
            isNameVisible = not isNameVisible
            if isNameVisible then
                UserName.Text = Players.LocalPlayer.Name 
                EyeButton.Image = EyeOffIcon.Url
                EyeButton.ImageRectOffset = EyeOffIcon.ImageRectOffset
                EyeButton.ImageRectSize = EyeOffIcon.ImageRectSize
            else
                UserName.Text = Players.LocalPlayer.Name:sub(1,3) .. "*******" 
                EyeButton.Image = EyeIcon.Url
                EyeButton.ImageRectOffset = EyeIcon.ImageRectOffset
                EyeButton.ImageRectSize = EyeIcon.ImageRectSize
            end
        end)

        -- 5. Tombol Keluar Pajangan (Logout Icon)
        local LogoutButton = Instance.new("ImageButton")
        LogoutButton.Name = "LogoutBtn"
        LogoutButton.Parent = ProfileArea
        LogoutButton.BackgroundTransparency = 1
        LogoutButton.Position = UDim2.new(1, -30, 0.5, -10)
        LogoutButton.Size = UDim2.new(0, 20, 0, 20)
        LogoutButton.Image = LogoutIcon.Url
        LogoutButton.ImageRectOffset = LogoutIcon.ImageRectOffset
        LogoutButton.ImageRectSize = LogoutIcon.ImageRectSize
        LogoutButton.ImageColor3 = Color3.fromRGB(188, 0, 255) 
        LogoutButton.ZIndex = 502

        LogoutButton.MouseButton1Click:Connect(function()
            Library:Notify("Cleaning UI and Unloading... Goodbye, Bro!", 2)
            task.wait(0.5)
            Library:Unload()
        end)
    end
end)

Library:Notify({
    Title = "Violence District Ready!",
    Description = "Enjoy the game, Bro! Press G to Toggle UI.",
    Time = 3,
})

--=====================================================
-- 📱 MOBILE ACTION BUTTONS (INDEPENDENT DRAGGABLE)
--=====================================================
UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled -- Deteksi apakah device support layar sentuh

-- 🔥 BUNGKUS SEMUA KODE DI BAWAH INI PAKAI IF isMobile 🔥
if isMobile then
    if _G.MobileActionGui then _G.MobileActionGui:Destroy() end

    local MobileActionGui = Instance.new("ScreenGui")
    MobileActionGui.Name = "BoyfinityMobileActions"
    MobileActionGui.Parent = game:GetService("CoreGui")
    _G.MobileActionGui = MobileActionGui

    -- Fungsi Pembuat Tombol Independen (Setiap tombol punya drag sendiri)
    local function CreateIndependentButton(name, icon, label, defaultPos, callback)
        -- ... (ISI FUNGSI INI BIARKAN SAMA SEPERTI ASLINYA) ...
        -- 🛠️ FIX TOTAL: Proteksi pergeseran argumen karena emoji hilang
        if type(defaultPos) == "function" then
            callback = defaultPos
            defaultPos = label
            label = icon
            icon = ""
        end

        icon = type(icon) == "string" and icon or ""
        label = type(label) == "string" and label or ""
        if typeof(defaultPos) ~= "UDim2" then 
            defaultPos = UDim2.new(0, 15, 0.4, 0)
        end

        local Wrapper = Instance.new("Frame")
        Wrapper.Name = name .. "_Wrapper"
        Wrapper.Parent = MobileActionGui
        Wrapper.BackgroundTransparency = 1
        Wrapper.Position = defaultPos 
        Wrapper.Size = UDim2.new(0, 55, 0, 65) 
        Wrapper.Visible = false 

        local DragHandle = Instance.new("Frame")
        DragHandle.Name = "DragHandle"
        DragHandle.Parent = Wrapper
        DragHandle.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        DragHandle.Size = UDim2.new(0, 30, 0, 5) 
        DragHandle.Position = UDim2.new(0.5, -15, 0, 0) 
        DragHandle.Active = true
        Instance.new("UICorner", DragHandle).CornerRadius = UDim.new(1, 0)

        local dragging, dragInput, dragStart, startPos

        DragHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Wrapper.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        DragHandle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                Wrapper.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Parent = Wrapper
        btn.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
        btn.Position = UDim2.new(0, 0, 0, 10) 
        btn.Size = UDim2.new(1, 0, 1, -10) 
        
        btn.Font = Enum.Font.GothamBold
        if icon == "" then
            btn.Text = label
        else
            btn.Text = icon .. "\n" .. label 
        end
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.TextSize = 11 
        btn.TextWrapped = true 
        btn.AutoButtonColor = true

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke")
        stroke.Parent = btn
        stroke.Color = Color3.fromRGB(70, 36, 138)
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        btn.MouseButton1Click:Connect(callback)
        
        return Wrapper
    end

    -- =====================================================
    -- BIKIN TOMBOL-TOMBOLNYA
    -- =====================================================
    _G.MobileBtns = {
        FakeParry = CreateIndependentButton("FakeParryBtn", "Parry", UDim2.new(0, 15, 0.35, 0), function()
            -- (ISI FUNGSI BIARKAN SAMA)
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://127096285501517" 
                    local track = animator:LoadAnimation(anim)
                    track.Priority = Enum.AnimationPriority.Action 
                    track:Play()
                end
            end
        end),
        
        Emote = CreateIndependentButton("EmoteBtn", "Emote", UDim2.new(0, 15, 0.35, 75), function()
            local S = _G.SharedState
            if S and S.SelectedEmote then
                _G.playCustomEmote(S.SelectedEmote)
            end
        end),
        
        FakeKnock = CreateIndependentButton("FakeKnockBtn", "Knock", UDim2.new(0, 15, 0.35, 150), function()
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if _G.isFakeKnocked then
                    _G.isFakeKnocked = false
                    if _G.fakeKnockedTrackMobile then
                        _G.fakeKnockedTrackMobile:Stop()
                        _G.fakeKnockedTrackMobile:Destroy()
                        _G.fakeKnockedTrackMobile = nil
                    end
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                else
                    _G.isFakeKnocked = true
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if animator then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://126526181422628"
                        _G.fakeKnockedTrackMobile = animator:LoadAnimation(anim)
                        _G.fakeKnockedTrackMobile.Priority = Enum.AnimationPriority.Action4
                        _G.fakeKnockedTrackMobile.Looped = true
                        _G.fakeKnockedTrackMobile:Play()
                    end
                    hum.WalkSpeed = 3
                    hum.JumpPower = 0
                end
            end
        end),
        
        GenTP = CreateIndependentButton("GenTPBtn","TP Gen", UDim2.new(0, 15, 0.35, 225), function()
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local validGens = {}
            for gen in pairs(ObjectCache.Generators) do
                local genPart = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
                if genPart and (gen:GetAttribute("RepairProgress") or 0) < 100 then
                    table.insert(validGens, genPart)
                end
            end
            if #validGens == 0 then return end
            
            local target = nil
            if _G.SharedState.GenTPMode == "Nearest" then
                local sDist = math.huge
                for _, p in ipairs(validGens) do
                    local d = (hrp.Position - p.Position).Magnitude
                    if d < sDist then sDist = d; target = p end
                end
            else
                target = validGens[math.random(1, #validGens)]
            end
            
            if target then
                hrp.CFrame = target.CFrame + Vector3.new(0, 10, 0)
            end
        end),

        Dash = CreateIndependentButton("DashBtn","Dash", UDim2.new(0, 15, 0.35, 300), function()
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if not hrp or not hum or hum.Health <= 0 then return end
            
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 0, 1e5) 
            bv.Velocity = hrp.CFrame.LookVector * (_G.SharedState.Misc.DashSpeed or 80)
            bv.Parent = hrp
            
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                local anim1 = Instance.new("Animation"); anim1.AnimationId = "rbxassetid://656118852"
                local anim2 = Instance.new("Animation"); anim2.AnimationId = "rbxassetid://656117878"
                local t1 = animator:LoadAnimation(anim1); t1:Play()
                local t2 = animator:LoadAnimation(anim2); t2:Play()
                
                task.delay(0.35, function()
                    if bv then bv:Destroy() end
                    if t1 then t1:Stop() end
                    if t2 then t2:Stop() end
                end)
            end
        end)
    }

    -- Deteksi Kapan Tombol Harus Muncul/Hilang
    game:GetService("RunService").Heartbeat:Connect(function()
        local S = _G.SharedState
        if not S then return end
        
        -- Tombol akan otomatis muncul HANYA jika toggle di UI Obsidian sedang aktif!
        if _G.MobileBtns.FakeParry then _G.MobileBtns.FakeParry.Visible = (S.FakeParry == true) end
        if _G.MobileBtns.Emote then _G.MobileBtns.Emote.Visible = (S.EmoteKeybind == true) end
        if _G.MobileBtns.FakeKnock then _G.MobileBtns.FakeKnock.Visible = (S.FakeKnockdown == true) end
        if _G.MobileBtns.GenTP then _G.MobileBtns.GenTP.Visible = (S.EnableGenTP == true) end
            end)
end -- 🔥 TUTUP IF ISMOBILE DI SINI 🔥

--=====================================================
-- LOGIC: BRANDING INJECTOR (STREAMER MODE)
--=====================================================
-- 1. Siapkan tempat untuk menyimpan data original UI
local OriginalStreamerData = {
    AvatarImage = nil,
    UsernameText = nil,
    UsernameColor = nil
}

local function InjectBoyfinityBranding()
    local success, err = pcall(function()
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not PlayerGui then return end

        -- Cari ScreenGui bernama "Survivor"
        local SurvivorGui = PlayerGui:FindFirstChild("Survivor")
        if not SurvivorGui then return end

        -- Cari objek bernama "Frame"
        local Frame = SurvivorGui:FindFirstChild("Frame")
        if not Frame then return end

        -- Cari objek bernama "Survivor1" 
        local Target = Frame:FindFirstChild("Survivor1")
        if not Target then return end

        local avatar = Target:FindFirstChildOfClass("ImageLabel")
        local nameLabel = Target:FindFirstChildOfClass("TextLabel")

        -- 2. SIMPAN DATA ORIGINAL SEBELUM DIUBAH
        if avatar and OriginalStreamerData.AvatarImage == nil and avatar.Image ~= "rbxassetid://120508213351603" then
            OriginalStreamerData.AvatarImage = avatar.Image
        end
        if nameLabel and OriginalStreamerData.UsernameText == nil and nameLabel.Text ~= "boyfinity" then
            OriginalStreamerData.UsernameText = nameLabel.Text
            OriginalStreamerData.UsernameColor = nameLabel.TextColor3
        end

        -- 3. LOGIC HIDE AVATAR (ON / OFF)
        if State.StreamerMode and State.StreamerMode.HideAvatar then
            if avatar and avatar.Image ~= "rbxassetid://120508213351603" then
                avatar.Image = "rbxassetid://120508213351603"
            end
        else
            -- KEMBALIKAN KE AVATAR ASLI
            if avatar and OriginalStreamerData.AvatarImage and avatar.Image ~= OriginalStreamerData.AvatarImage then
                avatar.Image = OriginalStreamerData.AvatarImage
            end
        end

        -- 4. LOGIC HIDE USERNAME (ON / OFF)
        if State.StreamerMode and State.StreamerMode.HideUsername then
            if nameLabel and nameLabel.Text ~= "boyfinity" then
                nameLabel.Text = "boyfinity"
                nameLabel.TextColor3 = Color3.fromRGB(188, 0, 255) 
            end
        else
            -- KEMBALIKAN KE NAMA & WARNA ASLI
            if nameLabel and OriginalStreamerData.UsernameText and nameLabel.Text ~= OriginalStreamerData.UsernameText then
                nameLabel.Text = OriginalStreamerData.UsernameText
                nameLabel.TextColor3 = OriginalStreamerData.UsernameColor or Color3.new(1, 1, 1)
            end
        end
    end)

    if not success then
        warn("Boyfinity Streamer Mode Debug: " .. tostring(err))
    end
end

-- Jalankan di background
task.spawn(function()
    while task.wait(0.5) do
        InjectBoyfinityBranding()
    end
end)

--=====================================================
-- FIXED MOBILE UI: PURE ARROW (NO BOX)
--=====================================================
local function CreateMoonwalkMobileUI()
    if _G.MoonwalkUI then _G.MoonwalkUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local FaceBtn = Instance.new("ImageButton")
    local NormBtn = Instance.new("ImageButton")

    ScreenGui.Name = "BoyfinityMoonwalkUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = false 
    _G.MoonwalkUI = ScreenGui

    Frame.Parent = ScreenGui
    Frame.BackgroundTransparency = 1 -- Transparan total biar kotaknya ilang
    Frame.Position = UDim2.new(1, -80, 0.5, -60) 
    Frame.Size = UDim2.new(0, 60, 0, 130)

    -- Tombol PANAH ATAS (MJ Mode)
    FaceBtn.Name = "FaceUserBtn"
    FaceBtn.Parent = Frame
    FaceBtn.BackgroundTransparency = 1 -- Kotak Hilang![cite: 2]
    FaceBtn.Size = UDim2.new(0, 60, 0, 60)
    FaceBtn.Image = "rbxassetid://118655273900373" -- Asset lo: ArrowUp[cite: 2]
    FaceBtn.ImageColor3 = Color3.fromRGB(150, 150, 150) -- Default Abu
    FaceBtn.ZIndex = 25 -- Pastikan paling depan[cite: 2]

    -- Tombol PANAH BAWAH (Normal Mode)
    NormBtn.Name = "NormalBtn"
    NormBtn.Parent = Frame
    NormBtn.BackgroundTransparency = 1 -- Kotak Hilang![cite: 2]
    NormBtn.Position = UDim2.new(0, 0, 0, 70)
    NormBtn.Size = UDim2.new(0, 60, 0, 60)
    NormBtn.Image = "rbxassetid://95252172620653" -- Asset lo: ArrowDown[cite: 2]
    NormBtn.ImageColor3 = Color3.fromRGB(188, 0, 255) -- Default Aktif Ungu
    NormBtn.ZIndex = 25 -- Pastikan paling depan[cite: 2]

    -- Logic Ganti Warna & State[cite: 2]
    FaceBtn.MouseButton1Click:Connect(function() 
        State.MoonwalkActive = true 
        FaceBtn.ImageColor3 = Color3.fromRGB(188, 0, 255) 
        NormBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
    end)

    NormBtn.MouseButton1Click:Connect(function() 
        State.MoonwalkActive = false 
        NormBtn.ImageColor3 = Color3.fromRGB(188, 0, 255) 
        FaceBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
    end)
end

CreateMoonwalkMobileUI()

-- =====================================================
-- LOGIKA FITUR
-- =====================================================
--==============================================================
--// MAIN LOOP (Hitbox, Anti-Slow Physics, & Animation Speed)
--=============================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Anti Slowdown Physics
    if State.NoCooldown and hum and hum.WalkSpeed < 16 then
        hum.WalkSpeed = 16
    end

    -- Fast Animation Speed (No Cooldown)
    if State.NoCooldown and hum then
        for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
            local name = anim.Name:lower()
            -- Mempercepat semua animasi serangan/ayunan
            if name:find("attack") or name:find("swing") or name:find("lunge") or name:find("slash") or name:find("hit") or anim.Priority == Enum.AnimationPriority.Action4 then
                if not name:find("walk") and not name:find("run") and not name:find("idle") then
                    anim:AdjustSpeed(50) -- Memotong cooldown animasi dengan menyelesaikannya hampir instan
                end
            end
        end
    end

    -- HITBOX LOGIC
    if State.HitboxEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetHRP = plr.Character.HumanoidRootPart
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                -- 1. VISUAL HITBOX
                targetHRP.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                targetHRP.Transparency = State.HitboxTransparency
                targetHRP.Shape = Enum.PartType.Ball
                targetHRP.CanCollide = false
            end
        end
    end
end)

-- Fungsi reset hitbox (hanya dipanggil 1x saat toggle dimatikan, bukan di-loop tiap frame)
State.ResetHitbox = function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = plr.Character.HumanoidRootPart
            targetHRP.Size = Vector3.new(2, 2, 1)
            targetHRP.Transparency = 1
            targetHRP.Shape = Enum.PartType.Block
            targetHRP.CanCollide = false
        end
    end
end

--=====================================================
-- LOGIC: MISC KILLER SYSTEM
--=====================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
GenRemote = ReplicatedStorage.Remotes.Generator.BreakGenEvent

--// 1. ANTI STUN & VISUAL BLIND REMOVER (Jalan di Heartbeat)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    
    -- A. ANTI STUN FISIK (SAFETIED - ANTI LAG/CRASH)
    if char and State.NoStun then
        for _, v in pairs(char:GetDescendants()) do
            if v.Name:find("Stun") then
                -- Jangan asal destroy GUI game, bikin script game error & ngelag!
                if v:IsA("GuiObject") or v:IsA("LayerCollector") then
                    pcall(function() v.Enabled = false end)
                    pcall(function() v.Visible = false end)
                elseif v:IsA("BasePart") then
                    pcall(function() v.Transparency = 1; v.CanCollide = false; v.Anchored = false end)
                elseif v:IsA("Script") or v:IsA("LocalScript") then
                    pcall(function() v.Disabled = true end)
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    pcall(function() v.Enabled = false end)
                elseif v:IsA("Sound") then
                    pcall(function() v:Stop(); v.Volume = 0 end)
                end
                -- Kita TIDAK LAGI menggunakan v:Destroy() secara asal.
                -- Karena jika v adalah Attachment/Folder yang berisi UI, maka UI akan ikut hancur 
                -- dan memicu error 'ImageLabel is not a valid member of Frame' pada script game.
            end
        end
    end

    -- B. ANTI BLIND VISUAL (Hapus Layar Putih langsung dari pusatnya)
    if State.AntiBlind then
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if PlayerGui then
            local hiddenGui = PlayerGui:FindFirstChild("Hidden")
            if hiddenGui and hiddenGui:FindFirstChild("Blind") then
                hiddenGui.Blind.Visible = false
            end
        end
    end
end)

--// 2. AUTO BREAK GENERATOR (Jalan di Loop Sendiri - Hemat CPU)
task.spawn(function()
    while task.wait(0.5) do 
        if State.AutoBreak then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                for obj in pairs(ObjectCache.Generators) do
                    if obj:IsA("Model") then
                        local genPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if genPart then
                            local distance = (root.Position - genPart.Position).Magnitude
                            if distance < 15 then
                                GenRemote:FireServer(obj)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--// 4. ANTI SLOWDOWN (GLOBAL PROTECTION & ANTI-BLAME)
-- // PERBAIKAN CORE PHYSICS (Heartbeat)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if char and hum then
        local isKnocked = char:GetAttribute("Knocked") or char:GetAttribute("IsKnocked") or _G.isFakeKnocked
        
        -- HANYA paksa WalkSpeed 16 jika TIDAK dalam keadaan Knocked
        if State.NoSlow and not isKnocked and hum.WalkSpeed < 16 then
            hum.WalkSpeed = 16
        end
    end
end)

-- // PERBAIKAN METAMETHOD (Anti WalkSpeed Change)
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
        if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") then
            local char = LocalPlayer.Character
            if char and self:IsDescendantOf(char) then
                -- Jika sedang jadi Killer dan NoSlow Aktif
                if idx == "WalkSpeed" and State.NoSlow then
                    return 16
                end
            end
        end
        return oldIndex(self, idx)
    end))
end)

--=====================================================
-- 🔍 DETEKSI CARRY AKURAT: Cek attribute DAN weld fisik
--=====================================================
local function IsCurrentlyCarrying(char, hrp)
    -- Cek attribute dari server
    if char:GetAttribute("IsCarrying") or char:GetAttribute("Carrying") then
        return true
    end
    -- Cek internal state
    if State and State.isCarrying then
        return true
    end
    -- Cek fisik: ada CarryWeld di HRP
    if hrp then
        for _, child in pairs(hrp:GetChildren()) do
            if child:IsA("Weld") or child:IsA("WeldConstraint") then
                if child.Name == "CarryWeld" or child.Name:find("Carry") then
                    return true
                end
            end
        end
    end
    return false
end

--=====================================================
--=====================================================
-- KILL AURA DEPENDENCIES (REMOTES & HELPERS)
--=====================================================
local UsedHooks = {} 
State.isCarrying = false
local CarryRemote = game:GetService("ReplicatedStorage").Remotes.Carry.CarrySurvivorEvent
local HookRemote = game:GetService("ReplicatedStorage").Remotes.Carry.HookEvent
local AttackRemote = game:GetService("ReplicatedStorage").Remotes.Attacks.BasicAttack
local HitRemote = game:GetService("ReplicatedStorage").Remotes.Attacks.hit

local function GetNearestSafeHook(myPos)
    local nearest, nearestDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do 
        if obj.Name:find("Hook") and (obj:IsA("Model") or obj:IsA("BasePart")) then 
            local hookPos = nil
            if obj:IsA("Model") and obj.PrimaryPart then
                hookPos = obj.PrimaryPart.Position 
            elseif obj:IsA("BasePart") then
                hookPos = obj.Position 
            end

            if hookPos then
                local isAlreadyUsed = false
                for _, usedPos in ipairs(UsedHooks) do
                    if (hookPos - usedPos).Magnitude < 15 then
                        isAlreadyUsed = true
                        break
                    end
                end

                if not isAlreadyUsed then
                    local dist = (myPos - hookPos).Magnitude 
                    if dist < nearestDist then
                        nearestDist = dist 
                        nearest = obj 
                    end
                end
            end
        end
    end
    return nearest
end

local function SafetyResetCarry(char, hrp)
    State.isCarrying = false
    pcall(function() char:SetAttribute("IsCarrying", false) end)
    pcall(function() char:SetAttribute("Carrying", false) end)
    
    if hrp then
        for _, child in pairs(hrp:GetChildren()) do
            if child:IsA("Weld") or child:IsA("WeldConstraint") then
                pcall(function() child:Destroy() end)
            end
        end
        hrp.Anchored = false
    end
end

local function GetKillerMobileActionBtn()
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    local possibleGuis = {"Hidden-mob", "Slasher-mob", "Killer-mob", "Masked-mob"}
    for _, guiName in ipairs(possibleGuis) do
        local killerGui = playerGui:FindFirstChild(guiName)
        if killerGui then
            local actionBtn = killerGui:FindFirstChild("Controls") and killerGui.Controls:FindFirstChild("action")
            if actionBtn then return actionBtn end
        end
    end
    return nil
end

local function PerformHook(char, hrp)
    local hookPart = GetNearestSafeHook(hrp.Position)
    if not hookPart then 
        SafetyResetCarry(char, hrp)
        return 
    end
    
    local carriedSurvivor = nil
    for _, weld in pairs(hrp:GetChildren()) do
        if (weld:IsA("Weld") or weld:IsA("WeldConstraint")) and weld.Part1 then
            local potentialSurvivor = weld.Part1.Parent
            if potentialSurvivor and potentialSurvivor:FindFirstChildOfClass("Humanoid") then
                carriedSurvivor = potentialSurvivor
                break
            end
        end
    end
    if not carriedSurvivor then
        local LocalPlayer = game.Players.LocalPlayer
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" then
                local pChar = p.Character
                if pChar and (pChar:GetAttribute("Knocked") or pChar:GetAttribute("IsKnocked")) 
                   and not (pChar:GetAttribute("IsHooked") or pChar:GetAttribute("Hooked")) then
                    carriedSurvivor = pChar
                    break
                end
            end
        end
    end
    
    local hookTarget = hookPart:IsA("Model") and (hookPart.PrimaryPart or hookPart:FindFirstChildWhichIsA("BasePart")) or hookPart
    if not hookTarget then
        SafetyResetCarry(char, hrp)
        return
    end
    
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.CFrame = hookTarget.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.pi, 0)
    hrp.Anchored = true
    
    task.wait(0.5) 
    hrp.Anchored = false
    task.wait(0.1) 
    
    local hookSuccess = false
    for attempt = 1, 8 do
        hrp.Velocity = Vector3.zero
        hrp.CFrame = hookTarget.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.pi, 0)
        
        local actionBtn = GetKillerMobileActionBtn()
        local VIM = game:GetService("VirtualInputManager")

        if actionBtn and firesignal then
            pcall(function()
                firesignal(actionBtn.MouseButton1Down)
                firesignal(actionBtn.MouseButton1Click)
                firesignal(actionBtn.MouseButton1Up)
            end)
        else
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end
        task.wait(0.4)
        
        if carriedSurvivor then
            local isHooked = carriedSurvivor:GetAttribute("IsHooked") or carriedSurvivor:GetAttribute("Hooked")
            if isHooked then
                hookSuccess = true
                break
            end
        end
        
        if not IsCurrentlyCarrying(char, hrp) and attempt > 1 then
            hookSuccess = true
            break
        end
    end
    
    if hookSuccess then
        task.wait(1.0)
        table.insert(UsedHooks, hookTarget.Position)
        if #UsedHooks > 20 then table.remove(UsedHooks, 1) end
    end
    
    SafetyResetCarry(char, hrp)
    task.wait(1)
end

--=====================================================
-- LOGIC: ADVANCED HOOK SYSTEM
--=====================================================

task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        -- Cek apakah kita sedang membawa survivor (Carry)
        if char and hrp and IsCurrentlyCarrying(char, hrp) then
            
            -- 1. SILENT HOOK (Hapus Animasi Gantung)
            if State.SilentHook then
                local animator = char:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        pcall(function()
                            if track.Name:lower():find("hook") or (track.Animation and track.Animation.AnimationId:find("hook")) then
                                track:Stop()
                            end
                        end)
                    end
                end
            end

            -- 2. HOOK SPAM & FORCE KILL
            if State.HookSpam or State.ForceKillCarried then
                local nearestHook = GetNearestSafeHook(hrp.Position)
                if nearestHook then
                    local amount = State.HookSpam and State.HookAmount or 1
                    
                    -- Spam tembakan ke remote hook
                    for i = 1, amount do
                        pcall(function() HookRemote:FireServer(nearestHook) end)
                    end
                    
                    -- Jika Force Kill aktif, kita anggap gantung berkali-kali sampai mati
                    if State.ForceKillCarried then
                        for i = 1, 50 do
                            pcall(function() HookRemote:FireServer(nearestHook) end)
                        end
                        Library:Notify("Survivor Force Killed!")
                    end
                    
                    task.wait(0.5) -- Cooldown singkat
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════
-- MAIN KILL AURA LOOP
-- ═══════════════════════════════════════════════════
task.spawn(function()
    while task.wait(0.1) do
        if not State.KillAura then continue end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or (LocalPlayer.Team and LocalPlayer.Team.Name ~= "Killer") then continue end

        -- ═══════════════════════════════════════════
        -- CEK STATUS: Apakah lagi gendong survivor?
        -- ═══════════════════════════════════════════
        local carrying = IsCurrentlyCarrying(char, hrp)
        
        if carrying then
            -- ==========================================
            -- 🧲 FASE HOOK: Teleport ke hook & gantung
            -- ==========================================
            PerformHook(char, hrp)
            -- Setelah PerformHook selesai, loop otomatis lanjut ke hunting
            
        else
            -- ==========================================
            -- ⚔️ FASE HUNTING: Cari & serang survivor
            -- ==========================================
            
            -- 🔥 MODE LEGIT: SELALU SWING setiap iterasi (constant animation)
            -- AttackRemote ditembak tanpa peduli ada musuh atau tidak
            if State.AttackMode == "Legit" then
                AttackRemote:FireServer()
            end

            -- Cari target survivor terbaik
            local bestTarget = nil
            local bestDist = math.huge
            local bestChar, bestHrp, bestHum = nil, nil, nil
            local bestIsKnocked = false

            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" then
                    local pChar = p.Character
                    local pHum = pChar and pChar:FindFirstChildOfClass("Humanoid")
                    local pHrp = pChar and pChar:FindFirstChild("HumanoidRootPart")
                    
                    if not pHrp or not pHum or pHum.Health <= 0 then continue end

                    local isHooked = pChar:GetAttribute("IsHooked") or pChar:GetAttribute("Hooked")
                    if isHooked then continue end

                    local dist = (hrp.Position - pHrp.Position).Magnitude
                    local isKnocked = pChar:GetAttribute("Knocked") == true or pChar:GetAttribute("IsKnocked") == true

                    -- Prioritas: Standing survivor > Knocked survivor
                    if not isKnocked then
                        if dist < bestDist then
                            bestDist = dist
                            bestChar = pChar
                            bestHrp = pHrp
                            bestHum = pHum
                            bestIsKnocked = false
                        end
                    elseif not bestChar or (bestIsKnocked and dist < bestDist) then
                        -- Hanya ambil knocked kalau belum ada standing target
                        if bestIsKnocked or not bestChar then
                            bestDist = dist
                            bestChar = pChar
                            bestHrp = pHrp
                            bestHum = pHum
                            bestIsKnocked = true
                        end
                    end
                end
            end

            -- Proses target yang ditemukan
            local spamCount = State.SpamHitCount or 1

            if bestChar and not bestIsKnocked then
                -- ==========================================
                -- 🔥 ATTACK MODE: Serang survivor berdiri
                -- ==========================================
                if State.AttackMode == "Teleport" then
                    -- Mode TP: Samperin dulu baru spam swing & hit
                    hrp.CFrame = bestHrp.CFrame * CFrame.new(0, 0, 2.5)
                    for i = 1, spamCount do
                        AttackRemote:FireServer()
                        HitRemote:FireServer(bestChar, bestHrp)
                    end
                
                elseif State.AttackMode == "Legit" then
                    -- Mode Legit: Spam HitRemote sesuai slider, HANYA kalau target deket (< 15 studs)
                    -- AttackRemote sudah di-fire di atas (constant swing)
                    if bestDist < 15 then
                        for i = 1, spamCount do
                            HitRemote:FireServer(bestChar, bestHrp)
                        end
                    end
                end
                
            elseif bestChar and bestIsKnocked then
                -- ==========================================
                -- 🔥 CARRY: Angkat survivor yang knocked
                -- ==========================================
                task.wait(0.8) -- Delay setelah knocked agar animasi selesai
                
                -- Re-verify target masih knocked & masih ada
                local stillValid = bestChar and bestChar.Parent
                    and bestHrp and bestHrp.Parent
                    and (bestChar:GetAttribute("Knocked") == true or bestChar:GetAttribute("IsKnocked") == true)
                    and not (bestChar:GetAttribute("IsHooked") or bestChar:GetAttribute("Hooked"))
                
                if stillValid then
                    local currentDist = (hrp.Position - bestHrp.Position).Magnitude
                    
                    if State.AttackMode == "Teleport" or currentDist < 15 then
                        -- Teleport ke target knocked
                        hrp.Velocity = Vector3.zero
                        hrp.CFrame = bestHrp.CFrame * CFrame.new(0, 0, 1)
                        task.wait(0.5) -- Jeda sebelum angkat
                        
                        -- Fire carry remote
                        CarryRemote:FireServer(bestChar)
                        State.isCarrying = true
                        --warn("🏋️ [Kill Aura] Carrying " .. bestChar.Name .. "!")
                        
                        -- Tunggu confirmation dari server (attribute update)
                        task.wait(1.5)
                        
                        -- Double check: kalau attribute belum update tapi ada weld, anggap carry berhasil
                        if not IsCurrentlyCarrying(char, hrp) then
                            -- warn("⚠️ [Kill Aura] Carry mungkin gagal, reset...")
                            State.isCarrying = false
                        end
                    end
                end
            end
        end
    end
end)

-- =====================================================
-- KILLER BREAK SPEED ENGINE (ROBUST METATABLE HOOK)
-- =====================================================
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

if hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() then
            -- Intersepsi pemanggilan SetAttribute dari game script
            if method == "SetAttribute" or method == "setAttribute" then
                local attrName = tostring(args[1]):lower()
                
                if attrName:find("break") or attrName:find("stomp") or attrName:find("actionspeed") then
                    if State.Killer and State.Killer.BreakSpeed > 1 then
                        args[2] = State.Killer.BreakSpeed

                        -- Kembalikan via oldNamecall dengan setnamecallmethod yang dipasang proper
                        if setnamecallmethod then
                            setnamecallmethod(method)
                        end
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end

        -- Untuk seluruh method namecall lainnya (FireServer, Lookscript CFrame, Replicator buffer, dsb)
        if setnamecallmethod then
            setnamecallmethod(method)
        end
        return oldNamecall(self, ...)
    end)
end

-- 🛡️ LAPIS DUKUNGAN: Force Attribute & Animation Track Speed Adjuster
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local speedVal = (State.Killer and State.Killer.BreakSpeed) or 1

    if speedVal > 1 then
        -- Force Attribute pada Karakter
        if char:GetAttribute("BreakSpeed") then
            char:SetAttribute("BreakSpeed", speedVal)
        end
        if char:GetAttribute("ActionSpeed") then
            char:SetAttribute("ActionSpeed", speedVal)
        end

        -- Accelerate Animasi Break/Stomp/Kick
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    local animName = track.Name:lower()
                    if animName:find("break") or animName:find("stomp") or animName:find("kick") or animName:find("destroy") then
                        track:AdjustSpeed(speedVal)
                    end
                end
            end
        end
    end
end)

--=====================================================
-- 🛠️ DYNAMIC GENERATOR STATUS UI (SLIDE ANIMATION) 🛠️
--=====================================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local isMobile = UserInputService.TouchEnabled

    if _G.GenStatusGui then _G.GenStatusGui:Destroy() end

    local GenStatusGui = Instance.new("ScreenGui")
    GenStatusGui.Name = "BoyfinityGenStatusUI"
    GenStatusGui.Parent = CoreGui
    GenStatusGui.Enabled = false -- Default mati, nyala dari Toggle UI
    _G.GenStatusGui = GenStatusGui

    -- Responsivitas (Ukuran beda antara PC dan Mobile)
    local frameWidth = isMobile and 130 or 170
    local textSize = isMobile and 10 or 12

    -- Posisi
    local openPos = UDim2.new(1, -frameWidth - 10, 0, 10)  -- Terbuka (Pojok kanan atas)
    local closedPos = UDim2.new(1, 10, 0, 10)              -- Tertutup (Ngeslide ke kanan luar layar)
    
    local btnOpenPos = UDim2.new(1, -frameWidth - 30, 0, 10) -- Posisi tombol panah saat terbuka
    local btnClosedPos = UDim2.new(1, -20, 0, 10)            -- Posisi tombol panah saat tertutup

    -- Frame Utama
    local GenFrame = Instance.new("Frame")
    GenFrame.Parent = GenStatusGui
    GenFrame.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
    GenFrame.BackgroundTransparency = 0.01
    GenFrame.BorderSizePixel = 0
    GenFrame.Position = openPos
    GenFrame.Size = UDim2.new(0, frameWidth, 0, 100) -- Tinggi sementara, nanti otomatis
    Instance.new("UICorner", GenFrame).CornerRadius = UDim.new(0, 8)

    local GenStroke = Instance.new("UIStroke")
    GenStroke.Parent = GenFrame
    GenStroke.Color = Color3.fromRGB(70, 36, 138)
    GenStroke.Thickness = 1.5
    GenStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Judul
    local Title = Instance.new("TextLabel")
    Title.Parent = GenFrame
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Generator Status"
    Title.TextColor3 = Color3.fromRGB(188, 0, 255)
    Title.TextSize = textSize + 3

    -- Isi Text Generator
    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Parent = GenFrame
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Position = UDim2.new(0, 8, 0, 25)
    ContentLabel.Size = UDim2.new(1, -16, 1, -30)
    ContentLabel.Font = Enum.Font.GothamBold
    ContentLabel.Text = "Scanning..."
    ContentLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    ContentLabel.TextSize = textSize + 2
    ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Tombol Slide Minimize (< / >)
    local SlideBtn = Instance.new("TextButton")
    SlideBtn.Parent = GenStatusGui
    SlideBtn.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
    SlideBtn.BackgroundTransparency = 0.2
    SlideBtn.Size = UDim2.new(0, 20, 0, 25)
    SlideBtn.Position = btnOpenPos
    SlideBtn.Font = Enum.Font.GothamBold
    SlideBtn.Text = ">"
    SlideBtn.TextColor3 = Color3.fromRGB(188, 0, 255)
    SlideBtn.TextSize = 14
    Instance.new("UICorner", SlideBtn).CornerRadius = UDim.new(0, 4)

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Parent = SlideBtn
    BtnStroke.Color = Color3.fromRGB(70, 36, 138)
    BtnStroke.Thickness = 1.5
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Animasi Slide Logic
    local isMinimized = false
    SlideBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        SlideBtn.Text = isMinimized and "<" or ">"
        
        local targetFramePos = isMinimized and closedPos or openPos
        local targetBtnPos = isMinimized and btnClosedPos or btnOpenPos
        
        local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(GenFrame, tweenInfo, {Position = targetFramePos}):Play()
        TweenService:Create(SlideBtn, tweenInfo, {Position = targetBtnPos}):Play()
    end)

    -- Auto-Update Data & Dynamic Height
    local lastUpdate = 0
    RunService.RenderStepped:Connect(function()
        local S = _G.SharedState or getgenv().State
        if not S or not S.ShowGenStatusUI then return end

        if tick() - lastUpdate >= 1 then -- Update teks setiap 1 detik biar ga ngelag
            lastUpdate = tick()
            local data = S.GeneratorData or {}
            
            if #data == 0 then
                ContentLabel.Text = "Waiting for map..."
                GenFrame.Size = UDim2.new(0, frameWidth, 0, 50)
            else
                local textResult = ""
                for i, gen in ipairs(data) do
                    -- Format: Gen 1: 50% ⏳
                    textResult = textResult .. string.format("Generator %d : %d%% %s\n", i, gen.Progress, gen.Status)
                end
                ContentLabel.Text = textResult
                
                -- Hitung tinggi otomatis (Header 25px + (Jumlah Gen * Jarak per baris) + Padding bawah)
                local dynamicHeight = 25 + (#data * (textSize + 5)) + 5
                GenFrame.Size = UDim2.new(0, frameWidth, 0, dynamicHeight)
            end
        end
    end)
end)


--=====================================================
-- 🔮 KILLER PERKS INFO & REAL-TIME NOTIFICATION SYSTEM 🔮
--=====================================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local isMobile = UserInputService.TouchEnabled

    if _G.KillerPerksGui then _G.KillerPerksGui:Destroy() end

    -- Database Definisi Semua Perk Killer dari PerksInfo.txt
    local KillerPerksDatabase = {
        ["Abyssal Covenant"] = {
            keys = {"abyssalcovenant", "abyssal_covenant", "abyssal"},
            desc = "Spawns 4 Cursed Chains. Trapping a Survivor causes gauge indicator explosion (-3/4/5%).",
            shortDesc = "Spawns 4 Cursed Chains & explodes repair gauge upon trapping"
        },
        ["All Seeing Eye"] = {
            keys = {"allseingeye", "allseeingeye", "all_seeing_eye"},
            desc = "Reveals aura of Generators worked on by >1 Survivor; repair 6/8/10% slower.",
            shortDesc = "Reveals co-op generators & slows repair by 6/8/10%"
        },
        ["Blood Between Worlds"] = {
            keys = {"bloodbetweenworlds", "blood_between_worlds"},
            desc = "When a Survivor loses health state, top 2 progressed gens regress for 45s (45s CD).",
            shortDesc = "Top 2 gens regress for 45s when survivor takes damage"
        },
        ["Brutal Strength"] = {
            keys = {"brutalstrength", "brutal_strength", "brutal"},
            desc = "Breaks pallets & kicks gens 10/20/30% faster; kicks deal +1/2/3% damage.",
            shortDesc = "10/20/30% faster pallet breaks & gen damage boost"
        },
        ["Cold Blooded"] = {
            keys = {"coldblooded", "cold_blooded"},
            desc = "Downing a survivor afflicts healthy survivors within 60 studs with Slowness & reveals aura for 4s.",
            shortDesc = "Downs apply 9-15% Slowness & 4s aura to survivors within 60 studs"
        },
        ["Containment"] = {
            keys = {"containment"},
            desc = "Vaults windows 5/7.5/10% faster and blocks window for 12/14/16s.",
            shortDesc = "Vaults 5-10% faster & blocks vaulted windows for 12-16s"
        },
        ["Corrupted Path"] = {
            keys = {"corruptedpath", "corrupted_path"},
            desc = "Hitting a Survivor creates a corrupted trail slowing anyone touching it by 7% for 20-30s.",
            shortDesc = "Hit survivors spawn trails causing 7% Slowness for 20-30s"
        },
        ["Deep Wound"] = {
            keys = {"deepwound", "deep_wound"},
            desc = "Spawns 3 Cursed Chains. Freed survivors gain Anti-Heal status effect for 20-40s.",
            shortDesc = "Freed survivors suffer Anti-Heal status for 20-40s"
        },
        ["Diminishing Returns"] = {
            keys = {"diminishingreturns", "diminishing_returns"},
            desc = "Damage grants tokens (max 2). Chaining spends tokens to reduce all repair speed by 3% per token.",
            shortDesc = "Reduces team repair speed up to 6% upon chaining"
        },
        ["Dread Harvest"] = {
            keys = {"dreadharvest", "dread_harvest"},
            desc = "Gain 1/2/3% Speed Boost per survivor actively repairing while a survivor is chained.",
            shortDesc = "Killer gets speed boost per repairing survivor while chaining"
        },
        ["Echo Location"] = {
            keys = {"echolocation", "echo_location"},
            desc = "After kicking a generator, reveals aura of Survivors within 100 studs for 3/4/5s.",
            shortDesc = "Reveals survivor auras within 100 studs after kicking gen"
        },
        ["Echo Of The Void"] = {
            keys = {"echoofthevoid", "echo_of_the_void", "echovoid"},
            desc = "Being spotted for 1.5/1.2/0.9s reveals the survivor for 4s and turns vision monochrome.",
            shortDesc = "Looking at killer triggers 4s aura reveal & monochrome vision"
        },
        ["Enhanced Senses"] = {
            keys = {"enhancedsenses", "enhanced_senses"},
            desc = "Survivor fast/med vault or pallet drop reveals aura for 4/5/6s (+2s all aura reads, 30s CD).",
            shortDesc = "Vaulting/Dropping pallet reveals your aura for 4-6s (30s CD)"
        },
        ["Eternal Torment"] = {
            keys = {"eternaltorment", "eternal_torment"},
            desc = "Stunning killer inflicts Vulnerable (20-30s). Pallet drop inflicts 5% Slowness for 4s.",
            shortDesc = "Stun inflicts Vulnerable; dropping pallet inflicts 5% Slowness"
        },
        ["Excitement"] = {
            keys = {"excitement"},
            desc = "Picks up downed survivors 25/33/50% faster, grants 9/12/15% speed while carrying.",
            shortDesc = "Faster pickup & 9-15% speed boost while carrying"
        },
        ["Exposure Therapy"] = {
            keys = {"exposuretherapy", "exposure_therapy"},
            desc = "Completing a heal within 150 studs inflicts Vulnerable (10s+) and reveals aura.",
            shortDesc = "Healing within 150 studs inflicts Vulnerable & aura reveal"
        },
        ["Eyes Of Hell"] = {
            keys = {"eyesofhell", "eyes_of_hell"},
            desc = "Sees pallets & vault auras within 80-100 studs. Survivor vault inflicts 5% Slowness for 8s.",
            shortDesc = "Survivor vaulting inflicts 5% Slowness for 8s (30-60s CD)"
        },
        ["Foundation Staff"] = {
            keys = {"foundationstaff", "foundation_staff"},
            desc = "Unchaining inflicts -10/20/30% healing speed for 60s; freed survivor has -15% repair speed.",
            shortDesc = "Unchaining causes healing slowdown; freed has -15% repair penalty"
        },
        ["King's Scourge"] = {
            keys = {"kingsscourge", "kings_scourge", "king_scourge"},
            desc = "Generators at 90% trigger 9/12/15 special skill checks; failing inflicts Vulnerable & regression.",
            shortDesc = "Gens at 90% spawn difficult skill checks; fail causes Vulnerable"
        },
        ["Murderous Acrobatics"] = {
            keys = {"murderousacrobatics", "murderous_acrobatics"},
            desc = "Once every 45s during chase, killer vaults 20% faster and gains 3/5/7% speed boost.",
            shortDesc = "Vaults 20% faster & gets speed boost during chase"
        },
        ["Next in Line"] = {
            keys = {"nextinline", "next_in_line"},
            desc = "Chaining a Survivor reveals aura of survivors >120 studs away for 6/7/8 seconds.",
            shortDesc = "Aura revealed for 6-8s when survivor chained if >120 studs away"
        },
        ["Piercing Reverie"] = {
            keys = {"piercingreverie", "piercing_reverie"},
            desc = "First chain blocks highest progress gen for 25s, white aura, 50% regression boost.",
            shortDesc = "First chain blocks highest gen for 25s & increases regression"
        },
        ["Play With Your Food"] = {
            keys = {"playwithyourfood", "play_with_your_food", "pwyf"},
            desc = "Escaping chase grants tokens for 1/2/3% Speed Boost (max 3 tokens).",
            shortDesc = "Escaping chase grants killer up to 9% speed boost"
        },
        ["Predator"] = {
            keys = {"predator"},
            desc = "Escaping chase reveals survivor aura for 8s and gives killer 5% speed boost.",
            shortDesc = "Escaped survivor aura revealed for 8s with 5% speed boost"
        },
        ["Silent Shadow"] = {
            keys = {"silentshadow", "silent_shadow"},
            desc = "Leaving chase without down readies Undetectable for 20/30/40s next chase exit.",
            shortDesc = "Killer gains Undetectable status after abandoned chases"
        },
        ["Sloppy Mess"] = {
            keys = {"sloppymess", "sloppy_mess"},
            desc = "Basic attack leaves blood 2x as frequently and inflicts 15/20/25% healing slowdown.",
            shortDesc = "Hit survivors bleed 2x and suffer 15-25% healing slowdown"
        },
        ["Stage Fright"] = {
            keys = {"stagefright", "stage_fright"},
            desc = "Whenever killer aura is revealed, killer gains 5/6/7% speed boost.",
            shortDesc = "Killer gets 5-7% speed boost whenever their aura is revealed"
        },
        ["Surge of Power"] = {
            keys = {"surgeofpower", "surge_of_power"},
            desc = "Within 50-70 studs of completed gen gains 6% Speed Boost (3% near regressing).",
            shortDesc = "Killer gains 6% speed boost near completed generators"
        },
        ["Terror Spread"] = {
            keys = {"terrorspread", "terror_spread"},
            desc = "Each completed gen inflicts Winded on all survivors and gives killer Undetectable for 20-40s.",
            shortDesc = "Gen completion inflicts Winded on all survivors & killer Undetectable"
        },
        ["Touch Of Death"] = {
            keys = {"touchofdeath", "touch_of_death"},
            desc = "Vaulting marks window (60s). Vaulting survivor suffers Vulnerable (10-20s) and 2s aura reveal.",
            shortDesc = "Vaulting marked window inflicts Vulnerable (10-20s) & reveals aura"
        },
        ["Trade Off"] = {
            keys = {"tradeoff", "trade_off"},
            desc = "Chaining on Cursed Chain reveals top gen for 10-20s; repairing it is 15% slower.",
            shortDesc = "Cursed chain traps reveal highest gen & slow repair by 15%"
        },
        ["Veiled Corruption"] = {
            keys = {"veiledcorruption", "veiled_corruption"},
            desc = "Start of match freezes 3 furthest gens for 45-75s.",
            shortDesc = "3 furthest gens blocked at start of match for 45-75s"
        },
        ["Visceral Drive"] = {
            keys = {"visceraldrive", "visceral_drive"},
            desc = "After chaining, next kick regresses 10-16% and reveals injured survivors within 120 studs for 5s.",
            shortDesc = "Post-chain kick regresses 10-16% & reveals injured auras"
        }
    }

    -- GUI SETUP (Slider Atas)
    local PerksGui = Instance.new("ScreenGui")
    PerksGui.Name = "BoyfinityKillerPerksUI"
    PerksGui.Parent = CoreGui
    PerksGui.Enabled = false
    _G.KillerPerksGui = PerksGui

    local frameW = isMobile and 330 or 400
    local normalH = 145

    -- Slider Atas: Tertutup di atas layar (Y < 0), Terbuka di Y = 12
    local targetOpenY = 12
    local targetClosedY = -220

    -- Container Utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "PerksFrame"
    MainFrame.Parent = PerksGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 15, 38)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -math.floor(frameW / 2), 0, targetClosedY)
    MainFrame.Size = UDim2.new(0, frameW, 0, normalH)
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Parent = MainFrame
    FrameStroke.Color = Color3.fromRGB(110, 50, 190)
    FrameStroke.Thickness = 1.8
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Header / Title Bar (Area Drag)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundColor3 = Color3.fromRGB(36, 20, 58)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Size = UDim2.new(1, 0, 0, 28)
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

    local TitleIcon = Instance.new("TextLabel")
    TitleIcon.Parent = Header
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Position = UDim2.new(0, 10, 0, 0)
    TitleIcon.Size = UDim2.new(0, 20, 1, 0)
    TitleIcon.Font = Enum.Font.GothamBold
    TitleIcon.Text = "⚡"
    TitleIcon.TextColor3 = Color3.fromRGB(255, 185, 0)
    TitleIcon.TextSize = 14

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = Header
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 32, 0, 0)
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "Killer Perks Detected"
    TitleLabel.TextColor3 = Color3.fromRGB(215, 130, 255)
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local DragHint = Instance.new("TextLabel")
    DragHint.Parent = Header
    DragHint.BackgroundTransparency = 1
    DragHint.Position = UDim2.new(1, -85, 0, 0)
    DragHint.Size = UDim2.new(0, 75, 1, 0)
    DragHint.Font = Enum.Font.Gotham
    DragHint.Text = "↔ Drag X"
    DragHint.TextColor3 = Color3.fromRGB(150, 130, 180)
    DragHint.TextSize = 10
    DragHint.TextXAlignment = Enum.TextXAlignment.Right

    -- Scrollable List untuk Perks
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Name = "PerksScroll"
    ScrollList.Parent = MainFrame
    ScrollList.BackgroundTransparency = 1
    ScrollList.BorderSizePixel = 0
    ScrollList.Position = UDim2.new(0, 8, 0, 32)
    ScrollList.Size = UDim2.new(1, -16, 1, -38)
    ScrollList.ScrollBarThickness = 3
    ScrollList.ScrollBarImageColor3 = Color3.fromRGB(188, 0, 255)
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Parent = ScrollList
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 4)

    -- Status Empty / Scanning Label
    local StatusMsgLabel = Instance.new("TextLabel")
    StatusMsgLabel.Name = "StatusMsg"
    StatusMsgLabel.Parent = ScrollList
    StatusMsgLabel.BackgroundTransparency = 1
    StatusMsgLabel.Size = UDim2.new(1, 0, 0, 70)
    StatusMsgLabel.Font = Enum.Font.Gotham
    StatusMsgLabel.Text = "🔍 Scanning Killer's attributes..."
    StatusMsgLabel.TextColor3 = Color3.fromRGB(180, 180, 210)
    StatusMsgLabel.TextSize = 12
    StatusMsgLabel.TextWrapped = true

    -- DRAGGABLE LOGIC: HANYA HORIZONTAL (KUNCI KOORDINAT Y)
    local isDragging = false
    local dragInput = nil
    local dragStartPos = nil
    local startFrameX = nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = input.Position
            startFrameX = MainFrame.Position.X

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging and dragStartPos and startFrameX then
            local deltaX = input.Position.X - dragStartPos.X
            -- Y TETAP DIKUNCI pada targetOpenY
            MainFrame.Position = UDim2.new(startFrameX.Scale, startFrameX.Offset + deltaX, 0, targetOpenY)
        end
    end)

    -- POP-UP SLIDER ATAS ANIMATION (TOGGLE CONTROL)
    local isUiActive = false
    local function TogglePerksUI(show)
        isUiActive = show
        local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if show then
            PerksGui.Enabled = true
            TweenService:Create(MainFrame, tweenInfo, {
                Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0, targetOpenY)
            }):Play()
        else
            local closeTween = TweenService:Create(MainFrame, tweenInfo, {
                Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0, targetClosedY)
            })
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not isUiActive then
                    PerksGui.Enabled = false
                end
            end)
        end
    end
    _G.PerksInfoToggle = TogglePerksUI

    -- HELPER: CARI KILLER PLAYER & OBJECT
    local function FindKiller()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Team and (plr.Team.Name == "Killer" or plr.Team.Name == "Slasher") then
                return plr, plr.Character
            end
        end
        -- Fallback jika Team belum diset tapi memiliki atribut killer spesifik
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                local char = plr.Character
                if (char and (char:GetAttribute("IsCarrying") ~= nil or char:GetAttribute("successswingendlag") ~= nil)) 
                   or plr:GetAttribute("allseingeye") ~= nil or plr:GetAttribute("BloodBetweenWorlds") ~= nil then
                    return plr, char
                end
            end
        end
        return nil, nil
    end

    -- SCANNER: MENDETEKSI SELURUH PERK KILLER
    local activeDetectedPerks = {}

    local function RenderPerksList()
        -- Hapus item lama kecuali StatusMsgLabel
        for _, child in ipairs(ScrollList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local perkCount = 0
        for perkName, data in pairs(activeDetectedPerks) do
            perkCount = perkCount + 1
            
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Name = "PerkItem"
            ItemFrame.Parent = ScrollList
            ItemFrame.BackgroundColor3 = Color3.fromRGB(35, 22, 54)
            ItemFrame.BackgroundTransparency = 0.25
            ItemFrame.Size = UDim2.new(1, 0, 0, 36)
            ItemFrame.BorderSizePixel = 0
            Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 6)

            local Stroke = Instance.new("UIStroke")
            Stroke.Parent = ItemFrame
            Stroke.Color = Color3.fromRGB(80, 45, 120)
            Stroke.Thickness = 1

            local PerkIcon = Instance.new("TextLabel")
            PerkIcon.Parent = ItemFrame
            PerkIcon.BackgroundTransparency = 1
            PerkIcon.Position = UDim2.new(0, 6, 0, 2)
            PerkIcon.Size = UDim2.new(0, 20, 0, 20)
            PerkIcon.Font = Enum.Font.GothamBold
            PerkIcon.Text = "✦"
            PerkIcon.TextColor3 = Color3.fromRGB(255, 215, 0)
            PerkIcon.TextSize = 13

            local NameLabel = Instance.new("TextLabel")
            NameLabel.Parent = ItemFrame
            NameLabel.BackgroundTransparency = 1
            NameLabel.Position = UDim2.new(0, 28, 0, 2)
            NameLabel.Size = UDim2.new(1, -34, 0, 16)
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.Text = perkName
            NameLabel.TextColor3 = Color3.fromRGB(240, 230, 255)
            NameLabel.TextSize = 12
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left

            local DescLabel = Instance.new("TextLabel")
            DescLabel.Parent = ItemFrame
            DescLabel.BackgroundTransparency = 1
            DescLabel.Position = UDim2.new(0, 28, 0, 18)
            DescLabel.Size = UDim2.new(1, -34, 0, 14)
            DescLabel.Font = Enum.Font.Gotham
            DescLabel.Text = data.shortDesc or data.desc
            DescLabel.TextColor3 = Color3.fromRGB(175, 160, 210)
            DescLabel.TextSize = 10
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
        end

        if perkCount > 0 then
            StatusMsgLabel.Visible = false
            TitleLabel.Text = string.format("Killer Perks Detected (%d)", perkCount)
            -- Dinamis height jika sedikit item
            local neededH = math.clamp(35 + (perkCount * 40), 90, 200)
            MainFrame.Size = UDim2.new(0, frameW, 0, neededH)
        else
            StatusMsgLabel.Visible = true
            StatusMsgLabel.Text = "🔍 Scanning Killer's attributes (None found yet)..."
            TitleLabel.Text = "Killer Perks Detected (0)"
            MainFrame.Size = UDim2.new(0, frameW, 0, 110)
        end
    end

    local function ScanKillerPerks()
        local killerPlr, killerChar = FindKiller()
        if not killerPlr and not killerChar then return end

        local newFound = false

        -- Kumpulkan semua atribut dari Player dan Character Killer
        local allAttributes = {}
        if killerPlr then
            for attr, val in pairs(killerPlr:GetAttributes()) do
                allAttributes[string.lower(string.gsub(attr, "[_%s]", ""))] = { orig = attr, val = val }
            end
        end
        if killerChar then
            for attr, val in pairs(killerChar:GetAttributes()) do
                allAttributes[string.lower(string.gsub(attr, "[_%s]", ""))] = { orig = attr, val = val }
            end
        end

        -- Cek kecocokan dengan database
        for perkName, info in pairs(KillerPerksDatabase) do
            local matched = false
            for _, key in ipairs(info.keys) do
                local cleanKey = string.lower(string.gsub(key, "[_%s]", ""))
                if allAttributes[cleanKey] ~= nil then
                    matched = true
                    break
                end
            end
            
            -- Cek juga fuzzy check jika nama perk persis ada di atribut
            local cleanPerkName = string.lower(string.gsub(perkName, "[_%s]", ""))
            if allAttributes[cleanPerkName] ~= nil then
                matched = true
            end

            if matched and not activeDetectedPerks[perkName] then
                activeDetectedPerks[perkName] = info
                newFound = true
            end
        end

        -- Tambahan: Auto-register atribut apapun yang memiliki pola perk tapi belum ada di dict
        for cleanAttr, data in pairs(allAttributes) do
            local isIgnored = (cleanAttr == "health" or cleanAttr == "speed" or cleanAttr == "immobile" 
                or cleanAttr == "platform" or cleanAttr == "cooldowntoken" or cleanAttr == "action" 
                or cleanAttr == "isvaulting" or cleanAttr == "isstunned" or cleanAttr == "iscarrying" 
                or cleanAttr == "carrying" or cleanAttr == "mask" or cleanAttr == "spearmode")
            if not isIgnored and type(data.val) == "boolean" and data.val == true then
                local exists = false
                for _, info in pairs(activeDetectedPerks) do
                    for _, k in ipairs(info.keys) do
                        if string.lower(string.gsub(k, "[_%s]", "")) == cleanAttr then
                            exists = true
                            break
                        end
                    end
                end
                if not exists and not activeDetectedPerks[data.orig] then
                    activeDetectedPerks[data.orig] = {
                        desc = "Custom active Killer attribute detected: " .. tostring(data.orig),
                        shortDesc = "Detected killer attribute: " .. tostring(data.orig)
                    }
                    newFound = true
                end
            end
        end

        if newFound then
            RenderPerksList()
        end
    end

    -- =========================================================
    -- REAL-TIME NOTIFIKASI EFEK PERK TERHADAP SURVIVOR
    -- =========================================================
    local lastNotifTimes = {}
    local function NotifyPerk(id, title, text, duration)
        local now = tick()
        if lastNotifTimes[id] and (now - lastNotifTimes[id]) < 6 then
            return -- Debounce per notif ID biar tidak spamming
        end
        lastNotifTimes[id] = now
        Library:Notify(string.format("⚠️ [%s]: %s", title, text), duration or 6)
    end

    local function HasPerk(name)
        return activeDetectedPerks[name] ~= nil
    end

    -- 1. Next in Line & Dread Harvest Tracker (Saat Killer Chaining Survivor)
    local prevCarrying = false
    local function MonitorKillerCarryState()
        local _, killerChar = FindKiller()
        if not killerChar then return end

        local isCarrying = (killerChar:GetAttribute("IsCarrying") == true or killerChar:GetAttribute("Carrying") == true)
        
        -- Deteksi momen Chained / Hooked
        if prevCarrying and not isCarrying then
            -- Killer baru saja melepaskan / chaining survivor
            local myChar = Players.LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local kHrp = killerChar:FindFirstChild("HumanoidRootPart")

            if myHrp and kHrp then
                local dist = (myHrp.Position - kHrp.Position).Magnitude
                if HasPerk("Next in Line") and dist > 120 then
                    NotifyPerk("NextInLine", "Next in Line", "Aura kamu terlihat karena perk Next in Line selama 6/7/8 detik!", 7)
                end
                if HasPerk("Visceral Drive") then
                    NotifyPerk("VisceralDrive", "Visceral Drive", "Killer baru saja chain! Generator kick berikutnya berkurang 10-16% & mendeteksi aura!", 6)
                end
                if HasPerk("Trade Off") then
                    NotifyPerk("TradeOff", "Trade Off", "Survivor di-chain di Cursed Chain! Generator tertinggi terdeteksi & repair melambat 15%!", 6)
                end
            end
        end
        prevCarrying = isCarrying
    end

    -- 2. All Seeing Eye Tracker: Cek generator yang diperbaiki >1 Survivor
    local function MonitorAllSeeingEye()
        if not HasPerk("All Seeing Eye") then return end
        
        local myChar = Players.LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        for gen in pairs(ObjectCache.Generators) do
            local p = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
            if p and (myHrp.Position - p.Position).Magnitude <= 14 then
                -- Survivor kita sedang di sekitar mesin ini, cek apakah ada survivor kawan lain
                local coSurvCount = 0
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Team and (plr.Team.Name == "Survivors" or plr.Team.Name == "Survivor") then
                        local oChar = plr.Character
                        local oHrp = oChar and oChar:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - p.Position).Magnitude <= 14 then
                            coSurvCount = coSurvCount + 1
                        end
                    end
                end

                if coSurvCount > 1 then
                    NotifyPerk("AllSeeingEye", "All Seeing Eye", "Kecepatan repair lambat dan generator terdeteksi karena perk All Seeing Eye!", 6)
                    break
                end
            end
        end
    end

    -- 3. Blood Between Worlds Tracker: Cek health state survivor turun
    local prevHealthStates = {}
    local function MonitorBloodBetweenWorlds()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Team and (plr.Team.Name == "Survivors" or plr.Team.Name == "Survivor") then
                local char = plr.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local pKey = plr.UserId
                    local curHealth = hum.Health
                    local oldHealth = prevHealthStates[pKey]

                    if oldHealth and curHealth < oldHealth then
                        -- Ada survivor kehilangan health!
                        if HasPerk("Blood Between Worlds") then
                            NotifyPerk("BloodBetweenWorlds", "Blood Between Worlds", "Survivor terluka! 2 Generator progress tertinggi terkena regresi dari Blood Between Worlds!", 6)
                        end
                    end
                    prevHealthStates[pKey] = curHealth
                end
            end
        end
    end

    -- 4. Cold Blooded Tracker: Saat Killer down survivor, cek jika kita dlm 60 studs & Healthy
    local prevKnockedStates = {}
    local function MonitorColdBlooded()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Team and (plr.Team.Name == "Survivors" or plr.Team.Name == "Survivor") then
                local char = plr.Character
                if char then
                    local isKnocked = (char:GetAttribute("Knocked") == true or char:GetAttribute("IsKnocked") == true)
                    local wasKnocked = prevKnockedStates[plr.UserId]

                    if isKnocked and not wasKnocked then
                        -- Seseorang baru saja di-down!
                        local myChar = Players.LocalPlayer.Character
                        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        local kPlr, kChar = FindKiller()
                        local kHrp = kChar and kChar:FindFirstChild("HumanoidRootPart")

                        if HasPerk("Cold Blooded") and myHum and myHum.Health > 60 and myHrp and kHrp then
                            local dist = (myHrp.Position - kHrp.Position).Magnitude
                            if dist <= 65 then
                                NotifyPerk("ColdBlooded", "Cold Blooded", "Survivor di-down! Kamu terkena 9-15% Slowness & Aura terlihat selama 4s (Cold Blooded)!", 7)
                            end
                        end
                    end
                    prevKnockedStates[plr.UserId] = isKnocked
                end
            end
        end
    end

    -- 5. Enhanced Senses & Eyes Of Hell Tracker: Vaulting / Pallet Dropping
    local function SetupSurvivorActionMonitoring()
        local function HookCharacter(char)
            if not char then return end
            
            -- Monitor attribute changes pada karakter survivor kita (Slowness, Vulnerable, Aura)
            char.AttributeChanged:Connect(function(attr)
                local attrLower = string.lower(attr)
                local val = char:GetAttribute(attr)

                if (attrLower:find("slow") or attrLower:find("speed")) and val and val < 1 then
                    if HasPerk("Eternal Torment") then
                        NotifyPerk("EternalTormentSlow", "Eternal Torment", "Kamu terkena Slowness 5% karena efek perk Eternal Torment!", 4)
                    elseif HasPerk("Eyes Of Hell") then
                        NotifyPerk("EyesOfHellSlow", "Eyes Of Hell", "Kamu terkena Slowness 5% saat vault dari perk Eyes Of Hell!", 5)
                    elseif HasPerk("Corrupted Path") then
                        NotifyPerk("CorruptedPathSlow", "Corrupted Path", "Kamu menyentuh trail terkutuk dan terkena Slowness 7% (Corrupted Path)!", 5)
                    else
                        NotifyPerk("GenericSlow", "Status Effect", "Karakter kamu terkena efek Slowness!", 4)
                    end
                end

                if (attrLower:find("vulnerable") or attrLower:find("exposed")) and (val == true or (type(val) == "number" and val > 0)) then
                    if HasPerk("Eternal Torment") then
                        NotifyPerk("EternalTormentVuln", "Eternal Torment", "Kamu terkena Vulnerable setelah men-stun Killer (Eternal Torment)!", 6)
                    elseif HasPerk("Touch Of Death") then
                        NotifyPerk("TouchOfDeathVuln", "Touch Of Death", "Kamu melewati jendela bertanda! Terkena Vulnerable & Aura terbaca (Touch Of Death)!", 6)
                    elseif HasPerk("Exposure Therapy") then
                        NotifyPerk("ExposureVuln", "Exposure Therapy", "Selesai healing! Kamu dan temanmu terkena Vulnerable (Exposure Therapy)!", 6)
                    elseif HasPerk("King's Scourge") then
                        NotifyPerk("KingScourgeVuln", "King's Scourge", "Gagal skill check King's Scourge! Status kamu menjadi Vulnerable!", 6)
                    else
                        NotifyPerk("GenericVuln", "Status Effect", "Karakter kamu terkena efek Vulnerable (One-hit Down)!", 5)
                    end
                end

                if (attrLower:find("winded") or attrLower:find("exhausted")) and val == true then
                    if HasPerk("Terror Spread") then
                        NotifyPerk("TerrorSpread", "Terror Spread", "Generator selesai! Seluruh survivor menderita Winded & Killer Undetectable!", 6)
                    end
                end
            end)

            -- Monitor Animasi Vault untuk deteksi Enhanced Senses & Eyes of Hell
            local hum = char:WaitForChild("Humanoid", 5)
            if hum then
                hum.AnimationPlayed:Connect(function(track)
                    local animName = track.Animation and track.Animation.Name:lower() or ""
                    if animName:find("vault") or animName:find("jump") then
                        if HasPerk("Enhanced Senses") then
                            NotifyPerk("EnhancedSensesVault", "Enhanced Senses", "Kamu melakukan Vault! Aura kamu terlihat oleh Killer selama 4-6s (Enhanced Senses)!", 5)
                        end
                        if HasPerk("Eyes Of Hell") then
                            NotifyPerk("EyesOfHellVault", "Eyes Of Hell", "Perk Eyes Of Hell aktif! Memperlambat kamu setelah vault!", 4)
                        end
                    end
                end)
            end
        end

        if Players.LocalPlayer.Character then
            HookCharacter(Players.LocalPlayer.Character)
        end
        Players.LocalPlayer.CharacterAdded:Connect(HookCharacter)
    end
    SetupSurvivorActionMonitoring()

    -- MAIN LOOP: SCAN PERKS & MONITOR EFFECT
    local lastScanTick = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastScanTick >= 1.5 then
            lastScanTick = now
            ScanKillerPerks()
            MonitorKillerCarryState()
            MonitorAllSeeingEye()
            MonitorBloodBetweenWorlds()
            MonitorColdBlooded()
        end
    end)
end)

-- Sets the draggable label visibility
--=====================================================
-- WATERMARK SYSTEM & UI TOGGLE
--=====================================================
-- 1. Setup Watermark Label
DraggableLabel = Library:AddDraggableLabel("boyfinity")
DraggableLabel:SetVisible(true)
 
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
 
-- 2. Logic Update FPS & Ping
game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1
 
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
 
    DraggableLabel:SetText(('boyfinity | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

-- 3. Tambahkan Toggle ke Settings Tab (MenuGB)
-- Karena MenuGB udah dideklarasiin di atas, kita bisa langsung panggil di sini
if MenuGB then
    MenuGB:AddToggle("ShowWatermark", {
        Text = "Show Watermark",
        Default = true,
        Tooltip = "Tampilkan label watermark boyfinity | fps | ping",
        Callback = function(Value)
            -- Sembunyikan atau tampilkan label sesuai status toggle
            DraggableLabel:SetVisible(Value)
        end
    })
end

--=====================================================
-- LOGIC: REAL-TIME GENERATOR SCANNER
--=====================================================
local function GetAllGenerators()
    local gens = {}
    for gen in pairs(ObjectCache.Generators) do
        if gen:IsA("Model") then table.insert(gens, gen) end
    end
    return gens
end

local lastGenScan = 0
RunService.Heartbeat:Connect(function()
    if tick() - lastGenScan < 1 then return end -- Update progress max 1 detik sekali (Mengurangi drop FPS)
    lastGenScan = tick()
    
    local generators = GetAllGenerators()
    local statusTable = {}

    for i, gen in ipairs(generators) do
        -- Ambil progress dari atribut 'RepairProgress' (Sesuai decompile source 49, 51)
        local progress = gen:GetAttribute("RepairProgress") or 0
        local isCompleted = progress >= 100
        
        table.insert(statusTable, {
            Name = "G " .. i,
            Progress = math.floor(progress),
            Instance = gen,
            Status = isCompleted and "✔️" or "⏳"
        })
    end
    
    State.GeneratorData = statusTable
end)

-- ==========================================
-- SKILL CHECK BYPASS (GENERATOR & HEALING) + ANTI-STUCK
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

remotes = ReplicatedStorage:WaitForChild("Remotes")
GenSkillEvent = remotes:WaitForChild("Generator"):WaitForChild("SkillCheckEvent")
GenResultEvent = remotes:WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
repairRemote = remotes:WaitForChild("Generator"):WaitForChild("RepairEvent")

-- 🔥 TAMBAHAN: Kita definisikan event Healing yang terlewat
HealSkillEvent = remotes:WaitForChild("Healing"):WaitForChild("SkillCheckEvent")
HealResultEvent = remotes:WaitForChild("Healing"):WaitForChild("SkillCheckResultEvent")
healRemote = remotes:WaitForChild("Healing"):WaitForChild("HealEvent")

-- 👑 KING'S SCOURGE: Remote untuk auto-sukses tiap Special Skill Check (per-event, bukan spam)
KingScourgeHitRemote = remotes:WaitForChild("KillerPerks"):WaitForChild("kingscourge"):WaitForChild("KingScourgeHit")

local currentGenPoint = nil
local currentHealTarget = nil

-- [1] AUTO SUCCESS GENERATOR & INSTANT KING'S SCOURGE
GenSkillEvent.OnClientEvent:Connect(function(genModel, genPoint)
    currentGenPoint = genPoint
    local progress = genModel:GetAttribute("RepairProgress") or 0

    -- 👑 INSTANT KING'S SCOURGE BYPASS 👑
    -- PerfectSkillCheck akan menembakkan spasi secara otomatis saat jarum pas.
    if State.InstantScourge and progress >= 89 then
        _G.IsKingScourgeActive = true

    -- LOGIC NORMAL NO SKILLCHECK
    elseif State.NoSkillCheck then
        task.wait(0.05)
        local bindable = remotes:WaitForChild("Generator"):FindFirstChild("Skillcheckvalidated")
        if bindable then
            pcall(function() bindable:Fire("success", 5, genModel, genPoint) end)
        else
            pcall(function() GenResultEvent:FireServer("success", 5, genModel, genPoint) end)
        end
    end
end)

-- 🔥 FAKE VISUAL PROGRESS (LAG-FREE, SINGLE RENDER) 🔥
local smoothCurrentProg = 0
RunService.RenderStepped:Connect(function(dt)
    if State.InstantScourge and _G.IsKingScourgeActive and currentGenPoint then
        local genModel = currentGenPoint.Parent
        -- Cek apakah generator sedang direpair dan mencapai 90%+
        if genModel and genModel:GetAttribute("repairing") then
            local realProg = genModel:GetAttribute("RepairProgress") or 0
            if realProg >= 89 and realProg < 100 then
                -- Sinkronisasi awal
                if smoothCurrentProg < realProg then
                    smoothCurrentProg = realProg
                end
                
                -- Naikkan visual dengan mulus (12% per detik)
                smoothCurrentProg = math.min(99.9, smoothCurrentProg + (12 * dt))
                
                -- Paksa timpa atribut untuk ESP teks
                genModel:SetAttribute("RepairProgress", smoothCurrentProg)
                
                -- Paksa timpa UI bar bawaan game
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    local prompt = pGui:FindFirstChild("ProgressPromptGui")
                    if prompt then
                        local frame = prompt:FindFirstChild("Frame")
                        if frame then
                            local bar = frame:FindFirstChild("Bar")
                            if bar then bar.Size = UDim2.new(smoothCurrentProg / 100, 0, 1, 0) end
                            local txt = frame:FindFirstChild("TextLabel") or frame:FindFirstChild("Percentage")
                            if txt and txt:IsA("TextLabel") then txt.Text = string.format("%d%%", math.floor(smoothCurrentProg)) end
                        end
                    end
                end
            else
                smoothCurrentProg = 0
            end
        else
            smoothCurrentProg = 0
        end
    else
        smoothCurrentProg = 0
    end
end)

-- [3] ANTI-STUCK (Cancel saat gerak WASD / Joystick)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Jika analog bergerak sedikit saja (> 0.05)
    if hum and hum.MoveDirection.Magnitude > 0.05 then
        if currentGenPoint then
            pcall(function() repairRemote:FireServer(currentGenPoint, false) end)
            currentGenPoint = nil
        end
        if currentHealTarget then
            pcall(function() healRemote:FireServer(currentHealTarget, false) end)
            currentHealTarget = nil
        end
    end
end)

--=====================================================
-- AUTO SKILL CHECK CORE (SYNC WITH UI) - (FIXED FOR KING`S SCOURGE)
--=====================================================

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")

local function normalize(angle)
    return (angle % 360 + 360) % 360
end

-- Remote result (support heal + gen)
HealResultEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("SkillCheckResultEvent")
GenResultEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")

-- PARAMETER
local OFFSET = 104
local WINDOW = 6
local STEP = 0.5

-- STATE
local hasTriggered = false
local lastTriggerRot = nil
local lastGoalRot = nil
local successCount = 0
local LOCKED = false
local lastNeedleRot = 1
local uiVisibleTime = 0
local uiWasVisible = false

-- LOOP
RunService.Heartbeat:Connect(function()

    -- 🔥 AKTIF HANYA JIKA TOGGLE ON
    if not State.PerfectSkillCheck then 
        hasTriggered = false
        lastNeedleRot = -1
        uiWasVisible = false
        return 
    end

    local PromptGui = PlayerGui:FindFirstChild("SkillCheckPromptGui")

    if PromptGui and PromptGui.Enabled and PromptGui:FindFirstChild("Check") and PromptGui.Check.Visible then

        -- 🛡️ ANTI-GLITCH: Catat waktu saat UI baru muncul
        if not uiWasVisible then
            uiVisibleTime = tick()
            uiWasVisible = true
            -- Simpan posisi asli UI supaya bisa dibalikin
            if not _G.OriginalCheckPos then
                _G.OriginalCheckPos = PromptGui.Check.Position
            end
        end

        -- Beri jeda 0.05 detik agar game stabil dan jarum muncul dengan sempurna
        if tick() - uiVisibleTime < 0.05 then
            lastNeedleRot = normalize(PromptGui.Check.Line.Rotation)
            return
        end

        local Line = PromptGui.Check:FindFirstChild("Line")
        local Goal = PromptGui.Check:FindFirstChild("Goal")
        if Line and Goal then
            local trueRot = normalize(Line.Rotation)
            local goalRot = normalize(Goal.Rotation)

            -- 🔥 DETEKSI LOMPATAN JARUM ASLI (Reset Kunci Klik)
            if lastNeedleRot ~= -1 then
                local jump = math.abs(trueRot - lastNeedleRot)
                if jump > 50 and jump < 310 then
                    hasTriggered = false
                end
            end
            lastNeedleRot = trueRot

            -- 🎯 CEK FASE: Apakah kita sedang di fase King's Scourge? (>= 89%)
            local isScourgePhase = false
            if currentGenPoint and currentGenPoint.Parent then
                local prog = currentGenPoint.Parent:GetAttribute("RepairProgress") or 0
                if prog >= 89 then
                    isScourgePhase = true
                end
            end

            -- 🔥 NO UI INSTANT SCOURGE 🔥
            -- Pindahkan UI ke ujung dunia (koordinat 999,999) supaya tidak terlihat tapi tetap merespon VIM!
            if State.InstantScourge and isScourgePhase then
                _G.WasScourgePhase = true
                PromptGui.Check.Position = UDim2.new(999, 0, 999, 0)
                
                -- 🔕 MUTE SOUND: Looping ke workspace sesuai logika ampuh dari user
                for _, model in ipairs(workspace:GetChildren()) do
                    for _, scName in ipairs({"Skillcheck-gen", "Skillcheck-player"}) do
                        local scPart = model:FindFirstChild(scName)
                        if scPart then
                            for _, sName in ipairs({"Sound", "Great", "Confirm"}) do
                                local snd = scPart:FindFirstChild(sName)
                                if snd and snd:IsA("Sound") then
                                    snd.Volume = 0
                                    snd:Stop()
                                end
                            end
                        end
                    end
                end
                for _, snd in pairs(PromptGui:GetDescendants()) do
                    if snd:IsA("Sound") then
                        snd.Volume = 0
                        snd:Stop()
                    end
                end
            else
                if _G.OriginalCheckPos then
                    PromptGui.Check.Position = _G.OriginalCheckPos
                end
                
                -- 🔊 RESTORE SOUND: Balikin volume kalau pindah ke generator biasa
                if _G.WasScourgePhase then
                    _G.WasScourgePhase = false
                    for _, model in ipairs(workspace:GetChildren()) do
                        for _, scName in ipairs({"Skillcheck-gen", "Skillcheck-player"}) do
                            local scPart = model:FindFirstChild(scName)
                            if scPart then
                                for _, sName in ipairs({"Sound", "Great", "Confirm"}) do
                                    local snd = scPart:FindFirstChild(sName)
                                    if snd and snd:IsA("Sound") then
                                        snd.Volume = 0.5 -- Default volume game
                                    end
                                end
                            end
                        end
                    end
                    for _, snd in pairs(PromptGui:GetDescendants()) do
                        if snd:IsA("Sound") then
                            snd.Volume = 0.5
                        end
                    end
                end
            end
            
            local shouldAutoHit = State.PerfectSkillCheck

            if not shouldAutoHit then 
                hasTriggered = false
                lastNeedleRot = -1
                uiWasVisible = false
                return 
            end


            local currentRot = trueRot

            
            -- 🔥 INSTANT MODE SWITCHER 🔥
            -- Jika Mode Instant NYALA, TAPI BUKAN fase Scourge, maka teleport jarum ke area putih.
            -- Jika sedang fase Scourge, paksa pakai Legit Mode (jarum jalan normal otomatis)
            if State.SkillCheckMode == "Instant" and not isScourgePhase then
                local targetAngle = normalize(goalRot + 110) -- Snap presisi ke area perfect
                currentRot = targetAngle
                Line.Rotation = targetAngle
            end

            -- Kalkulasi Zona Perfect
            local startZone = normalize(goalRot + OFFSET)
            local endZone = normalize(goalRot + OFFSET + WINDOW)

            local inZone
            if startZone <= endZone then
                inZone = (currentRot >= startZone and currentRot <= endZone)
            else
                inZone = (currentRot >= startZone or currentRot <= endZone)
            end

            local center = normalize(goalRot + 109)
            local diff = math.abs(currentRot - center)
            if diff > 180 then diff = 360 - diff end

            -- HARD FILTER (Mencegah klik palsu di luar area valid)
            local validMin = normalize(goalRot + 90)
            local validMax = normalize(goalRot + 130)

            local validRange
            if validMin <= validMax then
                validRange = (currentRot >= validMin and currentRot <= validMax)
            else
                validRange = (currentRot >= validMin or currentRot <= validMax)
            end

            -- Reset jika jarum sudah kelewat jauh
            if hasTriggered and not inZone and diff > 45 then
                hasTriggered = false
            end

            -- ⚡ EKSEKUSI KLIK SPACEBAR
            if inZone and not hasTriggered and diff < 10 and validRange then
                hasTriggered = true

                lastTriggerRot = currentRot
                lastGoalRot = goalRot
                
                -- CROSS-PLATFORM SKILL CHECK
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                local survMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
                local actionBtn = survMob and survMob:FindFirstChild("Controls") and survMob.Controls:FindFirstChild("action")

                if actionBtn and firesignal then    
                    pcall(function()
                        firesignal(actionBtn.MouseButton1Down)
                        firesignal(actionBtn.MouseButton1Click)
                        firesignal(actionBtn.MouseButton1Up)
                    end)
                else
                    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.01)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)    
                end
            end
        end
    else
        hasTriggered = false
        lastNeedleRot = -1
        uiWasVisible = false
    end
end)

-- AUTO CALIBRATION
local function CalibrateSkillCheck(result)
    if not State.PerfectSkillCheck then return end
    if not lastTriggerRot or not lastGoalRot then return end

    local successStart = normalize(lastGoalRot + 104)
    local successEnd = normalize(lastGoalRot + 114)

    local wasEarly = false
    local wasLate = false

    if successStart <= successEnd then
        wasEarly = lastTriggerRot < successStart
        wasLate = lastTriggerRot > successEnd
    else
        wasEarly = (lastTriggerRot < successStart and lastTriggerRot > successEnd)
    end

    if result == "success" then
        successCount += 1
        if successCount >= 3 and not LOCKED then
            LOCKED = true
            STEP = 0
        end
    elseif result == "fail" and not LOCKED then
        successCount = 0
        if wasEarly then
            OFFSET = OFFSET + STEP
        elseif wasLate then
            OFFSET = OFFSET - STEP
        end
    elseif result == "neutral" and not LOCKED then
        OFFSET = OFFSET + (math.random(-1,1) * 0.2)
    end
    OFFSET = math.clamp(OFFSET, 95, 110)
end

-- Daftarkan sensor kalibrasi ke Healing & Generator
HealResultEvent.OnClientEvent:Connect(CalibrateSkillCheck)
GenResultEvent.OnClientEvent:Connect(CalibrateSkillCheck)


--=====================================================
-- [ISOLATED] AUTO SKILLCHECK BEARTRAP (ESCAPE BUTCHER TRAP)
-- Terisolasi penuh dari SkillCheck Generator/Heal agar tidak mengganggu rotasi generator.
--=====================================================
task.spawn(function()
    local trapTriggered = false
    local trapNeedleRot = -1
    local lastTrapPress = 0

    local function normalizeAngle(angle)
        return (angle % 360 + 360) % 360
    end

    RunService.Heartbeat:Connect(function()
        if not State.AutoBearTrap then
            trapTriggered = false
            trapNeedleRot = -1
            return
        end

        local promptGui = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not (promptGui and promptGui.Enabled and promptGui:FindFirstChild("Check") and promptGui.Check.Visible) then
            trapTriggered = false
            trapNeedleRot = -1
            return
        end

        local check = promptGui.Check
        local line = check:FindFirstChild("Line")
        if not line then return end

        -- 1. DETEKSI DEDIKASI BEARTRAP UI
        -- BearTrap GUI menggunakan part spesifik 'TrapGoal' / 'TrapPerfect',
        -- atau karakter memiliki attribute Trapped / InTrap / BearTrap
        local trapGoal = check:FindFirstChild("TrapPerfect") or check:FindFirstChild("TrapGoal")
        local char = LocalPlayer.Character
        local isCharTrapped = char and (char:GetAttribute("Trapped") or char:GetAttribute("InTrap") or char:GetAttribute("BearTrapped") or char:GetAttribute("IsTrapped"))

        -- Hanya aktif jika UI benar-benar BearTrap (ada TrapGoal/TrapPerfect atau karakter terkena trap)
        if not (trapGoal or isCharTrapped) then
            return
        end

        local currentRot = normalizeAngle(line.Rotation)
        local goalRot = normalizeAngle(trapGoal and trapGoal.Rotation or (check:FindFirstChild("Goal") and check.Goal.Rotation or 0))

        -- Reset flag trigger jika jarum melompat/putaran baru
        if trapNeedleRot ~= -1 then
            local jump = math.abs(currentRot - trapNeedleRot)
            if jump > 50 and jump < 310 then
                trapTriggered = false
            end
        end
        trapNeedleRot = currentRot

        -- 2. HITUNG ZONA PERFECT BEARTRAP (Offset 104, Window 10)
        local startZone = normalizeAngle(goalRot + 102)
        local endZone = normalizeAngle(goalRot + 116)

        local inZone = false
        if startZone <= endZone then
            inZone = (currentRot >= startZone and currentRot <= endZone)
        else
            inZone = (currentRot >= startZone or currentRot <= endZone)
        end

        local center = normalizeAngle(goalRot + 109)
        local diff = math.abs(currentRot - center)
        if diff > 180 then diff = 360 - diff end

        -- 3. INSTANT HIT ATAU TIMED PERFECT HIT
        if inZone and not trapTriggered and diff < 12 and (tick() - lastTrapPress > 0.15) then
            trapTriggered = true
            lastTrapPress = tick()

            -- Tekan Spacebar via VIM atau firesignal touch action
            local survMob = PlayerGui:FindFirstChild("Survivor-mob")
            local actionBtn = survMob and survMob:FindFirstChild("Controls") and survMob.Controls:FindFirstChild("action")

            if actionBtn and firesignal then
                pcall(function()
                    firesignal(actionBtn.MouseButton1Down)
                    firesignal(actionBtn.MouseButton1Click)
                    firesignal(actionBtn.MouseButton1Up)
                end)
            else
                pcall(function()
                    VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.02)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
            end
        end
    end)
end)
--// LOGIC: SLOW SKILL CHECK & INSTANT SCOURGE SPEED
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if char then
            if State.InstantScourge and _G.IsKingScourgeActive then
                -- 🚀 SPEED HACK KING'S SCOURGE (0.35 detik putaran = super ngebut tapi VIM masih sanggup ngeklik)
                char:SetAttribute("skillcheckspeed", 0.35)
                LocalPlayer:SetAttribute("skillcheckspeed", 0.35)
            else
                if char:GetAttribute("skillcheckspeed") ~= 1 then
                    char:SetAttribute("skillcheckspeed", 1)
                end
                if LocalPlayer:GetAttribute("skillcheckspeed") ~= 1 then
                    LocalPlayer:SetAttribute("skillcheckspeed", 1)
                end
            end
        end
    end
end)

--// LOGIC: KING'S SCOURGE PERK DETECTOR (NOTIFIER)
local notifiedScourgeRound = false
task.spawn(function()
    while task.wait(3) do
        local myTeam = LocalPlayer.Team
        if myTeam and myTeam.Name == "Survivors" then
            if not notifiedScourgeRound then
                for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                    if plr.Team and plr.Team.Name == "Killer" then
                        local hasScourge = plr:GetAttribute("kings_scourge")
                        if not hasScourge and plr.Character then
                            hasScourge = plr.Character:GetAttribute("kings_scourge")
                        end
                        if hasScourge then
                            notifiedScourgeRound = true
                            Library:Notify("⚠️ WARNING: Killer is using [King's Scourge] Perk! Be careful when repairing!", 7)
                        end
                    end
                end
            end
        else
            -- Reset notifikasi jika match selesai / ganti tim
            notifiedScourgeRound = false
        end
    end
end)

--// LOGIC: HEALING YOURSELF (MANUAL)
local isSelfHealing = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not State.ManualSelfHeal then return end
    
    local healKey = (State and State.SelfHealKey) or Enum.KeyCode.H
    -- Jika menggunakan UI KeyPicker dari Linoria
    if Options and Options.SelfHealKey then
        -- Kami biarkan, deteksi input ditangani di bawah jika sesuai dengan enum
    end

    if input.KeyCode == healKey or (Options and Options.SelfHealKey and input.KeyCode.Name == Options.SelfHealKey.Value) then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and not char:GetAttribute("IsHooked") then
            isSelfHealing = true
            _G.IsManualSelfHealing = true
            local healRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("HealEvent")
            healRemote:FireServer(hrp, true)
            Library:Notify("Healing Started")
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if not isSelfHealing then return end
    
    local healKey = (State and State.SelfHealKey) or Enum.KeyCode.H
    if input.KeyCode == healKey or (Options and Options.SelfHealKey and input.KeyCode.Name == Options.SelfHealKey.Value) then
        isSelfHealing = false
        _G.IsManualSelfHealing = false
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local healRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("HealEvent")
            healRemote:FireServer(hrp, false)
        end
    end
end)

-- =====================================================
-- LOGIKA AUTO DODGE ABYSSWALKER (AUTO CROUCH - CTRL/MOBILE)
-- =====================================================
local VIM = game:GetService("VirtualInputManager")
LocalPlayer = game.Players.LocalPlayer

-- ID Animasi Tebasan Abysswalker
local ABYSS_DODGE_ID = 80411309607666

task.spawn(function()
    while task.wait() do
        if State.AutoDodge then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
                        local eChar = player.Character
                        local eHum = eChar and eChar:FindFirstChild("Humanoid")
                        local eRoot = eChar and eChar:FindFirstChild("HumanoidRootPart")

                        if eRoot and eHum then
                            local dist = (root.Position - eRoot.Position).Magnitude
                            
                            -- Deteksi dalam radius 20 unit
                            if dist <= 20 then 
                                for _, track in pairs(eHum:GetPlayingAnimationTracks()) do
                                    local animId = tonumber(track.Animation.AnimationId:match("%d+"))
                                    
                                    if animId == ABYSS_DODGE_ID then
                                        -- 🔥 AKSI: Nunduk (PC/Mobile)
                                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                                        local crouchBtn = playerGui 
                                            and playerGui:FindFirstChild("Survivor-mob") 
                                            and playerGui["Survivor-mob"].Controls:FindFirstChild("crouch")

                                        if crouchBtn and firesignal then
                                            -- Mobile: Tahan tombol crouch
                                            firesignal(crouchBtn.MouseButton1Down)
                                            task.wait(1.2)
                                            firesignal(crouchBtn.MouseButton1Up)
                                        else
                                            -- PC: Tahan tombol LeftControl
                                            VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
                                            task.wait(1.2)
                                            VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
                                        end

                                        -- Cooldown singkat agar tidak glitchy
                                        task.wait(0.5)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--=====================================================
-- LOGIC: COMBAT INSTINCT (ADVANCED PARRY V2)
--=====================================================
--!optimize 2
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

-- =====================================================
-- 1. HOSTILE SWING DATABASE
-- =====================================================
local HOSTILE_SWING_DB = {
    [113255068724446] = true, [74968262036854] = true,
    [96199016084581] = true, [74532620598483] = true, [117042998468241] = true, [133969373694098] = true,
    [129784271201071] = true, [132817836308238] = true,
    [118907603246885] = true, [78432063483146] = true,
    [78935059863801] = true,
    [139369275981139] = true, [110355011987939] = true,
    [105374834496520] = true, [111920872708571] = true,

    -- 🔥 KILLER BARU (CURE) 🔥
    [135002183282873] = true, -- lungehold
    [121216847022485] = true  -- attack
}

-- =====================================================
-- 2. PERIMETER RING VISUALIZER
-- =====================================================
local RingResolution = 50
local RingSegments = {}
for i = 1, RingResolution do
    local seg = Drawing.new("Line")
    seg.Visible = false
    seg.Color = Color3.fromRGB(255, 255, 255)
    seg.Thickness = 2
    seg.Transparency = 1
    table.insert(RingSegments, seg)
end

-- =====================================================
-- 3. DEFENSIVE ACTION
-- =====================================================
local function executeDefensiveStrike()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    
    -- [1] CANCEL REPAIR / INTERACTION TERLEBIH DAHULU (Biar gak sus)
    local survMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
    local controls = survMob and survMob:FindFirstChild("Controls")
    local actionBtn = controls and controls:FindFirstChild("action")
    
    if actionBtn and firesignal then
        pcall(function() firesignal(actionBtn.MouseButton1Up) end)
    end
    -- Paksa lepas M1 (Left Click) buat cancel repair di PC
    pcall(function() VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
    
    -- Jeda 1 frame (~0.01 detik) biar server mencatat repair dibatalkan tanpa bikin parry telat
    task.wait()

    -- [2] EKSEKUSI PARRY
    local itemBtn = playerGui and playerGui:FindFirstChild("Survivor-mob") and playerGui["Survivor-mob"].Controls:FindFirstChild("Gui-mob")
    
    if itemBtn and firesignal then
        firesignal(itemBtn.MouseButton1Down)
        firesignal(itemBtn.MouseButton1Click)
        firesignal(itemBtn.MouseButton1Up)
    else
        VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait(0.02)
        VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    end
end

local defenseCooldown = false
local daggerCooldown = false

LocalPlayer.CharacterAdded:Connect(function()
    daggerCooldown = false
end)

-- =====================================================
-- 4. PERIMETER RING RENDER
-- =====================================================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if State.AutoParry and root then
        local radius = State.ParryRadius
        local center = root.Position + Vector3.new(0, -2.8, 0)
        for i = 1, RingResolution do
            local a1 = (i - 1) / RingResolution * math.pi * 2
            local a2 = i / RingResolution * math.pi * 2
            local p1 = center + Vector3.new(math.cos(a1) * radius, 0, math.sin(a1) * radius)
            local p2 = center + Vector3.new(math.cos(a2) * radius, 0, math.sin(a2) * radius)
            local sp1, on1 = workspace.CurrentCamera:WorldToViewportPoint(p1)
            local sp2, on2 = workspace.CurrentCamera:WorldToViewportPoint(p2)
            local seg = RingSegments[i]
            if on1 and on2 then
                seg.From = Vector2.new(sp1.X, sp1.Y)
                seg.To = Vector2.new(sp2.X, sp2.Y)
                seg.Visible = true
            else
                seg.Visible = false
            end
        end
    else
        for _, seg in ipairs(RingSegments) do seg.Visible = false end
    end
end)

-- =====================================================
-- 5. LETHALITY CONE VISUALIZER
-- =====================================================
LeftConeLine = Drawing.new("Line")
LeftConeLine.Thickness = 2
LeftConeLine.Color = Color3.fromRGB(255, 50, 50)
LeftConeLine.Transparency = 0.6

RightConeLine = Drawing.new("Line")
RightConeLine.Thickness = 2
RightConeLine.Color = Color3.fromRGB(255, 50, 50)
RightConeLine.Transparency = 0.6

RunService.RenderStepped:Connect(function()
    if not State.ShowKillerAim or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LeftConeLine.Visible = false
        RightConeLine.Visible = false
        return
    end

    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local nearestThreat, nearestDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" then
            local kRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if kRoot then
                local d = (myRoot.Position - kRoot.Position).Magnitude
                if d < nearestDist then nearestDist = d; nearestThreat = kRoot end
            end
        end
    end

    if nearestThreat then
        local lethalVal = State.AimStrictness or 2.6
        local reqDot = 0.3 + ((lethalVal - 1) / 2) * 0.65
        local coneAngle = math.acos(math.clamp(reqDot, -1, 1))

        local kPos = nearestThreat.Position
        local lookDir = nearestThreat.CFrame.LookVector
        local pDist = State.ParryRadius or 15

        local lVec = CFrame.Angles(0, coneAngle, 0) * lookDir
        local rVec = CFrame.Angles(0, -coneAngle, 0) * lookDir

        local cam = workspace.CurrentCamera
        local sc, scOn = cam:WorldToViewportPoint(kPos)
        local sl, slOn = cam:WorldToViewportPoint(kPos + lVec * pDist)
        local sr, srOn = cam:WorldToViewportPoint(kPos + rVec * pDist)

        if scOn and slOn and srOn then
            LeftConeLine.From = Vector2.new(sc.X, sc.Y)
            LeftConeLine.To = Vector2.new(sl.X, sl.Y)
            LeftConeLine.Visible = true
            RightConeLine.From = Vector2.new(sc.X, sc.Y)
            RightConeLine.To = Vector2.new(sr.X, sr.Y)
            RightConeLine.Visible = true
        else
            LeftConeLine.Visible = false; RightConeLine.Visible = false
        end
    else
        LeftConeLine.Visible = false; RightConeLine.Visible = false
    end
end)

-- =====================================================
-- 6. COMBAT INSTINCT MAIN DETECTION LOOP
-- =====================================================

ResetRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("Reset")

-- ⚡ LOGIC FAKE PARRY TRIGGER ⚡
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and State.FakeParry then
        -- Cek input tombol sesuai dengan yang di-set di KeyPicker Obsidian
        local fakeParryKey = (Library.Options and Library.Options.FakeParryKey and Library.Options.FakeParryKey.Value) or Enum.KeyCode.X.Name
        
        if input.KeyCode == Enum.KeyCode[fakeParryKey] then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    -- Load animasi defense standard dari gamenya secara lokal
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://127096285501517" -- 🔥 ID ANIMASI BARU DARI KAMU
                    local track = animator:LoadAnimation(anim)
                    
                    -- Paksa prioritas ke Action agar tidak kalah sama animasi lari/diam
                    track.Priority = Enum.AnimationPriority.Action 
                    track:Play()
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not State.AutoParry or defenseCooldown or daggerCooldown then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if not root or not hum then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team ~= LocalPlayer.Team then
            local threatChar = plr.Character
            local threatHum = threatChar and threatChar:FindFirstChild("Humanoid")
            local threatRoot = threatChar and threatChar:FindFirstChild("HumanoidRootPart")

            if threatRoot and threatHum then
                local threatPos = threatRoot.Position
                local separation = (root.Position - threatPos).Magnitude

                if separation <= (State.ParryRadius or 15) then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {threatChar, char}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude

                    -- [POINT 3] WALL CHECK
                    local hitWall = workspace:Raycast(root.Position, (threatPos - root.Position), rayParams)
                    if hitWall then continue end 

                    -- [POINT 2] AIM STRICTNESS CHECK (Seberapa lurus killer ngarahin layar ke lu)
                    local killerGaze = threatRoot.CFrame.LookVector
                    local vecToMe = (root.Position - threatPos).Unit
                    local killerAlignment = killerGaze:Dot(vecToMe)
                    
                    -- Panggil nilai State yang bener (AimStrictness)
                    local requiredLethal = 0.3 + (((State.AimStrictness or 2.6) - 1) / 2) * 0.65

                    -- [NEW LOGIC] AIM PREDICTION vs FACE KILLER SENSITIVITY
                    local premonitionPass = false
                    
                    if State.AimPrediction then
                        -- [A] Aim Prediction (Trajectory Check) - Lebih Akurat
                        local killerVel = threatRoot.AssemblyLinearVelocity
                        local futurePos = threatPos + (killerVel * 0.15)
                        local swingEnd = futurePos + (killerGaze * 8)
                        local swingRay = (swingEnd - futurePos)
                        local toPlayer = (root.Position - futurePos)

                        local t = math.clamp(toPlayer:Dot(swingRay) / swingRay:Dot(swingRay), 0, 1)
                        local nearestPt = futurePos + swingRay * t

                        premonitionPass = (root.Position - nearestPt).Magnitude <= 12
                    else
                        -- [B] Fallback: Face Killer Sensitivity (Lu harus natap killernya)
                        local myGaze = root.CFrame.LookVector
                        local vecToKiller = (threatPos - root.Position).Unit
                        local playerAlignment = myGaze:Dot(vecToKiller)
                        
                        -- Panggil nilai State yang bener (FaceKillerSens)
                        local sens = State.FaceKillerSens or -1.0
                        if playerAlignment >= sens then
                            premonitionPass = true
                        end
                    end

                    if killerAlignment >= requiredLethal and premonitionPass then
                        local animator = threatHum:FindFirstChildOfClass("Animator")
                        
                        -- PRE FIRE LOGIC : Parry instan untuk jarak dekat
                        -- (Dihapus/dimatikan karena membuat dagger auto parry meski killer belum mengayunkan pedang)
                        -- if separation <= 8 then
                        --     executeDefensiveStrike() 
                        --
                        --     if State.SelectedEmote and State.SelectedEmote ~= "none" then
                        --         task.spawn(function()
                        --             task.wait(0.05)
                        --             _G.playCustomEmote(State.SelectedEmote)
                        --         end)
                        --     end
                        --
                        --     daggerCooldown = true
                        --     task.delay(50, function() 
                        --         daggerCooldown = false
                        --     end)
                        --     task.wait(0.2)
                        --     State.IsParrying = false
                        -- end

                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                local animId = tonumber(track.Animation.AnimationId:match("%d+"))
                                if HOSTILE_SWING_DB[animId] then
                                    defenseCooldown = true
                                    State.IsParrying = true

                                    ResetRemote:FireServer(LocalPlayer) 
                                    
                                    local reflexWait = State.DefensiveReflexDelay or 0
                                    if reflexWait > 0 then task.wait(reflexWait) end

                                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                                    task.wait(0.02)

                                    local cachedSpeed = hum.WalkSpeed
                                    hum.WalkSpeed = 0 
                                    root.Velocity = Vector3.new(0, 0, 0) 
                                    root.RotVelocity = Vector3.new(0, 0, 0)

                                    executeDefensiveStrike()
                                    
                                    -- 🔥 Tambahan Auto Emote setelah strike dari deteksi animasi
                                    if State.SelectedEmote and State.SelectedEmote ~= "none" then
                                        task.spawn(function()
                                            task.wait(0.05) -- Jeda tipis biar gak nge-bug
                                            _G.playCustomEmote(State.SelectedEmote)
                                        end)
                                    end

                                    daggerCooldown = true
                                    task.delay(50, function()
                                        daggerCooldown = false
                                        -- if Library and Library.Notify then
                                        --     Library:Notify("Parrying Dagger is Ready!", 1)
                                        -- end
                                    end)


                                    local recoveryTime = track.Length / (track.Speed or 1)
                                    task.wait(recoveryTime)

                                    if hum and hum.Parent then
                                        hum.WalkSpeed = cachedSpeed
                                    end

                                    State.IsParrying = false
                                    task.wait(0.1)
                                    defenseCooldown = false
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- =====================================================
-- LOGIC: STEALTH PARRY (NO ANIMATION BLOCKER)
-- =====================================================
local DEFENSIVE_ANIM_SIG = "75939529748815"

RunService.Heartbeat:Connect(function()
    if State.ParryMode == "No Animation" then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation.AnimationId:match(DEFENSIVE_ANIM_SIG) then
                    track:Stop()
                end
            end
        end
    end
end)

--=====================================================
-- LOGIC: INSTANT FLASH
--=====================================================
--!optimize 2
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
RunService = game:GetService("RunService")

-- ID Animasi Attack yang sama
local ATTACK_ANIM_IDS = {
    [113255068724446] = true, [74968262036854] = true,
    [96199016084581] = true, [74532620598483] = true, [117042998468241] = true, [133969373694098] = true,
    [129784271201071] = true, [132817836308238] = true,
    [118907603246885] = true, [78432063483146] = true,
    [78935059863801] = true,
    [139369275981139] = true, [110355011987939] = true,
    [105374834496520] = true, [111920872708571] = true,

    -- 🔥 KILLER BARU (CURE) 🔥
    [135002183282873] = true, -- lungehold
    [121216847022485] = true  -- attack
}

local flashCooldown = false

RunService.Heartbeat:Connect(function()
    if not State.InstantDash or flashCooldown then return end

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local eChar = player.Character
            local eHum = eChar and eChar:FindFirstChild("Humanoid")
            local eRoot = eChar and eChar:FindFirstChild("HumanoidRootPart")

            if eRoot and eHum then
                local dist = (root.Position - eRoot.Position).Magnitude
                
                -- Deteksi jarak (Default 15 meter)
                if dist <= 15 then
                    local animator = eHum:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                            local id = tonumber(track.Animation.AnimationId:match("%d+"))
                            
                            if ATTACK_ANIM_IDS[id] then
                                flashCooldown = true
                                
                                -- ⚡ LOGIKA TELEPORT KE BELAKANG
                                -- Kita pindahkan CFrame ke posisi sekarang + (arah belakang * jarak)
                                local distance = State.DashDistance or 20
                                root.CFrame = root.CFrame * CFrame.new(0, 0, distance)
                                
                        
                                
                                -- Cooldown agar tidak teleport terus-menerus dalam 1 detik
                                task.wait(1) 
                                flashCooldown = false
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

--=====================================================
-- LOGIC: FAKE KNOCKDOWN
--=====================================================
_G.isFakeKnocked = false
local fakeKnockedTrack = nil

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and State.FakeKnockdown then
        local keyStr = (Library.Options and Library.Options.FakeKnockKey and Library.Options.FakeKnockKey.Value) or Enum.KeyCode.Z.Name
        
        if input.KeyCode == Enum.KeyCode[keyStr] then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 then
                if _G.isFakeKnocked then
                    -- ⬆️ BANGUN
                    _G.isFakeKnocked = false
                    if fakeKnockedTrack then
                        fakeKnockedTrack:Stop()
                        fakeKnockedTrack:Destroy()
                        fakeKnockedTrack = nil
                    end
                    -- Kembalikan kecepatan normal
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                else
                    -- ⬇️ JATUH PURA-PURA MATI
                    _G.isFakeKnocked = true
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if animator then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://126526181422628" -- ID Animasi dari lu
                        fakeKnockedTrack = animator:LoadAnimation(anim)
                        
                        -- Paksa Action4 biar nipanya kuat dan ngeloop terus
                        fakeKnockedTrack.Priority = Enum.AnimationPriority.Action4
                        fakeKnockedTrack.Looped = true
                        fakeKnockedTrack:Play()
                    end
                    
                    -- Bikin kecepatan melambat drastis kayak orang ngerangkak/jatuh
                    hum.WalkSpeed = 3
                    hum.JumpPower = 0
                end
            end
        end
    end
end)

-- Bersihkan memori saat respawn agar tidak error
LocalPlayer.CharacterAdded:Connect(function()
    _G.isFakeKnocked = false
    fakeKnockedTrack = nil
end)



--=====================================================
-- LOGIC: GENERATOR TELEPORT VIA KEYBIND
--=====================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Cek apakah toggle fiturnya nyala
    if not State.EnableGenTP then return end
    
    -- Ambil tombol yang diset di UI Obsidian
    local tpKeyName = (Library.Options and Library.Options.GenTPKeybind and Library.Options.GenTPKeybind.Value) or Enum.KeyCode.T.Name
    
    if input.KeyCode == Enum.KeyCode[tpKeyName] then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- 1. Kumpulin semua generator yang belum selesai (progress < 100)
        local validGens = {}
        for gen in pairs(ObjectCache.Generators) do
            local genPart = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
            local progress = gen:GetAttribute("RepairProgress") or 0
            
            if genPart and progress < 100 then
                table.insert(validGens, genPart)
            end
        end
        
        -- Kalau udah kelar semua
        if #validGens == 0 then
            Library:Notify("Semua generator sudah selesai atau tidak ditemukan!")
            return
        end
        
        local targetGenPart = nil
        
        -- 2. Seleksi Target Berdasarkan Mode
        if State.GenTPMode == "Nearest" then
            local shortestDist = math.huge
            for _, part in ipairs(validGens) do
                local dist = (hrp.Position - part.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    targetGenPart = part
                end
            end
        elseif State.GenTPMode == "Random" then
            -- Pilih acak dari list generator yang masih nyala
            local randomIndex = math.random(1, #validGens)
            targetGenPart = validGens[randomIndex]
        end
        
        -- 3. Eksekusi Teleport
        if targetGenPart then
            -- Teleport 10 studs di atas generator biar gak nyangkut
            hrp.CFrame = targetGenPart.CFrame + Vector3.new(0, 10, 0)
            Library:Notify("⚡ Teleported to " .. State.GenTPMode .. " Generator!")
        end
    end
end)

--=====================================================
-- HELPER: SMART POSITIONING (ANTI-WALL DETECTION)
--=====================================================
local function GetOpenPosition(genPart)
    local LocalPlayer = game.Players.LocalPlayer
    local offsets = {
        CFrame.new(0, 0, 3.5),   -- Depan
        CFrame.new(0, 0, -3.5),  -- Belakang
        CFrame.new(3.5, 0, 0),   -- Kanan
        CFrame.new(-3.5, 0, 0)   -- Kiri
    }
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {genPart.Parent, LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local validPos = nil
    for _, offset in ipairs(offsets) do
        local targetCFrame = genPart.CFrame * offset
        local targetPos = targetCFrame.Position
        
        -- Cek halangan horizontal dari tengah generator
        local result = workspace:Raycast(genPart.Position, (targetPos - genPart.Position), raycastParams)
        
        if not result then
            -- Raycast ke bawah untuk mencari lantai sebenarnya biar HRP nggak nembus tanah
            local downRay = workspace:Raycast(targetPos + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), raycastParams)
            if downRay then
                -- +3 di sumbu Y biar HumanoidRootPart pas berdiri di atas lantai
                validPos = CFrame.new(downRay.Position + Vector3.new(0, 3, 0)) * targetCFrame.Rotation
            else
                validPos = targetCFrame + Vector3.new(0, 3, 0)
            end
            break
        end
    end
    
    -- Fallback kalau semuanya kehalang
    if not validPos then
        local fallbackCFrame = genPart.CFrame * offsets[1]
        local downRay = workspace:Raycast(fallbackCFrame.Position + Vector3.new(0, 5, 0), Vector3.new(0, -15, 0), raycastParams)
        if downRay then
            validPos = CFrame.new(downRay.Position + Vector3.new(0, 3, 0)) * fallbackCFrame.Rotation
        else
            validPos = fallbackCFrame + Vector3.new(0, 3, 0)
        end
    end

    return validPos
end

--=====================================================
-- MAIN LOGIC: REPAIR & ESCAPE (CROSS-PLATFORM)
--=====================================================
local VIM = game:GetService("VirtualInputManager")
local isInteracting = false

task.spawn(function()
    
    -- Fungsi mini buat ngatur klik/tahan tombol repair dengan aman
    local function SetRepairInteraction(state)
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local survMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
        local controls = survMob and survMob:FindFirstChild("Controls")
        local actionBtn = controls and controls:FindFirstChild("action")

        if state then
            -- Tahan tombol repair
            if not isInteracting then
                isInteracting = true
                if actionBtn and firesignal then
                    pcall(function() firesignal(actionBtn.MouseButton1Down) end)
                else
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                end
            end
        else
            -- Lepas tombol repair
            if isInteracting then
                isInteracting = false
                if actionBtn and firesignal then
                    pcall(function() firesignal(actionBtn.MouseButton1Up) end)
                else
                    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end

    while task.wait(0.3) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if not hrp or not State.AutoRepair then 
            SetRepairInteraction(false) -- Lepas klik kalau mati atau fitur dimatikan
            continue 
        end

        -- 🏃 1. PRIORITAS: PANIC ESCAPE
        local killerNear = nil
        if State.PanicEscape then
            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" then
                    local kRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if kRoot and (hrp.Position - kRoot.Position).Magnitude < (State.KillerDistance or 30) then
                        killerNear = kRoot
                        break
                    end
                end
            end
        end

        if killerNear then
            SetRepairInteraction(false) -- Lepas tangan dari mesin biar bisa kabur!
            
            local safeGen = nil
            local maxDist = -math.huge
            for gen in pairs(ObjectCache.Generators) do
                local p = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = (p.Position - killerNear.Position).Magnitude
                    if d > maxDist then maxDist = d; safeGen = p end
                end
            end

            if safeGen then
                hrp.CFrame = safeGen.CFrame * CFrame.new(0, 10, 0)
                task.wait(0.5)
                continue -- Loncat ke iterasi berikutnya setelah kabur
            end
        end

        -- 🛠️ 2. AUTO REPAIR (SISTEM KLIK/TAP)
        local nearestGen = nil
        local minDist = math.huge

        for gen in pairs(ObjectCache.Generators) do
            local genPart = gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
            local progress = gen:GetAttribute("RepairProgress") or 0
            if genPart and progress < 100 then
                local d = (hrp.Position - genPart.Position).Magnitude
                if d < minDist then minDist = d; nearestGen = gen end
            end
        end

        if nearestGen then
            local genPart = nearestGen.PrimaryPart or nearestGen:FindFirstChildWhichIsA("BasePart")
            
            -- Dekati Generator
            if minDist > 8 then
                SetRepairInteraction(false)
                hrp.CFrame = GetOpenPosition(genPart)
                task.wait(0.4)
            end

            -- Mulai Klik/Repair/Tap
            if not isInteracting then
                task.wait(0.1)
                SetRepairInteraction(true)
                
                -- Panggil remote buat mastiin server regis perbaikan
                game:GetService("ReplicatedStorage").Remotes.Generator.RepairEvent:FireServer(nearestGen, true)
            end

            -- Handle Skillcheck (Mode Silent)
            if State.RepairMethod == "Silent" then
                local SkillCheckRemote = game:GetService("ReplicatedStorage").Remotes.Generator.SkillCheckResultEvent
                SkillCheckRemote:FireServer("success", 5, nearestGen)
            end
        else
            -- Kalau nggak ada generator, pastikan lepas tombolnya
            SetRepairInteraction(false)
        end
    end
end)

--=====================================================
-- LOGIC: AIMBOT GLOBAL (SMART CAMERA LOCK)
--=====================================================
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Camera = workspace.CurrentCamera
LocalPlayer = Players.LocalPlayer

-- Bikin State Table kalau belum ada (biar gak error)
local State = _G.SharedState or getgenv().State
if not State.GlobalAim then State.GlobalAim = {} end

-- Variabel Status Tombol
local isAimKeyDown = false

-- 1. SETUP DRAWING VISUALS (ESP Aimbot)
FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(188, 0, 255) -- Ungu Neon Boyfinity
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Visible = false

TargetIndicator = Drawing.new("Circle")
TargetIndicator.Color = Color3.fromRGB(255, 0, 0) -- Merah terang buat titik target
TargetIndicator.Radius = 4
TargetIndicator.Filled = true
TargetIndicator.Visible = false

AimLine = Drawing.new("Line")
AimLine.Color = Color3.fromRGB(188, 0, 255) -- Ungu Neon
AimLine.Thickness = 1.5
AimLine.Transparency = 0.6
AimLine.Visible = false

-- 2. DETEKSI INPUT (HOLD KLIK KIRI)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- MouseButton1 = Klik Kiri
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isAimKeyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isAimKeyDown = false
    end
end)

currentAttackBtn = nil
local atkBtnDownConn = nil
local atkBtnUpConn = nil
_G.GlobalAimMobile = false

RunService.Heartbeat:Connect(function()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end

    -- Kumpulan nama GUI Mobile dari semua tipe Killer
    local killerGuis = {"Hidden-mob", "Slasher-mob", "Killer-mob", "Masked-mob"}
    local activeAttackBtn = nil

    -- Cari mana GUI yang lagi aktif di layar sekarang
    for _, guiName in ipairs(killerGuis) do
        local mobGui = playerGui:FindFirstChild(guiName)
        if mobGui then
            local controls = mobGui:FindFirstChild("Controls")
            if controls then
                activeAttackBtn = controls:FindFirstChild("attack")
                if activeAttackBtn then break end -- Ketemu tombolnya! Langsung stop pencarian
            end
        end
    end

    -- Safety Reset jika tombol hilang (misal match selesai atau mati)
    if currentAttackBtn and not currentAttackBtn.Parent then
        _G.GlobalAimMobile = false
        currentAttackBtn = nil
    end

    -- Pasang mata-mata (Listener) ke tombol attack yang baru ketemu
    if activeAttackBtn and activeAttackBtn ~= currentAttackBtn then
        if atkBtnDownConn then atkBtnDownConn:Disconnect() end
        if atkBtnUpConn then atkBtnUpConn:Disconnect() end
        
        currentAttackBtn = activeAttackBtn
        
        atkBtnDownConn = currentAttackBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.GlobalAimMobile = true
            end
        end)
        
        atkBtnUpConn = currentAttackBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.GlobalAimMobile = false
            end
        end)
    end
end)

-- 3. FUNGSI CEK VISIBILITY (TEMBUS TEMBOK ATAU NGGAK)
local function IsTargetVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, rayParams)
    
    -- Kalau nabrak sesuatu dan itu bagian dari karakter target, berarti KELIHATAN
    if result and result.Instance then
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        else
            return false -- Nabrak tembok/pohon
        end
    end
    return true
end

-- 4. FUNGSI MENCARI TARGET TERDEKAT DARI KURSOR (FOV)
local function GetGlobalAimTarget()
    local bestTarget = nil
    local shortestDist = State.GlobalAim.AimFOV or 150
    local mousePos = UserInputService:GetMouseLocation()
    
    local targetPartName = State.GlobalAim.TargetPart or "Head"

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        -- Filter Tim: Jangan aim temen sendiri
        if plr.Team == LocalPlayer.Team then continue end
        
        local char = plr.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local targetNode = char:FindFirstChild(targetPartName)
        
        if hum and hum.Health > 0 and targetNode then
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetNode.Position)
            
            if onScreen then
                local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                if distFromMouse < shortestDist then
                    -- Cek Visibility kalau fiturnya dinyalain di UI
                    if State.GlobalAim.VisibilityCheck then
                        if not IsTargetVisible(targetNode) then continue end
                    end
                    
                    shortestDist = distFromMouse
                    bestTarget = targetNode
                end
            end
        end
    end
    return bestTarget
end

-- 5. MAIN LOOP (RENDER STEPPED)
RunService.RenderStepped:Connect(function()
    local S = State.GlobalAim
    if not S then return end

    local mousePos = UserInputService:GetMouseLocation()

    -- [A] UPDATE FOV VISUAL
    if S.ShowFOV then
        FOVCircle.Position = mousePos
        FOVCircle.Radius = S.AimFOV or 150
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- [B] CARI TARGET JIKA TOMBOL DITAHAN (PC & MOBILE)
    local currentTarget = nil
    if S.Aimlock and (isAimKeyDown or _G.GlobalAimMobile) then
        currentTarget = GetGlobalAimTarget()
    end

    -- [C] EKSEKUSI AIMBOT & DRAWING
    if currentTarget then
        local screenPos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
        
        -- Gambar Indikator Titik
        if S.ShowIndicator and onScreen then
            TargetIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
            TargetIndicator.Visible = true
        else
            TargetIndicator.Visible = false
        end

        -- Gambar Garis Target
        if S.ShowAimLine and onScreen then
            AimLine.From = mousePos
            AimLine.To = Vector2.new(screenPos.X, screenPos.Y)
            AimLine.Visible = true
        else
            AimLine.Visible = false
        end

        -- LOGIC CAMERA LOCK & SMOOTHING
        -- Rumus: Makin kecil Smoothing, makin instan. Makin besar (10), makin pelan/halus
        local smoothingValue = S.Smoothing or 1
        local lerpFactor = 1 / smoothingValue
        
        -- Kalau smoothing 1, anggap instan aja biar nggak delay sama sekali
        if smoothingValue == 1 then lerpFactor = 1 end 

        -- Kunci target!
        local lookCFrame = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookCFrame, lerpFactor)
        
    else
        -- Sembunyikan Visual kalau nggak ada target / klik dilepas
        TargetIndicator.Visible = false
        AimLine.Visible = false
    end
end)

--=====================================================
-- DRAWING: CROSSHAIR CUSTOM (PURE UI, NO RAYCAST)
--=====================================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")

    -- Hapus crosshair lama kalau ada (biar ga numpuk)
    if CoreGui:FindFirstChild("BoyfinityCrosshair") then
        CoreGui.BoyfinityCrosshair:Destroy()
    end

    -- Buat UI Crosshair
    local CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "BoyfinityCrosshair"
    CrosshairGui.Parent = CoreGui
    CrosshairGui.IgnoreGuiInset = true
    CrosshairGui.Enabled = false -- Default mati

    -- Warna ungu khas Boyfinity
    local crosshairColor = Color3.fromRGB(188, 0, 255)

    -- Garis Horizontal
    local LineH = Instance.new("Frame")
    LineH.Name = "HorizontalLine"
    LineH.Size = UDim2.new(0, 14, 0, 2)
    LineH.Position = UDim2.new(0.5, -7, 0.5, -1)
    LineH.BackgroundColor3 = crosshairColor
    LineH.BorderSizePixel = 0
    LineH.Parent = CrosshairGui

    -- Garis Vertikal
    local LineV = Instance.new("Frame")
    LineV.Name = "VerticalLine"
    LineV.Size = UDim2.new(0, 2, 0, 14)
    LineV.Position = UDim2.new(0.5, -1, 0.5, -7)
    LineV.BackgroundColor3 = crosshairColor
    LineV.BorderSizePixel = 0
    LineV.Parent = CrosshairGui

    -- Titik Tengah (Opsional, bikin bidikan lebih akurat)
    local CenterDot = Instance.new("Frame")
    CenterDot.Name = "CenterDot"
    CenterDot.Size = UDim2.new(0, 4, 0, 4)
    CenterDot.Position = UDim2.new(0.5, -2, 0.5, -2)
    CenterDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Warna putih di tengah
    CenterDot.BorderSizePixel = 0
    CenterDot.Parent = CrosshairGui
    Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)

    -- Loop untuk mendeteksi nyala/mati dari Toggle UI
    RunService.RenderStepped:Connect(function()
        local State = _G.SharedState or getgenv().State
        if State and State.EnableCrosshair then
            CrosshairGui.Enabled = true
        else
            CrosshairGui.Enabled = false
        end
    end)
end)

--=====================================================
-- AIMBOT V2 (NORMAL & FLASHLIGHT INTEGRATED)
--=====================================================

-- 1. KONFIGURASI STATE
getgenv().State = getgenv().State or {
    -- Normal Aimbot (Key E)
    AimbotOn = true,
    AimbotPart = "Head", -- "Head", "HumanoidRootPart"
    AimbotKey = Enum.KeyCode.E,
    
    -- 🔥 FLASHLIGHT AIMBOT CONFIG 🔥
    FlashlightAimbot = false, -- Default ON
    FlashlightAimPart = "Head", -- "Head" atau "UpperTorso" (Paling stabil)
    FlashlightAimKey = Enum.UserInputType.MouseButton2, -- Klik Kanan
    FlashlightAccuracy = 1, -- 1 = 100% Kunci Total, 0.5 = Agak smooth
    
    -- General
    AimbotFOV = 15,
    ShowFOV = true
}


local isNormalAiming = false
local isFlashlightAiming = false -- 🔥 Variabel baru buat detect Klik Kanan

--=====================================================
-- 🔦 FLASHLIGHT AIMBOT (100% ACCURACY TO HEAD/EYES)
--=====================================================

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
Camera = Workspace.CurrentCamera

-- Konfigurasi Awal
getgenv().State = getgenv().State or {}
State.FlashlightAimbot = false -- Ubah ke false kalau mau dimatiin dari UI

local isFlashlightAiming = false

--// FUNGSI: MENCARI KEPALA KILLER TERDEKAT (Dari kursor mouse)
local function getKillerHead()
    local nearestDist = math.huge
    local targetHead = nil
    
    for _, plr in ipairs(Players:GetPlayers()) do
        -- Cek kalau dia musuh (Tim Killer) dan karakternya masih hidup
        if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" then
            local char = plr.Character
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if head and hum and hum.Health > 0 then
                -- Pastikan Killernya ada di layar kita
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Hitung jarak dari kursor mouse kita ke Killer
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    
                    if dist < nearestDist then
                        nearestDist = dist
                        targetHead = head
                    end
                end
            end
        end
    end
    return targetHead
end

--// DETEKSI KLIK KANAN MOUSE DITEKAN
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isFlashlightAiming = true
    end
end)

--// DETEKSI KLIK KANAN MOUSE DILEPAS
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isFlashlightAiming = false
    end
end)

-- 🔥 TAMBAHAN: Deteksi Tombol 'Gui-mob' khusus Senter di HP
currentFlashBtn = nil
local flashBtnDownConn = nil
local flashBtnUpConn = nil
_G.FlashAimMobile = false

RunService.Heartbeat:Connect(function()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local itemBtn = playerGui and playerGui:FindFirstChild("Survivor-mob") and playerGui["Survivor-mob"]:FindFirstChild("Controls") and playerGui["Survivor-mob"].Controls:FindFirstChild("Gui-mob")

    if currentFlashBtn and not currentFlashBtn.Parent then
        _G.FlashAimMobile = false
        currentFlashBtn = nil
    end

    if itemBtn and itemBtn ~= currentFlashBtn then
        if flashBtnDownConn then flashBtnDownConn:Disconnect() end
        if flashBtnUpConn then flashBtnUpConn:Disconnect() end
        
        currentFlashBtn = itemBtn
        
        flashBtnDownConn = currentFlashBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.FlashAimMobile = true
            end
        end)
        
        flashBtnUpConn = currentFlashBtn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.FlashAimMobile = false
            end
        end)
    end
end)

--// CORE LOGIC: EKSEKUSI AIMBOT (Berjalan terus menerus setiap frame)
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    
    if not myChar or not hrp or not hum then return end

    if State.FlashlightAimbot and (isFlashlightAiming or _G.FlashAimMobile) then
        -- Opsional: Cek apakah kita lagi pegang senter. 
        -- (Kalau nama senternya beda, lu bisa ganti tulisan "Flashlight" di bawah ini)
        local holdingFlashlight = myChar:FindFirstChild("Flashlight") 
        
        if holdingFlashlight then
            local targetHead = getKillerHead()
            
            if targetHead then
                -- 1. MATIKAN AUTOROTATE BAWAAN ROBLOX
                -- Biar gerakan kita ga bentrok sama engine game pas lagi jalan
                hum.AutoRotate = false
                
                -- 2. BODY LOCK (Fisik)
                -- Ratakan sumbu Y biar karakter kita nggak nunduk/ndangak ke tanah
                local targetBodyPos = Vector3.new(targetHead.Position.X, hrp.Position.Y, targetHead.Position.Z)
                hrp.CFrame = CFrame.lookAt(hrp.Position, targetBodyPos)
                
                -- 3. CAMERA LOCK (Visual & Raycast Mata)
                -- Kunci kamera LANGSUNG ke matanya/kepalanya. 
                -- Lerp 0.8 biar nempelnya brutal tapi masih dapet frame yang mulus.
                local lookCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
                Camera.CFrame = Camera.CFrame:Lerp(lookCFrame, 0.8)
            end
        else
            -- Kalau nggak pegang senter, normalkan gerakan
            hum.AutoRotate = true
        end
    else
        -- Normalkan gerakan kalau klik kanan dilepas
        if hum then hum.AutoRotate = true end
    end
end)

--=====================================================
-- INFINITE FLASHLIGHT (PURE USER LOGIC - THE REAL OP)
--=====================================================
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
UserInputService = game:GetService("UserInputService")

FlashlightRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Flashlight"):WaitForChild("Activate")
local isAiming = false

-- Deteksi klik kanan
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2) then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if not gpe and (input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.ButtonL2) then
        isAiming = false
    end
end)

-- 🔥 1. BODYGUARD BATERAI (MURNI LOGIC LU)
task.spawn(function()
    while task.wait(0.5) do
        local State = _G.SharedState or getgenv().State
        if State and State.InfiniteFlashlight then
            local char = LocalPlayer.Character
            local flashlight = char and char:FindFirstChild("Flashlight")
            
            -- Kasih tag biar eventnya ga ketumpuk-tumpuk
            if flashlight and not flashlight:GetAttribute("_Dijaga") then
                flashlight:SetAttribute("_Dijaga", true)
                
                -- Kasih angka gede biar cahayanya maksimal
                flashlight:SetAttribute("remaining", 100)
                
                -- KODE ASLI LU: Jaga baterai kalau mau habis
                flashlight:GetAttributeChangedSignal("remaining"):Connect(function()
                    if flashlight:GetAttribute("remaining") <= 5 then
                        flashlight:SetAttribute("remaining", 100)
                    end
                end)
            end
        end
    end
end)

-- 💥 2. THE REMOTE SPAMMER (BONUS OP LU)
task.spawn(function()
    while task.wait(0.1) do -- Kecepatan brutal 0.1 detik sesuai racikan lu
        local State = _G.SharedState or getgenv().State
        
        if State and State.InfiniteFlashlight and (isAiming or _G.FlashAimMobile) then
            local char = LocalPlayer.Character
            local flashlight = char and char:FindFirstChild("Flashlight")
            
            if flashlight then
                pcall(function()
                    -- Trik Reset Konsisten lu: False lalu True!
                    FlashlightRemote:FireServer(flashlight, false)
                    FlashlightRemote:FireServer(flashlight, true)
                end)
            end
        end
    end
end)

--=============================================================
---                  AIMBOT  
--=============================================================

UserInputService = game:GetService("UserInputService")
Camera = workspace.CurrentCamera

--=====================================================
-- 3. LOGIC: SMART TARGETING (OVERRIDE)
--=====================================================
-- Fungsi ini meng-update logic pencarian target agar mematuhi FOV dan Filter
local function GetSmartTarget()
    local target = nil
    local shortestScore = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        -- Filter Tim
        if State.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and root and hum.Health > 0 then
            -- Filter Knocked
            local isKnocked = char:GetAttribute("Knocked") or char:GetAttribute("IsKnocked")
            if State.IgnoreKnocked and isKnocked then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                local distFromMe = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude

                -- Cek apakah target berada di dalam radius FOV
                if distFromMouse <= (State.AimbotFOV or 150) then
                    local score = (State.TargetPriority == "Distance") and distFromMe or distFromMouse
                    
                    if score < shortestScore then
                        shortestScore = score
                        target = root
                    end
                end
            end
        end
    end
    return target
end

--=============================================================
---                  AIMBOT  
--=============================================================

UserInputService = game:GetService("UserInputService")
Camera = workspace.CurrentCamera

--=====================================================
-- 3. LOGIC: SMART TARGETING (OVERRIDE)
--=====================================================
-- Fungsi ini meng-update logic pencarian target agar mematuhi FOV dan Filter
local function GetSmartTarget()
    local target = nil
    local shortestScore = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        -- Filter Tim
        if State.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if char and hum and root and hum.Health > 0 then
            -- Filter Knocked
            local isKnocked = char:GetAttribute("Knocked") or char:GetAttribute("IsKnocked")
            if State.IgnoreKnocked and isKnocked then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                local distFromMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                local distFromMe = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude

                -- Cek apakah target berada di dalam radius FOV
                if distFromMouse <= (State.AimbotFOV or 150) then
                    local score = (State.TargetPriority == "Distance") and distFromMe or distFromMouse
                    
                    if score < shortestScore then
                        shortestScore = score
                        target = root
                    end
                end
            end
        end
    end
    return target
end

--=====================================================
-- UPDATED: SMART AIMBOT LOOP
--=====================================================
local Aiming = false

RunService.RenderStepped:Connect(function()
    -- Pastikan fitur Aktif dan Tombol ditekan (atau Toggle ON)[cite: 1]
    if State.AimbotEnabled and Aiming then
        -- Inject: Kita panggil fungsi GetSmartTarget di sini[cite: 1]
        local target = GetSmartTarget() 
        
        if target then
            -- Arahkan kamera ke target dengan halus (Smoothness)[cite: 1]
            -- Lo bisa nambahin Lerp di sini biar nggak kelihatan kaku[cite: 1]
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

--=====================================================
-- VISUAL
--=====================================================
local Lighting = game:GetService("Lighting")

--=====================================================
-- VISUAL LOGIC (Force Override)
--=====================================================
RunService.RenderStepped:Connect(function()
    -- Full Bright Logic: Terus-menerus paksa nilai terang setiap frame
    if State.FullBright and State.FullBright > 0 then
        Lighting.Brightness = 2 + (State.FullBright * 0.1)
        Lighting.ClockTime = 12 -- Paksa jadi jam 12 siang
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(0.7, 0.7, 0.7)
        Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7)
        
        -- Hapus rintangan visual lainnya
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("Bloom") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then
                obj.Enabled = false 
            elseif obj:IsA("Atmosphere") then
                -- Atmosphere tidak punya .Enabled, jadi kita set Density ke 0
                -- atau bisa di-Destroy/di-Parent-kan ke tempat lain agar hilang
                obj.Density = 0 
            elseif obj:IsA("ColorCorrectionEffect") then
                obj.Brightness = (State.FullBright or 0) * 0.01
                obj.Contrast = 0
                obj.Enabled = true
            end
        end
    end
end)

-- Fungsi No Fog yang lebih kuat
local function DisableFog(enable)
    if enable then
        -- Set fog ke nilai sangat besar (efektif menghilangkan fog)
        game:GetService("Lighting").FogEnd = 1e5
        
        -- Hapus semua Atmosphere
        for _, v in pairs(game:GetService("Lighting"):GetDescendants()) do
            if v:IsA("Atmosphere") then
                pcall(function() v:Destroy() end)
            end
        end
        
        -- Set property lain yang terkait fog
        game:GetService("Lighting").FogStart = 0
    else
        -- Kembalikan ke default (nilai ini bisa disesuaikan dengan game)
        game:GetService("Lighting").FogEnd = 100000  -- nilai default biasa
        game:GetService("Lighting").FogStart = 0
        -- Catatan: Atmosphere yang sudah dihapus tidak bisa dikembalikan
    end
end


     --=====================================================
    -- 🌟 ULTRA ROBUST ESP SYSTEM (ANTI-CRASH, CORE-GUI) 🌟
    --=====================================================
    local CoreGui = game:GetService("CoreGui")
    local ESPFolder = CoreGui:FindFirstChild("VD_ESP_Folder")
    if not ESPFolder then
        ESPFolder = Instance.new("Folder")
        ESPFolder.Name = "VD_ESP_Folder"
        ESPFolder.Parent = CoreGui
    end

    local espCache = { Highlights = {}, Labels = {}, PhaseImages = {} }

    local function clearESP(obj)
        if espCache.Highlights[obj] then espCache.Highlights[obj]:Destroy() espCache.Highlights[obj] = nil end
        if espCache.Labels[obj] then espCache.Labels[obj]:Destroy() espCache.Labels[obj] = nil end
        if espCache.PhaseImages[obj] then espCache.PhaseImages[obj]:Destroy() espCache.PhaseImages[obj] = nil end
    end

    local function checkSelected(key)
        local sel = State.ESP.Selected
        if type(sel) ~= "table" then return true end
        return table.find(sel, key) or sel[key] == true
    end

    -- // 1. UPDATE PLAYER ESP
    local function updatePlayer(plr, currentCam)
        if not State.ESP.Enabled then clearESP(plr) return end
        
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        if not char or not head then clearESP(plr) return end

        -- Filter Tim
        local team = plr.Team
        local isKiller = (team and team.Name == "Killer")
        local isSurvivor = (team and team.Name == "Survivors")

        if isKiller and not checkSelected("Killer") then clearESP(plr) return end
        if isSurvivor and not checkSelected("Survivor") then clearESP(plr) return end
        if not isKiller and not isSurvivor then clearESP(plr) return end

        local line1 = ""   -- Nama
        local line2 = ""   -- Info / Status / Killer Type
        local line3 = ""   -- Jarak
        local color = Color3.fromRGB(255, 255, 255) -- Default putih (kalau ada bug di logika warna, biar ga ilang semua)
        
        local isBot = false
        if char then
            isBot = char:GetAttribute("BotId") ~= nil 
                 or char:GetAttribute("BotNetId") ~= nil 
                 or game:GetService("CollectionService"):HasTag(char, "SurvivorBot")
                 or plr:GetAttribute("BotId") ~= nil
        end

        if isKiller then
            color = State.ESP.KillerColor or Color3.fromRGB(255, 0, 0) -- Merah
            local killerName = plr:GetAttribute("SelectedKiller") or "Killer"
            
            local displayName = plr.Name
            if State.StreamerMode and State.StreamerMode.HideUsername then
                displayName = "BOYFINITY"
            end
            line1 = State.ESP.Names and displayName or ""
            if State.ESP.ShowLevel then
                local lvl = plr:GetAttribute("Level") or "0"
                if line1 ~= "" then
                    line1 = line1 .. " [Lv." .. tostring(lvl) .. "]"
                else
                    line1 = "[Lv." .. tostring(lvl) .. "]"
                end
            end
            
            line2 = "[" .. killerName .. "]"

        elseif isBot then
            color = State.ESP.BotColor or Color3.fromRGB(0, 230, 255) -- Cyan Neon
            line2 = "[AFK BOT]"
            
            local displayName = plr.Name
            if State.StreamerMode and State.StreamerMode.HideUsername then
                displayName = "BOYFINITY"
            end
            line1 = State.ESP.Names and displayName or ""
            if State.ESP.ShowLevel then
                local lvl = plr:GetAttribute("Level") or "0"
                if line1 ~= "" then
                    line1 = line1 .. " [Lv." .. tostring(lvl) .. "]"
                else
                    line1 = "[Lv." .. tostring(lvl) .. "]"
                end
            end

        elseif isSurvivor then
            local knocked = char:GetAttribute("Knocked") or char:GetAttribute("IsKnocked")
            local hooked = char:GetAttribute("IsHooked") or char:GetAttribute("Hooked")
            local item = plr:GetAttribute("EquippedItem") or plr:GetAttribute("Item")

            -- Logika Tracker Phase Hook
            if not _G.SurvivorHookData then _G.SurvivorHookData = {} end
            
            -- Jika karakter berubah (misal match baru dimulai), reset phase-nya
            if _G.SurvivorHookData[plr.Name] and _G.SurvivorHookData[plr.Name].char ~= char then
                _G.SurvivorHookData[plr.Name] = nil
            end

            if not _G.SurvivorHookData[plr.Name] then
                _G.SurvivorHookData[plr.Name] = { phase = 0, currentlyHooked = false, char = char }
            end
            
            if hooked and not _G.SurvivorHookData[plr.Name].currentlyHooked then
                _G.SurvivorHookData[plr.Name].currentlyHooked = true
                _G.SurvivorHookData[plr.Name].phase = _G.SurvivorHookData[plr.Name].phase + 1
            elseif not hooked and _G.SurvivorHookData[plr.Name].currentlyHooked then
                _G.SurvivorHookData[plr.Name].currentlyHooked = false
            end
            
            local phaseNum = _G.SurvivorHookData[plr.Name].phase

            -- Cek Streamer Mode untuk menyembunyikan nama di ESP
            local displayName = plr.Name
            if State.StreamerMode and State.StreamerMode.HideUsername then
                displayName = "BOYFINITY"
            end
            
            line1 = State.ESP.Names and displayName or ""
            
            if State.ESP.ShowLevel then
                local lvl = plr:GetAttribute("Level") or "0"
                if line1 ~= "" then
                    line1 = line1 .. " [Lv." .. tostring(lvl) .. "]"
                else
                    line1 = "[Lv." .. tostring(lvl) .. "]"
                end
            end
            
            -- Cek apakah LocalPlayer (kamu) adalah Killer
            local amIKiller = (Players.LocalPlayer.Team and Players.LocalPlayer.Team.Name == "Killer")
            
            -- Render Phase Image (Hanya untuk Killer)
            if State.ESP.ShowHookPhase and phaseNum >= 1 and amIKiller then
                if not espCache.PhaseImages[plr] then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 60, 0, 60) -- Ukuran gambar phase (bisa disesuaikan)
                    bill.SizeOffset = Vector2.new(0, 0.5)
                    bill.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0) -- Lebih tinggi dari ESP Text
                    bill.AlwaysOnTop = true
                    bill.Parent = ESPFolder
                    
                    local img = Instance.new("ImageLabel", bill)
                    img.Size = UDim2.new(1, 0, 1, 0)
                    img.BackgroundTransparency = 1
                    img.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    img.ScaleType = Enum.ScaleType.Fit -- Memastikan rasio asli gambar terjaga
                    
                    espCache.PhaseImages[plr] = bill
                end
                
                local bill = espCache.PhaseImages[plr]
                local img = bill:FindFirstChildOfClass("ImageLabel")
                bill.Adornee = head
                
                -- Set gambar sesuai Phase dan atur ukuran secara dinamis agar proporsional
                if phaseNum == 1 then
                    img.Image = "rbxassetid://75320159990376"
                    bill.Size = UDim2.new(0, 42, 0, 75) -- Berdasarkan rasio 938:1676
                elseif phaseNum == 2 then
                    img.Image = "rbxassetid://115165939196413"
                    bill.Size = UDim2.new(0, 59, 0, 75) -- Berdasarkan rasio 1113:1413
                elseif phaseNum >= 3 then
                    img.Image = "rbxassetid://127731988662950"
                    bill.Size = UDim2.new(0, 56, 0, 75) -- Berdasarkan rasio 1089:1444
                end
                img.ScaleType = Enum.ScaleType.Stretch -- Paksa gambar mengisi penuh ukuran proporsional di atas
                
                bill.Enabled = true
            else
                if espCache.PhaseImages[plr] then
                    espCache.PhaseImages[plr]:Destroy()
                    espCache.PhaseImages[plr] = nil
                end
            end
            
            if hooked then 
                color = State.ESP.HookedColor or Color3.fromRGB(255, 80, 0) -- Orange
                line2 = "[HOOKED]"
            elseif knocked then 
                color = State.ESP.KnockedColor or Color3.fromRGB(255, 255, 0) -- Kuning
                line2 = "[KNOCKED]"
            else 
                color = State.ESP.SurvivorColor or Color3.fromRGB(0, 255, 0) -- HIJAU SUPER TERANG
                if item and item ~= "" and item ~= "None" then line2 = "[" .. tostring(item) .. "]" end
            end
        end

        if State.ESP.Studs then
            local myRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local d = math.floor((head.Position - myRoot.Position).Magnitude)
                line3 = "[" .. d .. "m]"
            end
        end
        
        local finalText = line1
        if line3 ~= "" then finalText = finalText ~= "" and (finalText .. " " .. line3) or line3 end
        if line2 ~= "" then finalText = finalText ~= "" and (finalText .. "\n" .. line2) or line2 end

        -- Render Highlight (CoreGui)
        if not espCache.Highlights[plr] then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.OutlineTransparency = 0
            hl.FillTransparency = 0.8
            hl.Parent = ESPFolder
            espCache.Highlights[plr] = hl
        end
        espCache.Highlights[plr].Adornee = char
        espCache.Highlights[plr].FillColor = color
        espCache.Highlights[plr].OutlineColor = color
        espCache.Highlights[plr].Enabled = true

        -- Render Billboard (Lebih kecil, dekat kepala)
        if not espCache.Labels[plr] then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 200, 0, 50)
            -- Menggunakan SizeOffset (0, 0.5) akan menggeser titik pivot Gui ke bagian bawahnya, 
            -- sehingga saat jauh pun teks tidak akan turun melewati kepala.
            bill.SizeOffset = Vector2.new(0, 0.5)
            bill.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
            bill.AlwaysOnTop = true
            bill.Parent = ESPFolder
            
            local txt = Instance.new("TextLabel", bill)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 13 -- Ukuran diperkecil
            txt.TextStrokeTransparency = 0.2
            txt.TextStrokeColor3 = Color3.new(0, 0, 0)
            txt.TextYAlignment = Enum.TextYAlignment.Bottom
            espCache.Labels[plr] = bill
        end

        local bill = espCache.Labels[plr]
        local txt = bill:FindFirstChildOfClass("TextLabel")
        bill.Adornee = head
        txt.Text = finalText
        txt.TextColor3 = color
        txt.Visible = (finalText ~= "")
    end

    -- // 2. UPDATE BOT ESP (Untuk Model Bot Standalone di Workspace / CollectionService)
    local function updateBot(botModel, currentCam)
        if not State.ESP.Enabled or not checkSelected("Bots") then 
            clearESP(botModel) 
            return 
        end

        local head = botModel:FindFirstChild("Head") or botModel.PrimaryPart
        local hum = botModel:FindFirstChildOfClass("Humanoid")
        if not botModel.Parent or not head or (hum and hum.Health <= 0) then 
            clearESP(botModel) 
            return 
        end

        local myRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local dist = (head.Position - myRoot.Position).Magnitude
            local maxDist = State.ESP.GenDistance or 500
            if dist > maxDist then
                clearESP(botModel)
                return
            end
        end

        local color = State.ESP.BotColor or Color3.fromRGB(0, 230, 255)
        local botName = botModel.Name
        if State.StreamerMode and State.StreamerMode.HideUsername then
            botName = "BOYFINITY"
        end

        local line1 = State.ESP.Names and (botName .. " [BOT]") or "[AFK BOT]"
        local line2 = "[AFK BOT]"
        local line3 = ""

        if State.ESP.Studs and myRoot then
            local d = math.floor((head.Position - myRoot.Position).Magnitude)
            line3 = "[" .. d .. "m]"
        end

        local finalText = line1
        if line3 ~= "" then finalText = finalText ~= "" and (finalText .. " " .. line3) or line3 end
        if line2 ~= "" then finalText = finalText ~= "" and (finalText .. "\n" .. line2) or line2 end

        -- Highlight CoreGui
        if not espCache.Highlights[botModel] then
            local hl = Instance.new("Highlight")
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.OutlineTransparency = 0
            hl.FillTransparency = 0.8
            hl.Parent = ESPFolder
            espCache.Highlights[botModel] = hl
        end
        espCache.Highlights[botModel].Adornee = botModel
        espCache.Highlights[botModel].FillColor = color
        espCache.Highlights[botModel].OutlineColor = color
        espCache.Highlights[botModel].Enabled = true

        -- Billboard
        if not espCache.Labels[botModel] then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 200, 0, 50)
            bill.SizeOffset = Vector2.new(0, 0.5)
            bill.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
            bill.AlwaysOnTop = true
            bill.Parent = ESPFolder
            
            local txt = Instance.new("TextLabel", bill)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Font = Enum.Font.SourceSansBold
            txt.TextSize = 13
            txt.TextStrokeTransparency = 0.2
            txt.TextStrokeColor3 = Color3.new(0, 0, 0)
            txt.TextYAlignment = Enum.TextYAlignment.Bottom
            espCache.Labels[botModel] = bill
        end

        local bill = espCache.Labels[botModel]
        local txt = bill:FindFirstChildOfClass("TextLabel")
        bill.Adornee = head
        txt.Text = finalText
        txt.TextColor3 = color
        txt.Visible = (finalText ~= "")
    end
 
-- // 3. UPDATE OBJECT ESP (FIXED: NO TEXT GANGGU, HIGHLIGHT PALLET/HOOK, WINDOW FIXED, ZOMBIE UNGU)
    local function updateObject(obj, objType, currentCam)
        if not State.ESP.Enabled or not checkSelected(objType) then 
            clearESP(obj) 
            return 
        end

        local myRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)) or obj
            if targetPart and targetPart:IsA("BasePart") then
                local dist = (targetPart.Position - myRoot.Position).Magnitude
                
                local maxDist = 500
                if objType == "Generators" then maxDist = State.ESP.GenDistance or 500
                elseif objType == "Gates" then maxDist = State.ESP.GateDistance or 500
                elseif objType == "Pallets" then maxDist = State.ESP.PalletDistance or 500
                elseif objType == "Hooks" then maxDist = State.ESP.HookDistance or 500
                elseif objType == "Windows" then maxDist = State.ESP.WindowDistance or 500
                elseif objType == "Zombies" then maxDist = State.ESP.ZombieDistance or 500
                elseif objType == "BearTraps" then maxDist = State.ESP.BearTrapDistance or 500
                elseif objType == "Bots" then maxDist = State.ESP.BotsDistance or 500
                elseif objType == "Pumpkins" then maxDist = State.ESP.PumpkinDistance or 70
                end

                -- Jika objek lebih jauh dari batas slider, HAPUS ESP-nya lalu gagalkan prosesnya
                if dist > maxDist then
                    clearESP(obj)
                    return
                end
            end
        end

        -- Pewarnaan berdasarkan Tipe
        local color = Color3.fromRGB(255, 255, 255)
        if objType == "Generators" then 
            local prog = obj:GetAttribute("RepairProgress") or 0
            if prog >= 99.9 then
                color = Color3.fromRGB(0, 255, 0)
            else
                color = Color3.fromRGB(255 * (1 - (prog/100)), 255, 0)
            end
        elseif objType == "Gates" then color = State.ESP.GateColor or Color3.fromRGB(227, 227, 227)
        elseif objType == "Pallets" then color = State.ESP.PalletColor or Color3.fromRGB(255, 221, 116)
        elseif objType == "Hooks" then color = State.ESP.HookColor or Color3.fromRGB(255, 45, 45)
        elseif objType == "Windows" then color = State.ESP.WindowColor or Color3.fromRGB(255, 227, 128)
        elseif objType == "Zombies" then color = State.ESP.ZombieColor or Color3.fromRGB(188, 0, 255)
        elseif objType == "BearTraps" then color = State.ESP.BearTrapColor or Color3.fromRGB(255, 100, 0)
        elseif objType == "Pumpkins" then color = State.ESP.PumpkinColor or Color3.fromRGB(255, 140, 0) -- 🎃 Tambahkan ini
        elseif objType == "Bots" or isBot then color = State.ESP.BotColor or Color3.fromRGB(0, 230, 255) end

        -- 🔥 RENDER LOGIC: BENTUK VISUAL ESP
       -- Ubah kondisi awal (Baris ~1484)
        if objType == "Windows" or objType == "Gates" then
            
            -- Logic BoxHandleAdornment buat Gate, Windows, Zombie
            local targetPart = obj
            if objType == "Windows" then
                targetPart = obj:FindFirstChild("Bottom", true) or (obj:IsA("Model") and obj.PrimaryPart)
            elseif objType == "Gates" then
                targetPart = obj -- Gate biasanya part kecil/basepart
            end

            if not targetPart or not targetPart:IsA("BasePart") then clearESP(obj) return end

            -- Pakai BoxHandleAdornment
            if not espCache.Highlights[obj] or not espCache.Highlights[obj]:IsA("BoxHandleAdornment") then
                if espCache.Highlights[obj] then espCache.Highlights[obj]:Destroy() end
                local box = Instance.new("BoxHandleAdornment")
                box.AlwaysOnTop = true
                box.ZIndex = 5
                box.Parent = ESPFolder
                espCache.Highlights[obj] = box
            end
            
            local box = espCache.Highlights[obj]
            box.Adornee = targetPart
            box.Size =  targetPart.Size + Vector3.new(0.05, 0.05, 0.05)
            box.Transparency = 0.4
            box.Color3 = color
            box.Visible = true

        else
            -- GENERATOR, GATE, PALLET, HOOK, ZOMBIE, BEARTRAP: Tetap pakai Highlight Bawaan tanpa dikorbankan!
            if not espCache.Highlights[obj] or not espCache.Highlights[obj]:IsA("Highlight") then
                if espCache.Highlights[obj] then espCache.Highlights[obj]:Destroy() end
                local hl = Instance.new("Highlight")
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = ESPFolder
                espCache.Highlights[obj] = hl
            end
            
            local hl = espCache.Highlights[obj]

            hl.Adornee = obj
            
            if objType == "Generators" or objType == "Zombies" or objType == "Pallets" or objType == "BearTraps" then
                hl.OutlineTransparency = 0 
                hl.FillTransparency = 0.75
                hl.FillColor = color
                hl.OutlineColor = color
            elseif objType == "Hooks" then
                hl.OutlineTransparency = 0 
                hl.FillTransparency = 0.85
                hl.FillColor = color
                hl.OutlineColor = color
            else
                hl.OutlineTransparency = 0 
                hl.FillTransparency = 0.8
                hl.FillColor = color
                hl.OutlineColor = color
            end
            
            hl.Enabled = true
        end

        -- 🔥 RENDER TULISAN: GENERATOR, ZOMBIE, & BEARTRAP
        if objType == "Generators" or objType == "Zombies" or objType == "BearTraps" then
            if not espCache.Labels[obj] then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 150, 0, 30)
                bill.AlwaysOnTop = true
                bill.Parent = ESPFolder
                
                local txt = Instance.new("TextLabel", bill)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Font = Enum.Font.SourceSansBold
                txt.TextStrokeTransparency = 0.4
                espCache.Labels[obj] = bill
            end
            
            local bill = espCache.Labels[obj]
            local txt = bill:FindFirstChildOfClass("TextLabel")
            
            -- Set Adornee ke part akar
            if objType == "Zombies" then
                bill.Adornee = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                bill.StudsOffset = Vector3.new(0, 3, 0) -- Pas di atas kepala kotak 3D
                txt.TextSize = 11 -- 🔥 Font kecil sesuai request
            elseif objType == "BearTraps" then
                bill.Adornee = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true) or obj)
                bill.StudsOffset = Vector3.new(0, 1.5, 0)
                txt.TextSize = 11
            else
                bill.Adornee = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true) or obj
                bill.StudsOffset = Vector3.new(0, 3.5, 0)
                txt.TextSize = 13 -- Font generator lebih besar
            end
            
            local nameStr = ""
            if objType == "Generators" then
                local prog = obj:GetAttribute("RepairProgress") or 0
                if prog >= 99.9 then
                    nameStr = "Generator [100%]"
                else
                    nameStr = string.format("Generator [%.1f%%]", prog)
                end
            elseif objType == "Zombies" then
                nameStr = "[Zombie]"
            elseif objType == "BearTraps" then
                nameStr = "[BearTrap]"
            end
            
            -- Tampilkan jarak jika disetting On di UI
            if State.ESP.Studs then
                local myRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local hitPos = bill.Adornee and (bill.Adornee:IsA("BasePart") and bill.Adornee.Position or bill.Adornee:GetPivot().Position) or Vector3.zero
                local dist = myRoot and math.floor((hitPos - myRoot.Position).Magnitude) or 0
                txt.Text = nameStr .. " [" .. dist .. "m]"
            else
                txt.Text = nameStr
            end
            
            txt.TextColor3 = color
            txt.Visible = true
        else
            -- Jika bukan Generator/Zombie/BearTrap, bersihkan teksnya biar layar gak penuh
            if espCache.Labels[obj] then
                espCache.Labels[obj]:Destroy()
                espCache.Labels[obj] = nil
            end
        end
    end -- Akhir dari fungsi updateObject
    --=====================================================
    -- ESP MAIN RENDER LOOP
    --=====================================================
    RunService.RenderStepped:Connect(function()
        local currentCam = workspace.CurrentCamera
        if not currentCam then return end

        if not State.ESP.Enabled then
            -- Jika ESP dimatikan, bersihkan semua yang aktif di cache
            for obj, _ in pairs(espCache.Highlights) do clearESP(obj) end
            return
        end

        -- Players
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then updatePlayer(plr, currentCam) end
        end

        local CollectionService = game:GetService("CollectionService")
        for _, botModel in ipairs(CollectionService:GetTagged("SurvivorBot")) do
            updateBot(botModel, currentCam)
        end

        -- Fallback check untuk model di Workspace yang memiliki attribute BotId / BotNetId
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and (child:GetAttribute("BotId") or child:GetAttribute("BotNetId")) then
                updateBot(child, currentCam)
            end
        end

        -- Objects
        for gen in pairs(ObjectCache.Generators) do 
            if gen.Parent then updateObject(gen, "Generators", currentCam) else clearESP(gen); ObjectCache.Generators[gen] = nil end 
        end
        for gate in pairs(ObjectCache.Gates) do 
            if gate.Parent then updateObject(gate, "Gates", currentCam) else clearESP(gate); ObjectCache.Gates[gate] = nil end 
        end
        for pallet in pairs(ObjectCache.Pallets) do 
            if pallet.Parent then updateObject(pallet, "Pallets", currentCam) else clearESP(pallet); ObjectCache.Pallets[pallet] = nil end 
        end
        for hook in pairs(ObjectCache.Hooks) do 
            if hook.Parent then updateObject(hook, "Hooks", currentCam) else clearESP(hook); ObjectCache.Hooks[hook] = nil end 
        end
        for win in pairs(ObjectCache.Windows) do 
            if win.Parent then updateObject(win, "Windows", currentCam) else clearESP(win); ObjectCache.Windows[win] = nil end 
        end
        for trap in pairs(ObjectCache.BearTraps) do 
            if trap.Parent then updateObject(trap, "BearTraps", currentCam) else clearESP(trap); ObjectCache.BearTraps[trap] = nil end 
        end
        for pumpkin in pairs(ObjectCache.Pumpkins) do 
            if pumpkin.Parent then updateObject(pumpkin, "Pumpkins", currentCam) else clearESP(pumpkin); ObjectCache.Pumpkins[pumpkin] = nil end 
        end
        
        -- =================================================================
        -- Render Zombie SCP (Detection via Attributes + State + Health)
        -- =================================================================
        local myTeam = game.Players.LocalPlayer.Team
        local isMeSurvivor = myTeam and myTeam.Name == "Survivors"

        for zombie in pairs(ObjectCache.Zombies) do 
            if zombie and zombie.Parent then
                
                if isMeSurvivor then
                    local hum = zombie:FindFirstChildOfClass("Humanoid")
                    local hrp = zombie:FindFirstChild("HumanoidRootPart")
                    
                    if hum and hrp then
                        -- 1. HEURISTIC DEATH CHECK (Karena Health selalu 100)
                        local isDead = false
                        
                        -- A. Cek State Humanoid
                        if hum:GetState() == Enum.HumanoidStateType.Dead then isDead = true end
                        
                        -- B. Cek Atribut atau Value "Dead" / "IsDead"
                        if zombie:GetAttribute("Dead") == true or zombie:GetAttribute("IsDead") == true then isDead = true end
                        if zombie:FindFirstChild("Dead") or zombie:FindFirstChild("IsDead") then isDead = true end
                        
                        -- C. Cek Nama Model (Biasa diubah jadi Corpse kalau mati)
                        if zombie.Name:lower():find("corpse") or zombie.Name:lower():find("dead") then isDead = true end
                        
                        -- D. Cek Kecepatan (Jika WalkSpeed 0, game menganggapnya tidak bisa bergerak/mati)
                        local isRagdoll = (hum:GetState() == Enum.HumanoidStateType.Physics)
                        if hum.WalkSpeed == 0 then isDead = true end

                        -- 2. NORMAL ZOMBIE CHECK (Masih Hidup)
                        -- Cek Atribut dasar
                        local isAttributeZombie = (zombie:GetAttribute("Cured") == 3) or (zombie:GetAttribute("CorpseCreated0492") ~= nil)
                        
                        -- Cek WalkSpeed (Jika dia zombie tapi ga ragdoll)
                        local isSlowZombie = (hum.WalkSpeed > 0 and hum.WalkSpeed < 15)
                        
                        -- Kalau dia tidak mati, dan salah satu syarat zombie terpenuhi, GAS ESP!
                        if not isDead and (isAttributeZombie or isRagdoll or isSlowZombie) then
                            updateObject(zombie, "Zombies", currentCam) 
                        else
                            clearESP(zombie) 
                        end
                    else
                        clearESP(zombie)
                    end
                else
                    clearESP(zombie) 
                end
                
            else 
                clearESP(zombie)
                ObjectCache.Zombies[zombie] = nil 
            end 
        end
    end)

-- =====================================================
-- LOGIKA AUTO FARM PUMPKIN (SPEED 30, CONTINUOUS WAYPOINT RUNNER & CRUSH)
-- =====================================================
local PathfindingService = game:GetService("PathfindingService")
local VIM = game:GetService("VirtualInputManager")

task.spawn(function()
    local FARM_SPEED = 30
    local HalloweenCrushRemote = nil
    
    local function getCrushRemote()
        if HalloweenCrushRemote and HalloweenCrushRemote.Parent then return HalloweenCrushRemote end
        pcall(function()
            HalloweenCrushRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 2):WaitForChild("Events", 2):WaitForChild("Halloween", 2):WaitForChild("Crush", 2)
        end)
        return HalloweenCrushRemote
    end

    local function executeCrush(pumpkinModel, targetPart)
        local crush = getCrushRemote()
        if crush then
            pcall(function()
                local hbPart = nil
                if pumpkinModel then
                    hbPart = pumpkinModel:FindFirstChild("HB") 
                        or pumpkinModel:FindFirstChild("HitBox")
                        or pumpkinModel:FindFirstChild("Hitbox")
                end
                if not hbPart and targetPart and targetPart.Parent then
                    hbPart = targetPart.Parent:FindFirstChild("HB")
                        or targetPart.Parent:FindFirstChild("HitBox")
                        or targetPart.Parent:FindFirstChild("Hitbox")
                end
                if not hbPart and targetPart and targetPart.Name == "HB" then
                    hbPart = targetPart
                end

                local targetToFire = hbPart or targetPart or pumpkinModel
                crush:FireServer(targetToFire)

                if hbPart and pumpkinModel and hbPart ~= pumpkinModel then
                    crush:FireServer(pumpkinModel)
                end
            end)
        end

        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.04)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end

    while task.wait(0.1) do
        if State.AutoFarmPumpkin then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hrp and hum and hum.Health > 0 then
                if hum.WalkSpeed ~= FARM_SPEED then
                    hum.WalkSpeed = FARM_SPEED
                end

                -- 1. Cari Labu Terdekat
                local nearestPumpkin = nil
                local targetPumpkinModel = nil
                local shortestDist = math.huge

                local searchSources = {}
                if ObjectCache and ObjectCache.Pumpkins then
                    for p in pairs(ObjectCache.Pumpkins) do
                        table.insert(searchSources, p)
                    end
                end
                
                if #searchSources == 0 then
                    local currentMap = workspace:FindFirstChild("Map")
                    local pFolder = currentMap and currentMap:FindFirstChild("Pumpkins")
                    if pFolder then
                        for _, child in ipairs(pFolder:GetChildren()) do
                            table.insert(searchSources, child)
                        end
                    end
                end

                for _, pumpkin in ipairs(searchSources) do
                    if pumpkin and pumpkin.Parent then
                        local targetPart = pumpkin:IsA("BasePart") and pumpkin or (pumpkin.PrimaryPart or pumpkin:FindFirstChildWhichIsA("BasePart", true))
                        if targetPart then
                            local dist = (hrp.Position - targetPart.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                nearestPumpkin = targetPart
                                targetPumpkinModel = pumpkin
                            end
                        end
                    elseif ObjectCache and ObjectCache.Pumpkins and ObjectCache.Pumpkins[pumpkin] then
                        ObjectCache.Pumpkins[pumpkin] = nil
                    end
                end

                -- 2. Menuju Labu & Stomp
                if nearestPumpkin and targetPumpkinModel and targetPumpkinModel.Parent then
                    local dist = (hrp.Position - nearestPumpkin.Position).Magnitude

                    -- Jika sudah di dekat labu (<= 7 studs), langsung crush
                    if dist <= 7 then
                        hum:Move(Vector3.zero)
                        executeCrush(targetPumpkinModel, nearestPumpkin)
                        task.wait(0.2)
                    else
                        -- Hitung Pathfinding sekali untuk rute ini
                        local path = PathfindingService:CreatePath({
                            AgentRadius = 2.0,
                            AgentHeight = 5.0,
                            AgentCanJump = true,
                            WaypointSpacing = 4.0
                        })

                        local success, _ = pcall(function()
                            path:ComputeAsync(hrp.Position, nearestPumpkin.Position)
                        end)

                        if success and path.Status == Enum.PathStatus.Success then
                            local waypoints = path:GetWaypoints()

                            -- Telusuri seluruh waypoints secara kontinyu tanpa patah-patah
                            for i, waypoint in ipairs(waypoints) do
                                if not State.AutoFarmPumpkin then break end
                                if not (targetPumpkinModel and targetPumpkinModel.Parent) then break end
                                if not (hrp and hum and hum.Health > 0) then break end

                                -- Lock speed 30
                                if hum.WalkSpeed ~= FARM_SPEED then
                                    hum.WalkSpeed = FARM_SPEED
                                end

                                if waypoint.Action == Enum.PathWaypointAction.Jump then
                                    hum.Jump = true
                                end

                                -- Gerakkan karakter ke waypoint
                                hum:MoveTo(waypoint.Position)

                                -- Tunggu sampai mendekati waypoint atau timeout (maks 1 detik per waypoint)
                                local reached = false
                                local timeout = tick() + 1.0

                                while tick() < timeout do
                                    if not State.AutoFarmPumpkin or not targetPumpkinModel.Parent then break end
                                    
                                    -- Cek jarak ke target labu langsung
                                    local currentDistToTarget = (hrp.Position - nearestPumpkin.Position).Magnitude
                                    if currentDistToTarget <= 7 then
                                        reached = true
                                        break
                                    end

                                    -- Cek jarak ke waypoint saat ini
                                    local distToWaypoint = (hrp.Position - waypoint.Position) * Vector3.new(1, 0, 1)
                                    if distToWaypoint.Magnitude <= 3.0 then
                                        reached = true
                                        break
                                    end

                                    RunService.Heartbeat:Wait()
                                end

                                -- Jika sudah sampai di dekat target labu, keluar dari loop waypoint
                                local currentDistToTarget = (hrp.Position - nearestPumpkin.Position).Magnitude
                                if currentDistToTarget <= 7 then
                                    break
                                end
                            end

                            -- Setelah selesai waypoint atau sudah dekat, eksekusi stomp jika dalam jangkauan
                            local finalDist = (hrp.Position - nearestPumpkin.Position).Magnitude
                            if finalDist <= 7 then
                                hum:Move(Vector3.zero)
                                executeCrush(targetPumpkinModel, nearestPumpkin)
                                task.wait(0.2)
                            end
                        else
                            -- Fallback Direct Move mulus jika pathfinding gagal (garis lurus)
                            local moveTimeout = tick() + 0.6
                            while tick() < moveTimeout do
                                if not State.AutoFarmPumpkin or not targetPumpkinModel.Parent then break end
                                if (hrp.Position - nearestPumpkin.Position).Magnitude <= 7 then break end
                                
                                if hum.WalkSpeed ~= FARM_SPEED then
                                    hum.WalkSpeed = FARM_SPEED
                                end

                                local dir = (nearestPumpkin.Position - hrp.Position) * Vector3.new(1, 0, 1)
                                if dir.Magnitude > 0.5 then
                                    hum:Move(dir.Unit)
                                else
                                    hum:MoveTo(nearestPumpkin.Position)
                                end

                                RunService.Heartbeat:Wait()
                            end

                            if (hrp.Position - nearestPumpkin.Position).Magnitude <= 7 then
                                hum:Move(Vector3.zero)
                                executeCrush(targetPumpkinModel, nearestPumpkin)
                                task.wait(0.2)
                            end
                        end
                    end
                else
                    hum:Move(Vector3.zero)
                end
            end
        else
            -- Pastikan input movement bersih saat dimatikan
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:Move(Vector3.zero)
            end
        end
    end
end)

    Players.PlayerRemoving:Connect(clearESP)

--=====================================================
-- INTEGRATED MOVEMENT: SPEED, NOCLIP, & CAMERA
--=====================================================
--=====================================================
-- [A] UNIVERSAL WALKSPEED (INFINITE YIELD 'LOOPSPEED' METHOD)
-- Langsung aktif mengikuti slider SpeedValue tanpa toggle.
-- Menggunakan GetPropertyChangedSignal("WalkSpeed") agar
-- game / anticheat tidak bisa mereset nilai kecepatan.
--=====================================================
local wsLoopConn = nil

local function applyUniversalSpeed(char)
    if wsLoopConn then
        wsLoopConn:Disconnect()
        wsLoopConn = nil
    end

    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local function enforceSpeed()
        if not (hum and hum.Parent) then return end
        if State.AutoFarmPumpkin then
            if hum.WalkSpeed ~= 30 then
                hum.WalkSpeed = 30
            end
            return
        end

        local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        if isShiftPressed then
            local target = (State.Movement and State.Movement.SpeedValue) or 16
            if hum.WalkSpeed ~= target then
                hum.WalkSpeed = target
            end
        end
    end

    -- Terapkan langsung
    enforceSpeed()

    -- IY loopws listener: jika game coba mereset WalkSpeed, langsung paksa kembali
    wsLoopConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(enforceSpeed)
end

-- Terapkan saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    repeat RunService.Heartbeat:Wait() until newChar:FindFirstChildOfClass("Humanoid")
    applyUniversalSpeed(newChar)
end)

-- Jalankan untuk karakter saat ini
if LocalPlayer.Character then
    applyUniversalSpeed(LocalPlayer.Character)
end

-- RenderStepped backup loop untuk menjamin kecepatan selalu terpasang per frame
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if char and hum then
        -- 🛑 1. PROTEKSI KNOCKED / DOWN (Agar ngerangkak tetap normal & ga sus)
        local isKnocked = char:GetAttribute("Knocked") or char:GetAttribute("IsKnocked") or _G.isFakeKnocked
        if isKnocked then 
            return 
        end

        -- ⚡ 2. PRIORITAS 1: LOCK SPEED 100 SAAT AUTO FARM PUMPKIN AKTIF
        if State.AutoFarmPumpkin then
            hum.WalkSpeed = 30
        else
            -- 🏃 3. PRIORITAS 2: SPRINT MANUAL (LeftShift / RightShift) JIKA AUTO FARM MATI
            local isShiftPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) 
                or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

            if isShiftPressed then
                local customSpeed = (State.Movement and State.Movement.SpeedValue) or 16
                hum.WalkSpeed = customSpeed
            end
        end
    end
end)
--=====================================================
-- [B] STANDALONE ANTI-RUBBERBANDING (SAFE TELEPORT & MATCH TRANSITION)
-- Mencegah server rollback tanpa memblokir teleportasi match resmi game.
--=====================================================
local _lastCF, _stopAntiRubber, _heartbeatConnection

local function startAntiRubber()
    if _heartbeatConnection then _heartbeatConnection:Disconnect(); _heartbeatConnection = nil end
    _stopAntiRubber = false
    _lastCF = nil

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = hum and hum.RootPart
    if not hum or not root then return end

    _heartbeatConnection = RunService.Heartbeat:Connect(function()
        if _stopAntiRubber then return end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = h and h.RootPart
        if r then
            _lastCF = r.CFrame
        end
    end)

    root:GetPropertyChangedSignal("CFrame"):Connect(function()
        if _stopAntiRubber then return end
        if _lastCF == nil then return end

        local newPos = root.Position
        local oldPos = _lastCF.Position
        local delta = (newPos - oldPos).Magnitude

        -- Jika perubahan posisi besar (> 35 studs), ini adalah TELEPORT RESMI dari game
        -- (masuk match round start, cutscene, escape, respawn, dll).
        -- Jangan revert! Izinkan teleportasi berlangsung mulus tanpa tertahan di lobby.
        if delta > 35 then
            _lastCF = root.CFrame
            return
        end

        _stopAntiRubber = true
        root.CFrame = _lastCF
        RunService.Heartbeat:Wait()
        _stopAntiRubber = false
    end)

    hum.Died:Connect(function()
        if _heartbeatConnection then
            _heartbeatConnection:Disconnect()
            _heartbeatConnection = nil
        end
    end)
end

-- Deteksi sinyal round start game agar Anti-Rubberband tidak menahan teleport
pcall(function()
    local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
    if Remotes then
        local GameRemotes = Remotes:WaitForChild("Game", 5)
        if GameRemotes then
            local StartEvent = GameRemotes:FindFirstChild("Start")
            if StartEvent and StartEvent:IsA("BindableEvent") then
                StartEvent.Event:Connect(function()
                    _stopAntiRubber = true
                    task.delay(3, function()
                        local c = LocalPlayer.Character
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if r then _lastCF = r.CFrame end
                        _stopAntiRubber = false
                    end)
                end)
            end

            local EnableScript = GameRemotes:FindFirstChild("EnableScript")
            if EnableScript and EnableScript:IsA("RemoteEvent") then
                EnableScript.OnClientEvent:Connect(function()
                    _stopAntiRubber = true
                    task.delay(3, function()
                        local c = LocalPlayer.Character
                        local r = c and c:FindFirstChild("HumanoidRootPart")
                        if r then _lastCF = r.CFrame end
                        _stopAntiRubber = false
                    end)
                end)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    _G.StopAntiRubber = true
    _G.IsTeleporting = true
    _G.LastCF = nil -- Reset posisi lobby lama

    repeat RunService.Heartbeat:Wait() until character:FindFirstChildOfClass('Humanoid')
    repeat RunService.Heartbeat:Wait() until character:FindFirstChildOfClass('Humanoid').RootPart

    -- 2. Beri waktu 2.5 detik agar server selesai memindahkan karakter ke spawn map
    task.wait(2.5)

    -- 3. Nyalakan kembali Anti-Rubberband dengan koordinat map baru
    _G.LastCF = character:FindFirstChildOfClass('Humanoid').RootPart.CFrame
    _G.StopAntiRubber = false
    _G.IsTeleporting = false

    startAntiRubber()
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if _heartbeatConnection then
        _heartbeatConnection:Disconnect()
        _heartbeatConnection = nil
    end
end)

if LocalPlayer.Character then
    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h and h.RootPart then
        startAntiRubber()
    end
end
-- [B] LOGIC NOCLIP
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if State.Movement.NoClip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

--=====================================================
-- LOGIC: SPECTATOR LIST (TEAM BASED)
--=====================================================
local lastSpectatorUpdate = tick()

RunService.RenderStepped:Connect(function()
    -- Kalau toggle di UI dimatikan, sembunyikan total
    if not State.SpectatorList then 
        if _G.SpecFrame then _G.SpecFrame.Visible = false end
        return 
    end
    
    -- Kalau toggle nyala, pastikan kotaknya selalu terlihat
    if _G.SpecFrame then _G.SpecFrame.Visible = true end
    
    if tick() - lastSpectatorUpdate >= 0.5 then
        lastSpectatorUpdate = tick()
        local spectators = {}

        -- Langsung sikat loop semua player
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pTeam = player.Team
                local pTeamName = pTeam and pTeam.Name or ""
                
                -- Jika nama timnya "Spectator" (Sesuai Dex), langsung masukin ke list
                if pTeamName == "Spectator" or pTeamName == "Spectators" then
                    table.insert(spectators, player.Name)
                end
            end
        end

        -- Update UI Text & Size (Kotak tetep draggable dari logic sebelumnya)
        if _G.SpecListLabel and _G.SpecFrame then
            if #spectators > 0 then
                _G.SpecListLabel.Text = table.concat(spectators, "\n")
                _G.SpecFrame.Size = UDim2.new(0, 150, 0, 30 + (#spectators * 15)) 
            else
                _G.SpecListLabel.Text = "None"
                _G.SpecFrame.Size = UDim2.new(0, 150, 0, 45)
            end
        end
    end
end)

--=====================================================
-- 1. SKYBOX DATA & APPLY FUNCTION
--=====================================================
local SkyData = {
    ["Night City"] = { -- Mapped dari "Night" di gambar lo
        ["CelestialBodiesShown"] = false,
        ["StarCount"] = 0,
        ["MoonAngularSize"] = 11,
        ["MoonTextureId"] = "rbxasset://sky/moon.jpg",
        ["SunAngularSize"] = 21,
        ["SunTextureId"] = "rbxasset://sky/sun.jpg",
        ["SkyboxBk"] = "http://www.roblox.com/asset/?id=12064107",
        ["SkyboxDn"] = "http://www.roblox.com/asset/?id=12064152",
        ["SkyboxFt"] = "http://www.roblox.com/asset/?id=12064121",
        ["SkyboxLf"] = "http://www.roblox.com/asset/?id=12063984",
        ["SkyboxRt"] = "http://www.roblox.com/asset/?id=12064115",
        ["SkyboxUp"] = "http://www.roblox.com/asset/?id=12064131",
    },
    ["Deep Space"] = { -- Mapped dari "Space" di gambar lo
        ["CelestialBodiesShown"] = false,
        ["StarCount"] = 3000,
        ["MoonAngularSize"] = 11,
        ["MoonTextureId"] = "rbxasset://sky/moon.jpg",
        ["SunAngularSize"] = 21,
        ["SunTextureId"] = "rbxasset://sky/sun.jpg",
        ["SkyboxBk"] = "http://www.roblox.com/asset/?id=149397692",
        ["SkyboxDn"] = "http://www.roblox.com/asset/?id=149397686",
        ["SkyboxFt"] = "http://www.roblox.com/asset/?id=149397697",
        ["SkyboxLf"] = "http://www.roblox.com/asset/?id=149397684",
        ["SkyboxRt"] = "http://www.roblox.com/asset/?id=149397688",
        ["SkyboxUp"] = "http://www.roblox.com/asset/?id=149397702",
    },
    ["None"] = { -- Mode polosan dari gambar lo
        ["CelestialBodiesShown"] = false,
        ["StarCount"] = 0,
        ["SkyboxBk"] = "http://www.roblox.com/asset/?id=2675785344",
        ["SkyboxDn"] = "http://www.roblox.com/asset/?id=2675785344",
        ["SkyboxFt"] = "http://www.roblox.com/asset/?id=2675785344",
        ["SkyboxLf"] = "http://www.roblox.com/asset/?id=2675785344",
        ["SkyboxRt"] = "http://www.roblox.com/asset/?id=2675785344",
        ["SkyboxUp"] = "http://www.roblox.com/asset/?id=2675785344",
    },
    -- Untuk yang lain, gue pake format properti yang sama biar aktif
    ["Anime Sunset"] = {
        ["SkyboxBk"] = "rbxassetid://12064573", ["SkyboxDn"] = "rbxassetid://12064521", 
        ["SkyboxFt"] = "rbxassetid://12064548", ["SkyboxLf"] = "rbxassetid://12064596", 
        ["SkyboxRt"] = "rbxassetid://12064611", ["SkyboxUp"] = "rbxassetid://12064631"
    },
    ["Vaporwave"] = {
        ["SkyboxBk"] = "rbxassetid://1417491756", ["SkyboxDn"] = "rbxassetid://1417491410", 
        ["SkyboxFt"] = "rbxassetid://1417492131", ["SkyboxLf"] = "rbxassetid://1417491958", 
        ["SkyboxRt"] = "rbxassetid://1417492330", ["SkyboxUp"] = "rbxassetid://1417492582"
    }
}

--=====================================================
-- UPDATED APPLY FUNCTION (FULL INJECTION)
--=====================================================
_G.ApplySkybox = function(name)
    local Lighting = game:GetService("Lighting")
    
    -- Bersihkan Skybox lama
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    
    if name == "Default" then return end
    
    local data = SkyData[name]
    if data then
        local newSky = Instance.new("Sky")
        -- Inject semua properti (StarCount, SkyboxBk, dll)
        for prop, val in pairs(data) do
            pcall(function()
                newSky[prop] = val
            end)
        end
        newSky.Parent = Lighting
    end
end

--=====================================================
-- 2. ENVIRONMENT ENFORCEMENT LOOP
--=====================================================
RunService.RenderStepped:Connect(function()
    local S = _G.SharedState
    if not S then return end

    -- Logic Jam (Time of Day)
    if S.CustomTime then
        game:GetService("Lighting").ClockTime = S.CustomTime
    end

    -- Logic Hapus Kabut (Remove Fog)
    if S.RemoveFog then
        game:GetService("Lighting").FogEnd = 100000
        for _, obj in pairs(game:GetService("Lighting"):GetChildren()) do
            if obj:IsA("Atmosphere") then
                obj.Density = 0
            end
        end
    end
end)

--=====================================================
-- 3. DYNAMIC ESP COLOR INJECTION
--=====================================================
-- Pastikan tabel warna terinisialisasi agar tidak error saat pertama load
State.ESP.KillerColor = State.ESP.KillerColor or Color3.fromRGB(255, 0, 0)
State.ESP.SurvivorColor = State.ESP.SurvivorColor or Color3.fromRGB(0, 255, 0)
State.ESP.GenColor = State.ESP.GenColor or Color3.fromRGB(255, 255, 0)
State.ESP.GateColor = State.ESP.GateColor or Color3.fromRGB(227, 227, 227)
State.ESP.PalletColor = State.ESP.PalletColor or Color3.fromRGB(255, 221, 116)
State.ESP.WindowColor = State.ESP.WindowColor or Color3.fromRGB(255, 227, 128)
State.ESP.HookColor = State.ESP.HookColor or Color3.fromRGB(255, 45, 45)
State.ESP.BotColor = State.ESP.BotColor or Color3.fromRGB(0, 230, 255) 

-- Fungsi Helper untuk mendapatkan warna ESP yang dipilih user di UI
local function GetESPColor(objType, isKiller, isSurvivor, specialStatus)
    local E = State.ESP
    
    if isKiller then return E.KillerColor end
    if isSurvivor then
        -- Jika survivor sedang dihook atau knocked, lo bisa pilih pake warna custom atau warna picker
        if specialStatus == "Hooked" then return Color3.fromRGB(255, 80, 0) end
        if specialStatus == "Knocked" then return Color3.fromRGB(255, 255, 0) end
        return E.SurvivorColor
    end
    
    -- Warna untuk Objek
    if objType == "Generators" then return E.GenColor end
    if objType == "Gates" then return E.GateColor end
    if objType == "Pallets" then return E.PalletColor end
    if objType == "Windows" then return E.WindowColor end
    if objType == "Hooks" then return E.HookColor end
    
    return Color3.fromRGB(255, 255, 255) -- Putih jika tidak terdefinisi
end

--=====================================================
-- 2. LOGIC: PHYSICS, SPIN & MOONWALK
--=====================================================
UserInputService = game:GetService("UserInputService")
Players = game:GetService("Players")

if _G.InfiniteJumpConnection then
    _G.InfiniteJumpConnection:Disconnect()
end

_G.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
    local currentState = _G.SharedState or getgenv().State
    if currentState and currentState.InfiniteJump then
        local char = Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    end
end)

-- [B] MAIN MOVEMENT LOOP
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Update JumpPower
    if State.JumpPower then hum.JumpPower = State.JumpPower end

    -- Spinbot Logic
    if State.Spinbot then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(State.SpinSpeed or 50), 0)
    end

    -- Moonwalk Logic: Karakter menghadap kamera (Mundur)
    if State.MoonwalkEnabled and State.MoonwalkActive then
        hum.AutoRotate = false -- Matikan rotasi otomatis agar tidak bentrok
        
        local camLook = camera.CFrame.LookVector
        -- Karakter menghadap sebaliknya dari arah kamera (Mundur)
        local targetRotation = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(camLook.X, 0, camLook.Z)) * CFrame.Angles(0, math.pi, 0)
        
        -- Gunakan LERP (0.2) agar transisi rotasi halus, tidak kaku saat digerakkan WASD
        hrp.CFrame = hrp.CFrame:Lerp(targetRotation, 0.2)
    else
        -- Kembalikan kontrol rotasi ke game jika fitur mati atau mode normal
        if not State.Spinbot then 
            hum.AutoRotate = true 
        end
    end
end)

--=====================================================
-- LOGIC: CUSTOM AMBIENCE (FIXED)
--=====================================================
local Lighting = game:GetService("Lighting")

-- 1. Simpan warna original bawaan game saat script pertama kali jalan
local OriginalAmbient = Lighting.Ambient
local OriginalOutdoorAmbient = Lighting.OutdoorAmbient

-- 2. Tracker untuk ngecek apakah sebelumnya fitur ini nyala
local wasCustomAmbienceOn = false

RunService.RenderStepped:Connect(function()
    -- Pastikan toggle-nya nyala
    if State.CustomAmbience then
        -- Mencegah bentrok: Kalau FullBright lagi jalan dengan persentase tinggi, 
        -- biasanya dia bakal maksa ambient ke putih (1,1,1). 
        -- Logic ini bakal nimpa FullBright buat urusan warna ambience-nya.
        Lighting.Ambient = State.AmbientColor
        Lighting.OutdoorAmbient = State.OutdoorAmbientColor
        wasCustomAmbienceOn = true
    else
        -- Jika dimatikan, balikin ke warna aslinya HANYA SEKALI biar ga bentrok
        if wasCustomAmbienceOn then
            Lighting.Ambient = OriginalAmbient
            Lighting.OutdoorAmbient = OriginalOutdoorAmbient
            wasCustomAmbienceOn = false
        end
    end
end)

--=====================================================
    -- FIXED CAMERA FOV (NO JITTERING)
    --=====================================================
    -- Gunakan RenderStepped biar menang lawan script game
    RunService.RenderStepped:Connect(function()
        if State.Movement and State.Movement.FOVValue then
            -- Langsung paksa tanpa 'if', biar script game kalah telak
            workspace.CurrentCamera.FieldOfView = State.Movement.FOVValue
        end
    end)

    
    --=====================================================
    -- NOCLIP CLEANER (Reset saat dimatikan)
    --=====================================================
    do
    local function getCharacter()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end

    local function resetCollision()
        -- Ketika NoClip dimatikan, kita harus pastikan semua part utama karakter bisa collides lagi agar tidak jatuh menembus lantai
        local char = getCharacter() -- Pastikan kita dapet karakter terbaru (kalau mati respawn)
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Kembalikan collision part utama agar tidak jatuh menembus lantai
                    if part.Name == "HumanoidRootPart" or part.Name == "UpperTorso" or part.Name == "LowerTorso" or part.Name == "Head" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end

--=====================================================
-- LOGIC: FLOWSTATE (ANTI-SLOW VAULT & ANIMATION OVERRIDE)
--=====================================================
local FLOWSTATE_ANIM_ID = "rbxassetid://83873880822918"
local flowstateTrack = nil
local activeFlowstateChar = nil

local function EnforceFlowstateAnimation(animator)
    if not animator then return end
    
    -- Hentikan track sebelumnya jika ada
    if flowstateTrack then
        pcall(function() flowstateTrack:Stop() end)
        flowstateTrack = nil
    end

    local flowAnim = Instance.new("Animation")
    flowAnim.AnimationId = FLOWSTATE_ANIM_ID
    local success, track = pcall(function()
        return animator:LoadAnimation(flowAnim)
    end)

    if success and track then
        track.Priority = Enum.AnimationPriority.Action4
        flowstateTrack = track
    end
end

-- Listener pemantau animasi karakter: Blokir animasi vault bawaan & ganti dengan Parkour Vault ID
local function HookFlowstateCharacter(char)
    if not char then return end
    activeFlowstateChar = char
    local hum = char:WaitForChild("Humanoid", 5)
    local animator = hum and hum:WaitForChild("Animator", 5)

    if animator then
        EnforceFlowstateAnimation(animator)
    end

    if hum then
        hum.AnimationPlayed:Connect(function(track)
            if not State.FastVault then return end

            local anim = track.Animation
            local animId = anim and tostring(anim.AnimationId) or ""
            local animName = (anim and anim.Name or ""):lower()

            -- Jangan blokir jika ini adalah animasi Flowstate Parkour kita sendiri
            if animId:find("83873880822918") then return end

            -- Cek apakah animasi yang diputar adalah animasi Vault bawaan game (slow vault, medium vault, default vault)
            local isVaultAnim = animName:find("vault") or animName:find("climb") 
                or animId:find("vault") or animId:find("126230221638196") or animId:find("80105342981313")

            if isVaultAnim then
                -- Blokir animasi lambat bawaan game
                pcall(function() track:Stop(0) end)

                -- Paksa putar parkour vault animation ID 83873880822918
                local animObj = hum:FindFirstChildOfClass("Animator") or hum
                if animObj then
                    local customTrack = flowstateTrack
                    if not customTrack or customTrack.Animation.AnimationId ~= FLOWSTATE_ANIM_ID then
                        local a = Instance.new("Animation")
                        a.AnimationId = FLOWSTATE_ANIM_ID
                        customTrack = animObj:LoadAnimation(a)
                        customTrack.Priority = Enum.AnimationPriority.Action4
                        flowstateTrack = customTrack
                    end
                    if customTrack then
                        customTrack:Play(0.05, 1, 1.25)
                    end
                end
            end
        end)
    end
end

if LocalPlayer.Character then
    HookFlowstateCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(HookFlowstateCharacter)

-- Loop Pengawas (Heartbeat): Enforce Atribut Fast Vault 1.1 & Pre-empt Anti-Slow Vault
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    if State.FastVault then
        local myTeam = LocalPlayer.Team
        local teamName = myTeam and myTeam.Name or ""
        local isSurvivor = (teamName == "Survivors" or teamName == "Survivor" or teamName ~= "Killer")

        -- Target kecepatan: Survivor = 1.1 (Sesuai spesifikasi Flowstate) | Killer = 1.45
        local targetSpeed = isSurvivor and 1.1 or 1.45

        -- Paksa terus atribut vaultspeed ke targetSpeed (1.1) jika game mencoba meresetnya
        if char:GetAttribute("vaultspeed") ~= targetSpeed then
            char:SetAttribute("vaultspeed", targetSpeed)
        end
        if char:GetAttribute("fastvault") ~= true then
            char:SetAttribute("fastvault", true)
        end

        -- Deteksi kondisi Sprinting (LeftShift / RightShift ditekan atau AutoRun aktif)
        local isSprinting = State.AutoRun 
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) 
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

        -- Jika sedang sprinting, pre-empt status agar server selalu menganggap survivor memenuhi kualifikasi fast vault
        if isSprinting then
            if char:GetAttribute("sprinting") ~= true then
                char:SetAttribute("sprinting", true)
            end
            if char:GetAttribute("blocked") == true then
                char:SetAttribute("blocked", false)
            end
        end
    else
        -- Kembalikan atribut ke normal jika fitur dimatikan
        if char:GetAttribute("vaultspeed") ~= 1 and char:GetAttribute("vaultspeed") ~= nil then
            char:SetAttribute("vaultspeed", 1)
        end
        if char:GetAttribute("fastvault") == true then
            char:SetAttribute("fastvault", false)
        end
    end
end)

    -- Monitor saat NoClip dimatikan (Background Task)
    task.spawn(function()
        local lastState = State.Movement.NoClip
        while task.wait(0.1) do
            if lastState == true and State.Movement.NoClip == false then
                resetCollision()
            end
            lastState = State.Movement.NoClip
        end
    end)
    end

--=====================================================
-- LOGIC: FLIGHT SYSTEM (EMPEROR / GOD MODE WASD)
--=====================================================
do
local flyBV, flyBG = nil, nil
local flyAnimTrack = nil
UserInputService = game:GetService("UserInputService")

-- ID Animasi Melayang (Bisa lu ganti kalau punya ID pose dewa lain)
local EMPEROR_ANIM_ID = "rbxassetid://3137836269" 
-- Opsi ID lain kalau mau nyoba pose berbeda: "rbxassetid://8563914515" atau "rbxassetid://10860555615"

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    local isFlying = State.Movement.FlyEnabled or State.Movement.IsCurrentlyFlying

    if not (isFlying and hrp and hum) then 
        -- Bersihkan semua efek saat Fly dimatikan
        if flyBV then flyBV:Destroy(); flyBV = nil end
        if flyBG then flyBG:Destroy(); flyBG = nil end
        if flyAnimTrack then 
            flyAnimTrack:Stop() 
            flyAnimTrack:Destroy()
            flyAnimTrack = nil 
        end
        if hum then 
            hum.AutoRotate = true 
            hum.PlatformStand = false 
        end
        return 
    end

    -- Setup Fisika & Animasi (Hanya dieksekusi sekali pas baru nyala)
    if not flyBV then
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9000

        -- ✨ MAGIC: LOAD ANIMASI DEWA ✨
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator and not flyAnimTrack then
            local anim = Instance.new("Animation")
            anim.AnimationId = EMPEROR_ANIM_ID
            flyAnimTrack = animator:LoadAnimation(anim)
            flyAnimTrack.Priority = Enum.AnimationPriority.Action4 -- Paksa numpuk animasi lain
            flyAnimTrack.Looped = true
            flyAnimTrack:Play()
            flyAnimTrack:AdjustSpeed(0.2) -- Bikin gerakannya slow-mo biar auranya kerasa
        end
    end

    -- Bikin karakter kaku biar animasi dewa-nya berjalan mulus
    hum.AutoRotate = false
    hum.PlatformStand = true 

    -- 🔥 FIX MOBILE: Gunakan MoveDirection (Membaca Joystick HP dan WASD PC)
    local moveDir = hum.MoveDirection
    
    if moveDir.Magnitude > 0 then
        flyBV.Velocity = moveDir * (State.Movement.FlySpeed or 50)
    else
        flyBV.Velocity = Vector3.zero
    end

    -- Fix Spinbot: Kunci badan menghadap lurus ke depan kamera secara stabil
    local cam = workspace.CurrentCamera
    local camLook = cam.CFrame.LookVector
    local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
    
    if flatLook.Magnitude > 0 then
        -- Gunakan CFrame.lookAt agar tidak error / spinbot
        flyBG.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flatLook)
    end
end)

-- Bersihkan jika mati/respawn
LocalPlayer.CharacterAdded:Connect(function()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyAnimTrack then flyAnimTrack:Stop(); flyAnimTrack:Destroy(); flyAnimTrack = nil end
end)
end

--=====================================================
-- MISC SHIELD SYSTEM LOGIC
--=====================================================

-- 1. ANTI AFK
LocalPlayer.Idled:Connect(function()
    if State.Misc.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

-- 2. ANTI ADMIN (Detection - UserID Based)
do
local AdminUserIDs = {
    [239360597] = true, [46285306] = true, [739618054] = true, [1731111957] = true,
    [271036866] = true, [4069187142] = true, [2579663690] = true, [3435625601] = true,
    [1076732745] = true, [115342213] = true, [1806115340] = true, [396125889] = true,
    [1500845039] = true, [1260363902] = true, [566513703] = true, [1243527439] = true,
    [194122127] = true, [2377987690] = true, [119799297] = true, [204813847] = true,
    [410062232] = true, [16644591] = true
}

local function CheckAdmin(plr)
    if State.Misc.AntiAdmin then
        -- Cek berdasarkan UserID Admin Violence District atau indikasi nama mencurigakan
        if AdminUserIDs[plr.UserId] or plr.Name:lower():find("admin") or plr.Name:lower():find("mod") then
            LocalPlayer:Kick("\n[Shield System]\nViolence District Admin/Moderator Detected: " .. plr.Name)
        end
    end
end

-- Deteksi admin jika mereka masuk ke server setelah kamu
Players.PlayerAdded:Connect(CheckAdmin)

-- Loop pengecekan pemain yang sudah ada di server (Aktif jika kamu menyalakan toggle telat)
task.spawn(function()
    while task.wait(5) do
        if State.Misc.AntiAdmin then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    CheckAdmin(plr)
                end
            end
        end
    end
end)
end

-- 3. ANTI FLING & TOUCH FLING LOOP
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not root or not hum then return end

    -- FIX: Tambahkan pengecekan State.Misc agar tidak nil
    if State.Misc.AntiFling then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                pcall(function() -- Tambahkan pcall agar tidak error jika part player lain hilang mendadak
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Velocity = Vector3.new(0,0,0)
                            part.RotVelocity = Vector3.new(0,0,0)
                        end
                    end
                end)
            end
        end
    end
    
    -- TOUCH FLING
    if State.Misc.TouchFling then
        local oldV = root.Velocity
        root.Velocity = Vector3.new(20000, 40000, 20000)
        RunService.RenderStepped:Wait()
        root.Velocity = oldV
    end

    -- RESET PHYSICS (Jika TouchFling mati)
    if not State.Misc.TouchFling then
        if root.Velocity.Magnitude > 1000 then
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end      
end)

--=====================================================
-- LOGIC: POTATO MODE (GOD-TIER FPS BOOST)
--=====================================================
-- Kita pakai task.spawn biar loop ini jalan di background nungguin tombol ditekan
task.spawn(function()
    while task.wait(1) do
        if State.PotatoMode == true then
            -- Langsung ubah ke "Done" biar script ga nge-loop ngeksekusi ini berkali-kali
            State.PotatoMode = "Done" 
            
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace:FindFirstChildOfClass("Terrain")
            
            -- 1. BANTAI LIGHTING & SHADOWS
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            
            if sethiddenproperty then
                pcall(function() sethiddenproperty(Lighting, "Technology", 2) end)
            end
            
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                    v.Enabled = false
                end
            end
            
            -- 2. RATAKAN AIR & TERRAIN
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 0
                if sethiddenproperty then
                    pcall(function() sethiddenproperty(Terrain, "Decoration", false) end)
                end
            end
            
            -- 3. THE ULTIMATE TEXTURE KILLER
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1 
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
            
            -- 4. PENJAGA GERBANG (Otomatis ratakan objek baru)
            workspace.DescendantAdded:Connect(function(obj)
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.CastShadow = false
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end)
            
        end
    end
end)

    -- ==========================================
    -- Fungsi Efek Bayangan (Afterimages)
    -- ==========================================
    local function CreateAfterimages(char, duration)
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local visualFolder = Workspace:FindFirstChild("DashVisuals")
        if not visualFolder then
            visualFolder = Instance.new("Folder")
            visualFolder.Name = "DashVisuals"
            visualFolder.Parent = Workspace
        end

        local startTime = os.clock()
        -- Loop selama durasi dash buat bikin bayangan setiap beberapa detik
        task.spawn(function()
            while os.clock() - startTime < duration do
                if not char:FindFirstChild("HumanoidRootPart") then break end
                
                -- Bikin model baru buat bayangan
                local shadowModel = Instance.new("Model")
                shadowModel.Name = "Shadow"
                shadowModel.Parent = visualFolder

                -- Copy semua BasePart yang ada di karakter (Tangan, Kaki, Torso, Head)
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        local clone = part:Clone()
                        clone.Anchored = true
                        clone.CanCollide = false
                        -- Set warna bayangan (biru pudar biar estetik kayak chakra)
                        clone.Color = Color3.fromRGB(100, 150, 255)
                        clone.Material = Enum.Material.Neon
                        clone.Transparency = 0.6
                        clone.Parent = shadowModel
                        
                        -- Hapus Attachment/Script kalau ada yang ikut ter-clone
                        for _, child in pairs(clone:GetChildren()) do
                            if child:IsA("Attachment") or child:IsA("Script") then
                                child:Destroy()
                            end
                        end
                    end
                end
                
                -- Posisikan model bayangan di lokasi karakter saat ini
                local cframe, size = char:GetBoundingBox()
                shadowModel:MoveTo(cframe.p)

                -- Hapus model bayangan setelah pudar
                task.delay(0.15, function() -- Bayangan bertahan 0.15 detik
                    if shadowModel then
                        -- Efek pudarnya
                        for _, p in pairs(shadowModel:GetChildren()) do
                            if p:IsA("BasePart") then
                                p.Transparency = 1
                            end
                        end
                        task.wait(0.05)
                        shadowModel:Destroy()
                    end
                end)

                -- Jeda bikin bayangan berikutnya (makin kecil angkanya makin rapat bayangannya)
                task.wait(0.04) 
            end
        end)
    end
-- Loop untuk stop emote kalau player jalan/loncat
RunService.Heartbeat:Connect(function()
    local autoStop = true
    if State.AutoStopEmote ~= nil then autoStop = State.AutoStopEmote end

    if autoStop then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum and (currentTrack or currentSound) then
            if hum.MoveDirection.Magnitude > 0.1 or 
               hum:GetState() == Enum.HumanoidStateType.Jumping or 
               hum:GetState() == Enum.HumanoidStateType.Freefall then
                _G.stopEmote()
            end
        end
    end
end)

--=====================================================
-- LISTENERS: EMOTE KEYBIND DYNAMIC
--=====================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- Pastikan toggle keybind emote-nya nyala
    if State.EmoteKeybind then
        -- Ambil tombol yang lu setel di UI (Kalau belum di-set, otomatis balik ke V)
        local emoteKeyName = (Library.Options and Library.Options.CustomEmoteKey and Library.Options.CustomEmoteKey.Value) or Enum.KeyCode.V.Name
        
        -- Cek apakah tombol yang ditekan sesuai sama yang di UI
        if input.KeyCode == Enum.KeyCode[emoteKeyName] then
            if State.SelectedEmote then
                _G.playCustomEmote(State.SelectedEmote)
            end
        end
    end
end)

-- =====================================================
-- 🔫 TWIST OF FATE & SILENT AIM V2 (ALL-IN-ONE)
-- =====================================================
do -- Scope isolasi agar variable tidak bocor ke global

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
Camera = Workspace.CurrentCamera

-- =====================================================
-- INTERNAL STATE
-- =====================================================
local ToF_Target       = nil   
local ToF_ShooterPos   = nil   
local ToF_IsAiming     = false 
  
-- =====================================================
-- 🔴 TARGET VISUALIZER & FOV CIRCLE (FIXED)
-- =====================================================
local visualFolder = CoreGui:FindFirstChild("VD_ToF_Folder")
if not visualFolder then
    visualFolder = Instance.new("Folder")
    visualFolder.Name = "VD_ToF_Folder"
    visualFolder.Parent = CoreGui
end

local ToF_Visualizer = visualFolder:FindFirstChild("AimSphere")
if not ToF_Visualizer then
    ToF_Visualizer = Instance.new("SphereHandleAdornment")
    ToF_Visualizer.Name = "AimSphere"
    ToF_Visualizer.Radius = 0.3 
    ToF_Visualizer.Color3 = Color3.fromRGB(166, 0, 0) 
    ToF_Visualizer.Transparency = 0.3
    ToF_Visualizer.AlwaysOnTop = true 
    ToF_Visualizer.ZIndex = 10
    ToF_Visualizer.Adornee = Workspace.Terrain 
    ToF_Visualizer.Parent = visualFolder
end

-- 🔥 FIX: Deklarasi FOVCircle menggunakan Drawing API 🔥
ToFFOVCircle = Drawing.new("Circle")
ToFFOVCircle.Color = Color3.fromRGB(255, 255, 255)
ToFFOVCircle.Thickness = 1.5
-- ToFFOVCircle.NumSides = 64 -- Invalid property in modern executors
ToFFOVCircle.Radius = 150
ToFFOVCircle.Transparency = 0.8
ToFFOVCircle.Filled = false
ToFFOVCircle.Visible = false

SpearFOVCircle = Drawing.new("Circle")
SpearFOVCircle.Color = Color3.fromRGB(255, 0, 0) -- Red for Spear
SpearFOVCircle.Thickness = 1.5
-- SpearFOVCircle.NumSides = 64 -- Invalid property in modern executors
SpearFOVCircle.Radius = 150
SpearFOVCircle.Transparency = 0.8
SpearFOVCircle.Filled = false
SpearFOVCircle.Visible = false

local SpearSnapLine = Drawing.new("Line")
SpearSnapLine.Color = Color3.fromRGB(180, 50, 255)
SpearSnapLine.Thickness = 1.5
SpearSnapLine.Transparency = 1
SpearSnapLine.Visible = false

local SpearTargetDot = Drawing.new("Circle")
SpearTargetDot.Color = Color3.fromRGB(255, 50, 50)
SpearTargetDot.Radius = 6
SpearTargetDot.Filled = true
SpearTargetDot.Visible = false

-- =====================================================
-- DETEKSI KLIK KANAN
-- =====================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
        ToF_IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        ToF_IsAiming = false
    end
end)

-- =====================================================
-- HELPER: ESTIMASI & PREDIKSI
-- =====================================================
local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result or (result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)) then
        return true
    end
    return false
end

local function PredictHitPosition(targetPart, shooterPos, bulletSpeed)
    local tPos = targetPart.Position
    local tVel = targetPart.AssemblyLinearVelocity
    if tVel.Magnitude < 0.5 then return tPos end
    
    local timeToHit = (tPos - shooterPos).Magnitude / bulletSpeed
    return tPos + (tVel * timeToHit)
end

-- =====================================================
-- RADAR & VISUALIZER LOOP
-- =====================================================
RunService.RenderStepped:Connect(function()
    local S = _G.SharedState or getgenv().State
    if not S then return end

    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    ToF_ShooterPos = Camera.CFrame.Position

    -- Update FOV Circle (Hanya bergantung pada toggle ShowFOV)
    if S.ShowFOV then
        ToFFOVCircle.Radius = S.SilentAimFOV or 150
        ToFFOVCircle.Position = UserInputService:GetMouseLocation()
        ToFFOVCircle.Visible = true
    else
        ToFFOVCircle.Visible = false
    end
    
    -- Update Spear FOV Circle
    if S.ShowSpearFOV then
        SpearFOVCircle.Radius = S.SpearFOVRadius or 150
        SpearFOVCircle.Position = UserInputService:GetMouseLocation()
        SpearFOVCircle.Visible = true
    else
        SpearFOVCircle.Visible = false
    end

    -- Matikan semua jika fitur ToF / Spear / Butcher OFF
    if not S.TwistOfFateAimbot and not S.ToFSilentAim and not S.SpearSilentAim and not S.ButcherSilentAim then
        ToF_Target = nil
        ToF_Visualizer.Visible = false
        if myHum then myHum.AutoRotate = true end
        SpearSnapLine.Visible = false
        return
    end

    -- Cari Target Menggunakan Camera Dot Product & Distance Prioritizer
    local bestPart = nil
    local bestScore = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    local camLook = Camera.CFrame.LookVector
    local camPos = Camera.CFrame.Position
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Head"))
    local myPos = myRoot and myRoot.Position or camPos

    -- Auto-detect tim musuh (kalau kita Killer, otomatis targetin Survivor)
    local myIsKiller = (LocalPlayer.Team and LocalPlayer.Team.Name == "Killer")
    local targetTeam = S.TargetTeam or "Killer"
    if myIsKiller then targetTeam = "Survivor" end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local pChar = plr.Character
        if not pChar then continue end

        local hum = pChar:FindFirstChildOfClass("Humanoid")
        local targetNode = pChar:FindFirstChild("UpperTorso") or pChar:FindFirstChild("LowerTorso") or pChar:FindFirstChild("Torso") or pChar:FindFirstChild("HumanoidRootPart")
        
        if not hum or not targetNode or hum.Health <= 0 then continue end

        local isEnemyKiller = (plr.Team and plr.Team.Name == "Killer")
        local validTeam = (targetTeam == "Killer" and isEnemyKiller) or (targetTeam == "Survivor" and not isEnemyKiller)

        if validTeam then
            local isVisible = IsVisible(targetNode)
            local canTarget = false
            
            if S.SpearSilentAim and (S.ThroughTheVeil or isVisible) then canTarget = true end
            if S.ButcherSilentAim and (not S.ButcherWallCheck or isVisible) then canTarget = true end
            if (S.TwistOfFateAimbot or S.ToFSilentAim) and (S.AimbotThroughWall or isVisible) then canTarget = true end
            
            if canTarget then
                -- Dot Product Camera Check: Hitung arah hadap kamera terhadap musuh
                local toEnemy = targetNode.Position - myPos
                local dist = toEnemy.Magnitude
                local dirToEnemy = toEnemy.Unit
                local dot = camLook:Dot(dirToEnemy)

                local screenPos, onScreen = Camera:WorldToViewportPoint(targetNode.Position)
                
                -- Khusus Killer (Spear & Butcher) menerapkan Dot Product Camera Check
                if S.SpearSilentAim or S.ButcherSilentAim then
                    local screenDist = 9999
                    if onScreen then
                        screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    else
                        screenDist = 2000 + (1 - math.max(dot, 0)) * 1000
                    end

                    -- Rumus Score cerdas: jarak layar + jarak studs
                    local score = screenDist + (dist * 0.5)

                    -- Penalti jika musuh berada di samping / belakang (dot < 0.1)
                    -- Silent aim TIDAK AKAN PERNAH membalik badan ke musuh di belakang!
                    if dot < 0.1 then
                        score = score + 5000
                    end

                    if score < bestScore then
                        bestScore = score
                        bestPart = targetNode
                    end
                else
                    -- Mode ToF / Normal Aimbot
                    if onScreen then
                        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        local currentFovRadius = S.SilentAimFOV or 150
                        if fovDist <= currentFovRadius then
                            if fovDist < bestScore then
                                bestScore = fovDist
                                bestPart = targetNode
                            end
                        end
                    end
                end
            end
        end
    end

    -- 2. Scan AFK / Survivor Bot di Workspace (Penambahan Fitur Lock Bot)
    if targetTeam == "Survivor" then
        local CollectionService = game:GetService("CollectionService")
        local botTargets = {}

        -- Kumpulkan bot dari CollectionService Tag & Workspace Attributes
        for _, botModel in ipairs(CollectionService:GetTagged("SurvivorBot")) do
            table.insert(botTargets, botModel)
        end
        for _, child in ipairs(workspace:GetChildren()) do
            if child:IsA("Model") and (child:GetAttribute("BotId") or child:GetAttribute("BotNetId")) then
                if not table.find(botTargets, child) then
                    table.insert(botTargets, child)
                end
            end
        end

        for _, botModel in ipairs(botTargets) do
            local hum = botModel:FindFirstChildOfClass("Humanoid")
            local targetNode = botModel:FindFirstChild("UpperTorso") or botModel:FindFirstChild("Head") or botModel.PrimaryPart
            
            if hum and targetNode and hum.Health > 0 then
                local isVisible = IsVisible(targetNode)
                local canTarget = false
                
                if S.SpearSilentAim and (S.ThroughTheVeil or isVisible) then canTarget = true end
                if S.ButcherSilentAim and (not S.ButcherWallCheck or isVisible) then canTarget = true end
                if (S.TwistOfFateAimbot or S.ToFSilentAim) and (S.AimbotThroughWall or isVisible) then canTarget = true end

                if canTarget then
                    local toEnemy = targetNode.Position - myPos
                    local dist = toEnemy.Magnitude
                    local dirToEnemy = toEnemy.Unit
                    local dot = camLook:Dot(dirToEnemy)
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetNode.Position)

                    if S.SpearSilentAim or S.ButcherSilentAim then
                        local screenDist = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude or (2000 + (1 - math.max(dot, 0)) * 1000)
                        local score = screenDist + (dist * 0.5)
                        if dot < 0.1 then score = score + 5000 end

                        if score < bestScore then
                            bestScore = score
                            bestPart = targetNode
                        end
                    else
                        if onScreen then
                            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if fovDist <= (S.SilentAimFOV or 150) and fovDist < bestScore then
                                bestScore = fovDist
                                bestPart = targetNode
                            end
                        end
                    end
                end
            end
        end
    end

    ToF_Target = bestPart

    -- Update Bola Merah & Visualizer Target
    if ToF_Target and (S.TwistOfFateAimbot or S.ToFSilentAim or S.SpearSilentAim or S.ButcherSilentAim) then
        ToF_Visualizer.CFrame = CFrame.new(ToF_Target.Position)
        ToF_Visualizer.Visible = true
        
        local isVeilActive = S.SpearSilentAim
        local isButcherActive = S.ButcherSilentAim

        if isVeilActive or isButcherActive then
            local screenPos, onScreen = Camera:WorldToViewportPoint(ToF_Target.Position)
            if onScreen then
                local shouldShowLine = false
                local shouldShowDot = false

                if isVeilActive then
                    if S.SnapLine then shouldShowLine = true end
                    if S.SpearShowTargetDot ~= false then shouldShowDot = true end
                end

                if isButcherActive then
                    if S.ButcherSnapLine ~= false then shouldShowLine = true end
                    if S.ButcherShowTargetDot ~= false then shouldShowDot = true end
                end

                if shouldShowLine then
                    SpearSnapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    SpearSnapLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    SpearSnapLine.Visible = true
                else
                    SpearSnapLine.Visible = false
                end

                if shouldShowDot then
                    SpearTargetDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                    SpearTargetDot.Visible = true
                else
                    SpearTargetDot.Visible = false
                end
            else
                SpearSnapLine.Visible = false
                SpearTargetDot.Visible = false
            end
        else
            SpearSnapLine.Visible = false
            SpearTargetDot.Visible = false
        end
    else
        ToF_Visualizer.Visible = false
        SpearSnapLine.Visible = false
        SpearTargetDot.Visible = false
    end

    -- Kunci Kamera (Hanya untuk Normal Aimbot)
    if S.TwistOfFateAimbot and ToF_IsAiming and ToF_Target and myHum then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myHum.AutoRotate = false 
            local targetBodyPos = Vector3.new(ToF_Target.Position.X, myRoot.Position.Y, ToF_Target.Position.Z)
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetBodyPos)
            
            local lookCFrame = CFrame.new(Camera.CFrame.Position, ToF_Target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookCFrame, 0.8)
        end
    else
        if myHum then myHum.AutoRotate = true end
    end
end)

--=====================================================
-- 3. THE ULTIMATE METATABLE HOOK
--=====================================================
--=====================================================
-- VEIL FLYING SPEAR TRACER (VEILSPEARPHASE FLIGHT - 100% GACOR)
--=====================================================
local function attachVeilFlightTracer(spearModel)
    if not spearModel then return end
    pcall(function()
        local S = _G.SharedState or getgenv().State or State
        if not (S and S.SpearTracer) then return end

        -- Ambil part utama dari proyektil tombak
        local primaryPart = spearModel.PrimaryPart or spearModel:FindFirstChild("HumanoidRootPart") or spearModel:FindFirstChildWhichIsA("BasePart")
        if not primaryPart then
            primaryPart = spearModel:WaitForChild("HumanoidRootPart", 0.5) or spearModel:FindFirstChildWhichIsA("BasePart")
        end
        if not primaryPart or primaryPart:FindFirstChild("VeilSpearTracer") then return end

        local tracerWidth = 0.6
        local att0 = Instance.new("Attachment")
        att0.Name = "TracerAtt0"
        att0.Position = Vector3.new(0, tracerWidth / 2, 0)
        att0.Parent = primaryPart

        local att1 = Instance.new("Attachment")
        att1.Name = "TracerAtt1"
        att1.Position = Vector3.new(0, -tracerWidth / 2, 0)
        att1.Parent = primaryPart

        -- Trail Neon Ungu yang terang dan tajam
        local trail = Instance.new("Trail")
        trail.Name = "VeilSpearTracer"
        trail.Attachment0 = att0
        trail.Attachment1 = att1
        trail.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 50, 255)),   -- Ungu Neon
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(220, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.7, 0.2),
            NumberSequenceKeypoint.new(1, 1)
        })
        trail.Lifetime = 1.5
        trail.LightEmission = 1
        trail.FaceCamera = true
        trail.Parent = primaryPart

        -- PAKSA AURA & BEAMS BAWAAN TOMBAK MENYALA WALAUPUN TANPA PASIF TEMBUS TEMBOK
        local aura = spearModel:FindFirstChild("Aura")
        if aura then
            for _, desc in ipairs(aura:GetDescendants()) do
                if desc:IsA("Beam") or desc:IsA("Trail") then
                    desc.Enabled = true
                    desc.Transparency = NumberSequence.new(0)
                elseif desc:IsA("ParticleEmitter") then
                    desc.Enabled = true
                end
            end
        end

        -- Hapus atau fadeout tracer saat tombak mengenai target atau mendarat
        spearModel:GetAttributeChangedSignal("VeilSpearPhase"):Connect(function()
            local phase = spearModel:GetAttribute("VeilSpearPhase")
            if phase == "hit" or phase == "impact" then
                task.delay(0.2, function()
                    if trail and trail.Parent then
                        trail.Enabled = false
                    end
                end)
            end
        end)
    end)
end

-- Deteksi instan saat tombak terbang (VeilSpearPhase == "flight") muncul di Workspace
workspace.ChildAdded:Connect(function(child)
    local S = _G.SharedState or getgenv().State or State
    if not (S and S.SpearTracer) then return end

    if child:IsA("Model") then
        task.wait()
        local phase = child:GetAttribute("VeilSpearPhase")
        local name = child.Name:lower()
        if phase == "flight" or name:find("spear") then
            attachVeilFlightTracer(child)
        end
    end
end)

-- Scan tombak yang mungkin sudah ada di workspace saat status flight
for _, child in ipairs(workspace:GetChildren()) do
    if child:IsA("Model") and child:GetAttribute("VeilSpearPhase") == "flight" then
        attachVeilFlightTracer(child)
    end
end

--=====================================================
-- 3. THE ULTIMATE METATABLE HOOK
--=====================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local S = _G.SharedState or getgenv().State

    if method == "FireServer" then
        local args = {...}
        local callerIsScript = not checkcaller()

        if callerIsScript and S then
            -- Ambil nama remote secara aman
            local ok, selfName = pcall(function() return self.Name end)
            if not ok then selfName = "" end
            local ok2, selfStr = pcall(tostring, self)
            if not ok2 then selfStr = "" end

            -- Bypass Anti-Cancel untuk Manual Self Heal
            if selfStr == "HealEvent" and _G.IsManualSelfHealing and args[2] == false then
                return -- Block game dari ngirim 'false' (cancel heal)
            end

            -- Bypass untuk SILENT AIM (Magic Bullet)
            if S.ToFSilentAim and ToF_Target then
                local targetPos = ToF_Target.Position

                -- Hook buat senjata normal yang pakai Remote "HitPart"
                if selfStr == "HitPart" then
                    args[1] = ToF_Target
                    args[2] = targetPos
                    local fire = self.FireServer
                    if fire then return fire(self, unpack(args)) end
                end

                -- Hook buat Twist of Fate Violence District
                if selfName == "Fire" and self.Parent and self.Parent.Name == "Twist of Fate" then
                    local shooterPos = Camera.CFrame.Position
                    local newDirection = (targetPos - shooterPos).Unit
                    args[2] = newDirection
                    local fire = self.FireServer
                    if fire then return fire(self, unpack(args)) end
                end
            end

            -- Hook buat Veil Spearthrow (Silent Aim - GACOR DYNAMIC AUTO-ARC)
            if selfName == "Spearthrow" and S.SpearSilentAim and ToF_Target then
                if typeof(args[1]) == "table" and args[1].Direction then
                    local targetEnemy = ToF_Target
                    local shooterPos = args[1].Origin or (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.Position)
                    
                    if targetEnemy and shooterPos then
                        local rawDiff = targetEnemy.Position - shooterPos
                        local dist = rawDiff.Magnitude

                        -- Dynamic Y Offset berdasarkan jarak:
                        local baseOffsetY = S.SpearTargetYOffset or -0.6
                        local maxOffsetY = S.SpearMaxTargetYOffset or -2.2
                        local scaleStart = S.SpearOffsetScaleStart or 120
                        local scaleEnd = S.SpearOffsetScaleEnd or 320
                        local dynamicYOffset = baseOffsetY
                        
                        if dist > scaleStart then
                            local t = math.min((dist - scaleStart) / math.max(scaleEnd - scaleStart, 1), 1.0)
                            dynamicYOffset = baseOffsetY + (maxOffsetY - baseOffsetY) * t
                        end

                        local targetPos = targetEnemy.Position + Vector3.new(0, dynamicYOffset, 0)
                        local diff = targetPos - shooterPos
                        dist = diff.Magnitude

                        -- Penentuan Mode Otomatis:
                        local isHighArc = false
                        local arcMode = S.SpearArcMode or "Auto"
                        local threshold = S.SpearHighArcThreshold or 120
                        if arcMode == "Auto" then
                            isHighArc = (dist > threshold)
                        elseif arcMode == "High" then
                            isHighArc = true
                        end

                        local v = S.SpearSpeed or 165
                        local g = S.SpearGravity or 98.1
                        local horizontalDiff = Vector3.new(diff.X, 0, diff.Z)
                        local dx = math.max(horizontalDiff.Magnitude, 1)
                        local dy = diff.Y
                        local v2 = v * v
                        local discriminant = (v2 * v2) - g * (g * (dx * dx) + 2 * dy * v2)

                        local theta = 0
                        local flightTime = dist / v

                        if discriminant >= 0 then
                            local root = math.sqrt(discriminant)
                            if isHighArc then
                                theta = math.atan((v2 + root) / (g * dx))
                                local vy = v * math.sin(theta)
                                flightTime = (vy + math.sqrt(math.max(0, vy * vy - 2 * g * dy))) / g
                            else
                                theta = math.atan((v2 - root) / (g * dx))
                                flightTime = dx / (v * math.cos(theta))
                            end
                        end

                        -- Prediksi Gerakan Musuh
                        local predictedPos = targetPos
                        if S.SpearSmartPrediction then
                            local vel = targetEnemy.AssemblyLinearVelocity or Vector3.zero
                            local horizontalVel = Vector3.new(vel.X, 0, vel.Z)
                            predictedPos = targetPos + (horizontalVel * flightTime)
                            diff = predictedPos - shooterPos
                            horizontalDiff = Vector3.new(diff.X, 0, diff.Z)
                            dx = math.max(horizontalDiff.Magnitude, 1)
                            dy = diff.Y
                            discriminant = (v2 * v2) - g * (g * (dx * dx) + 2 * dy * v2)
                        end

                        -- Arah Lemparan Final
                        local finalDirection = nil
                        if discriminant >= 0 then
                            local root = math.sqrt(discriminant)
                            if isHighArc then
                                theta = math.atan((v2 + root) / (g * dx))
                            else
                                theta = math.atan((v2 - root) / (g * dx))
                            end
                            local hUnit = horizontalDiff.Unit
                            finalDirection = ((hUnit * math.cos(theta)) + Vector3.new(0, math.sin(theta), 0)).Unit
                        else
                            local dropComp = 0.5 * g * (flightTime ^ 2)
                            finalDirection = (predictedPos + Vector3.new(0, dropComp, 0) - shooterPos).Unit
                        end

                        args[1].Direction = finalDirection
                        local fire = self.FireServer
                        if fire then return fire(self, unpack(args)) end
                    end
                end
            end

            -- Hook buat Butcher ChainThrow (Silent Aim)
            if selfName == "ChainThrow" and S.ButcherSilentAim and ToF_Target then
                if typeof(args[1]) == "Vector3" then
                    local shooterPos = Camera.CFrame.Position
                    if typeof(args[3]) == "table" and args[3].Origin then
                        shooterPos = args[3].Origin
                    end
                    local newDirection = (ToF_Target.Position - shooterPos).Unit
                    args[1] = newDirection
                    local fire = self.FireServer
                    if fire then return fire(self, unpack(args)) end
                end
            end
        end

        -- // FLOWSTATE (ANTI-SLOW VAULT) REMOTE INTERCEPTION & ENFORCEMENT
        if S and S.FastVault then
            -- Intersepsi VaultEvent: jika game memanggil VaultEvent dengan mode slow / medium, ubah menjadi "fast"
            if selfName == "VaultEvent" or selfStr == "VaultEvent" then
                if args[5] and args[5] ~= "fast" then
                    args[5] = "fast"
                end
                -- Pastikan argumen ke-2 (canVault / allowed) bernilai true
                if args[2] == false then
                    args[2] = true
                end
                -- Pre-empt panggil fastvault remote ke server
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                local windowFolder = remotes and remotes:FindFirstChild("Window")
                if windowFolder then
                    local fastvaultRemote = windowFolder:FindFirstChild("fastvault")
                    if fastvaultRemote and fastvaultRemote:IsA("RemoteEvent") then
                        pcall(function() fastvaultRemote:FireServer(LocalPlayer) end)
                    end
                end
            end
        end

        -- Untuk FireServer game lainnya (Lookscript CFrame, Replicator buffer, SpectateController, dsb):
        -- Kembalikan via oldNamecall dengan namecall method yang proper agar tipe argumen tidak error
        if setnamecallmethod then
            setnamecallmethod(method)
        end
        return oldNamecall(self, ...)
    end

    if setnamecallmethod then
        setnamecallmethod(method)
    end
    return oldNamecall(self, ...)
end))
end


--=====================================================
-- KILLER ATTACK LOGIC (Infinite Lunge & Double Swing)
--=====================================================
do
    local lastClickTime = 0

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local S = _G.SharedState or getgenv().State
            if not S then return end

            local char = LocalPlayer.Character
            if not char then return end

            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end

            -- Double Swing Logic (Double Tap to swing 2x)
            if S.DoubleSwing then
                local now = tick()
                if (now - lastClickTime) < 0.4 then
                    -- Trigger additional swings
                    task.spawn(function()
                        tool:Activate()
                        task.wait(0.05)
                        tool:Activate()
                    end)
                end
                lastClickTime = now
            end
        end
    end)

    -- Infinite Lunge Logic (Endless attacks)
    task.spawn(function()
        while task.wait(0.1) do
            local S = _G.SharedState or getgenv().State
            if S and S.InfiniteLunge then
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end
        end
    end)
end

-- Streamer Mode Logic
task.spawn(function()
    while task.wait(0.2) do
        local S = _G.SharedState or getgenv().State or State
        if S and S.StreamerMode and S.StreamerMode.HideUsername then
            pcall(function()
                local lp = game:GetService("Players").LocalPlayer
                local pGui = lp:FindFirstChild("PlayerGui")
                if pGui then
                    local spectator = pGui:FindFirstChild("Spectator")
                    if spectator then
                        local info = spectator:FindFirstChild("Info")
                        if info then
                            -- Hide 'Your' Username
                            local your = info:FindFirstChild("Your")
                            if your and your:FindFirstChild("Username") then
                                if your.Username.Text ~= "BOYFINITY" then
                                    your.Username.Text = "BOYFINITY"
                                end
                            end
                            
                            -- Hide Leaderboard Usernames
                            local lbMain = info:FindFirstChild("Leaderboard")
                            if lbMain then
                                local lbContainer = lbMain:FindFirstChild("Leaderboard")
                                if lbContainer then
                                    for _, frame in pairs(lbContainer:GetChildren()) do
                                        -- Semua frame daftar pemain di leaderboard akan diubah namanya
                                        if frame:IsA("Frame") and frame:FindFirstChild("Username") then
                                            if frame.Username.Text ~= "BOYFINITY" then
                                                frame.Username.Text = "BOYFINITY"
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)




--=====================================================
-- INVISCAM & ANTI-SMOOTH INSTANT MAX ZOOM CONTROLLER
--=====================================================
do
    local lp = game:GetService("Players").LocalPlayer
    local rs = game:GetService("RunService")
    local cam = workspace.CurrentCamera or workspace:WaitForChild("Camera", 5)

    -- 1. InvisCam Logic
    local invisConn = nil
    _G.SetInvisCam = function(enable)
        if enable then
            lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            if not invisConn then
                invisConn = lp:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
                    local S = _G.SharedState or getgenv().State or State
                    if S and S.InvisCam and lp.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
                        lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                    end
                end)
            end
        else
            if invisConn then
                invisConn:Disconnect()
                invisConn = nil
            end
            lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        end
    end

    -- 2. Safe Zoom Controller (Tanpa merusak script Camera resetter / SmoothCamera game)
    local zoomMaxConn = nil
    local zoomMinConn = nil

    _G.ApplyMaxZoomDistance = function(targetZoom)
        local S = _G.SharedState or getgenv().State or State
        -- Guard: jangan apply kalau fitur belum diaktifkan
        if not (S and S.AntiSmoothZoom) then return end
        targetZoom = targetZoom or 25
        lp.CameraMaxZoomDistance = targetZoom
        lp.CameraMinZoomDistance = targetZoom
        task.delay(0.1, function()
            local S2 = _G.SharedState or getgenv().State or State
            if S2 and S2.AntiSmoothZoom then
                lp.CameraMinZoomDistance = 0.5
                lp.CameraMaxZoomDistance = targetZoom
            end
        end)
    end

    _G.SetAntiSmoothZoom = function(enable)
        local S = _G.SharedState or getgenv().State or State
        local targetZoom = (S and S.ZoomDistance) or 25
        if enable then
            _G.ApplyMaxZoomDistance(targetZoom)

            if not zoomMaxConn then
                zoomMaxConn = lp:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(function()
                    local S2 = _G.SharedState or getgenv().State or State
                    if S2 and S2.AntiSmoothZoom and lp.CameraMaxZoomDistance < (S2.ZoomDistance or 25) then
                        lp.CameraMaxZoomDistance = S2.ZoomDistance or 25
                    end
                end)
            end

            if not zoomMinConn then
                zoomMinConn = lp:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(function()
                    local S2 = _G.SharedState or getgenv().State or State
                    if S2 and S2.AntiSmoothZoom and lp.CameraMinZoomDistance > 0.5 then
                        lp.CameraMinZoomDistance = 0.5
                    end
                end)
            end
        else
            if zoomMaxConn then zoomMaxConn:Disconnect(); zoomMaxConn = nil end
            if zoomMinConn then zoomMinConn:Disconnect(); zoomMinConn = nil end
            -- Jangan set zoom saat disable - biarkan SmoothCamera/Camera resetter game yang mengatur
            -- (Killer butuh 6/6, Survivor butuh 8/30 - jangan dioverride)
        end
    end

    -- Auto re-apply saat respawn
    lp.CharacterAdded:Connect(function()
        task.wait(0.3)
        local S = _G.SharedState or getgenv().State or State
        if S and S.AntiSmoothZoom then
            _G.ApplyMaxZoomDistance(S.ZoomDistance or 25)
        end
        if S and S.InvisCam then
            lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        end
    end)
end
