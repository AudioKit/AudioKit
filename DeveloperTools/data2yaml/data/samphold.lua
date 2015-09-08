sptbl["samphold"] = {

    files = {
        module = "samphold.c",
        header = "samphold.h",
        example = "ex_samphold.c",
    },

    func = {
        create = "sp_samphold_create",
        destroy = "sp_samphold_destroy",
        init = "sp_samphold_init",
        compute = "sp_samphold_compute",
    },

    params = {
    },

    modtype = "module",

    description = [[Classic sample and hold.]],

    ninputs = 2,
    noutputs = 1,

    inputs = {
        {
            name = "trig",
            description = "Will hold the current input value when non-zero."
        },
        {
            name = "input",
            description = "Audio input."
        },
    },

    outputs = {
        {
            name = "out",
            description = "Signal output."
        }
    }

}
