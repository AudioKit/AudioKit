sptbl["count"] = {

    files = {
        module = "count.c",
        header = "count.h",
        example = "ex_count.c",
    },

    func = {
        create = "sp_count_create",
        destroy = "sp_count_destroy",
        init = "sp_count_init",
        compute = "sp_count_compute",
    },

    params = {
        optional = {
            {
                name = "count",
                type = "SPFLOAT",
                description = "Number to count up to (count - 1). Decimal points will be truncated.",
                default = 4
            },
            {
                name = "mode",
                type = "SPFLOAT",
                description = "Counting mode. 0 = wrap-around, 1 = count up to N -1, then stop and spit out -1",
                default = 0
            },
        },
    },

    modtype = "module",

    description = [[Trigger-based fixed counter. The signal output will count from 0 to [N-1], and then
repeat itself. Count will start when it has been triggered, otherwise it will be -1.]],

    ninputs = 1,
    noutputs = 1,

    inputs = {
        {
            name = "trig",
            description = "When non-zero, will increment."
        },
    },

    outputs = {
        {
            name = "out",
            description = "Signal output."
        },
    }

}
