return {
	name = 'ping',
	alias = '', 
	description = 'Get bot\'s ping.',
    execute = function(_, msg)
        local m = msg:reply("Calculating.. :thinking:")
        local ping = m.createdAt - msg.createdAt
        m:setContent(string.format("Ping: **%sms**", math.floor(tonumber(ping)*1000)))
	end
}