sptbl["dmetro"] = {

    files = { 
        module = "dmetro.c",
        header = "dmetro.h",
        example = "ex_dmetro.c",
    },
    
    func = {
        create = "sp_dmetro_create",
        destroy = "sp_dmetro_destroy",
        init = "sp_dmetro_init",
        compute = "sp_dmetro_compute",
    },
    
    params = {
        optional = {
            {
                name = "time",
                type = "SPFLOAT",
                description ="Time between triggers (in seconds). This will update at the start of each trigger.",
                default = 1.0
            },
        }
    },
    
    modtype = "module",
    
    description = [[Delta Metro. Produce a set of triggers spaced apart by  . 
time.]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "this doesn't do anything."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Trigger output."
        },
    }

}
