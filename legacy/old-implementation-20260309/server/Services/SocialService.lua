--!strict
-- Social Service for Semantic Slime
-- Handles guilds, friends, chat, trading, and social interactions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local SocialService = Knit.CreateService {
    Name = "SocialService",
    Client = {
        -- Chat events
        MessageReceived = Knit.CreateSignal(),
        ChannelJoined = Knit.CreateSignal(),
        ChannelLeft = Knit.CreateSignal(),
        
        -- Friend events
        FriendRequestSent = Knit.CreateSignal(),
        FriendRequestReceived = Knit.CreateSignal(),
        FriendAdded = Knit.CreateSignal(),
        FriendRemoved = Knit.CreateSignal(),
        
        -- Guild events
        GuildCreated = Knit.CreateSignal(),
        GuildJoined = Knit.CreateSignal(),
        GuildLeft = Knit.CreateSignal(),
        GuildUpdated = Knit.CreateSignal(),
        GuildMemberJoined = Knit.CreateSignal(),
        GuildMemberLeft = Knit.CreateSignal(),
        
        -- Trading events
        TradeRequestSent = Knit.CreateSignal(),
        TradeRequestReceived = Knit.CreateSignal(),
        TradeStarted = Knit.CreateSignal(),
        TradeAccepted = Knit.CreateSignal(),
        TradeDeclined = Knit.CreateSignal(),
        TradeCompleted = Knit.CreateSignal(),
    },
}

-- Types
export type PlayerProfile = {
    UserId: number,
    Username: string,
    DisplayName: string,
    Avatar: string?,
    Level: number,
    JoinDate: number,
    LastActive: number,
    Status: string,
    IsOnline: boolean,
}

export type FriendData = {
    UserId: number,
    Since: number,
    Status: "Pending" | "Accepted" | "Blocked",
}

export type ChatChannel = {
    Id: string,
    Name: string,
    Type: "Global" | "Guild" | "Private" | "Trade",
    Members: {number},
    Messages: {ChatMessage},
    CreatedAt: number,
}

export type ChatMessage = {
    Id: string,
    UserId: number,
    Username: string,
    Message: string,
    Timestamp: number,
    ChannelId: string,
}

export type GuildData = {
    Id: string,
    Name: string,
    Description: string,
    Emblem: string?,
    OwnerId: number,
    Members: {GuildMember},
    CreatedAt: number,
    Level: number,
    Experience: number,
    Settings: GuildSettings,
}

export type GuildMember = {
    UserId: number,
    Role: "Owner" | "Officer" | "Member",
    JoinedAt: number,
    Contribution: number,
    LastActive: number,
}

export type GuildSettings = {
    IsPublic: boolean,
    RequireApproval: boolean,
    MinLevel: number,
    MaxMembers: number,
    AutoPromote: boolean,
}

export type TradeData = {
    Id: string,
    InitiatorId: number,
    TargetId: number,
    InitiatorOffer: {TradeItem},
    TargetOffer: {TradeItem},
    Status: "Pending" | "Accepted" | "Declined" | "Completed",
    CreatedAt: number,
    ExpiresAt: number,
}

export type TradeItem = {
    Type: "Slime" | "Crystal" | "Item",
    Id: string,
    Name: string,
    Rarity: string,
    Quantity: number,
}

-- Configuration
local MAX_FRIENDS = 100
local MAX_GUILD_MEMBERS = 50
local TRADE_DURATION = 300 -- 5 minutes
local MESSAGE_HISTORY_LIMIT = 100
local GUILD_NAME_MIN_LENGTH = 3
local GUILD_NAME_MAX_LENGTH = 20

-- Data stores
local socialDataStore = nil -- initialized in KnitStart
local guildDataStore = nil -- initialized in KnitStart
local chatDataStore = nil -- initialized in KnitStart

-- Private state
local playerProfiles: {[number]: PlayerProfile} = {}
local playerFriends: {[number]: {FriendData}} = {}
local playerGuilds: {[number]: string?} = {}
local activeTrades: {[string]: TradeData} = {}
local chatChannels: {[string]: ChatChannel} = {}
local playerChannels: {[number]: {string}} = {}

-- Private functions
local function generateId(): string
    return HttpService:GenerateGUID(false)
end

local function getPlayerProfile(userId: number): PlayerProfile?
    local success, data = pcall(function()
        return socialDataStore:GetAsync("Profile_" .. userId)
    end)
    
    if success and data then
        return data
    end
    
    -- Create default profile
    local player = Players:GetPlayerByUserId(userId)
    local profile: PlayerProfile = {
        UserId = userId,
        Username = player and player.Name or "User" .. userId,
        DisplayName = player and player.DisplayName or "User" .. userId,
        Avatar = player and player.UserId and "https://roblox.com/thumbs/avatar.ashx?x=100&y=100&format=png&userId=" .. player.UserId or "",
        Level = 1,
        JoinDate = os.time(),
        LastActive = os.time(),
        Status = "🎮 Playing Semantic Slime",
        IsOnline = player ~= nil,
    }
    
    -- Save default profile
    pcall(function()
        socialDataStore:SetAsync("Profile_" .. userId, profile)
    end)
    
    return profile
end

local function updatePlayerProfile(userId: number, updates: any)
    local profile = getPlayerProfile(userId)
    if not profile then return end
    
    for key, value in pairs(updates) do
        profile[key] = value
    end
    
    profile.LastActive = os.time()
    profile.IsOnline = Players:GetPlayerByUserId(userId) ~= nil
    
    pcall(function()
        socialDataStore:SetAsync("Profile_" .. userId, profile)
    end)
    
    playerProfiles[userId] = profile
end

local function loadPlayerFriends(userId: number): {FriendData}
    local success, data = pcall(function()
        return socialDataStore:GetAsync("Friends_" .. userId) or {}
    end)
    
    if success then
        return data
    end
    
    return {}
end

local function savePlayerFriends(userId: number, friends: {FriendData})
    pcall(function()
        socialDataStore:SetAsync("Friends_" .. userId, friends)
    end)
end

local function createChatChannel(name: string, channelType: string, members: {number}): ChatChannel
    local channelId = generateId()
    
    local channel: ChatChannel = {
        Id = channelId,
        Name = name,
        Type = channelType,
        Members = members,
        Messages = {},
        CreatedAt = os.time(),
    }
    
    chatChannels[channelId] = channel
    
    -- Add channel to all members
    for _, memberId in ipairs(members) do
        if not playerChannels[memberId] then
            playerChannels[memberId] = {}
        end
        table.insert(playerChannels[memberId], channelId)
        
        -- Notify online members
        local player = Players:GetPlayerByUserId(memberId)
        if player then
            SocialService.Client.ChannelJoined:Fire(player, channel)
        end
    end
    
    -- Save channel
    pcall(function()
        chatDataStore:SetAsync("Channel_" .. channelId, channel)
    end)
    
    return channel
end

local function addChatMessage(channelId: string, userId: number, message: string): ChatMessage?
    local channel = chatChannels[channelId]
    if not channel then return nil end
    
    -- Check if user is in channel
    local isInChannel = false
    for _, memberId in ipairs(channel.Members) do
        if memberId == userId then
            isInChannel = true
            break
        end
    end
    
    if not isInChannel then return nil end
    
    local profile = getPlayerProfile(userId)
    if not profile then return nil end
    
    local chatMessage: ChatMessage = {
        Id = generateId(),
        UserId = userId,
        Username = profile.Username,
        Message = message,
        Timestamp = os.time(),
        ChannelId = channelId,
    }
    
    -- Add to channel
    table.insert(channel.Messages, chatMessage)
    
    -- Limit message history
    if #channel.Messages > MESSAGE_HISTORY_LIMIT then
        table.remove(channel.Messages, 1)
    end
    
    -- Notify all online members
    for _, memberId in ipairs(channel.Members) do
        local player = Players:GetPlayerByUserId(memberId)
        if player then
            SocialService.Client.MessageReceived:Fire(player, chatMessage)
        end
    end
    
    -- Save channel
    pcall(function()
        chatDataStore:SetAsync("Channel_" .. channelId, channel)
    end)
    
    return chatMessage
end

-- Public methods
function SocialService:GetPlayerProfile(userId: number): PlayerProfile?
    return playerProfiles[userId] or getPlayerProfile(userId)
end

function SocialService:UpdatePlayerStatus(status: string)
    local player = Players.LocalPlayer
    if not player then return end
    
    updatePlayerProfile(player.UserId, {Status = status})
end

function SocialService:GetFriends(userId: number): {FriendData}
    return playerFriends[userId] or loadPlayerFriends(userId)
end

function SocialService:SendFriendRequest(targetUserId: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local initiatorId = player.UserId
    
    -- Check if already friends
    local initiatorFriends = self:GetFriends(initiatorId)
    for _, friend in ipairs(initiatorFriends) do
        if friend.UserId == targetUserId then
            return false -- Already friends
        end
    end
    
    -- Create friend request
    local friendData: FriendData = {
        UserId = targetUserId,
        Since = os.time(),
        Status = "Pending",
    }
    
    table.insert(initiatorFriends, friendData)
    savePlayerFriends(initiatorId, initiatorFriends)
    playerFriends[initiatorId] = initiatorFriends
    
    -- Add to target's pending requests
    local targetFriends = self:GetFriends(targetUserId)
    local targetFriendData: FriendData = {
        UserId = initiatorId,
        Since = os.time(),
        Status = "Pending",
    }
    
    table.insert(targetFriends, targetFriendData)
    savePlayerFriends(targetUserId, targetFriends)
    playerFriends[targetUserId] = targetFriends
    
    -- Notify target if online
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    if targetPlayer then
        SocialService.Client.FriendRequestReceived:Fire(targetPlayer, self:GetPlayerProfile(initiatorId))
    end
    
    SocialService.Client.FriendRequestSent:Fire(player, self:GetPlayerProfile(targetUserId))
    
    return true
end

function SocialService:AcceptFriendRequest(requesterId: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local targetId = player.UserId
    
    -- Update both friend lists
    local targetFriends = self:GetFriends(targetId)
    local requesterFriends = self:GetFriends(requesterId)
    
    -- Find and update the request
    for _, friend in ipairs(targetFriends) do
        if friend.UserId == requesterId and friend.Status == "Pending" then
            friend.Status = "Accepted"
            break
        end
    end
    
    -- Add reciprocal friendship
    local reciprocalFriend: FriendData = {
        UserId = targetId,
        Since = os.time(),
        Status = "Accepted",
    }
    
    local found = false
    for _, friend in ipairs(requesterFriends) do
        if friend.UserId == targetId then
            friend.Status = "Accepted"
            found = true
            break
        end
    end
    
    if not found then
        table.insert(requesterFriends, reciprocalFriend)
    end
    
    -- Save both
    savePlayerFriends(targetId, targetFriends)
    savePlayerFriends(requesterId, requesterFriends)
    
    -- Notify both players
    SocialService.Client.FriendAdded:Fire(player, self:GetPlayerProfile(requesterId))
    
    local requesterPlayer = Players:GetPlayerByUserId(requesterId)
    if requesterPlayer then
        SocialService.Client.FriendAdded:Fire(requesterPlayer, self:GetPlayerProfile(targetId))
    end
    
    return true
end

function SocialService:RemoveFriend(friendId: number): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local userId = player.UserId
    
    -- Remove from user's friends
    local userFriends = self:GetFriends(userId)
    for i, friend in ipairs(userFriends) do
        if friend.UserId == friendId then
            table.remove(userFriends, i)
            break
        end
    end
    savePlayerFriends(userId, userFriends)
    
    -- Remove from friend's friends
    local friendFriends = self:GetFriends(friendId)
    for i, friend in ipairs(friendFriends) do
        if friend.UserId == userId then
            table.remove(friendFriends, i)
            break
        end
    end
    savePlayerFriends(friendId, friendFriends)
    
    -- Notify both players
    SocialService.Client.FriendRemoved:Fire(player, self:GetPlayerProfile(friendId))
    
    local friendPlayer = Players:GetPlayerByUserId(friendId)
    if friendPlayer then
        SocialService.Client.FriendRemoved:Fire(friendPlayer, self:GetPlayerProfile(userId))
    end
    
    return true
end

function SocialService:JoinChannel(channelId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local channel = chatChannels[channelId]
    if not channel then return false end
    
    -- Check if already in channel
    for _, memberId in ipairs(channel.Members) do
        if memberId == player.UserId then
            return false -- Already in channel
        end
    end
    
    -- Add to channel
    table.insert(channel.Members, player.UserId)
    
    if not playerChannels[player.UserId] then
        playerChannels[player.UserId] = {}
    end
    table.insert(playerChannels[player.UserId], channelId)
    
    -- Notify player
    SocialService.Client.ChannelJoined:Fire(player, channel)
    
    -- Save channel
    pcall(function()
        chatDataStore:SetAsync("Channel_" .. channelId, channel)
    end)
    
    return true
end

function SocialService:LeaveChannel(channelId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local channel = chatChannels[channelId]
    if not channel then return false end
    
    -- Remove from channel
    for i, memberId in ipairs(channel.Members) do
        if memberId == player.UserId then
            table.remove(channel.Members, i)
            break
        end
    end
    
    -- Remove from player's channels
    if playerChannels[player.UserId] then
        for i, channelId_ in ipairs(playerChannels[player.UserId]) do
            if channelId_ == channelId then
                table.remove(playerChannels[player.UserId], i)
                break
            end
        end
    end
    
    -- Notify player
    SocialService.Client.ChannelLeft:Fire(player, channelId)
    
    -- Save channel
    pcall(function()
        chatDataStore:SetAsync("Channel_" .. channelId, channel)
    end)
    
    return true
end

function SocialService:SendMessage(channelId: string, message: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    -- Validate message
    if type(message) ~= "string" or #message == 0 or #message > 200 then
        return false
    end
    
    -- Add message
    local chatMessage = addChatMessage(channelId, player.UserId, message)
    return chatMessage ~= nil
end

function SocialService:GetPlayerChannels(userId: number): {ChatChannel}
    local channels = {}
    
    if playerChannels[userId] then
        for _, channelId in ipairs(playerChannels[userId]) do
            local channel = chatChannels[channelId]
            if channel then
                table.insert(channels, channel)
            end
        end
    end
    
    return channels
end

-- Guild methods
function SocialService:CreateGuild(name: string, description: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    -- Validate guild name
    if type(name) ~= "string" or #name < GUILD_NAME_MIN_LENGTH or #name > GUILD_NAME_MAX_LENGTH then
        return false
    end
    
    -- Check if player is already in a guild
    if playerGuilds[player.UserId] then
        return false
    end
    
    -- Create guild
    local guildId = generateId()
    local guild: GuildData = {
        Id = guildId,
        Name = name,
        Description = description,
        Emblem = nil,
        OwnerId = player.UserId,
        Members = {
            {
                UserId = player.UserId,
                Role = "Owner",
                JoinedAt = os.time(),
                Contribution = 0,
                LastActive = os.time(),
            }
        },
        CreatedAt = os.time(),
        Level = 1,
        Experience = 0,
        Settings = {
            IsPublic = true,
            RequireApproval = false,
            MinLevel = 1,
            MaxMembers = MAX_GUILD_MEMBERS,
            AutoPromote = false,
        },
    }
    
    -- Save guild
    pcall(function()
        guildDataStore:SetAsync("Guild_" .. guildId, guild)
    end)
    
    -- Update player's guild
    playerGuilds[player.UserId] = guildId
    pcall(function()
        socialDataStore:SetAsync("Guild_" .. player.UserId, guildId)
    end)
    
    -- Create guild chat channel
    createChatChannel(name, "Guild", {player.UserId})
    
    -- Notify player
    SocialService.Client.GuildCreated:Fire(player, guild)
    
    return true
end

function SocialService:GetGuild(guildId: string): GuildData?
    local success, data = pcall(function()
        return guildDataStore:GetAsync("Guild_" .. guildId)
    end)
    
    return success and data or nil
end

function SocialService:GetPlayerGuild(userId: number): GuildData?
    local guildId = playerGuilds[userId]
    if not guildId then
        -- Load from data store
        local success, data = pcall(function()
            return socialDataStore:GetAsync("Guild_" .. userId)
        end)
        guildId = success and data
        playerGuilds[userId] = guildId
    end
    
    if guildId then
        return self:GetGuild(guildId)
    end
    
    return nil
end

-- Trading methods
function SocialService:SendTradeRequest(targetUserId: number, offerItems: {TradeItem}): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local initiatorId = player.UserId
    
    -- Check if player is in a trade
    for _, trade in pairs(activeTrades) do
        if (trade.InitiatorId == initiatorId or trade.TargetId == initiatorId) and trade.Status == "Pending" then
            return false -- Already in a trade
        end
    end
    
    -- Create trade
    local tradeId = generateId()
    local trade: TradeData = {
        Id = tradeId,
        InitiatorId = initiatorId,
        TargetId = targetUserId,
        InitiatorOffer = offerItems,
        TargetOffer = {},
        Status = "Pending",
        CreatedAt = os.time(),
        ExpiresAt = os.time() + TRADE_DURATION,
    }
    
    activeTrades[tradeId] = trade
    
    -- Notify target
    local targetPlayer = Players:GetPlayerByUserId(targetUserId)
    if targetPlayer then
        SocialService.Client.TradeRequestReceived:Fire(targetPlayer, trade)
    end
    
    SocialService.Client.TradeRequestSent:Fire(player, trade)
    
    -- Auto-expire trade
    task.delay(TRADE_DURATION, function()
        if activeTrades[tradeId] and activeTrades[tradeId].Status == "Pending" then
            activeTrades[tradeId].Status = "Declined"
            SocialService.Client.TradeDeclined:Fire(player, "Trade expired")
            
            local targetPlayer = Players:GetPlayerByUserId(targetUserId)
            if targetPlayer then
                SocialService.Client.TradeDeclined:Fire(targetPlayer, "Trade expired")
            end
            
            activeTrades[tradeId] = nil
        end
    end)
    
    return true
end

function SocialService:AcceptTradeRequest(tradeId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local trade = activeTrades[tradeId]
    if not trade or trade.TargetId ~= player.UserId then
        return false
    end
    
    trade.Status = "Accepted"
    
    -- Notify both players
    SocialService.Client.TradeStarted:Fire(Players:GetPlayerByUserId(trade.InitiatorId), trade)
    SocialService.Client.TradeStarted:Fire(player, trade)
    
    return true
end

function SocialService:DeclineTradeRequest(tradeId: string): boolean
    local player = Players.LocalPlayer
    if not player then return false end
    
    local trade = activeTrades[tradeId]
    if not trade then return false end
    
    if trade.InitiatorId ~= player.UserId and trade.TargetId ~= player.UserId then
        return false
    end
    
    trade.Status = "Declined"
    
    -- Notify both players
    local initiatorPlayer = Players:GetPlayerByUserId(trade.InitiatorId)
    local targetPlayer = Players:GetPlayerByUserId(trade.TargetId)
    
    if initiatorPlayer then
        SocialService.Client.TradeDeclined:Fire(initiatorPlayer, "Trade declined")
    end
    
    if targetPlayer then
        SocialService.Client.TradeDeclined:Fire(targetPlayer, "Trade declined")
    end
    
    activeTrades[tradeId] = nil
    
    return true
end

-- Service lifecycle
function SocialService:KnitStart()
    print("[SocialService] Starting social systems...")
    
    -- Load global chat channel
    local success, globalChannel = pcall(function()
        return chatDataStore:GetAsync("Channel_Global")
    end)
    
    if not success or not globalChannel then
        -- Create global channel
        globalChannel = createChatChannel("Global", "Global", {})
    end
    
    chatChannels["Global"] = globalChannel
    
    print("[SocialService] Social systems started.")
end

function SocialService:KnitStop()
    print("[SocialService] Stopping social systems...")
    
    -- Save all active data
    for userId, profile in pairs(playerProfiles) do
        updatePlayerProfile(userId, profile)
    end
    
    print("[SocialService] Social systems stopped.")
end

-- Client handlers
function SocialService.Client:SendFriendRequest(player: Player, targetUserId: number)
    return self:SendFriendRequest(targetUserId)
end

function SocialService.Client:AcceptFriendRequest(player: Player, requesterId: number)
    return self:AcceptFriendRequest(requesterId)
end

function SocialService.Client:RemoveFriend(player: Player, friendId: number)
    return self:RemoveFriend(friendId)
end

function SocialService.Client:SendMessage(player: Player, channelId: string, message: string)
    return self:SendMessage(channelId, message)
end

function SocialService.Client:CreateGuild(player: Player, name: string, description: string)
    return self:CreateGuild(name, description)
end

function SocialService.Client:SendTradeRequest(player: Player, targetUserId: number, offerItems: {TradeItem})
    return self:SendTradeRequest(targetUserId, offerItems)
end

function SocialService.Client:AcceptTradeRequest(player: Player, tradeId: string)
    return self:AcceptTradeRequest(tradeId)
end

function SocialService.Client:DeclineTradeRequest(player: Player, tradeId: string)
    return self:DeclineTradeRequest(tradeId)
end

return SocialService
