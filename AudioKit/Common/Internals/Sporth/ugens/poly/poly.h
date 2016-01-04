typedef struct poly_event {
    uint32_t delta;
    uint32_t timer;
    uint32_t pos;
    struct poly_event *next;
    float *p;
    uint16_t nvals;
} poly_event;

typedef struct {
    poly_event *root;
    poly_event *last;
    poly_event *next;
    uint32_t nevents;
} poly_iterator;

typedef struct {
    poly_iterator itr;
    poly_event root;
    poly_event *last;
    uint32_t total_events;
    uint32_t pos;
    uint32_t end_of_events;
    FILE *fp;
} poly_data;

typedef struct poly_voice {
    int val;
    struct poly_voice *next;
} poly_voice;


typedef struct {
    poly_voice *voice;
    poly_voice root;
    poly_voice *last;
    poly_voice *tmp;
    int nvoices;
    int total_voices;
    int pos;
    int *stack;
} poly_cluster;

int poly_init(poly_data *cd);
int poly_destroy(poly_data *cd);
int poly_itr_reset(poly_data *cd);
poly_event * poly_itr_next(poly_data *cd);
int poly_end(poly_data *cd);
int poly_compute(poly_data *cd);
uint32_t poly_nevents(poly_data *cd);
int poly_add(poly_data *cd, uint32_t delta, uint16_t nvals);
int poly_pset(poly_data *cd, uint32_t pos, float val);

/* Binary file operations */
int poly_binary_open(poly_data *cd, char *filename);
int poly_binary_close(poly_data *cd);
int poly_binary_write(poly_data *cd, float delta, uint16_t nvals, float *vals);
int poly_binary_parse(poly_data *cd, char *filename, float scale);

int poly_cluster_init(poly_cluster *clust, int nvals);
int poly_cluster_destroy(poly_cluster *clust);
int poly_cluster_add(poly_cluster *clust, int *id);
int poly_cluster_remove(poly_cluster *clust, int id);
int poly_cluster_nvoices(poly_cluster *clust);
int poly_cluster_reset(poly_cluster *clust);
poly_voice* poly_next_voice(poly_cluster *clust);
