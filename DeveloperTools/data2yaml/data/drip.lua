sptbl["drip"] = {

    files = { 
        module = "drip.c",
        header = "drip.h",
        example = "ex_drip.c",
    },
    
    func = {
        create = "sp_drip_create",
        destroy = "sp_drip_destroy",
        init = "sp_drip_init",
        compute = "sp_drip_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "dettack",
                type = "SPFLOAT",
                description = "Period of time over which all sound is stopped.",
                default = 0.09
            },
        },
    
        optional = {
            {
                name = "num_tubes",
                type = "SPFLOAT",
                description = "Number of units.",
                default = 10
            },
            {
                name = "amp",
                type = "SPFLOAT",
                description = "Amplitude.",
                default = 0.3
            },
            {
                name = "damp",
                type = "SPFLOAT",
                description ="The dampening factor. Maximum value is 2.0.",
                default = 0.2
            },
            {
                name = "shake_max",
                type = "SPFLOAT",
                description = "The amount of energy to add back into the system.",
                default = 0
            },
            {
                name = "freq",
                type = "SPFLOAT",
                description ="Main resonant frequency.",
                default = 450
            },
            {
                name = "freq1",
                type = "SPFLOAT",
                description ="The first resonant frequency.",
                default = 600
            },
            {
                name = "freq2",
                type = "SPFLOAT",
                description ="The second resonant frequency.",
                default = 750
            },
        }
    },
    
    modtype = "module",
    
    description = [[This is a physical model of the sound of dripping water. When triggered, it will produce a droplet of water.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trig",
            description = "Trigger value. When non-zero, it will reinit the drip and create a drip sound."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Stereo left output for drip."
        },
    }

}
