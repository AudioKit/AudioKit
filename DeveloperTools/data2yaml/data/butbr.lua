sptbl["butbr"] = {

    files = { 
        module = "butbr.c",
        header = "butbr.h",
        example = "ex_butbr.c",
    },
    
    func = {
        create = "sp_butbr_create",
        destroy = "sp_butbr_destroy",
        init = "sp_butbr_init",
        compute = "sp_butbr_compute",
    },
    
    params = {
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "center frequency. (in Hertz)",
                default = 1000
            },
            {
                name = "bw",
                type = "SPFLOAT",
                description = "Bandwidth. (in Hertz)",
                default = 1000
            },
        }
    },
    
    modtype = "module",
    
    description = [[Band reject butterworth filter.]], 
    
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
