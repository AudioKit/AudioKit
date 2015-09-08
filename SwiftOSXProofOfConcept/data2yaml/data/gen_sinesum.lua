sptbl["gen_sinesum"] = {

    files = { 
        module = "ftbl.c",
        header = "ftbl.h",
        example = "ex_gen_sinesum.c",
    },
    
    func = {
        name = "sp_gen_sinesum",
    },
    
    params = {
        {
            name = "argstring",
            type = "char *",
            description = [[A list of amplitudes, in the range 0-1, separated by spaces.Each position coordinates to their partial number. Position 1 is the fundamental amplitude (1 * freq). Position 2 is the first overtone (2 * freq), 3 is the second (3 * freq), etc...]],
            default = "1 0.5 0.25"
        },
    },
    
    modtype = "gen",
    
    description = [[Create a wave by summing together harmonically related sines. ]], 
    
}
