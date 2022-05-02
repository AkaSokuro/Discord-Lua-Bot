local discordia = require('discordia')
discordia.extensions()

local client = discordia.Client()

local json = require("json")
local coro = require("coro-http")

local timer = require("timer")

local config = require('Structures.config')

local guildDataFile = './guildData.json'

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
    local open = io.open(file, 'r')
    local contents = open:read("*a")
    local dataTable = {}
    dataTable = json.decode(contents)
    if dataTable then
        return dataTable
    else
        return nil
    end
end

function client._saveData(t, file)
    local open = io.open(file, 'w')
    local content = json.encode(t)
    open:write(content)
    print("Save new data: "..tostring(content))
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
        if (commandObject.botPermission) then
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
end)

client:on('messageCreate', function(msg)
    local guildData = client._getData(guildDataFile)
    for _,v in pairs(guildData) do
        if v[msg.guild.id].prefix then
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
    local _, err = pcall(execute, msg)
    if err then 
        msg.channel:send('Error occured with the command.') 
        client:error(err)
    end
end)

client:run('Bot '..config.token)