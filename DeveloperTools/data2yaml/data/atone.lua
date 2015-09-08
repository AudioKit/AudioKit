sptbl["atone"] = {

	files = { 
	    module = "atone.c",
	    header = "atone.h",
	    example = "ex_atone.c",
	},
	
	func = {
	    create = "sp_atone_create",
	    destroy = "sp_atone_destroy",
	    init = "sp_atone_init",
	    compute = "sp_atone_compute",
	},
	
	params = {
	    mandatory = {
	        {
	            name = "hp",
	            type = "SPFLOAT *",
	            description = "This is the response curve's half power point (aka cutoff).",
	            default = "1000"
	        },
	    },
	},
	
	modtype = "module",
	
	description = [[atone is a first-order recursive highpass filter, the complement to the tone module.]], 
	
	ninputs = 1,
	noutputs = 1,
	
	inputs = { 
	    {
	        name = "in",
	        description = "Audio signal in."
	    },
	},
	
	outputs = {
	    {
	        name = "out",
	        description = "Audio signal out."
	    },
	}

}
