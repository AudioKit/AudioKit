#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "h/sporth.h"

enum {
    SPACE,
    STRING,
    SEEK,
    COMMENT,
    LEX_START,
    LEX_FLOAT,
    LEX_FLOAT_DOT,
    LEX_FLOAT_POSTDOT,
    LEX_STRING,
    LEX_FUNC,
    LEX_ERROR,
    LEX_IGNORE,
    LEX_DASH,
    LEX_WORD
};

char * sporth_tokenizer(char *str,
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
                    case '(':
                    case ')':
                    case '\n':
                    case ' ':
                        mode = SPACE;
                        *pos = *pos + 1;
                        break;
                    case '\'':
                    case '"':
                        mode = STRING;
                        *pos = *pos + 1;
                        offset++;
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
            case STRING:
                switch(c) {
                    case '\'':
                    case '"':
                        mode = SPACE;
                        *pos = *pos + 1;
                        offset++;
                        break;
                    default:
                        *pos = *pos + 1;
                        offset++;
                        break;
                }
                break;
            case COMMENT:
                //*pos = *pos + 1;
                switch(c) {
                    case '\n':
                        mode = SPACE;
                        *pos = *pos + 1;
                        offset++;
                        break;
                    default:
                        *pos = *pos + 1;
                        break;
                }
                break;
            default:
                printf("This shouldn't happen. Eep.\n");
                break;
        }
    }
    out = malloc(sizeof(char) * offset + 1);
    strncpy(out, &str[prev], offset);
    out[offset] = '\0';
    return out;
}

int sporth_lexer(char *str, int32_t size)
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
                    case '"':
                    case '\'':
                        mode = LEX_STRING;
                        break;
                    case '_':
                        mode = LEX_WORD;
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
            case LEX_STRING:
                break;
            case LEX_WORD:
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
            return SPORTH_FLOAT;
        case LEX_STRING:
            return SPORTH_STRING;
        case LEX_WORD:
            return SPORTH_WORD;
        case LEX_IGNORE:
            return SPORTH_IGNORE;
        case LEX_DASH:
        case LEX_FUNC:
            return SPORTH_FUNC;
        case LEX_START:
            if(size == 0) {
                return SPORTH_IGNORE;
            }
        default:
            return SPORTH_NOTOK;
    }
    return SPORTH_NOTOK;
}
