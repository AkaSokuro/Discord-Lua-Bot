local json = require("json")

local DataFolder = 'Structures/Data'

return {
    save = function(t, filename)
        local loc = string.format("%s/%s.json", DataFolder, filename)
        local file = io.open(loc, 'w')

        if file then
            local contents = json.encode(t)
            file:write(contents)
            print("Save new data: "..tostring(t))
            io.close(file)
            return true
        else
            return false
        end
    end;

    load = function(filename)
        local loc = string.format("%s/%s.json", DataFolder, filename)
        local file = io.open(loc, 'r')

        if file then
            local dataTable = {}
            local contents = file:read( "*a" )
            dataTable = json.decode(contents);
            io.close(file)
            return dataTable
        end
        return nil
    end;
}