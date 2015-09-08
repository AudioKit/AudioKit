sptbl["gen_gauss"] = {

    files = {
        module = "ftbl.c",
        header = "ftbl.h",
        example = "ex_gen_gauss.c",
    },

    func = {
        name = "sp_gen_gauss",
    },

    params = {
        {
            name = "scale",
            type = "SPFLOAT",
            description = [[The scale of the distribution, in the range of -/+scale]],
            default = 123456
        },
        {
            name = "seed",
            type = "uint32_t",
            description = [[Random seed.]],
            default = 123456
        },
    },

    modtype = "gen",

    description = [[Generate a gaussian distribution.]],

}
