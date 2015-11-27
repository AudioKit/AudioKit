-- data2yaml
-- Convert a soundpipe module into a YAML file for AK.
--
-- Usage:
--
-- lua data2yaml.lua NAME > NAME.yaml
--
-- Where *name* is the name of the soundpipe module.


sptbl = {}

dofile(string.format("../../Soundpipe/modules/data/%s.lua", arg[1]))

YAML = { name=arg[1] }

function YAML.tables(self, tbl)
    if(tbl.params.mandatory == nil) then return end
    local ftbl = {}
    for k,v in pairs(tbl.params.mandatory) do
        if(string.match(v.type, "sp_ftbl")) then
            local ft = {}
            ft.name = v.name
            ft.comment = v.description
            table.insert(ftbl, ft)
        end
    end

    if(next(ftbl) == nil) then return end
    io.write("tables:\n")
    for k,v in pairs(ftbl) do
        io.write(string.format("- %s: {\n", v.name))
        io.write(string.format("  ak-variable: %s,\n", v.name))
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
        io.write(string.format("  ak-variable: %s,\n", v.name))
        io.write(string.format("  comment: \"%s\",\n", v.description))
        io.write(string.format("  au-name: \"%s\",\n", v.description))
        io.write(string.format("  au-unit: Hertz,\n"))
        io.write(string.format("  default: %s,\n", v.default))
        io.write(string.format("  minimum: ,\n"))
        io.write(string.format("  maximum: \n"))
        io.write("}\n")
    end
    io.write("\n")
end

function YAML.constants(self, tbl)
    if(tbl.params.mandatory == nil) then return end
    local constants = {}
    for k,v in pairs(tbl.params.mandatory) do
        if(string.match(v.type, "sp_ftbl")) then
            -- ignore
        else
            local c = {}
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
        io.write(string.format("  ak-variable: %s ,\n", v.name))
        io.write(string.format("  comment: \"%s\",\n", v.comment))
        io.write(string.format("  default: %s\n", v.default))
        io.write("}\n")
    end
    io.write("\n")
end


function YAML.generate(self, tbl)
    io.write(string.format("installation-directory: \"../AudioKit/Operations/\"\n\n"))
    io.write(string.format("sp-module: %s\n\n", self.name))
    io.write(string.format("operation: AK\n\n"))
    io.write(string.format("four-letter-code: AK\n\n"))
    io.write(string.format("summary: %s\n\n", tbl.description));
    io.write(string.format("one-word-description: %s\n\n", tbl.description ))
    io.write(string.format("description: %s\n\n", tbl.description))

    self:tables(tbl)
    self:parameters(tbl)
    self:constants(tbl)
end


YAML:generate(sptbl[arg[1]])
