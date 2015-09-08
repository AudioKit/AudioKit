sptbl["maygate"] = {

    files = {
        module = "maygate.c",
        header = "maygate.h",
        example = "ex_maygate.c",
    },

    func = {
        create = "sp_maygate_create",
        destroy = "sp_maygate_destroy",
        init = "sp_maygate_init",
        compute = "sp_maygate_compute",
    },

    params = {
        optional = {
            {
                name = "prob",
                type = "SPFLOAT",
                description = "Probability of maygate. This is a value between 0-1. The closer to 1, the more likely the maygate will let a signal through.",
                default = 0
            },

            {
                name = "mode",
                type = "int",
                description = "If mode is nonzero, maygate will output one sample triggers instead of a gate signal.",
                default = 0
            },
        }
    },

    modtype = "module",

    description = [[Maygate is a "maybe gate". It takes in a trigger, and then it will randomly decide to turn the gate on or not. One particular application for maygate is to arbitrarily turn on/off sends to effects. One specific example of this could be a randomized reverb throw on a snare.]],

    ninputs = 1,
    noutputs = 1,

    inputs = {
        {
            name = "trig",
            description = "This expects a trigger signal."
        }
    },

    outputs = {
        {
            name = "out",
            description = "Signal out."
        }
    }

}
