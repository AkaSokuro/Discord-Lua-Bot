return {
	name = 'test',
	alias = 't', 
	description = 'Test',
	botPermission = {
		"sendMessages"
	},
	ownerOnly = true,

    execute = function(_, msg)

        msg:reply('hello!')

	end
}