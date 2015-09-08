sptbl["dust"] = {

    files = { 
        module = "dust.c",
        header = "dust.h",
        example = "ex_dust.c",
    },
    
    func = {
        create = "sp_dust_create",
        destroy = "sp_dust_destroy",
        init = "sp_dust_init",
        compute = "sp_dust_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "amp",
                type = "SPFLOAT",
                description = "",
                default = 0.3
            },
            {
                name = "density",
                type = "SPFLOAT",
                description = "",
                default = 10
            }
        },
    
        optional = {
            {
                name = "bipolar",
                type = "int",
                description = "Bipolar flag. A non-zero makes the signal bipolar as opposed to unipolar. ",
                default = 0
            },
        }
    },
    
    modtype = "module",
    
    description = [[Dust creates a series of random impulses.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "This doesn't do anything."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal out."
        },
    }

}
