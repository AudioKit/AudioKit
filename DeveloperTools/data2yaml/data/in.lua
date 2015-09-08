sptbl["in"] = {

    files = { 
        module = "in.c",
        header = "in.h",
        example = "ex_in.c",
    },
    
    func = {
        create = "sp_in_create",
        destroy = "sp_in_destroy",
        init = "sp_in_init",
        compute = "sp_in_compute",
    },
    
    params = {
    },
    
    modtype = "module",
    
    description = [[Reads from standard input. Expects type of SPFLOAT, which by default is a float. If the input data is larger than the number of samples, you will get a complaint about a broken pipe (but it will still work). If there is no input data from STDIN, it will hang. 
<br><br>
The expected use case of sp_in is to utilize pipes from the commandline, like so:
<br><br>
cat /dev/urandom | ./my_program 
<br><br>
Assuming <i>my_program</i> is using sp_in, this will write /dev/urandom (essentially white noise) to an audio file. 
]], 
    
    ninputs = 0,
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
            description = "Signal output."
        },
    }

}
