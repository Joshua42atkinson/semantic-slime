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
    Generates a Mad Lib template based on Jungian Archetype.
]=]
function AIService:GenerateMadLibQuest(archetype: string)
    local systemPrompt = string.format([[
        You are a storyteller for the "Semantic Slime" game.
        Generate a short Mad Lib template (1-2 sentences) in JSON format.
        The template MUST contain exactly 3-4 slot tags: {ADJECTIVE}, {VERB}, or {NOUN}.
        The story should reflect the Jungian archetype: %s.
        
        Keep it whimsical and educational.
        
        Output Format:
        {
            "title": "String",
            "template": "String with {SLOT} placeholders"
        }
        No markdown formatting.
    ]], archetype)
    
    local response = self:_requestGemini(systemPrompt, "Create a " .. archetype .. " story.")
    local text = self:_extractText(response)
    
    -- Cleanup Markdown if present
    text = text:gsub("```json", ""):gsub("```", "")
    
    local success, questData = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    
    if success and questData.template then
        return questData
    else
        warn("[AIService] Failed to decode MadLib Quest JSON: ", text)
        return nil
    end
end

--[=[
    Chat with an NPC.
]=]
function AIService:Chat(npcId: string, message: string)
    local LoreDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Master_Lore"):WaitForChild("LoreDB"))
    local npcData = LoreDB.NPCs[npcId]
    
    local role = npcData and npcData.Archetype or "The Wanderer"
    local district = npcData and npcData.District or "The Hub"
    local teaches = npcData and npcData.Teaches and table.concat(npcData.Teaches, ", ") or "nothing yet"

    local systemPrompt = string.format([[
        You are an NPC in the world of "Semantic Slime". 
        Your Identity: %s.
        Your District: %s.
        Your Teaching Domain: %s.
        
        This is a world where linguistics and Jungian psychology manifest as living matter.
        
        Guidelines:
        - Keep responses very short (1-2 sentences).
        - Ground your speech in your Jungian Archetype and your district's philosophy.
        - Use slightly academic but whimsical language (isomorphic to the project's pedagogy).
        - Treat the player as a "Seeker" or "Conductor" of meaning.
    ]], role, district, teaches)

    local response = self:_requestGemini(systemPrompt, message)
    local text = self:_extractText(response)
    if text == "" then return "..." end
    return text
end

return AIService
