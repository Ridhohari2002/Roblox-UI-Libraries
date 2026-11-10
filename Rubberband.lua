local players = game:GetService('Players')
local lplr = players.LocalPlayer
local lastCF, stop, heartbeatConnection
local function start()
    heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
        -- Cek _G override dari Teleportcharacter handler di main script
        if _G.AntiRubberStop or stop then
            return 
        end
        -- Jika main script menangkap posisi match baru, pakai itu
        if _G.AntiRubberLastCF then
            lastCF = _G.AntiRubberLastCF
            _G.AntiRubberLastCF = nil
        end
        lastCF = lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame
    end)
    lplr.Character:FindFirstChildOfClass('Humanoid').RootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
        if _G.AntiRubberStop or stop then return end
        stop = true
        lplr.Character:FindFirstChildOfClass('Humanoid').RootPart.CFrame = lastCF
        game:GetService('RunService').Heartbeat:Wait()
        stop = false
    end)    
    lplr.Character:FindFirstChildOfClass('Humanoid').Died:Connect(function()
        heartbeatConnection:Disconnect()
    end)
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

if lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid') and lplr.Character:FindFirstChildOfClass('Humanoid').RootPart then
    start()
end
