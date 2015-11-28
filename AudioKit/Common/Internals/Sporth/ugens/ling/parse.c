#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "sporth.h"
#include "ling.h"

enum {
    SPACE,
    SEEK,
    COMMENT,
    LEX_START,
    LEX_FLOAT,
    LEX_FLOAT_DOT,
    LEX_FLOAT_POSTDOT,
    LEX_FUNC,
    LEX_ERROR,
    LEX_IGNORE,
    LEX_DASH
};

char * ling_tokenizer(ling_data *ld, char *str,
        uint32_t size, uint32_t *pos)
{
    char c;
    uint32_t offset = 0;
    int mode = SEEK;
    uint32_t prev = *pos;
    char *out;
    int running = 1;
    while(*pos < size && running) {
        c = str[*pos];
        switch(mode) {
            case SEEK:
                switch(c) {
                    case '\n':
                    case ' ':
                        mode = SPACE;
                        *pos = *pos + 1;
                        break;
                    case '#':
                        mode = COMMENT;
                        break;
                    default:
                        *pos = *pos + 1;
                        offset++;
                        break;
                }
                break;
            case SPACE:
                switch(c) {
                    case ' ':
                        *pos = *pos + 1;
                        break;
                    default:
                        running = 0;
                        break;
                }
                break;
            case COMMENT:
                *pos = *pos + 1;
                break;
            default:
                printf("This shouldn't happen. Eep.\n");
                break;
        }
    }
    /* TODO: make it so malloc is not needed */
    out = malloc(sizeof(char) * offset + 1);
    strncpy(out, &str[prev], offset);
    out[offset] = '\0';
    return out;
}

int ling_lexer(ling_data *ld, char *str, int32_t size)
{
    char c;
    int mode = LEX_START;
    uint32_t pos = 0;
    while(pos < size) {
        c = str[pos++];
        switch(mode) {
            case LEX_START:
                switch(c) {
                    case '-':
                        mode = LEX_DASH;
                        break;
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                        mode = LEX_FLOAT;
                        break;
                    case '#':
                        mode = LEX_IGNORE;
                        break;
                    default:
                        mode = LEX_FUNC;
                        break;
                }
                break;
            case LEX_DASH:
                mode = LEX_FLOAT;
            case LEX_FLOAT:
                switch(c) {
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                        break;
                    case '.':
                        mode = LEX_FLOAT_DOT;
                        break;
                    default:
                        return LEX_ERROR;
                }
                break;
            case LEX_FLOAT_DOT:
                switch(c) {
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                        mode = LEX_FLOAT_POSTDOT;
                        break;
                    default:
                        return LEX_ERROR;
                }
                break;
            case LEX_FLOAT_POSTDOT:
                switch(c) {
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9':
                        break;
                    default:
                        return LEX_ERROR;
                }
                break;
            case LEX_FUNC:
                break;
            case LEX_IGNORE:
                break;
            default:
                return LEX_ERROR;
        }
    }

    switch(mode) {
        case LEX_FLOAT:
        case LEX_FLOAT_DOT:
        case LEX_FLOAT_POSTDOT:
            return LING_INT;
        case LEX_IGNORE:
            return LING_IGNORE;
        case LEX_DASH:
        case LEX_FUNC:
            return LING_FUNC;
        case LEX_START:
            if(size == 0) {
                return LING_IGNORE;
            }
        default:
            return LING_NOTOK;
    }
    return LING_NOTOK;
}
