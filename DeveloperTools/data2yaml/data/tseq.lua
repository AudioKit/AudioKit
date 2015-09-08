sptbl["tseq"] = {

    files = { 
        module = "tseq.c",
        header = "tseq.h",
        example = "ex_tseq.c",
    },
    
    func = {
        create = "sp_tseq_create",
        destroy = "sp_tseq_destroy",
        init = "sp_tseq_init",
        compute = "sp_tseq_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "ft",
                type = "sp_ftbl *",
                description = "An ftable of values",
                default = "N/A"
            },
        },
    
        optional = {
            {
                name = "shuf",
                type = "int",
                description = "When shuf is non-zero, randomly pick a value rather than go through sequentially.",
                default = 0
            },
        }
    },
    
    modtype = "module",
    
    description = [[TSeq runs through values in an ftable. It will change values when the trigger input is a non-zero value, and wrap around when it reaches the end.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trig",
            description = "Trigger."
        },
    },
    
    outputs = {
        {
            name = "val",
            description = "Value from current position in ftable."
        },
    }

}
