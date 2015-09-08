sptbl["streson"] = {

    files = { 
        module = "streson.c",
        header = "streson.h",
        example = "ex_streson.c",
    },
    
    func = {
        create = "sp_streson_create",
        destroy = "sp_streson_destroy",
        init = "sp_streson_init",
        compute = "sp_streson_compute",
    },
    
    params = {
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Fundamental frequency of string.",
                default = 440.0
            },
            {
                name = "fdbgain",
                type = "SPFLOAT",
                description = "Feedback amount (value between 0-1)",
                default = 0.8
            },
        }
    },
    
    modtype = "module",
    
    description = [[String resonator filter.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "input",
            description = "Signal input."
        },
    },
    
    outputs = {
        {
            name = "output",
            description = "Signal output."
        },
    }

}
