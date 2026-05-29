--!strict
--==============================================================
-- CrashGuard.lua
-- Utility module for wrapping service/controller initialization
-- in pcall with structured logging, timestamps, and memory tracking.
-- Use this to diagnose crashes during boot or runtime.
--==============================================================

local CrashGuard = {}

-- Memory tracking
function CrashGuard.GetMemoryKB(): number
	-- gcinfo() returns KB used by Lua
	return gcinfo()
end

-- Structured log with timestamp and memory
function CrashGuard.Log(tag: string, message: string)
	local mem = CrashGuard.GetMemoryKB()
	local timestamp = string.format("%.2f", tick() % 10000)
	print(string.format("[%s] [%ss] [%dKB] %s", tag, timestamp, mem, message))
end

-- Warning log
function CrashGuard.Warn(tag: string, message: string)
	local mem = CrashGuard.GetMemoryKB()
	local timestamp = string.format("%.2f", tick() % 10000)
	warn(string.format("[%s] [%ss] [%dKB] ⚠ %s", tag, timestamp, mem, message))
end

-- Error log
function CrashGuard.Error(tag: string, message: string)
	local mem = CrashGuard.GetMemoryKB()
	local timestamp = string.format("%.2f", tick() % 10000)
	warn(string.format("[%s] [%ss] [%dKB] ❌ %s", tag, timestamp, mem, message))
end

-- Wrap a function in pcall with logging
-- Returns: success (bool), result (any)
function CrashGuard.SafeCall(tag: string, description: string, fn: () -> any): (boolean, any)
	CrashGuard.Log(tag, "Starting: " .. description)
	local startMem = CrashGuard.GetMemoryKB()
	
	local ok, result = pcall(fn)
	
	local endMem = CrashGuard.GetMemoryKB()
	local memDelta = endMem - startMem
	
	if ok then
		CrashGuard.Log(tag, string.format("✅ Done: %s (Δmem: %+dKB)", description, memDelta))
	else
		CrashGuard.Error(tag, string.format("FAILED: %s — %s (Δmem: %+dKB)", description, tostring(result), memDelta))
	end
	
	return ok, result
end

-- Wrap a require() call with crash protection
function CrashGuard.SafeRequire(tag: string, module: ModuleScript): (boolean, any)
	return CrashGuard.SafeCall(tag, "require(" .. module.Name .. ")", function()
		return require(module)
	end)
end

-- Log a boot stage summary
function CrashGuard.BootStage(stageName: string, stageNumber: number, totalStages: number)
	local mem = CrashGuard.GetMemoryKB()
	print(string.format(
		"[Boot] ━━━ Stage %d/%d: %s ━━━ [%dKB]",
		stageNumber, totalStages, stageName, mem
	))
end

-- Log a final boot report
function CrashGuard.BootReport(loaded: number, failed: number, failedNames: {string})
	local mem = CrashGuard.GetMemoryKB()
	print("[Boot] ════════════════════════════════════════")
	print(string.format("[Boot] BOOT COMPLETE — %d loaded, %d failed, %dKB memory", loaded, failed, mem))
	if failed > 0 then
		warn(string.format("[Boot] Failed: %s", table.concat(failedNames, ", ")))
	end
	print("[Boot] ════════════════════════════════════════")
end

return CrashGuard
