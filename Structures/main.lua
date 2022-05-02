local discordia = require('discordia')
discordia.extensions()

local client = discordia.Client()

local json = require("json")
local coro = require("coro-http")

local timer = require("timer")

local config = require('Structures.config')

local commandList = {}
local commandFolder = './Commands/'

local botPrefix = config.prefix

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
    local open = io.open(string.format('Structures/Data/%s.json', file), 'r')
    if not open then return false end
    local contents = open:read("*a")
    local dataTable = {}
    dataTable = json.decode(contents)
    if dataTable then
        return dataTable
    else
        return nil
    end
end

function client._getGuildData(guildId)
    local open = io.open('Structures/Data/guildData.json', 'r')
    local contents = open:read("*a")
    local data = json.decode(contents)
    for _,v in pairs(data) do
        if v[guildId] then
            return v[guildId]
        else
            return nil
        end
    end
end

function client._saveData(t, file)
    local open = io.open(string.format('Structures/Data/%s.json', file), 'w')
    if not open then return false end
    local content = json.encode(t)
    open:write(content)
    print("Save new data: "..tostring(content))
    open:close()
end

function client._syncGuildData()
    local guildData = client._getData('guildData') or {}
    local open = io.open('Structures/Data/guildData.json', 'w')
    local guilds = client.guilds
    local inGuilds = {}
    for _,guild in pairs(guilds) do
        table.insert(inGuilds, guild.id)
        local gData = {}
        for _,v in pairs(guildData) do if v[guild.id] then gData = v end end
        local gTable = {
            [guild.id] = {
                prefix = gData.prefix or config.prefix
            }
        }
        if next(gData) == nil then
            table.insert(guildData, gTable)
        else
            for _,v in pairs(guildData) do 
                if v[guild.id] then 
                    v[guild.id].prefix = v[guild.id].prefix or config.prefix
                end 
            end
        end
    end
    for i,v in pairs(guildData) do
        if type(v) == 'table' then
            for k,v in pairs(v) do
                if not table.search(inGuilds, k) then
                    table.remove(guildData, table.search(guildData, k))
                end
            end
        end
    end
    local content = json.encode(guildData)
    open:write(content)
    client:info("Synced all guilds data!")
    open:close()
end

function execute(msg)
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

        if not bot:hasPermission(msg.channel, "sendMessages") then
            return
        end
        if (commandObject.userPermission) and not userIsAdmin then
            for _,p in pairs(commandObject.userPermission) do
                if not user:hasPermission(msg.channel, p) then
                    msg:reply("You don't have "..p.." permission :(")
                    return
                end
            end
        end
        if (commandObject.botPermission) and not botIsAdmin then
            for _,p in pairs(commandObject.botPermission) do
                if not bot:hasPermission(msg.channel, p) then
                    msg:reply("Sorry, I don't have "..p.." permission :(")
                    return
                end
            end
        end
        if (commandObject.ownerOnly) and msg.author.id ~= config.ownerId then
            return
        end

        local _, err = pcall(function()
            commandObject.run(args, msg, client, {
                commands = commandList,
                prefix = config.prefix
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
    local guildData = client._getData('guildData')
    for _,v in pairs(guildData) do
        if v[msg.guild.id] then
            if v[msg.guild.id].prefix then
                botPrefix = v[msg.guild.id].prefix
            end
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
    local _, err = pcall(execute, msg)
    if err then 
        msg.channel:send('Error occured with the command.') 
        client:error(err)
    end
end)

client:on('guildCreate', function(guild)
    print(string.format("Joined new guild: %s (%s)", guild.name, guild.id))
    client._syncGuildData()
end)

client:on('guildDelete', function(guild)
    print(string.format("Leave the guild: %s (%s)", guild.name, guild.id))
    client._syncGuildData()
end)

client:run('Bot '..config.token)