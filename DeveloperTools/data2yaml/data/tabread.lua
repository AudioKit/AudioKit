sptbl["tabread"] = {
    files = { 
        module = "tabread.c",
        header = "tabread.h",
        example = "ex_tabread.c",
    },
    
    func = {
        create = "sp_tabread_create",
        destroy = "sp_tabread_destroy",
        init = "sp_tabread_init",
        compute = "sp_tabread_compute",
    },
    
    params = {
        mandatory = {
            {
                name = "bar",
                type = "sp_ftbl *",
                description = "A properly allocated table (using a function like sp_gen_file).",
                default = "N/A"
            },
        },
    
        optional = {
            {
                name = "speed",
                type = "SPFLOAT",
                description ="Playback speed. 1.0 = normal. 2.0 = doublespeed, 0.5 = halfspeed, etc...",
                default = 1.0
            },
        }
    },
    
    modtype = "module",
    
    description = [[Read through a table at audio-rate with varispeed. No interpolation is implemented yet, so this works very quickly.]], 
    
    ninputs = 0,
    noutputs = 1,
    
    inputs = { 
        {
            name = "dummy",
            description = "This doesn't do anything. Can be set to NULL."
        },
    },
    
    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }
}
