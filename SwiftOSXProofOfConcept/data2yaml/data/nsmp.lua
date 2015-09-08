sptbl["nsmp"] = {

    files = { 
        module = "nsmp.c",
        header = "nsmp.h",
        example = "ex_nsmp.c",
    },
    
    func = {
        create = "sp_nsmp_create",
        destroy = "sp_nsmp_destroy",
        init = "sp_nsmp_init",
        compute = "sp_nsmp_compute",
        other = { 
            sp_nsmp_print_index = {
                description = "Prints the index and their corresponding keyword",
                args = {
                }
            }
        }
    },
    
    params = {
        mandatory = {
            {
                name = "wav",
                type = "const char *",
                description = "The filepath of the audio file. It should be mono and matching the samplerate of the project, as no resampling is done.",
                default = "N/A"
            },
            {
                name = "ini",
                type = "const char *",
                description = "The filepath of the INI file. See oneart.ini in the examples folder for an example of an INI file.",
                default = "N/A"
            }
        },
    
        optional = {
            {
                name = "index",
                type = "uint32_t",
                description = "This is an optional parameter. These values are always set to a value by default, and can be set after the init function has been called.",
                default = 0
            },
        }
    },
    
    modtype = "module",
    
    description = [[Nanosamp: a tiny sampler built for Soundpipe. A nanosamp file is comprised of a mono audio file and an ini file. Nanosamp is geared towards percussive and found sound sample players, and is intended to be combined with soundpipe modules. 
<br>    
The ini file contains mappings that correspond to the audio file. Such an entry would look like this:
<br><pre>
[keyword]
pos = 2.3
size = 3
</pre>
In this instance, an entry called "keyword" has been made, starting at 2.3 seconds in the 
audio file, with a length of 3 seconds. An example file oneart.ini has been created in the 
examples folder.

The SoundPipe implementation of nanosamp will automatically index the entries
in the order they appear in the INI file and must be selected this way by changing the index
parameter. Soundpipe will only select the new entry when the trigger input is a non-zero value.

]], 
    
    ninputs = 1,
    noutputs = 1,
    
    inputs = { 
        {
            name = "trigger",
            description = "Trigger input."
        },
    },
    
    outputs = {
        {
            name = "signal out",
            description = "Signal out."
        },
    }

}
