local players = game:GetService('Players')
local lplr = players.LocalPlayer
local lastCF, stop, heartbeatConnection

-- Variabel kontrol untuk bypass saat round start / teleport sah
local allowTeleport = false

local function start()
    heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
        if stop then
            return 
        end 
        
        local rootPart = lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid') and lplr.Character:FindFirstChildOfClass('Humanoid').RootPart
        if rootPart then
            -- FILTER DELTA > 35 STUDS: Jika perpindahan posisi lebih dari 35 studs (misal: teleport round start), 
            -- maka posisi terakhir di-update alih-alih di-rollback, sehingga tidak tertahan di lobby.
            if lastCF and (rootPart.Position - lastCF.Position).Magnitude > 35 then
                lastCF = rootPart.CFrame
                return
            end
            lastCF = rootPart.CFrame
        end
    end)
    
    local humanoid = lplr.Character:FindFirstChildOfClass('Humanoid')
    if humanoid and humanoid.RootPart then
        humanoid.RootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
            -- Jika sedang dalam status allowTeleport (round start), abaikan penguncian posisi
            if allowTeleport then
                return
            end

            stop = true
            lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame = lastCF
            game:GetService('RunService').Heartbeat:Wait()
            stop = false
        end)    
        
        humanoid.Died:Connect(function()
            if heartbeatConnection then
                heartbeatConnection:Disconnect()
            end
        end)
    end
end

lplr.CharacterAdded:Connect(function(character)
    repeat 
        game:GetService('RunService').Heartbeat:Wait() 
    until character:FindFirstChildOfClass('Humanoid')
    repeat 
        game:GetService('RunService').Heartbeat:Wait() 
    until character:FindFirstChildOfClass('Humanoid').RootPart
    start()
end)

lplr.CharacterRemoving:Connect(function()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
    end
end)

start()

-- LISTENER REMOTE / BINDABLE ROUND START GAME (Remotes.Game.Start & EnableScript)
-- Mendeteksi sinyal round start untuk membuka kunci posisi (allowTeleport = true) sementara
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Fungsi aman untuk mencari path Remote event
local function findRemote(parent, path)
    local current = parent
    for _, name in ipairs(path) do
        current = current and current:FindFirstChild(name)
    end
    return current
end

-- Listener untuk Remotes.Game.Start (bisa berupa RemoteEvent atau BindableEvent)
local gameStartRemote = findRemote(ReplicatedStorage, {"Remotes", "Game", "Start"}) or ReplicatedStorage:FindFirstChild("Start", true)
if gameStartRemote then
    local function onRoundStart()
        allowTeleport = true
        task.delay(1.5, function() -- Beri jeda waktu agar teleportasi map / round start selesai sempurna
            allowTeleport = false
            if lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid') and lplr.Character:FindFirstChildOfClass('Humanoid').RootPart then
                lastCF = lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame
            end
        end)
    end

    if gameStartRemote:IsA("RemoteEvent") then
        gameStartRemote.OnClientEvent:Connect(onRoundStart)
    elseif gameStartRemote:IsA("BindableEvent") then
        gameStartRemote.Event:Connect(onRoundStart)
    end
end

-- Listener untuk EnableScript (BindableEvent/RemoteEvent tambahan jika ada)
local enableScriptRemote = ReplicatedStorage:FindFirstChild("EnableScript", true)
if enableScriptRemote then
    local function onEnableScript()
        allowTeleport = true
        task.delay(1.5, function()
            allowTeleport = false
            if lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid') and lplr.Character:FindFirstChildOfClass('Humanoid').RootPart then
                lastCF = lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame
            end
        end)
    end

    if enableScriptRemote:IsA("RemoteEvent") then
        enableScriptRemote.OnClientEvent:Connect(onEnableScript)
    elseif enableScriptRemote:IsA("BindableEvent") then
        enableScriptRemote.Event:Connect(onEnableScript)
    end
end
