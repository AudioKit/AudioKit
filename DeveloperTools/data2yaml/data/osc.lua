sptbl["osc"] = {

    files = {
        module = "osc.c",
        header = "osc.h",
        example = "ex_osc.c",
    },

    func = {
        create = "sp_osc_create",
        destroy = "sp_osc_destroy",
        init = "sp_osc_init",
        compute = "sp_osc_compute",
    },

    params = {
        mandatory = {
            {
                name = "tbl",
                type = "sp_ftbl *",
                description = "Wavetable to read from. <B>Note:</B> the size of this table must be a power of 2.",
                default = "N/A"
            },
            {
                name = "phase",
                type = "SPFLOAT",
                description ="Initial phase of waveform, expects a value 0-1",
                default = 0
            }
        },
        optional = {
            {
                name = "freq",
                type = "SPFLOAT",
                description = "Frequency (in Hz)",
                default = 440
            },
            {
                name = "amp",
                type = "SPFLOAT",
                description ="Amplitude (typically a value between 0 and 1).",
                default = 0.2
            },
        }
    },

    modtype = "module",

    description = [[ "Osc" is a table-lookup oscilator with linear interpolation. ]],

    ninputs = 0,
    noutputs = 1,

    inputs = {
        {
            name = "dummy",
            description = "This does nothing."
        },
    },

    outputs = {
        {
            name = "out",
            description = "Signal out."
        },
    }

}
