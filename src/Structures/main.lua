local discordia = require('discordia')
discordia.extensions()

local timer = require('timer')

local client = discordia.Client()

local config = require('Structures.config')

client:on('ready', function()
	print(string.format("%s ready.", client.user.username))
    client:setStatus(config.status.status)
    client:setGame({name=config.status.name,type=config.status.type})
end)

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
            ownerOnly = command.ownerOnly or false,
            run = command.execute,
        });
        print(string.format(#commandList.." Command \"%s\" Enabled.", command.name))
    end
end

function errorHandler(err)
    print("Error occured: "..err)
end

function execute(msg)
    local args = string.split(msg.content, ' ')
    local command = string.gsub(args[1], config.prefix, '')

    args = table.slice(args, 2)
    command = string.lower(command)

    local commandObject
    for _,cmd in pairs(commandList) do
        if string.lower(cmd.name) == command or string.lower(cmd.alias) == command then
            commandObject = cmd
        end
    end
        
    if (commandObject) then
        if (commandObject.ownerOnly) and msg.author.id ~= config.ownerId then
            return
        end
        local pass, err = pcall(function()
            commandObject.run(args, msg, client, {
                commands = commandList,
                prefix = config.prefix
            });
        end)
        if err then
            errorHandler(err)
        end
	end
end

client:on('messageCreate', function(msg)
	if (not string.startswith(msg.content, config.prefix)) then
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
    local pass, err = pcall(execute, msg)
    if not pass then
        print(err); msg.channel:send('Error occured with the command.')
    end
end)

client:run('Bot '..config.token)