return {
	name = 'test',
	alias = 't', 
	description = 'Test',
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