sptbl["comb"] = {

    files = { 
        module = "comb.c",
        header = "comb.h",
        example = "ex_comb.c",
    },
    
    func = {
        create = "sp_comb_create",
        destroy = "sp_comb_destroy",
        init = "sp_comb_init",
        compute = "sp_comb_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "looptime",
                type = "SPFLOAT",
                description = "The loop time of the filter, in seconds. This can also be thought of as the delay time.",
                default = 0.1
            }
        },
    
        optional = {
            {
                name = "revtime",
                type = "SPFLOAT",
                description = "The reverberation time, in seconds (aka RT-60).",
                default = 3.5
            },
        }
    },
    
    modtype = "module",
    
    description = [[Comb filter.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "input",
            description = "Signal input."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
