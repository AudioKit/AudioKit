sptbl["clip"] = {

    files = { 
        module = "clip.c",
        header = "clip.h",
        example = "ex_clip.c",
    },
    
    func = {
        create = "sp_clip_create",
        destroy = "sp_clip_destroy",
        init = "sp_clip_init",
        compute = "sp_clip_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "meth",
                type = "int",
                description = "Method of clipping. 0 = Bram de Jong, 1 = Sine, 2 = tanh.",
                default = 0 
            },
            {
                name = "lim",
                type = "SPFLOAT",
                description = "threshold / limiting value.",
                default = 1.0 
            }
        }, 
        optional = {
            {
                name = "arg",
                type = "SPFLOAT",
                description = "When meth is 0 (Bram De Jong), indicates point at which clipping starts in the range 0-1.",
                default = 0.5 
            }
        }
    },
    
    modtype = "module",
    
    description = [[Applies clip limiting to a signal.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "in",
            description = "Input signal."
        }
    },
    
    outputs = {
        {
            name = "out",
            description = "Output signal."
        }
    }

}
