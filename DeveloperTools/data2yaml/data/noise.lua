sptbl["noise"] = {

    files = { 
        module = "noise.c",
        header = "noise.h",
        example = "ex_noise.c",
    },
    
    func = {
        create = "sp_noise_create",
        destroy = "sp_noise_destroy",
        init = "sp_noise_init",
        compute = "sp_noise_compute",
    },
    
    params = {
        optional = {
            {
                name = "gain",
                type = "SPFLOAT",
                description = "Amplitude. (Value between 0-1).",
                default = 1.0
            },
        }
    },
    
    modtype = "module",
    
    description = [[White noise generator.]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "This doesn't do anything"
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal out."
        },
    }

}
