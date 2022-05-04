return {
	name = '8ball',
	alias = '', 
	description = 'Ask a question and get a reply.',
    cooldown = 5,
    botPermission = {
		
	},

    execute = function(args, msg)

        local responses = require("Helper.8ballResponses")
        local ans = responses[math.random(1, #responses)]

        if not args[1] then return msg:reply(string.format("**%s**, Please provide me the question.", msg.author.username)) end

        msg:reply(string.format("**%s**, %s", msg.author.username, ans))

	end
}