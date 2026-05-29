--!strict
-- Guild Service for Semantic Slime
-- Handles guild creation, management, and progression

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local GuildService = Knit.CreateService {
    Name = "GuildService",
    Client = {
        -- Guild events
        GuildCreated = Knit.CreateSignal(),
        GuildJoined = Knit.CreateSignal(),
        GuildLeft = Knit.CreateSignal(),
        GuildUpdated = Knit.CreateSignal(),
        GuildDisbanded = Knit.CreateSignal(),
        
        -- Member events
        MemberJoined = Knit.CreateSignal(),
        MemberLeft = Knit.CreateSignal(),
        MemberPromoted = Knit.CreateSignal(),
        MemberDemoted = Knit.CreateSignal(),
        
        -- Guild events
        GuildEventStarted = Knit.CreateSignal(),
        GuildEventCompleted = Knit.CreateSignal(),
        GuildRewardClaimed = Knit.CreateSignal(),
    },
}

-- Types
export type Guild = {
    Id: string,
    Name: string,
    Description: string,
    Emblem: string?,
    Motto: string?,
    OwnerId: number,
    Members: {[number]: GuildMember},
    CreatedAt: number,
    Level: number,
    Experience: number,
    Settings: GuildSettings,
    Vault: GuildVault,
    Events: {GuildEvent},
    Permissions: {[number]: GuildPermissions},
}

export type GuildMember = {
    UserId: number,
    Role: "Owner" | "Officer" | "Veteran" | "Member",
    JoinedAt: number,
    Contribution: number,
    LastActive: number,
    WeeklyContribution: number,
    Notes: string?,
}

export type GuildSettings = {
    IsPublic: boolean,
    RequireApproval: boolean,
    MinLevel: number,
    MaxMembers: number,
    AutoPromote: boolean,
    PromotionThreshold: number,
    AllowInvites: boolean,
    MemberRanking: boolean,
}

export type GuildVault = {
    Gold: number,
    Items: {GuildItem},
    LastDeposit: number,
    WeeklyDeposits: {[number]: number},
}

export type GuildItem = {
    Type: string,
    Id: string,
    Name: string,
    Quantity: number,
    DonatedBy: number,
    DonatedAt: number,
}

export type GuildEvent = {
    Id: string,
    Type: "Dungeon" | "Boss" | "Collection" | "Social",
    Name: string,
    Description: string,
    StartTime: number,
    EndTime: number,
    Participants: {number},
    Objectives: {GuildObjective},
    Rewards: GuildRewards,
    Status: "Planned" | "Active" | "Completed" | "Failed",
}

export type GuildObjective = {
    Type: string,
    Target: number,
    Current: number,
    Description: string,
}

export type GuildRewards = {
    Gold: number,
    Experience: number,
    Items: {string},
}

export type GuildPermissions = {
    CanInvite: boolean,
    CanKick: boolean,
    CanPromote: boolean,
    CanManageVault: boolean,
    CanCreateEvents: boolean,
    CanManageSettings: boolean,
    CanDisband: boolean,
}

-- Configuration
local MAX_GUILD_NAME_LENGTH = 30
local MIN_GUILD_NAME_LENGTH = 3
local MAX_GUILD_DESCRIPTION_LENGTH = 200
local MAX_GUILD_MEMBERS = 50
local GUILD_LEVEL_CAP = 100
local EXPERIENCE_PER_LEVEL = 1000
local GUILD_EVENT_DURATION = 3600 -- 1 hour
local GUILD_VAULT_LIMIT = 1000

-- Guild level requirements
local GUILD_LEVEL_REQUIREMENTS = {
    [1] = {RequiredExp = 0, MaxMembers = 10, VaultLimit = 100},
    [5] = {RequiredExp = 4000, MaxMembers = 20, VaultLimit = 250},
    [10] = {RequiredExp = 9000, MaxMembers = 30, VaultLimit = 500},
    [15] = {RequiredExp = 14000, MaxMembers = 40, VaultLimit = 750},
    [20] = {RequiredExp = 19000, MaxMembers = 50, VaultLimit = 1000},
    [25] = {RequiredExp = 24000, MaxMembers = 60, VaultLimit = 1500},
    [30] = {RequiredExp = 29000, MaxMembers = 70, VaultLimit = 2000},
    [40] = {RequiredExp = 39000, MaxMembers = 80, VaultLimit = 3000},
    [50] = {RequiredExp = 49000, MaxMembers = 100, VaultLimit = 5000},
}

-- Data stores (initialized lazily)
local guildDataStore = nil
local guildMemberDataStore = nil
local guildEventDataStore = nil

local function ensureDataStores()
    if guildDataStore then return true end
    local ok = pcall(function()
        guildDataStore = DataStoreService:GetDataStore("GuildData")
        guildMemberDataStore = DataStoreService:GetDataStore("GuildMembers")
        guildEventDataStore = DataStoreService:GetDataStore("GuildEvents")
    end)
    if not ok then
        warn("[GuildService] DataStore unavailable (publish place to enable)")
    end
    return ok
end

-- Private state
local guilds: {[string]: Guild} = {}
local playerGuilds: {[number]: string} = {}
local guildApplications: {[string]: {number}} = {}
local activeEvents: {[string]: GuildEvent} = {}

-- Private functions
local function generateId(): string
    return HttpService:GenerateGUID(false)
end

local function getGuildLevelRequirements(level: number): any
    -- Find the highest requirement level that's <= current level
    local highestLevel = 1
    for reqLevel, requirements in pairs(GUILD_LEVEL_REQUIREMENTS) do
        if reqLevel <= level and reqLevel > highestLevel then
            highestLevel = reqLevel
        end
    end
    return GUILD_LEVEL_REQUIREMENTS[highestLevel]
end

local function calculateGuildLevel(experience: number): number
    return math.min(math.floor(experience / EXPERIENCE_PER_LEVEL) + 1, GUILD_LEVEL_CAP)
end

local function getRolePermissions(role: string): GuildPermissions
    local permissions = {
        Owner = {
            CanInvite = true,
            CanKick = true,
            CanPromote = true,
            CanManageVault = true,
            CanCreateEvents = true,
            CanManageSettings = true,
            CanDisband = true,
        },
        Officer = {
            CanInvite = true,
            CanKick = true,
            CanPromote = false,
            CanManageVault = true,
            CanCreateEvents = true,
            CanManageSettings = false,
            CanDisband = false,
        },
        Veteran = {
            CanInvite = true,
            CanKick = false,
            CanPromote = false,
            CanManageVault = false,
            CanCreateEvents = false,
            CanManageSettings = false,
            CanDisband = false,
        },
        Member = {
            CanInvite = false,
            CanKick = false,
            CanPromote = false,
            CanManageVault = false,
            CanCreateEvents = false,
            CanManageSettings = false,
            CanDisband = false,
        },
    }
    
    return permissions[role] or permissions.Member
end

local function validateGuildName(name: string): boolean
    if type(name) ~= "string" then return false end
    if #name < MIN_GUILD_NAME_LENGTH or #name > MAX_GUILD_NAME_LENGTH then return false end
    
    -- Check for inappropriate content (basic validation)
    local bannedWords = {"admin", "moderator", "roblox", "official", "system"}
    local lowerName = name:lower()
    
    for _, word in ipairs(bannedWords) do
        if lowerName:find(word) then
            return false
        end
    end
    
    return true
end

local function updateGuildLevel(guild: Guild)
    local newLevel = calculateGuildLevel(guild.Experience)
    if newLevel ~= guild.Level then
        guild.Level = newLevel
        
        -- Update guild limits based on new level
        local requirements = getGuildLevelRequirements(newLevel)
        guild.Settings.MaxMembers = requirements.MaxMembers
        guild.Vault.Items = {} -- Reset vault items if limit decreased
        
        -- Notify members
        for userId, _ in pairs(guild.Members) do
            local player = Players:GetPlayerByUserId(userId)
            if player then
                self.Client.GuildUpdated:Fire(player, guild)
            end
        end
    end
end

local function addGuildExperience(guild: Guild, amount: number)
    guild.Experience += amount
    updateGuildLevel(guild)
    
    -- Save guild
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guild.Id, guild)
    end)
end

local function removeMember(guild: Guild, userId: number, reason: string?)
    local member = guild.Members[userId]
    if not member then return false end
    
    -- Remove from guild
    guild.Members[userId] = nil
    playerGuilds[userId] = nil
    
    -- Save changes
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guild.Id, guild)
        guildMemberDataStore:RemoveAsync("GuildMember_" .. userId)
    end)
    
    -- Notify remaining members
    for memberId, _ in pairs(guild.Members) do
        local player = Players:GetPlayerByUserId(memberId)
        if player then
            self.Client.MemberLeft:Fire(player, userId, reason)
        end
    end
    
    -- Notify removed member
    local removedPlayer = Players:GetPlayerByUserId(userId)
    if removedPlayer then
        self.Client.GuildLeft:Fire(removedPlayer, guild.Id)
    end
    
    return true
end

-- Public methods
function GuildService:CreateGuild(name: string, description: string, motto: string?): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    -- Validate input
    if not validateGuildName(name) then
        return false
    end
    
    if type(description) ~= "string" or #description > MAX_GUILD_DESCRIPTION_LENGTH then
        return false
    end
    
    -- Check if player is already in a guild
    if playerGuilds[player.UserId] then
        return false
    end
    
    -- Check player level requirement
    local success, playerLevel = pcall(function()
        local DataService = Knit.GetService("DataService")
        return DataService and DataService:GetPlayerLevel(player.UserId)
    end)
    
    if not success or (playerLevel and playerLevel < 5) then
        return false -- Minimum level 5 to create guild
    end
    
    -- Create guild
    local guildId = generateId()
    local guild: Guild = {
        Id = guildId,
        Name = name,
        Description = description,
        Emblem = nil,
        Motto = motto or "",
        OwnerId = player.UserId,
        Members = {},
        CreatedAt = os.time(),
        Level = 1,
        Experience = 0,
        Settings = {
            IsPublic = true,
            RequireApproval = false,
            MinLevel = 1,
            MaxMembers = 10,
            AutoPromote = false,
            PromotionThreshold = 1000,
            AllowInvites = true,
            MemberRanking = true,
        },
        Vault = {
            Gold = 0,
            Items = {},
            LastDeposit = os.time(),
            WeeklyDeposits = {},
        },
        Events = {},
        Permissions = {},
    }
    
    -- Add owner as first member
    guild.Members[player.UserId] = {
        UserId = player.UserId,
        Role = "Owner",
        JoinedAt = os.time(),
        Contribution = 0,
        LastActive = os.time(),
        WeeklyContribution = 0,
        Notes = "Guild Founder",
    }
    
    guild.Permissions[player.UserId] = getRolePermissions("Owner")
    
    -- Save guild
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guildId, guild)
        guildMemberDataStore:SetAsync("GuildMember_" .. player.UserId, guildId)
    end)
    
    -- Update tracking
    guilds[guildId] = guild
    playerGuilds[player.UserId] = guildId
    
    -- Notify player
    self.Client.GuildCreated:Fire(player, guild)
    
    return true
end

function GuildService:GetGuild(guildId: string): Guild?
    return guilds[guildId]
end

function GuildService:GetPlayerGuild(userId: number): Guild?
    local guildId = playerGuilds[userId]
    if not guildId then
        -- Load from data store
        local success, data = pcall(function()
            return guildMemberDataStore:GetAsync("GuildMember_" .. userId)
        end)
        guildId = success and data
        playerGuilds[userId] = guildId
    end
    
    if guildId then
        return self:GetGuild(guildId)
    end
    
    return nil
end

function GuildService:JoinGuild(guildId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local guild = self:GetGuild(guildId)
    if not guild then return false end
    
    -- Check if player is already in a guild
    if playerGuilds[player.UserId] then
        return false
    end
    
    -- Check guild capacity
    local requirements = getGuildLevelRequirements(guild.Level)
    if #guild.Members >= requirements.MaxMembers then
        return false
    end
    
    -- Check minimum level requirement
    local success, playerLevel = pcall(function()
        local DataService = Knit.GetService("DataService")
        return DataService and DataService:GetPlayerLevel(player.UserId)
    end)
    
    if not success or (playerLevel and playerLevel < guild.Settings.MinLevel) then
        return false
    end
    
    -- Check if approval is required
    if guild.Settings.RequireApproval then
        -- Add to applications
        if not guildApplications[guildId] then
            guildApplications[guildId] = {}
        end
        
        table.insert(guildApplications[guildId], player.UserId)
        
        -- Notify officers
        for userId, member in pairs(guild.Members) do
            if member.Role == "Owner" or member.Role == "Officer" then
                local officer = Players:GetPlayerByUserId(userId)
                if officer then
                    -- Would need to implement notification system
                    print("[GuildService] Guild application from", player.Name, "to", guild.Name)
                end
            end
        end
        
        return true
    end
    
    -- Add member directly
    guild.Members[player.UserId] = {
        UserId = player.UserId,
        Role = "Member",
        JoinedAt = os.time(),
        Contribution = 0,
        LastActive = os.time(),
        WeeklyContribution = 0,
    }
    
    guild.Permissions[player.UserId] = getRolePermissions("Member")
    
    -- Save changes
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guildId, guild)
        guildMemberDataStore:SetAsync("GuildMember_" .. player.UserId, guildId)
    end)
    
    -- Update tracking
    playerGuilds[player.UserId] = guildId
    
    -- Notify guild members
    for userId, _ in pairs(guild.Members) do
        local memberPlayer = Players:GetPlayerByUserId(userId)
        if memberPlayer then
            self.Client.MemberJoined:Fire(memberPlayer, player.UserId)
        end
    end
    
    -- Notify new member
    self.Client.GuildJoined:Fire(player, guild)
    
    return true
end

function GuildService:LeaveGuild(): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local guild = self:GetPlayerGuild(player.UserId)
    if not guild then return false end
    
    -- Cannot leave if you're the owner and there are other members
    if guild.OwnerId == player.UserId and #guild.Members > 1 then
        return false
    end
    
    return removeMember(guild, player.UserId, "Left guild")
end

function GuildService:KickMember(targetUserId: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local guild = self:GetPlayerGuild(player.UserId)
    if not guild then return false end
    
    -- Check permissions
    local permissions = guild.Permissions[player.UserId]
    if not permissions or not permissions.CanKick then
        return false
    end
    
    -- Cannot kick owner
    if targetUserId == guild.OwnerId then
        return false
    end
    
    -- Cannot kick members with higher role
    local targetMember = guild.Members[targetUserId]
    local kickerMember = guild.Members[player.UserId]
    
    if not targetMember or not kickerMember then
        return false
    end
    
    local roleHierarchy = {Owner = 4, Officer = 3, Veteran = 2, Member = 1}
    if roleHierarchy[targetMember.Role] >= roleHierarchy[kickerMember.Role] then
        return false
    end
    
    return removeMember(guild, targetUserId, "Kicked from guild")
end

function GuildService:PromoteMember(targetUserId: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local guild = self:GetPlayerGuild(player.UserId)
    if not guild then return false end
    
    -- Check permissions
    local permissions = guild.Permissions[player.UserId]
    if not permissions or not permissions.CanPromote then
        return false
    end
    
    local targetMember = guild.Members[targetUserId]
    if not targetMember then return false end
    
    -- Cannot promote to same or higher role
    local promoterMember = guild.Members[player.UserId]
    if not promoterMember then return false end
    
    local roleHierarchy = {Owner = 4, Officer = 3, Veteran = 2, Member = 1}
    if roleHierarchy[targetMember.Role] >= roleHierarchy[promoterMember.Role] then
        return false
    end
    
    -- Promote to next role
    local newRole = "Member"
    if targetMember.Role == "Member" then
        newRole = "Veteran"
    elseif targetMember.Role == "Veteran" then
        newRole = "Officer"
    elseif targetMember.Role == "Officer" then
        newRole = "Owner" -- Transfer ownership
        guild.OwnerId = targetUserId
    end
    
    targetMember.Role = newRole
    guild.Permissions[targetUserId] = getRolePermissions(newRole)
    
    -- Save changes
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guild.Id, guild)
    end)
    
    -- Notify members
    for userId, _ in pairs(guild.Members) do
        local memberPlayer = Players:GetPlayerByUserId(userId)
        if memberPlayer then
            self.Client.MemberPromoted:Fire(memberPlayer, targetUserId, newRole)
        end
    end
    
    return true
end

function GuildService:DepositToVault(amount: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local guild = self:GetPlayerGuild(player.UserId)
    if not guild then return false end
    
    if amount <= 0 then return false end
    
    -- Check player's gold (would need to implement with DataService)
    local success, playerGold = pcall(function()
        local DataService = Knit.GetService("DataService")
        return DataService and DataService:GetPlayerGold(player.UserId)
    end)
    
    if not success or not playerGold or playerGold < amount then
        return false
    end
    
    -- Deduct from player
    local deductSuccess = pcall(function()
        local DataService = Knit.GetService("DataService")
        if DataService then
            return DataService:RemovePlayerGold(player.UserId, amount)
        end
        return false
    end)
    
    if not deductSuccess then
        return false
    end
    
    -- Add to guild vault
    guild.Vault.Gold += amount
    guild.Vault.LastDeposit = os.time()
    
    -- Update weekly deposits
    if not guild.Vault.WeeklyDeposits[player.UserId] then
        guild.Vault.WeeklyDeposits[player.UserId] = 0
    end
    guild.Vault.WeeklyDeposits[player.UserId] += amount
    
    -- Update member contribution
    local member = guild.Members[player.UserId]
    if member then
        member.Contribution += amount
        member.WeeklyContribution += amount
        member.LastActive = os.time()
    end
    
    -- Save changes
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guild.Id, guild)
    end)
    
    -- Add guild experience
    addGuildExperience(guild, math.floor(amount / 10))
    
    return true
end

function GuildService:CreateGuildEvent(eventType: string, name: string, description: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local guild = self:GetPlayerGuild(player.UserId)
    if not guild then return false end
    
    -- Check permissions
    local permissions = guild.Permissions[player.UserId]
    if not permissions or not permissions.CanCreateEvents then
        return false
    end
    
    -- Create event
    local eventId = generateId()
    local event: GuildEvent = {
        Id = eventId,
        Type = eventType,
        Name = name,
        Description = description,
        StartTime = os.time(),
        EndTime = os.time() + GUILD_EVENT_DURATION,
        Participants = {},
        Objectives = {},
        Rewards = {
            Gold = 1000,
            Experience = 500,
            Items = {},
        },
        Status = "Active",
    }
    
    -- Add event objectives based on type
    if eventType == "Dungeon" then
        event.Objectives = {
            {Type = "Complete", Target = 1, Current = 0, Description = "Complete the dungeon"},
            {Type = "Collect", Target = 50, Current = 0, Description = "Collect 50 crystals"},
        }
    elseif eventType == "Boss" then
        event.Objectives = {
            {Type = "Defeat", Target = 1, Current = 0, Description = "Defeat the boss"},
            {Type = "Survive", Target = 1, Current = 0, Description = "Survive the encounter"},
        }
    elseif eventType == "Collection" then
        event.Objectives = {
            {Type = "Collect", Target = 100, Current = 0, Description = "Collect 100 items"},
            {Type = "Contribute", Target = 1000, Current = 0, Description = "Contribute 1000 gold"},
        }
    end
    
    guild.Events[eventId] = event
    activeEvents[eventId] = event
    
    -- Save changes
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guild.Id, guild)
        guildEventDataStore:SetAsync("Event_" .. eventId, event)
    end)
    
    -- Notify guild members
    for userId, _ in pairs(guild.Members) do
        local memberPlayer = Players:GetPlayerByUserId(userId)
        if memberPlayer then
            self.Client.GuildEventStarted:Fire(memberPlayer, event)
        end
    end
    
    return true
end

-- Service lifecycle
function GuildService:KnitStart()
    print("[GuildService] Starting guild system...")
    
    -- Load active guilds
    -- In a real implementation, you'd load guilds on demand rather than all at once
    
    print("[GuildService] Guild system started.")
end

function GuildService:KnitStop()
    print("[GuildService] Stopping guild system...")
    
    -- Save all active guilds
    for guildId, guild in pairs(guilds) do
        pcall(function()
            guildDataStore:SetAsync("Guild_" .. guildId, guild)
        end)
    end
    
    print("[GuildService] Guild system stopped.")
end

-- Client handlers
function GuildService.Client:CreateGuild(player: Player, name: string, description: string, motto: string?)
    return self:CreateGuild(name, description, motto)
end

function GuildService.Client:JoinGuild(player: Player, guildId: string)
    return self:JoinGuild(guildId)
end

function GuildService.Client:LeaveGuild(player: Player)
    return self:LeaveGuild()
end

function GuildService.Client:KickMember(player: Player, targetUserId: number)
    return self:KickMember(targetUserId)
end

function GuildService.Client:PromoteMember(player: Player, targetUserId: number)
    return self:PromoteMember(targetUserId)
end

function GuildService.Client:DepositToVault(player: Player, amount: number)
    return self:DepositToVault(amount)
end

function GuildService.Client:CreateGuildEvent(player: Player, eventType: string, name: string, description: string)
    return self:CreateGuildEvent(eventType, name, description)
end

return GuildService
