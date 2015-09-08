sptbl["phasor"] = {

    files = { 
        module = "phasor.c",
        header = "phasor.h",
        example = "ex_phasor.c",
    },
    
    func = {
        create = "sp_phasor_create",
        destroy = "sp_phasor_destroy",
        init = "sp_phasor_init",
        compute = "sp_phasor_compute",
    },
    
    params = {
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Frequency.",
                default = 1.5
            },
        }
    },
    
    modtype = "module",
    
    description = [[Produces a normalized sawtooth wave between the values of 0 and 1. Phasors are often used when building table-lookup oscillators.]], 

    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "this doesn't do anything."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal out."
        },
    }

}
