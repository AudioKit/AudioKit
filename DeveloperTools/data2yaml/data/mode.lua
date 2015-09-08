sptbl["mode"] = {

    files = { 
        module = "mode.c",
        header = "mode.h",
        example = "ex_mode.c",
    },
    
    func = {
        create = "sp_mode_create",
        destroy = "sp_mode_destroy",
        init = "sp_mode_init",
        compute = "sp_mode_compute",
    },
    
    params = {
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Resonant frequency of the filter.",
                default = 500
            },
            {
                name = "q",
                type = "SPFLOAT",
                description ="Quality factor of the filter. Roughly equal to q/freq.",
                default = 50
            },
        }
    },
    
    modtype = "module",
    
    description = [[A modal resonance filter used for modal synthesis. Plucked and bell sounds can be created using  passing an impulse through a combination of modal filters. ]], 
    
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
            description = "Signal output."
        },
    }

}
