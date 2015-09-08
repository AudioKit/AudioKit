sptbl["pluck"] = {

    files = { 
        module = "pluck.c",
        header = "pluck.h",
        example = "ex_pluck.c",
    },
    
    func = {
        create = "sp_pluck_create",
        destroy = "sp_pluck_destroy",
        init = "sp_pluck_init",
        compute = "sp_pluck_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "ifreq",
                type = "SPFLOAT",
                description = "Sets the initial frequency. This frequency is used to allocate all the buffers needed for the delay. This should be the lowest frequency you plan on using.",
                default = 110
            }
        },
    
        optional = {
            {
                name = "plk",
                type = "SPFLOAT",
                description = [[Point of pluck. Expects value in the rnage of 0-1. 
A value of 0 is no initial pluck. ]],
                default = 0.75
            },
            {
                name = "freq",
                type = "SPFLOAT",
                description = [[Variable frequency. Values less than the initial 
frequency (ifreq) will be doubled until it is greater than or equal to ifreq.]],
                default = "ifreq"
            },
            {
                name = "amp",
                type = "SPFLOAT",
                description ="Amplitude",
                default = 0.8
            },
            {
                name = "pick",
                type = "SPFLOAT",
                description =[[Proportion along the string to sample the input. 
Expects a value in the range of 0-1.]],
                default = 0.75
            },
            {
                name = "reflect",
                type = "SPFLOAT",
                description = [[Coeffecient of reflection, indicating lossiness 
and rate of decay. Must be between 0 and 1, but not 0 and 1 themselves.]],
                default = 0.95
            },
        }
    },
    
    modtype = "module",
    
    description = [[Physical model of a plucked string, based on Karplus-Strong 
algorithm]], 
    
    ninputs = 2,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trigger",
            description = "Trigger input. When non-zero, will reinitialize and pluck."
        },
        {
            name = "excite",
            description = "This is signal that will excite the string. A typical signal would be a 1hz sine wave with an amplitude of 1."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
