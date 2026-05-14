--!strict
-- AmbientController: coordinates district ambient audio/VFX/prop states

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local EnvironmentConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EnvironmentConfig"))

local AMBIENT_FOLDER_NAME = "AmbientLayers"
local PROXIMITY_CHECK_INTERVAL = 1

local AmbientController = Knit.CreateService {
    Name = "AmbientController",
    Client = {
        AmbientCue = Knit.CreateSignal(),
        EnvironmentStateChanged = Knit.CreateSignal(),
    },
}

type AmbientLayer = EnvironmentConfig.AmbientLayer

local ambientFolder: Folder
local districtInstances: {[string]: Folder} = {}
local activeEvents: {[string]: number} = {}

local function ensureAmbientFolder(): Folder
    local folder = Workspace:FindFirstChild(AMBIENT_FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = AMBIENT_FOLDER_NAME
        folder.Parent = Workspace
    end
    return folder
end

local function createLayerInstance(districtFolder: Folder, layer: AmbientLayer)
    if layer.Type == "Audio" then
        local sound = Instance.new("Sound")
        sound.Name = layer.Id
        sound.SoundId = layer.AssetId or ""
        sound.Looped = true
        sound.Volume = layer.Intensity or 0.5
        sound.Parent = districtFolder
        if layer.Trigger == "AlwaysOn" then
            sound:Play()
        end
    elseif layer.Type == "VFX" then
        local particle = Instance.new("ParticleEmitter")
        particle.Name = layer.Id
        particle.Texture = layer.AssetId or ""
        particle.Rate = math.floor((layer.Intensity or 1) * 10)
        particle.Parent = districtFolder
        particle.Enabled = layer.Trigger == "AlwaysOn"
    else
        local prop = Instance.new("Part")
        prop.Name = layer.Id
        prop.Anchored = true
        prop.CanCollide = false
        prop.Transparency = 1
        prop.Size = layer.Size or Vector3.new(1, 1, 1)
        prop.CFrame = CFrame.new(districtFolder:GetAttribute("Origin") or Vector3.new())
        prop.Parent = districtFolder
    end
end

local function bootstrapDistricts()
    for name, district in pairs(EnvironmentConfig.Districts) do
        local folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = ambientFolder
        folder:SetAttribute("Origin", district.Position)
        districtInstances[name] = folder

        for _, layer in ipairs(district.AmbientLayers) do
            createLayerInstance(folder, layer)
        end
    end
end

local function triggerLayer(districtName: string, layerId: string?, enabled: boolean)
    if not layerId or layerId == "" then return end
    local folder = districtInstances[districtName]
    if not folder then return end
    local instance = folder:FindFirstChild(layerId)
    if not instance then return end

    if instance:IsA("Sound") then
        if enabled and not instance.IsPlaying then
            instance:Play()
        elseif not enabled and instance.IsPlaying then
            instance:Stop()
        end
    elseif instance:IsA("ParticleEmitter") then
        instance.Enabled = enabled
    end
end

local function handleMicroEvents()
    for districtName, district in pairs(EnvironmentConfig.Districts) do
        for _, event in ipairs(district.MicroEvents) do
            task.spawn(function()
                while true do
                    task.wait(event.Interval)
                    local eventKey = districtName .. "_" .. event.Id
                    if activeEvents[eventKey] then
                        continue
                    end
                    activeEvents[eventKey] = os.clock()
                    triggerLayer(districtName, event.VFXCue, true)
                    AmbientController.Client.AmbientCue:FireAll(districtName, event)
                    task.delay(event.Duration, function()
                        triggerLayer(districtName, event.VFXCue, false)
                        activeEvents[eventKey] = nil
                    end)
                end
            end)
        end
    end
end

local function monitorProximity()
    RunService.Heartbeat:Connect(function(dt)
        local now = os.clock()
        if now % PROXIMITY_CHECK_INTERVAL > dt then
            return
        end
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            local primary = char and char.PrimaryPart
            if not primary then
                continue
            end
            for districtName, folder in pairs(districtInstances) do
                local origin = folder:GetAttribute("Origin") :: Vector3 or Vector3.new()
                local district = EnvironmentConfig.Districts[districtName]
                if (primary.Position - origin).Magnitude <= district.Radius then
                    for _, layer in ipairs(district.AmbientLayers) do
                        if layer.Trigger == "PlayerProximity" then
                            triggerLayer(districtName, layer.Id, true)
                            AmbientController.Client.AmbientCue:Fire(player, districtName, {
                                Id = layer.Id,
                                Description = "Proximity ambient cue",
                            })
                        end
                    end
                end
            end
        end
    end)
end

function AmbientController:TriggerAmbientEvent(districtName: string, eventId: string)
    local district = EnvironmentConfig.Districts[districtName]
    if not district then return end
    for _, macro in ipairs(district.MacroEvents) do
        if macro.Id == eventId then
            triggerLayer(districtName, macro.VFXCue, true)
            AmbientController.Client.AmbientCue:FireAll(districtName, macro)
            task.delay(10, function()
                triggerLayer(districtName, macro.VFXCue, false)
            end)
            break
        end
    end
end

function AmbientController:KnitStart()
    ambientFolder = ensureAmbientFolder()
    bootstrapDistricts()
    handleMicroEvents()
    monitorProximity()
    print("[AmbientController] Ambient systems initialized")
end

return AmbientController
