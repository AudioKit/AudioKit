sptbl["dist"] = {

    files = { 
        module = "dist.c",
        header = "dist.h",
        example = "ex_dist.c",
    },
    
    func = {
        create = "sp_dist_create",
        destroy = "sp_dist_destroy",
        init = "sp_dist_init",
        compute = "sp_dist_compute",
    },
    
    params = {
        optional = {
            {
                name = "pregrain",
                type = "SPFLOAT",
                description ="Gain applied before waveshaping.",
                default = 2.0
            },
            {
                name = "postgain",
                type = "SPFLOAT",
                description ="Gain applied after waveshaping",
                default = 0.5
            },
            {
                name = "shape1",
                type = "SPFLOAT",
                description ="Shape of the positive part of the signal. A value of 0 gets a flat clip.",
                default = 0
            },
            {
                name = "shape2",
                type = "SPFLOAT",
                description ="Like shape1, only for the negative part.",
                default = 0
            },
            
        }
    },
    
    modtype = "module",
    
    description = [[Distortion using a modified hyperbolic tangent function.]], 
    
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
        }
    }

}
