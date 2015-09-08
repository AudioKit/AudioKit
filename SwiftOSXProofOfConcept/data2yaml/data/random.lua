sptbl["random"] = {

    files = { 
        module = "random.c",
        header = "random.h",
        example = "ex_random.c",
    },
    
    func = {
        create = "sp_random_create",
        destroy = "sp_random_destroy",
        init = "sp_random_init",
        compute = "sp_random_compute",
    },
    
    params = {
        optional = {
            {
                name = "min",
                type = "SPFLOAT",
                description = "Minimum value.",
                default = -0.2
            },
            {
                name = "max",
                type = "SPFLOAT",
                description ="Maximum value.",
                default = 0.2
            },
        }
    },
    
    modtype = "module",
    
    description = [[Generate random values within a range.]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummmy",
            description = "This doesn't do nuthin."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
