sptbl["reverse"] = {

	files = {
	    module = "reverse.c",
	    header = "reverse.h",
	    example = "ex_reverse.c",
	},

	func = {
	    create = "sp_reverse_create",
	    destroy = "sp_reverse_destroy",
	    init = "sp_reverse_init",
	    compute = "sp_reverse_compute",
	},

	params = {
	    mandatory = {
	        {
	            name = "delay",
	            type = "SPFLOAT",
	            description = "Delay time in seconds.",
	            default = "1.0"
	        }
	    }
	},

	modtype = "module",

	description = [[Reverse will store a signal inside a buffer and play it back reversed.]],

	ninputs = 1,
	noutputs = 1,

	inputs = {
	    {
	        name = "input",
	        description = "Signal input."
	    }
	},

	outputs = {
	    {
	        name = "out",
	        description = "Signal output."
	    }
	}

}
