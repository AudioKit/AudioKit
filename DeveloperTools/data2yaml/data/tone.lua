sptbl["tone"] = {

	files = { 
	    module = "tone.c",
	    header = "tone.h",
	    example = "ex_tone.c",
	},
	
	func = {
	    create = "sp_tone_create",
	    destroy = "sp_tone_destroy",
	    init = "sp_tone_init",
	    compute = "sp_tone_compute",
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
	
	description = [[Tone is a first-order recursive lowpass filter.]], 
	
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
