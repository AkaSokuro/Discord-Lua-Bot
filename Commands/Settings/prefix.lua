return {
	name = 'prefix',
	alias = '', 
	description = 'Set bot\'s prefix in server.',
	userPermission = {
		"administrator"
	},
	botPermission = {
		
	},

    execute = function(args, msg, client)

        if not args[1] then return msg:reply("You have to provide the prefix for me.") end

        local newPrefix = args[1]
        
        local guildData = client._getData('guildData') or  {}
        local newData = {[msg.guild.id] = {prefix = newPrefix}}

        local guildTable = {}
        for _,v in pairs(guildData) do
            if v[msg.guild.id] then
                guildTable = v[msg.guild.id]
                v[msg.guild.id].prefix = newPrefix
            end
        end

        if next(guildTable) == nil then
            table.insert(guildData, newData)
            client._saveData(guildData, 'guildData')
        else
            client._saveData(guildData, 'guildData')
        end

        msg:reply(string.format("The prefix has been set to: `%s`", newPrefix))

	end
}