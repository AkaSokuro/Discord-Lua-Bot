return {
	name = 'prune',
	alias = 'purge', 
	description = 'Prune chats for specify amount.',
	userPermission = {
		"manageMessages"
	},
	botPermission = {
		"manageMessages"
	},

    execute = function(args, msg, client)

        if not args[1] then return msg:reply("You have to provide amount for me.") end

        local amount = tonumber(args[1])

        if type(amount) ~= "number" then return msg:reply("Amount has to be number!") end
        if amount < 1 then return msg:reply("Amount can't be lower than 1!") end

        amount = amount+1

        if amount > 100 then amount = 100 end -- Prevent ratelimit.

        local msgcaches = msg.channel:getMessages(amount)
        msg.channel:bulkDelete(msgcaches)

        --local m = msg:reply(string.format("Prune %s messages. :broom:", amount))

	end
}