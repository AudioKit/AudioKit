sptbl["buthp"] = {

    files = { 
        module = "buthp.c",
        header = "buthp.h",
        example = "ex_buthp.c",
    },
    
    func = {
        create = "sp_buthp_create",
        destroy = "sp_buthp_destroy",
        init = "sp_buthp_init",
        compute = "sp_buthp_compute",
    },
    
    params = {
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Cutoff frequency.",
                default = 1000
            },
        }
    },
    
    modtype = "module",
    
    description = [[Highpass butterworth filter.]], 
    
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
            name = "output",
            description = "Signal output."
        },
    }

}
