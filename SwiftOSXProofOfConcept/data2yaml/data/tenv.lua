sptbl["tenv"] = {

    files = { 
        module = "tenv.c",
        header = "tenv.h",
        example = "ex_tenv.c",
    },
    
    func = {
        create = "sp_tenv_create",
        destroy = "sp_tenv_destroy",
        init = "sp_tenv_init",
        compute = "sp_tenv_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "atk",
                type = "SPFLOAT",
                description = "Attack time, in seconds.",
                default = 0.1
            },
            {
                name = "hold",
                type = "SPFLOAT",
                description = "Hold time, in seconds.",
                default = 0.3
            },
            {
                name = "rel",
                type = "SPFLOAT",
                description = "Release time, in seconds.",
                default = 0.2
            }
        },
        optional = {
            {
                name = "sigmode",
                type = "int",
                description = "If set to non-zero value, tenv will multiply the envelope with an internal signal instead of just returning an enveloped signal.",
                default = 0
            },
            {
                name = "in",
                type = "SPFLOAT",
                description = "Internal input signal. If sigmode variable is set, it will multiply the envelope by this variable. Most of the time, this should be updated at audiorate.",
                default = 0
            }
        }    
    },
    
    modtype = "module",
    
    description = [[TEnv is a trigger based linear AHD envelope generator.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trig",
            description = "Trigger input. When non-zero, the envelope will (re)trigger."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output"
        },
    }

}
