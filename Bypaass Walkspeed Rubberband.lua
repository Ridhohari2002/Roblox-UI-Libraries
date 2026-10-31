local players = game:GetService('Players')
local runService = game:GetService('RunService')
local lplr = players.LocalPlayer

local lastCF
local heartbeatConnection
local cframeConnection

local MAX_SAFE_DISTANCE = 5 

local function cleanup()
    if heartbeatConnection then heartbeatConnection:Disconnect(); heartbeatConnection = nil end
    if cframeConnection then cframeConnection:Disconnect(); cframeConnection = nil end
end

local function start()
    cleanup()
    
    local char = lplr.Character
    local hum = char:FindFirstChildOfClass('Humanoid')
    local rootPart = hum and hum.RootPart

    if not rootPart then return end

    lastCF = rootPart.CFrame

    -- Simpan posisi aman setiap frame
    heartbeatConnection = runService.Heartbeat:Connect(function()
        lastCF = rootPart.CFrame
    end)

    -- Pantau perubahan posisi
    cframeConnection = rootPart:GetPropertyChangedSignal('CFrame'):Connect(function()
        local currentCF = rootPart.CFrame
        local distance = (currentCF.Position - lastCF.Position).Magnitude

        -- Jika perubahan posisi melampaui batas (Server mencoba rubberband)
        if distance > MAX_SAFE_DISTANCE then
            -- Pause penyimpanan posisi
            heartbeatConnection:Disconnect()
            
            -- Lawan tarikan server, kembalikan ke posisi client yang aman
            rootPart.CFrame = lastCF
            
            -- Tunggu engine merender frame, lalu nyalakan kembali penyimpanannya
            runService.Heartbeat:Wait()
            
            heartbeatConnection = runService.Heartbeat:Connect(function()
                lastCF = rootPart.CFrame
            end)
        end
    end)

    hum.Died:Connect(cleanup)
end

lplr.CharacterAdded:Connect(function(character)
    repeat runService.Heartbeat:Wait() until character:FindFirstChildOfClass('Humanoid')
    repeat runService.Heartbeat:Wait() until character:FindFirstChildOfClass('Humanoid').RootPart
    start()
end)

lplr.CharacterRemoving:Connect(cleanup)

if lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid') and lplr.Character:FindFirstChildOfClass('Humanoid').RootPart then
    start()
end
