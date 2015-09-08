sptbl["reson"] = {

    files = { 
        module = "reson.c",
        header = "reson.h",
        example = "ex_reson.c",
    },
    
    func = {
        create = "sp_reson_create",
        destroy = "sp_reson_destroy",
        init = "sp_reson_init",
        compute = "sp_reson_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "cutoff",
                type = "SPFLOAT",
                description = "Center frequency of the filter, or frequency position of the peak response.",
                default = 4000
            },
            {
                name = "bw",
                type = "SPFLOAT",
                description = "Bandwidth of the filter.",
                default = 1000
            }
        },
    
    },
    
    modtype = "module",
    
    description = [[A second-order resonant filter. NOTE: The output for reson appears to be very hot, so take caution when using this module.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "input",
            description = "Signal Input."
        },
    },
    
    outputs = {
        {
            name = "output",
            description = "Signal output."
        },
    }

}
