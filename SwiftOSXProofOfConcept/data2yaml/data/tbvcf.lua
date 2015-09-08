sptbl["tbvcf"] = {

    files = { 
        module = "tbvcf.c",
        header = "tbvcf.h",
        example = "ex_tbvcf.c",
    },
    
    func = {
        create = "sp_tbvcf_create",
        destroy = "sp_tbvcf_destroy",
        init = "sp_tbvcf_init",
        compute = "sp_tbvcf_compute",
    },
    
    params = {
        optional = {
            {
                name = "fco",
                type = "SPFLOAT",
                description = "Filter cutoff frequency",
                default = 500
            },
            {
                name = "res",
                type = "SPFLOAT",
                description ="Resonance",
                default = 0.8
            },
            {
                name = "dist",
                type = "SPFLOAT",
                description ="Distortion. Value is typically 2.0, deviation from this can cause stability issues. ",
                default = 2.0
            },
            {
                name = "asym",
                type = "SPFLOAT",
                description ="Asymmetry of resonance. Value is between 0-1",
                default = 0.5
            },
        }
    },
    
    modtype = "module",
    
    description = [[This is an emulation of the tb303 filter.]], 
    
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
