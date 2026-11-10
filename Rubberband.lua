local players = game:GetService('Players')
local lplr = players.LocalPlayer
local replicatedStorage = game:GetService('ReplicatedStorage')
local lastCF, stop, heartbeatConnection

local function isKillerChar()
    local myTeam = lplr.Team and lplr.Team.Name
    if myTeam == "Killer" or myTeam == "Slasher" then return true end
    if lplr:GetAttribute("SelectedKiller") ~= nil then return true end
    local c = lplr.Character
    if c and (c:GetAttribute("IsCarrying") ~= nil or c:GetAttribute("successswingendlag") ~= nil) then
        return true
    end
    return false
end

local function start()
    heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
        if stop or isKillerChar() then
            return 
        end 
        local hum = lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid')
        if hum and hum.RootPart then
            lastCF = hum.RootPart.CFrame
        end
    end)
    lplr.Character:FindFirstChildOfClass('Humanoid').RootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
        if stop or isKillerChar() or not lastCF then return end
        stop = true
        lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame = lastCF
        game:GetService('RunService').Heartbeat:Wait()
        stop = false
    end)    
    lplr.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end
    end)
end

-- KUNCI UTAMA: Tangkap event Teleportcharacter dari server
-- Begitu remote ini fire, langsung update lastCF ke targetCF teleportasi!
-- Dengan begitu, posisi lobby langsung tertimpa oleh posisi match baru.
task.spawn(function()
    local remotes = replicatedStorage:WaitForChild('Remotes', 10)
    local mechanics = remotes and remotes:WaitForChild('Mechanics', 10)
    local tpRemote = mechanics and mechanics:WaitForChild('Teleportcharacter', 10)
    
    if tpRemote and tpRemote:IsA('RemoteEvent') then
        tpRemote.OnClientEvent:Connect(function(targetCF, char)
            stop = true -- jeda sebentar agar CFrame listener tidak menimpa balik ke lobby
            if typeof(targetCF) == 'CFrame' then
                lastCF = targetCF -- langsung ganti lastCF ke posisi match!
            end
            task.wait(0.2)
            stop = false
        end)
    end
end)

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
