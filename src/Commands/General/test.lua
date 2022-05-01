return {
	name = 'test',
	alias = '', 
	description = 'Test',
	ownerOnly = true,
    execute = function(_, msg)
        msg:reply('hello!')
	end
}