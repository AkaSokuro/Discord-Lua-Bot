local discordia = require('discordia')
discordia.extensions()

local client = discordia.Client()

local timer = require("timer")
local coro = require("coro-http")

--// Global Variables //
_G.require = require
_G.timer = timer
_G.coro = coro

local dataManager = require("Structures.dataManager")

local config = require('Structures.config')

local commandList = {}
local commandFolder = './Commands/'

for n,category in pairs(config.enableCommands) do
    for _,cmd in pairs(category) do
        local command = require(commandFolder .. n.."/" .. cmd)
        table.insert(commandList,{
            name = command.name,
            alias = command.alias,
            category = n,
            description = command.description,
            userPermission = command.userPermission,
            botPermission = command.botPermission,
            ownerOnly = command.ownerOnly,
            run = command.execute,
        });
        client:info(string.format("%s Command \"%s\" Enabled.", #commandList, command.name))
    end
end

function client._getData(file)
    return dataManager.load(file)
end

function client._saveData(t, file)
    return dataManager.save(t, file)
end

function client._syncGuildData()
    local guildData = client._getData('guildData') or {}
    local guilds = client.guilds
    local inGuilds = {}
    for _,guild in pairs(guilds) do
        table.insert(inGuilds, guild.id)
    end
    if guildData then
        for _,v in pairs(guildData) do
            if type(v) == 'table' then
                for k,v in pairs(v) do
                    if not table.search(inGuilds, k) then
                        table.remove(guildData, table.search(guildData, k))
                    end
                end
            end
        end
    end
    dataManager.save(guildData, 'guildData')
end

function execute(botPrefix, msg)
    local args = string.split(msg.content, ' ')
    local command = string.gsub(args[1], botPrefix, '')

    args = table.slice(args, 2)
    command = string.lower(command)

    local commandObject
    for _,cmd in pairs(commandList) do
        if string.lower(cmd.name) == command or string.lower(cmd.alias) == command then
            commandObject = cmd
        end
    end
        
    if (commandObject) then

        local bot = msg.guild:getMember(client.user.id)
        local user = msg.guild:getMember(msg.author.id)

        local botIsAdmin = bot:hasPermission(msg.channel, "administrator")
        local userIsAdmin = user:hasPermission(msg.channel, "administrator")

        -- If bot doesn't has permission to send message.
        if not bot:hasPermission(msg.channel, "sendMessages") then
            return
        end

        -- If user doesn't has the requirement permission.
        if (commandObject.userPermission) and not userIsAdmin then
            for _,p in pairs(commandObject.userPermission) do
                if not user:hasPermission(msg.channel, p) then
                    msg:reply("You don't have "..p.." permission :(")
                    return
                end
            end
        end

        -- If bot doesn't has the requirement permission.
        if (commandObject.botPermission) and not botIsAdmin then
            for _,p in pairs(commandObject.botPermission) do
                if not bot:hasPermission(msg.channel, p) then
                    msg:reply("Sorry, I don't have "..p.." permission :(")
                    return
                end
            end
        end

        -- If the command can only be executed by bot's owner.
        if (commandObject.ownerOnly) and msg.author.id ~= config.ownerId then
            return
        end

        local _, err = pcall(function()
            commandObject.run(args, msg, client, {
                commands = commandList,
                prefix = botPrefix
            });
        end)
        if err then client:error(err) end
	end
end

client:on('ready', function()
    client:info(string.format("%s Deployed", client.user.username))
    client:setStatus(config.presence.status)
    client:setGame({name=config.presence.name,type=config.presence.type})
    client._syncGuildData()
end)

client:on('messageCreate', function(msg)
    local botPrefix = config.prefix

    local guildData = client._getData('guildData')
    -- If guild use custom prefix.
    for _,v in pairs(guildData) do
        if v[msg.guild.id] then
            botPrefix = v[msg.guild.id].prefix
        end
    end

	if (not string.startswith(msg.content, botPrefix)) then
		return
	end
	if (not msg.author) then
		return
    end
	if (msg.author.id == client.user.id) then
		return
    end
	if (msg.author.bot) then
		return
    end

    local _, err = pcall(execute, botPrefix, msg)
    if err then 
        msg.channel:send('Error occured with the command.') 
        client:error(err)
    end
end)

client:on('guildCreate', function(guild)
    print(string.format("Joined new guild: %s (%s)", guild.name, guild.id))
    --client._syncGuildData()
end)

client:on('guildDelete', function(guild)
    print(string.format("Leave the guild: %s (%s)", guild.name, guild.id))
    client._syncGuildData()
end)

client:run('Bot '..config.token)