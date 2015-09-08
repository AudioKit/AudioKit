sptbl["rms"] = {

    files = { 
        module = "rms.c",
        header = "rms.h",
    },
    
    func = {
        create = "sp_rms_create",
        destroy = "sp_rms_destroy",
        init = "sp_rms_init",
        compute = "sp_rms_compute",
    },
    
    params = {
        optional = {
            {
                name = "ihp",
                type = "SPFLOAT",
                description = "Half-power point (in Hz) of internal lowpass filter. This parameter is fixed at 10Hz and is not yet mutable.",
                default = 10
            },
        }
    },
    
    modtype = "module",
    
    description = [[Perform "root-mean-square" on a signal to get overall amplitude of a signal. The output signal looks similar to that of a classic VU meter.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "in",
            description = "Input signal."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Output signal."
        },
    }

}
