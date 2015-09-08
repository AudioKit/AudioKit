sptbl["allpass"] = {

    files = { 
        module = "allpass.c",
        header = "allpass.h",
        example = "ex_allpass.c",
    },
    
    func = {
        create = "sp_allpass_create",
        destroy = "sp_allpass_destroy",
        init = "sp_allpass_init",
        compute = "sp_allpass_compute",
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
    
    description = [[Allpass filter, often used for the creation of reverb modules.]], 
    
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
