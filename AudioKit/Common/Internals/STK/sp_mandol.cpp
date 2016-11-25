extern "C" {
#include <soundpipe.h>    
}

#include "Mandolin.h"

typedef struct {
    stk::Mandolin *mand;
} UserData;

void process(sp_data *sp, void *udata)
{
    UserData *ud = (UserData *)udata;
    if(sp->pos == 0) {
        ud->mand->noteOn(440, 0.5);
    }
    sp->out[0] = ud->mand->tick();
}

int main()
{
sp_data *sp;
UserData ud;
sp_create(&sp);
stk::Stk::setRawwavePath("./rawwaves");
stk::Stk::setSampleRate(sp->sr);
ud.mand = new stk::Mandolin(100);
sp_process(sp, &ud, process);
delete ud.mand;
sp_destroy(&sp);
}
