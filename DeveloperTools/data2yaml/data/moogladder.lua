sptbl["moogladder"] = {

    files = { 
        module = "moogladder.c",
        header = "moogladder.h",
        example = "ex_moogladder.c",
    },
    
    func = {
        create = "sp_moogladder_create",
        destroy = "sp_moogladder_destroy",
        init = "sp_moogladder_init",
        compute = "sp_moogladder_compute",
    },
    
    params = {
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Filter cutoff frequency.",
                default = 1000
            },
            {
                name = "res",
                type = "SPFLOAT",
                description ="Filter resonance",
                default = 0.4
            },
        }
    },
    
    modtype = "module",
    
    description = [[Low pass resonant filter based on the moog ladder filter.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        { name = "input",
            description = "this is the clock source for a made up plugin."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Stereo left output for moogladder."
        },
    }

}
