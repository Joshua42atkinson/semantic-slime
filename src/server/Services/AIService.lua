--!strict
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

--[=[
    @class AIService
    Handles all communication with Google Gemini API.
    
    Security Note:
    API Keys should effectively be pulled from a secure source or environment variable.
    For this implementation, we expect a StringValue in ServerStorage named "GeminiAPIKey".
]=]
local AIService = Knit.CreateService {
    Name = "AIService",
    Client = {},
}

-- Config
local API_KEY = "YOUR_API_KEY_HERE"
local API_URL_BASE = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key="

local MOCK_MODE = false -- Set to true to avoid API calls during testing

function AIService:KnitStart()
    print("[AIService] Started.")
    
    -- Attempt to load key from ServerStorage if present
    local secret = ServerStorage:FindFirstChild("GeminiAPIKey")
    if secret and secret:IsA("StringValue") then
        API_KEY = secret.Value
        print("[AIService] Loaded API Key from ServerStorage.")
    else
        warn("[AIService] No API Key found in ServerStorage/GeminiAPIKey. Using placeholder.")
    end
end

--[=[
    @private
    Sends the raw HTTP request to Gemini.
]=]
function AIService:_requestGemini(systemInstruction: string, userPrompt: string)
    if not API_KEY or API_KEY == "YOUR_API_KEY_HERE" then
        if not MOCK_MODE then
            warn("[AIService] Invalid API Key. Call aborted.")
            return nil
        end
    end

    if MOCK_MODE then
        print("[AIService] Mock Mode active. Simulated call.")
        task.wait(0.5)
        return {
            candidates = {{
                content = {
                    parts = {{ text = "Mock Response: " .. userPrompt }}
                }
            }}
        }
    end

    local url = API_URL_BASE .. API_KEY
    
    local payload = {
        contents = {
            {
                role = "user",
                parts = {
                    { text = systemInstruction .. "\n\n" .. userPrompt }
                }
            }
        },
        generationConfig = {
            temperature = 0.9,
            maxOutputTokens = 1000,
        }
    }

    local success, response = pcall(function()
        local jsonData = HttpService:JSONEncode(payload)
        return HttpService:PostAsync(url, jsonData)
    end)

    if success then
        local decoded = HttpService:JSONDecode(response)
        if decoded.error then
            warn("[AIService] API Error: ", decoded.error.message)
            return nil
        end
        return decoded
    else
        warn("[AIService] HTTP Error: ", response)
        return nil
    end
end

--[=[
    Extracts the text from Gemini's JSON structure.
]=]
function AIService:_extractText(response: any): string
    if not response then return "" end
    
    if response.candidates and response.candidates[1] and 
       response.candidates[1].content and 
       response.candidates[1].content.parts then
        
        return response.candidates[1].content.parts[1].text
    end
    
    return ""
end

--[=[
    Generates a Quest Definition based on player profile.
    Returns a Table (parsed from JSON).
]=]
function AIService:GenerateQuest(playerProfile: any)
    local systemPrompt = [[
        You are the Game Master for a Fantasy RPG.
        Generate a Quest in JSON format.
        The JSON must have:
        {
            "title": "String",
            "description": "String (Narrative)",
            "objectives": [
                {"id": "obj1", "text": "Task description", "type": "talk|find|kill", "target": "String"}
            ],
            "rewards": {"xp": Number, "insight": Number}
        }
        Do not add Markdown formatting (like ```json). Just raw JSON.
    ]]
    
    local userPrompt = "Generate a 'Call to Adventure' quest for a level " .. (playerProfile.Level or 1) .. " hero."
    
    local response = self:_requestGemini(systemPrompt, userPrompt)
    local text = self:_extractText(response)
    
    -- Cleanup Markdown if present
    text = text:gsub("```json", ""):gsub("```", "")
    
    local success, questData = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    
    if success and questData.title then
        return questData
    else
        warn("[AIService] Failed to decode Quest JSON: ", text)
        -- Fallback Quest
        return {
            title = "The Silent Echo",
            description = "The spirits failed to communicate clearly. (AI Error)",
            objectives = {
                {id="fallback", text="Report this to the developer", type="talk", target="Dev"}
            },
            rewards = {xp = 10, insight = 0}
        }
    end
end

--[=[
    Chat with an NPC.
]=]
function AIService:Chat(npcId: string, message: string)
    local systemPrompt = "You are a village NPC in a fantasy world. Keep responses short (under 2 sentences)."
    local response = self:_requestGemini(systemPrompt, message)
    local text = self:_extractText(response)
    if text == "" then return "..." end
    return text
end

return AIService
