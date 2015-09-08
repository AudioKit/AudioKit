sptbl["biquad"] = {

    files = { 
        module = "biquad.c",
        header = "biquad.h",
        --example = "ex_tone.c",
    },
    
    func = {
        create = "sp_biquad_create",
        destroy = "sp_biquad_destroy",
        init = "sp_biquad_init",
        compute = "sp_biquad_compute",
    },
    
    params = {
        optional = {
            {
                name = "b0",
                type = "SPFLOAT",
                description = "biquad coefficient.",
                default = "???"
            },
            {
                name = "b1",
                type = "SPFLOAT",
                description = "biquad coefficient.",
                default = "???"
            },
            {
                name = "b2",
                type = "SPFLOAT",
                description = "biquad coefficient.",
                default = "???"
            },
            {
                name = "a0",
                type = "SPFLOAT",
                description = "biquad coefficient.",
                default = "???"
            },
            {
                name = "a1",
                type = "SPFLOAT",
                description = "biquad coefficient.",
                default = "???"
            },
            {
                name = "a2",
                type = "SPFLOAT",
                description = "biquad coefficient.",
                default = "???"
            }
        }
    },
    
    modtype = "module",
    
    description = [[A sweepable biquadratic general purpose filter. More work needs to be done here... at some point the biquadratic equation will placed here, along with a brief explanation on how to use the coefficients.]], 
    
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
