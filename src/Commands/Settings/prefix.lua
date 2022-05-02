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
        
        local guildData = client._getData('./guildData.json')
        local newData = {[msg.guild.id] = {prefix = newPrefix}}

        for _,v in pairs(guildData) do
            if not v[msg.guild.id] then
                table.insert(guildData, newData)
                client._saveData(guildData, './guildData.json')
            else
                v[msg.guild.id].prefix = newPrefix
                client._saveData(guildData, './guildData.json')
            end
        end
        msg:reply(string.format("The prefix has been set to: `%s`", newPrefix))

	end
}