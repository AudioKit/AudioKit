sptbl["vco"] = {

    files = { 
        module = "vco.c",
        header = "vco.h",
        example = "ex_vco.c",
    },
    
    func = {
        create = "sp_vco_create",
        destroy = "sp_vco_destroy",
        init = "sp_vco_init",
        compute = "sp_vco_compute",
    },
    
    params = {
        optional = {
            {
                name = "amp",
                type = "SPFLOAT",
                description = "Amplitude",
                default = 0.3
            },
            {
                name = "freq",
                type = "SPFLOAT",
                description ="Frequency",
                default = 440
            },
            {
                name = "wave",
                type = "SPFLOAT",
                description ="Wave type. 1 = sawtooth, 2 = square/PWM, 3 = triangle/saw/ramp",
                default = 1
            },
            {
                name = "pw",
                type = "SPFLOAT",
                description ="Pulse width. Should be a value between 0 and 1.",
                default = 0.5
            },
            {
                name = "maxd",
                type = "SPFLOAT",
                description ="(not yet implemented) maximum delay time. Used for PWM and triangle waveform.",
                default = 1
            },
            {
                name = "iphs",
                type = "SPFLOAT",
                description ="(not yet implemented) set initial phase. Must be a value between 0 and 1.",
                default = 0 
            },
            {
                name = "ileak",
                type = "SPFLOAT",
                description ="(not eyet implemented) Leaky integrator value, that expects a value in the range of 0 and 1. If set to .9999, can help with the sound of saw waves and low frequencies. Can also give a hollower sounding square wave.",
                default = 0
            },
            {
                name = "inyq",
                type = "SPFLOAT",
                description ="(not yet implemented) Used to determine the number of harmonics in the band limited pulse. All overtimes inyq * sr will be used.",
                default = 0.5
            },
        }
    },
    
    modtype = "module",
    
    description = [[Band-limited analogue modelled oscillator with a selection of traditional oscillators to choose from.]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "This doesn't do anything. set to NULL."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal out."
        },
    }

}
