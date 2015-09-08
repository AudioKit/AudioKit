sptbl["gen_line"] = {

    files = {
        module = "ftbl.c",
        header = "ftbl.h",
        example = "ex_gen_line.c",
    },

    func = {
        name = "sp_gen_line",
    },

    params = {
        {
            name = "argstring",
            type = "char *",
            description = [[A list of ordered xy pairs. X expects whole number integers, as they correlate to index positions in the ftable.]],
            default = "0 0 4096 1"
        },
    },

    modtype = "gen",

    description = [[Generate a line segment.]],

}
