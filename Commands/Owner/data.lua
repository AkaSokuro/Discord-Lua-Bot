return {
	name = 'data',
	alias = '', 
	description = 'Get data.',
	userPermission = {

	},
	botPermission = {
		
	},
    ownerOnly = true,

    execute = function(args, msg, client)

        if not args[1] then return msg:reply("`m>data [Data Type]`") end
        
        local dataTable = {}
        local data = client._getData(args[1])

        if not data then return msg:reply(string.format("**%s** doesn't exist / empty.", args[1])) end

        client._syncGuildData()

        function formatTable(node)
            local cache, stack, output = {},{},{}
            local depth = 1
            local output_str = "{\n"
        
            while true do
                local size = 0
                for k,v in pairs(node) do
                    size = size + 1
                end
        
                local cur_index = 1
                for k,v in pairs(node) do
                    if (cache[node] == nil) or (cur_index >= cache[node]) then
        
                        if (string.find(output_str,"}",output_str:len())) then
                            output_str = output_str .. ",\n"
                        elseif not (string.find(output_str,"\n",output_str:len())) then
                            output_str = output_str .. "\n"
                        end
        
                        table.insert(output,output_str)
                        output_str = ""
        
                        local key
                        if (type(k) == "number" or type(k) == "boolean") then
                            key = "["..tostring(k).."]"
                        else
                            key = "['"..tostring(k).."']"
                        end
        
                        if (type(v) == "number" or type(v) == "boolean") then
                            output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                        elseif (type(v) == "table") then
                            output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                            table.insert(stack,node)
                            table.insert(stack,v)
                            cache[node] = cur_index+1
                            break
                        else
                            output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                        end
        
                        if (cur_index == size) then
                            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                        else
                            output_str = output_str .. ","
                        end
                    else
                        if (cur_index == size) then
                            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                        end
                    end
        
                    cur_index = cur_index + 1
                end
        
                if (size == 0) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
        
                if (#stack > 0) then
                    node = stack[#stack]
                    stack[#stack] = nil
                    depth = cache[node] == nil and depth + 1 or depth - 1
                else
                    break
                end
            end
        

            table.insert(output,output_str)
            output_str = table.concat(output)
        
            return output_str
        end

        for _,v in pairs(data) do
            table.insert(dataTable, v)
        end

        local output = formatTable(dataTable)

        if not output then return msg:reply("Data existed but empty.") end

        msg:reply(string.format(':mag: This is %s\'s data table. \n```lua\n%s\n```', args[1], output))

	end
}