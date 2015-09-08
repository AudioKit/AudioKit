sptbl["dtrig"] = {

    files = { 
        module = "dtrig.c",
        header = "dtrig.h",
        example = "ex_dtrig.c",
    },
    
    func = {
        create = "sp_dtrig_create",
        destroy = "sp_dtrig_destroy",
        init = "sp_dtrig_init",
        compute = "sp_dtrig_compute",
    },
        
    params = {
        mandatory = {
            {
                name = "ft",
                type = "sp_ftbl *",
                description = "An ftable containing times in seconds.",
                default = "N/A"
            }
        },
    
        optional = {
            {
                name = "loop",
                type = "int",
                description = "When set to 1, dtrig will wrap around and loop again.",
                default = 0
            },
            {
                name = "delay",
                type = "SPFLOAT",
                description = "This sets a delay (in seconds) on the triggered output when it is initially triggered. This is useful for rhythmic sequences with rests in the beginnings.",
                default = 0
            }
        }
    },
    
    modtype = "module",
    
    description = [[ "dtrig" is a a delta dtrigger that is able to create spaced out triggers. It is set off by a single trigger.]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trig",
            description = "trigger input."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "These are the triggered outputs."
        },
    }

}
