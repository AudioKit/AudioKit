sptbl["pan2"] = {

    files = { 
        module = "pan2.c",
        header = "pan2.h",
        example = "ex_pan2.c",
    },
    
    func = {
        create = "sp_pan2_create",
        destroy = "sp_pan2_destroy",
        init = "sp_pan2_init",
        compute = "sp_pan2_compute",
    },
    
    params = {
        mandatory = {
        },
    
        optional = {
            {
                name = "type",
                type = "uint32_t",
                description = [[Panning type. 0 = equal power, 1 = square root, 2 = linear, 
3 = alternative equal power. Values outside this range will wrap. ]],
                default = 0
            },
            {
                name = "pan",
                type = "SPFLOAT",
                description ="Panning. A value of zero is hard left, and a value of 1 is hard right.",
                default = 0.5
            },
        }
    },
    
    modtype = "module",
    
    description = [[This is a description of the entire module. This is not a real module. This description should be a comprehensive sumary of what this function does. 
    
Inside the Lua table, this is expressed as a multiline string, however it does not adhere to the tradtional 80 column rule found in programming. 

Write as much text as needed here...
]], 
    
    ninputs = 1,
    noutputs = 2,
    
    inputs = { 
        {
            name = "clock",
            description = "this is the clock source for a made up plugin."
        },
        {
            name = "input",
            description = "this is the audio input for a made up plugin."
        },
    },
    
    outputs = {
        {
            name = "out_left",
            description = "Stereo left output for pan2."
        },
        {
            name = "out_right",
            description = "Stereo right output for pan2."
        },
    }

}
