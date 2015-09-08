sptbl["randi"] = {

    files = { 
        module = "randi.c",
        header = "randi.h",
        example = "ex_randi.c",
    },
    
    func = {
        create = "sp_randi_create",
        destroy = "sp_randi_destroy",
        init = "sp_randi_init",
        compute = "sp_randi_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "seed",
                type = "int",
                description = "Seed to use. Use time(NULL) to generate seed.",
                default = "N/A"
            },
        },
    
        optional = {
            {
                name = "min",
                type = "SPFLOAT",
                description = "Minimum value",
                default = 0
            },
            {
                name = "max",
                type = "SPFLOAT",
                description ="Maximum value",
                default = 1
            },
            {
                name = "cps",
                type = "SPFLOAT",
                description ="Frequency to change values.",
                default = 3
            },
            {
                name = "mode",
                type = "SPFLOAT",
                description = "Randi mode (not yet implemented yet.)",
                default = 0,
                irate = true
            },
        }
    },
    
    modtype = "module",
    
    description = [[Produces line of interpolated values within a range.]], 
    
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
            description = "Signal out."
        },
    }

}
