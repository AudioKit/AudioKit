typedef struct {
    SPFLOAT freq;
    SPFLOAT pos;
    SPFLOAT diam;
    SPFLOAT tenseness;
    SPFLOAT nasal;
    sp_voc *voc;
} sp_vocwrapper;

int sp_vocwrapper_create(sp_vocwrapper **p);
int sp_vocwrapper_destroy(sp_vocwrapper **p);
int sp_vocwrapper_init(sp_data *sp, sp_vocwrapper *p);
int sp_vocwrapper_compute(sp_data *sp, sp_vocwrapper *p, SPFLOAT *in, SPFLOAT *out);
