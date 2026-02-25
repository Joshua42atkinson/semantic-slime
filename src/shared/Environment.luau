--!strict
--[[
    Environment Configuration
    
    Provides runtime environment detection and secure API key access.
    NEVER hardcode API keys in source files - use ServerStorage in production.
]]

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Environment = {}

-- Runtime detection
Environment.IsStudio = RunService:IsStudio()
Environment.IsServer = RunService:IsServer()
Environment.IsClient = RunService:IsClient()
Environment.IsRunning = RunService:IsRunning()

-- Environment type
Environment.IsProduction = not Environment.IsStudio
Environment.IsDevelopment = Environment.IsStudio

-- Feature flags (adjust based on environment)
Environment.Features = {
	EnableAI = Environment.IsStudio, -- AI features in studio for testing
	EnableDebugCommands = Environment.IsStudio,
	EnableProfiling = Environment.IsStudio,
	EnableAnalytics = not Environment.IsStudio,
}

-- Debug mode
Environment.DebugMode = Environment.IsStudio
Environment.LogLevel = if Environment.IsStudio then "Debug" else "Info"

--[[
    Get an API key securely from ServerStorage
    
    In production:
    1. Create a StringValue in ServerStorage named "{Name}APIKey"
    2. Set the value to your actual API key
    3. Never commit API keys to git!
    
    In development:
    - Returns a placeholder that won't work (safe)
    - Or set up dev keys in ServerStorage manually
]]
function Environment.GetAPIKey(name: string): string?
	if not Environment.IsServer then
		warn("API keys can only be accessed on the server")
		return nil
	end

	local keyName = name .. "APIKey"
	local key = ServerStorage:FindFirstChild(keyName)

	if key and key:IsA("StringValue") then
		return key.Value
	end

	if Environment.IsStudio then
		-- In studio, check for a dev keys folder
		local devKeys = ServerStorage:FindFirstChild("DevAPIKeys")
		if devKeys then
			local devKey = devKeys:FindFirstChild(name)
			if devKey and devKey:IsA("StringValue") then
				return devKey.Value
			end
		end
		warn(string.format("API key '%s' not found in ServerStorage. Create a StringValue named '%s'", name, keyName))
	else
		warn(string.format("API key '%s' not configured in production", name))
	end

	return nil
end

--[[
    Get a configuration value with environment-aware defaults
]]
function Environment.GetConfig<T>(name: string, defaultValue: T): T
	local config = ServerStorage:FindFirstChild("GameConfig")
	if config then
		local value = config:FindFirstChild(name)
		if value then
			if value:IsA("StringValue") then
				return value.Value :: any
			elseif value:IsA("NumberValue") then
				return value.Value :: any
			elseif value:IsA("BoolValue") then
				return value.Value :: any
			end
		end
	end
	return defaultValue
end

--[[
    Log a message if debug mode is enabled
]]
function Environment.DebugLog(message: string, ...: any)
	if Environment.DebugMode then
		print("[DEBUG]", message, ...)
	end
end

--[[
    Log a warning in development only
]]
function Environment.DevWarn(message: string, ...: any)
	if Environment.IsDevelopment then
		warn("[DEV]", message, ...)
	end
end

return Environment