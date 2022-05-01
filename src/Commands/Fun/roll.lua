return {
	name = 'roll',
	alias = 'dice', 
	description = 'Rolls the dice.',

    execute = function(args, msg)

        local max = tonumber(args[1]) or 100

        if max < 1 then return msg:reply("Max Point can't be lower than 1.") end

        msg:reply(string.format("**%s**, You got `%s` points! :tada:", msg.author.username, math.random(1,max)))

	end
}