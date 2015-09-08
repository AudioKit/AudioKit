sptbl["switch"] = {

    files = {
        module = "switch.c",
        header = "switch.h",
        example = "ex_switch.c",
    },

    func = {
        create = "sp_switch_create",
        destroy = "sp_switch_destroy",
        init = "sp_switch_init",
        compute = "sp_switch_compute",
    },

    params = {
    },

    modtype = "module",

    description = [[Switch between two signals. By default the incoming first signal is selected. When triggered, the output signal will switch to the other signal.]],

    ninputs = 3,
    noutputs = 1,

    inputs = {
        {
            name = "trig",
            description = "When non-zero, will switch to the other signal."
        },
        {
            name = "input_1",
            description = "Signal input 1. This is the default signal."
        },
        {
            name = "input_2",
            description = "Signal input 2."
        },
    },

    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
