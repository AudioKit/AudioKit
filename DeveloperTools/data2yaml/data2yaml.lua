sptbl = {}
print(arg[1])
dofile(string.format("data/%s.lua", arg[1]))

YAML = { name=arg[1] }

function YAML.tables(self, tbl)
    if(tbl.params.mandatory == nil) then return end
    local ftbl = {}
    local ft = {}
    for k,v in pairs(tbl.params.mandatory) do
        if(string.match(v.type, "sp_ftbl")) then
            ft.name = v.name
            ft.comment = v.description
            table.insert(ftbl, ft)
        end
    end 

    if(next(ftbl) == nil) then return end
    io.write("tables:\n")
    for k,v in pairs(ftbl) do 
        io.write(string.format("- %s: {\n", v.name))
        io.write(string.format("  audioKitName: %s,\n", v.name))
        io.write(string.format("  comment: \"%s\",\n", v.comment))
        io.write("  default: \n")
        io.write("}\n")
    end
    io.write("\n")
end

function YAML.parameters(self, tbl)
    if(tbl.params.optional == nil) then return end
    io.write("parameters:\n")
    for k,v in pairs(tbl.params.optional) do 
        io.write(string.format("- %s: {\n", v.name))
        io.write(string.format("  audioKitName: %s,\n", v.name))
        io.write(string.format("  comment: \"%s\",\n", v.description))
        io.write(string.format("  default: %s\n", v.default))
        io.write("}\n")
    end
    io.write("\n")
end

function YAML.constants(self, tbl)
    if(tbl.params.mandatory == nil) then return end
    local constants = {}
    local c = {}
    for k,v in pairs(tbl.params.mandatory) do
        if(string.match(v.type, "sp_ftbl")) then
            -- ignore
        else
            c.name = v.name
            c.comment = v.description
            c.default = v.default
            table.insert(constants, c)
        end
    end 

    if(next(constants) == nil) then return end

    io.write("constants:\n")
    for k,v in pairs(constants) do 
        io.write(string.format("- %s: {\n", v.name))
        io.write(string.format("  audioKitName: %s ,\n", v.name))
        io.write(string.format("  comment: \"%s\",\n", v.comment))
        io.write(string.format("  default: %s\n", v.default))
        io.write("}\n")
    end
    io.write("\n")
end


function YAML.generate(self, tbl) 
    io.write(string.format("sp_name: %s\n\n", self.name))
    io.write(string.format("summary: \n\n"));
    io.write(string.format("shortDescription: \n\n"))
    io.write(string.format("description: \n\n"))

    self:tables(tbl)
    self:parameters(tbl)
    self:constants(tbl)
end


YAML:generate(sptbl[arg[1]])
