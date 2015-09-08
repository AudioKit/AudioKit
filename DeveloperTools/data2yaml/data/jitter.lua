sptbl["jitter"] = {

    files = { 
        module = "jitter.c",
        header = "jitter.h",
        example = "ex_jitter.c",
    },
    
    func = {
        create = "sp_jitter_create",
        destroy = "sp_jitter_destroy",
        init = "sp_jitter_init",
        compute = "sp_jitter_compute",
    },
    
    params = {
        optional = {
            {
                name = "amp",
                type = "SPFLOAT",
                description ="The amplitude of the line. Will produce values in the range of (+/-)amp.",
                default = 0.5
            },
            {
                name = "cpsMin",
                type = "SPFLOAT",
                description = "The minimum frequency of change in Hz.",
                default = 0.5
            },
            {
                name = "cpsMax",
                type = "SPFLOAT",
                description ="The maximum frequency of change in Hz.",
                default = 4
            },
        }
    },
    
    modtype = "module",
    
    description = [[Produce a signal with random fluctuations (aka... jitter). This is useful for emulating jitter found in analogue equipment. ]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "This doesn't do anything."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
