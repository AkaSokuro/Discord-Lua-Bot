return {
	name = 'choose',
	alias = 'pick', 
	description = 'Let the bot pick a choice for you.',
    botPermission = {
		
	},

    execute = function(args, msg)

        local choices = {}
        for _,choice in pairs(args) do
            table.insert(choices, choice)
        end

        if #choices < 1 then return msg:reply(string.format("**%s**, Please provide choices for me.", msg.author.username)) end
        if #choices < 2 then return msg:reply(string.format("**%s**, You must provide me atleast 2 choices :l", msg.author.username)) end

        msg:reply(string.format("**%s**, I will pick, %s", msg.author.username, choices[math.random(1,#choices)]))

	end
}