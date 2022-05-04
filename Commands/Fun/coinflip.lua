return {
	name = 'coinflip',
	alias = 'flip', 
	description = 'Flips the coin.',
	cooldown = 5,
	botPermission = {
		
	},

    execute = function(_, msg)

        local isHeads = math.random(0,1) < 1
        if isHeads then msg:reply("Heads.") else msg:reply("Tails.") end

	end
}