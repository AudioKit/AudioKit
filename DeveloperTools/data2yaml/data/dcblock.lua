sptbl["dcblock"] = {

    files = { 
        module = "dcblock.c",
        header = "dcblock.h",
    },
    
    func = {
        create = "sp_dcblock_create",
        destroy = "sp_dcblock_destroy",
        init = "sp_dcblock_init",
        compute = "sp_dcblock_compute",
    },
    
    params = {
    },
    
    modtype = "module",
    
    description = [[A simple dcblock filter.]], 
    
    ninputs = 1,
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
