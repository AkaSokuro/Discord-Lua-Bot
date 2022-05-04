return {
	name = 'test',
	alias = 't', 
	description = 'Test',
	cooldown = 1,
	userPermission = {
		"banMembers"
	},
	botPermission = {
		
	},
	ownerOnly = true,

    execute = function(_, msg)

        msg:reply('hello!')

	end
}