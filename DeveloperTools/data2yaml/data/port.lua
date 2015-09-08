sptbl["port"] = {

    files = { 
        module = "port.c",
        header = "port.h",
        example = "ex_port.c",
    },
    
    func = {
        create = "sp_port_create",
        destroy = "sp_port_destroy",
        init = "sp_port_init",
        compute = "sp_port_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "htime",
                type = "SPFLOAT",
                description = "",
                default = 0.02
            },
        },
    },
    
    modtype = "module",
    
    description = [[This applies portamento to a control signal. Useful for smoothing out low-resolution signals and applying glissando to filters.]], 
    
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
