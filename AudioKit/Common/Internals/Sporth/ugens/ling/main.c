#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "h/sporth.h"
#include "ling.h"

static void num_to_bin(uint32_t val, char *out, int size) 
{
    uint32_t n;
    for(n = 1; n <= size; n++) {
        out[n - 1] = (val & (1 << (n - 1))) >> (n - 1);
    }
}

int main() {
    FILE *fp = stdin;
    char *line = NULL;
    size_t len = 0;
    ssize_t read;
    char out[32];
    uint32_t n;

    ling_data ling;

    n = 0;

    ling_init(&ling);
    ling_func *fl = ling_create_flist(&ling);
    ling_register_func(&ling, fl);
    
    while((read = getline(&line, &len, fp)) != -1) {
        ling_parse_line(&ling, line);
    }
    free(line);
    ling_seq_run(&ling);
    uint32_t val = ling_stack_pop(&ling.stack);

    num_to_bin(val, out, 32);

    //printf("%d\n", val);
    for(n = 0; n < 32; n++) 
    printf("%d", out[31 - n]);

    printf("\n");

    ling_destroy(&ling);
    return 0;
}
