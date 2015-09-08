sptbl["vdelay"] = {

    files = { 
        module = "vdelay.c",
        header = "vdelay.h",
        example = "ex_vdelay.c",
    },
    
    func = {
        create = "sp_vdelay_create",
        destroy = "sp_vdelay_destroy",
        init = "sp_vdelay_init",
        compute = "sp_vdelay_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "maxdel",
                type = "SPFLOAT",
                description = "The maximum delay time, in seconds.",
                default = 1.0,
                irate = true
            },
        },
    
        optional = {
            {
                name = "del",
                type = "SPFLOAT",
                description = "Delay time (in seconds) that can be changed during performance. This value must not exceed the maximum delay time.",
                default = "maxdel * 0.5"
            },
        }
    },
    
    modtype = "module",
    
    description = [[A delay line with cubic interpolation.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "in",
            description = "Signal input."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal out."
        },
    }

}
