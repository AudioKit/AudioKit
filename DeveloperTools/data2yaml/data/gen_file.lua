sptbl["gen_file"] = {

    files = {
        module = "ftbl.c",
        header = "ftbl.h",
        --example = "ex_gen_file.c",
    },

    func = {
        name = "sp_gen_file",
    },

    params = {
        {
            name = "filename",
            type = "const char *",
            description = [[filename]],
            default = "file.wav"
        },
    },

    modtype = "gen",

    description = [[Reads from a wav file. This will only load as many samples as the 
length of the ftable.]],

}
