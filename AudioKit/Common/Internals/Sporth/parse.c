#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "plumber.h"

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
    LEX_POS,
    LEX_NEG,
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
                /* *pos = *pos + 1; */
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

/* This code is public domain -- Will Hartung 4/9/09 */

size_t sporth_getline(char **lineptr, size_t *n, FILE *stream) {
    char *bufptr = NULL;
    char *p = bufptr;
    size_t size;
    int c;

    if (lineptr == NULL) {
        return -1;
    }
    if (stream == NULL) {
        return -1;
    }
    if (n == NULL) {
        return -1;
    }
    bufptr = *lineptr;
    size = *n;

    c = fgetc(stream);
    if (c == EOF) {
        return -1;
    }
    if (bufptr == NULL) {
        bufptr = malloc(128);
        if (bufptr == NULL) {
            return -1;
        }
        size = 128;
    }
    p = bufptr;
    while(c != EOF) {
        if ((p - bufptr) > (size - 1)) {
            size = size + 128;
            bufptr = realloc(bufptr, size);
            if (bufptr == NULL) {
                return -1;
            }
        }
        *p++ = c;
        if (c == '\n') {
            break;
        }
        c = fgetc(stream);
    }

    *p++ = '\0';
    *lineptr = bufptr;
    *n = size;

    return p - bufptr - 1;
}

void sporth_print(sporth_data *sporth, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vfprintf(stderr, fmt, args);
    va_end(args);
}

int plumber_lexer(plumber_data *plumb, plumbing *pipes, char *out, uint32_t len)
{
    char *tmp;
    float flt = 0;
    int rc;
    switch(sporth_lexer(out, len)) {
        case SPORTH_FLOAT:
#ifdef DEBUG_MODE
            plumber_print(plumb, "%s is a float!\n", out);
#endif
            flt = atof(out);
            plumber_add_float(plumb, pipes, flt);
            sporth_stack_push_float(&plumb->sporth.stack, flt);
            break;
        case SPORTH_STRING:
            tmp = out;
            tmp[len - 1] = '\0';
            tmp++;
#ifdef DEBUG_MODE
            plumber_print(plumb, "%s is a string!\n", out);
#endif
            tmp = plumber_add_string(plumb, pipes, tmp);
            sporth_stack_push_string(&plumb->sporth.stack, &tmp);
            break;
        case SPORTH_WORD:
            /* A sporth word is like a string, except it looks like _this
             * instead of "this" or 'this'.
             * It saves a character, and it can make things look nicer. 
             * A sporth word has no spaces, hence the name.
             */
            tmp = out;
            /* don't truncate the last character here like the string */
            tmp[len] = '\0';
            tmp++;
#ifdef DEBUG_MODE
            plumber_print(plumb, "%s is a word!\n", out);
#endif
            tmp = plumber_add_string(plumb, pipes, tmp);
            sporth_stack_push_string(&plumb->sporth.stack, &tmp);
            break;
        case SPORTH_FUNC:
#ifdef DEBUG_MODE
            plumber_print(plumb, "%s is a function!\n", out);
#endif
            rc = sporth_exec(&plumb->sporth, out);
            if(rc == PLUMBER_NOTOK || rc == SPORTH_NOTOK) {
                plumber_print(plumb, "%s returned an error.\n", out);
#ifdef DEBUG_MODE
            plumber_print(plumb, "plumber_lexer: error with function %s\n", out);
#endif
                plumb->sporth.stack.error++;
                return PLUMBER_NOTOK;
            }
            break;
        case SPORTH_IGNORE:
            break;
        default:
#ifdef DEBUG_MODE
            plumber_print(plumb,"No idea what %s is!\n", out);
#endif
            break;
    }
    return PLUMBER_OK;
}

int plumbing_parse(plumber_data *plumb, plumbing *pipes)
{
    FILE *fp = plumb->fp;
    char *line = NULL;
    size_t length = 0;
    ssize_t read;
    char *out;
    uint32_t pos = 0, len = 0;
    int err = PLUMBER_OK;
    plumb->mode = PLUMBER_CREATE;

    /* save top level tmp variable. */
    plumbing *top_tmp = plumb->tmp;
    plumb->tmp = pipes;

    while((read = sporth_getline(&line, &length, fp)) != -1 && err == PLUMBER_OK) {
        pos = 0;
        len = 0;
        while(pos < read - 1) {
            out = sporth_tokenizer(line, (unsigned int)read - 1, &pos);
            len = (unsigned int)strlen(out);
            err = plumber_lexer(plumb, pipes, out, len);
            free(out);
            if(err == PLUMBER_NOTOK) break;
        }
    }
    free(line);

    /* restore tmp */
    plumb->tmp = top_tmp;
    return err;

}

int plumbing_parse_string(plumber_data *plumb, plumbing *pipes, char *str)
{
    char *out;
    uint32_t pos = 0, len = 0;
    uint32_t size = (unsigned int)strlen(str);
    int err = PLUMBER_OK;
    pos = 0;
    len = 0;
    plumb->mode = PLUMBER_CREATE;

    /* save top level tmp variable. */
    plumbing *top_tmp = plumb->tmp;
    plumb->tmp = pipes;

    while(pos < size) {
        out = sporth_tokenizer(str, size, &pos);
        len = (unsigned int)strlen(out);
        err = plumber_lexer(plumb, pipes, out, len);
        free(out);
        if(err == PLUMBER_NOTOK) break;
    }

    /* restore tmp */
    plumb->tmp = top_tmp;
    return err;
}

int plumber_parse(plumber_data *plumb)
{
    return plumbing_parse(plumb, plumb->pipes);
}

int plumber_reparse(plumber_data *plumb) 
{
    if(plumbing_parse(plumb, plumb->tmp) == PLUMBER_OK) {
        plumbing_compute(plumb, plumb->tmp, PLUMBER_INIT);
#ifdef DEBUG_MODE
        plumber_print(plumb, "Successful parse...\n");
        plumber_print(plumb, "at stack position %d\n",
                plumb->sporth.stack.pos);
        plumber_print(plumb, "%d errors\n",
                plumb->sporth.stack.error);
#endif
    } else {
       return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int plumber_reparse_string(plumber_data *plumb, char *str) 
{
    plumbing *pipes = plumb->tmp;
    if(plumbing_parse_string(plumb, pipes, str) == PLUMBER_OK) {
#ifdef DEBUG_MODE
        plumber_print(plumb, "Successful parse...\n");
        plumber_print(plumb, "at stack position %d\n",
                plumb->sporth.stack.pos);
        plumber_print(plumb, "%d errors\n",
                plumb->sporth.stack.error);
#endif
        plumb->tmp = pipes;
    } else {
        plumb->tmp = pipes;
        return PLUMBER_NOTOK;
    }
    return PLUMBER_OK;
}

int plumber_swap(plumber_data *plumb, int error)
{
    if(error == PLUMBER_NOTOK) {
        plumber_print(plumb, "Did not recompile...\n");
        plumbing_compute(plumb, plumb->tmp, PLUMBER_DESTROY);
        plumbing_destroy(plumb->tmp);
        sporth_stack_init(&plumb->sporth.stack);
        plumber_ftmap_destroy(plumb);
        plumb->ftmap = plumb->ftold;
        plumb->current_pipe = (plumb->current_pipe == 0) ? 1 : 0;
        if(plumb->current_pipe == 1) {
#ifdef DEBUG_MODE
            plumber_print(plumb, "Reverting to alt\n");
#endif
            plumb->pipes = &plumb->alt;
        } else {
#ifdef DEBUG_MODE
            plumber_print(plumb, "Reverting to main\n");
#endif
            plumb->pipes = &plumb->main;
        }
        plumb->sp->pos = 0;
    } else {
#ifdef DEBUG_MODE
        plumber_print(plumb, "Recompiling...\n");
#endif
        plumbing_compute(plumb, plumb->pipes, PLUMBER_DESTROY);
        plumbing_destroy(plumb->pipes);
        plumb->ftmap = plumb->ftold;
        plumber_ftmap_destroy(plumb);
        plumb->ftmap = plumb->ftnew;
        plumb->pipes = plumb->tmp;
        plumb->sp->pos = 0;
        plumbing_compute(plumb, plumb->pipes, PLUMBER_INIT);
    }
    return PLUMBER_OK;
}

int plumber_recompile(plumber_data *plumb)
{
    int error;
    plumber_reinit(plumb);
    error = plumber_reparse(plumb);
    plumber_swap(plumb, error);
    return PLUMBER_OK;
}

int plumber_recompile_string(plumber_data *plumb, char *str)
{

    int error;
#ifdef DEBUG_MODE
    plumber_print(plumb, "** Attempting to compile string '%s' **\n", str);
#endif
    /* file pointer needs to be NULL for reinit to work with strings */
    plumb->fp = NULL;
    plumber_reinit(plumb);
    error = plumber_reparse_string(plumb, str);
    plumber_swap(plumb, error);
    return PLUMBER_OK;
}

/* This version of plumber_recompile_string includes a callback function,
 * to be called after it is reinitialized, but before the string
 * is parsed. Useful for adding global ftables.
 */
int plumber_recompile_string_v2(plumber_data *plumb, 
        char *str, 
        void *ud,
        int (*callback)(plumber_data *, void *))
{

    int error;
#ifdef DEBUG_MODE
    plumber_print(plumb, "** Attempting to compile string '%s' **\n", str);
#endif
    /* file pointer needs to be NULL for reinit to work with strings */
    plumb->fp = NULL;
    plumber_reinit(plumb);
    callback(plumb, ud);
    error = plumber_reparse_string(plumb, str);
    plumber_swap(plumb, error);
    return PLUMBER_OK;
}

int plumber_parse_string(plumber_data *plumb, char *str)
{
    return plumbing_parse_string(plumb, plumb->pipes, str);
}

