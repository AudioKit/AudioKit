extern "C" {
#include <soundpipe.h>    
}

#include "ModalBar.h"

typedef struct {
    stk::ModalBar *bar;
} UserData;

void process(sp_data *sp, void *udata)
{
    UserData *ud = (UserData *)udata;
    if(sp->pos == 0) {
        ud->bar->noteOn(440, 0.5);
    }
    sp->out[0] = ud->bar->tick();
}

int main()
{
sp_data *sp;
UserData ud;
sp_create(&sp);
//stk::Stk::setRawwavePath("./rawwaves");
stk::Stk::setSampleRate(sp->sr);
ud.bar = new stk::ModalBar();
sp_process(sp, &ud, process);
delete ud.bar;
sp_destroy(&sp);
}
