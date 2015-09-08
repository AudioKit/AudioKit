sptbl["tin"] = {

    files = { 
        module = "tin.c",
        header = "tin.h",
        example = "ex_tin.c",
    },
    
    func = {
        create = "sp_tin_create",
        destroy = "sp_tin_destroy",
        init = "sp_tin_init",
        compute = "sp_tin_compute",
    },
    
    params = {
    },
    
    modtype = "module",
    
    description = [[Similar to in, tin reads SPFLOATs (by default, this is a 4 byte binary float) from standard input every time it is triggered. behaves like a sample and hold, retaining the previous value (initial set to 0) until triggered. ]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trig",
            description = "When non-zero, reads a single SPFLOAt from standard input."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
