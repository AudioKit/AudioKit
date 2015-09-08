sptbl["scale"] = {

    files = { 
        module = "scale.c",
        header = "scale.h",
        example = "ex_scale.c",
    },
    
    func = {
        create = "sp_scale_create",
        destroy = "sp_scale_destroy",
        init = "sp_scale_init",
        compute = "sp_scale_compute",
    },
    
    params = {
        optional = {
            {
                name = "min",
                type = "SPFLOAT",
                description = "Minimum value to scale to.",
                default = 0
            },
            {
                name = "max",
                type = "SPFLOAT",
                description ="Maximum value to scale to.",
                default = 1
            },
        }
    },
    
    modtype = "module",
    
    description = [[This module scales an incoming signal (in the range of -1, and 1),
and scales it to an arbitrary range.
]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "in",
            description = "Signal to be scaled, expected to be in the range of +/-1."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal out"
        },
    }

}
