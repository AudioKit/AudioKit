sptbl["gbuzz"] = {

    files = { 
        module = "gbuzz.c",
        header = "gbuzz.h",
        example = "ex_gbuzz.c",
    },
    
    func = {
        create = "sp_gbuzz_create",
        destroy = "sp_gbuzz_destroy",
        init = "sp_gbuzz_init",
        compute = "sp_gbuzz_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "ft",
                type = "sp_ftbl *",
                description = "Soundpipe function table used internally. This should be a sine wave.",
                default = "N/A"
            },
        },
    
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Frequency, in Hertz.",
                default = 440
            },
            {
                name = "amp",
                type = "SPFLOAT",
                description ="Amplitude (Typically a value between 0 and 1).",
                default = 0.4
            },
            {
                name = "nharm",
                type = "SPFLOAT",
                description ="Number of harmonics.",
                default = 4
            },
            {
                name = "lharm",
                type = "SPFLOAT",
                description ="Lowest harmonic present. This should be a whole number integer.",
                default = 0
            },
            {
                name = "mul",
                type = "SPFLOAT",
                description ="Multiplier. This determines the relative strength of each harmonic.",
                default = 0.1
            },
            {
                name = "iphs",
                type = "SPFLOAT",
                description ="Not yet implemented. Phase to start on (in the range 0-1)",
                default = 0
            },
        }
    },
    
    modtype = "module",
    
    description = [["Gbuzz" is used to generate a series of partials from the harmonic series. GBuzz comes from the "buzz" family of Csound opcodes, and is capable of producing a rich spectrum of harmonic content, possibly ideal for subtractive synthesis techniques.]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "in",
            description = "Signal input"
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output"
        },
    }

}
