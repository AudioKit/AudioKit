/*67:*/
#line 54 "./ugen.w"

#include <stdlib.h> 
#include <math.h> 
#include <string.h> 
#ifdef BUILD_SPORTH_PLUGIN
#include <soundpipe.h> 
#include <sporth.h> 
#include "voc.h"
#else
#include "plumber.h"
#endif

#ifdef BUILD_SPORTH_PLUGIN
static int sporth_voc(plumber_data*pd,sporth_stack*stack,void**ud)
#else
int sporth_voc(sporth_stack*stack,void*ud)
#endif
{
sp_voc*voc;
SPFLOAT out;
SPFLOAT freq;
SPFLOAT pos;
SPFLOAT diameter;
SPFLOAT tenseness;
SPFLOAT nasal;
#ifndef BUILD_SPORTH_PLUGIN
plumber_data*pd;
pd= ud;
#endif


switch(pd->mode){
case PLUMBER_CREATE:
/*68:*/
#line 113 "./ugen.w"


sp_voc_create(&voc);
#ifdef BUILD_SPORTH_PLUGIN
*ud= voc;
#else
plumber_add_ugen(pd,SPORTH_VOC,voc);
#endif
if(sporth_check_args(stack,"fffff")!=SPORTH_OK){
plumber_print(pd,"Voc: not enough arguments!\n");
}
nasal= sporth_stack_pop_float(stack);
tenseness= sporth_stack_pop_float(stack);
diameter= sporth_stack_pop_float(stack);
pos= sporth_stack_pop_float(stack);
freq= sporth_stack_pop_float(stack);
sporth_stack_push_float(stack,0.0);

/*:68*/
#line 87 "./ugen.w"
;
break;
case PLUMBER_INIT:
/*69:*/
#line 140 "./ugen.w"

#ifdef BUILD_SPORTH_PLUGIN
voc= *ud;
#else
voc= pd->last->ud;
#endif
sp_voc_init(pd->sp,voc);
nasal= sporth_stack_pop_float(stack);
tenseness= sporth_stack_pop_float(stack);
diameter= sporth_stack_pop_float(stack);
pos= sporth_stack_pop_float(stack);
freq= sporth_stack_pop_float(stack);
sporth_stack_push_float(stack,0.0);

/*:69*/
#line 90 "./ugen.w"
;
break;

case PLUMBER_COMPUTE:
/*70:*/
#line 162 "./ugen.w"

#ifdef BUILD_SPORTH_PLUGIN
voc= *ud;
#else
voc= pd->last->ud;
#endif
nasal= sporth_stack_pop_float(stack);
tenseness= sporth_stack_pop_float(stack);
diameter= sporth_stack_pop_float(stack);
pos= sporth_stack_pop_float(stack);
freq= sporth_stack_pop_float(stack);
sp_voc_set_frequency(voc,freq);
sp_voc_set_tenseness(voc,tenseness);

if(sp_voc_get_counter(voc)==0){
sp_voc_set_velum(voc,0.01+0.8*nasal);
sp_voc_set_tongue_shape(voc,12+16.0*pos,diameter*3.5);
}

sp_voc_compute(pd->sp,voc,&out);
sporth_stack_push_float(stack,out);

/*:70*/
#line 94 "./ugen.w"
;
break;

case PLUMBER_DESTROY:
/*71:*/
#line 189 "./ugen.w"

#ifdef BUILD_SPORTH_PLUGIN
voc= *ud;
#else
voc= pd->last->ud;
#endif
sp_voc_destroy(&voc);

/*:71*/
#line 98 "./ugen.w"
;
break;
}
return PLUMBER_OK;
}

/*72:*/
#line 201 "./ugen.w"

#ifdef BUILD_SPORTH_PLUGIN
plumber_dyn_func sporth_return_ugen()
{
return sporth_voc;
}
#endif

/*:72*/
#line 104 "./ugen.w"


/*:67*//*73:*/
#line 210 "./ugen.w"


#ifdef BUILD_SPORTH_PLUGIN
static int sporth_tract(plumber_data*pd,sporth_stack*stack,void**ud)
{
sp_voc*voc;
SPFLOAT out;
SPFLOAT pos;
SPFLOAT diameter;
SPFLOAT nasal;
SPFLOAT in;

switch(pd->mode){
case PLUMBER_CREATE:
sp_voc_create(&voc);
*ud= voc;
if(sporth_check_args(stack,"ffff")!=SPORTH_OK){
plumber_print(pd,"Voc: not enough arguments!\n");
}
nasal= sporth_stack_pop_float(stack);
diameter= sporth_stack_pop_float(stack);
pos= sporth_stack_pop_float(stack);
in= sporth_stack_pop_float(stack);

sporth_stack_push_float(stack,0.0);
break;
case PLUMBER_INIT:
voc= *ud;
sp_voc_init(pd->sp,voc);
nasal= sporth_stack_pop_float(stack);
diameter= sporth_stack_pop_float(stack);
pos= sporth_stack_pop_float(stack);
in= sporth_stack_pop_float(stack);

sporth_stack_push_float(stack,0.0);
break;
case PLUMBER_COMPUTE:
voc= *ud;
nasal= sporth_stack_pop_float(stack);
diameter= sporth_stack_pop_float(stack);
pos= sporth_stack_pop_float(stack);
in= sporth_stack_pop_float(stack);

if(sp_voc_get_counter(voc)==0){
sp_voc_set_velum(voc,0.01+0.8*nasal);
sp_voc_set_tongue_shape(voc,12+16.0*pos,diameter*3.5);
}

sp_voc_tract_compute(pd->sp,voc,&in,&out);
sporth_stack_push_float(stack,out);
break;
case PLUMBER_DESTROY:
voc= *ud;
sp_voc_destroy(&voc);
break;
}

return PLUMBER_OK;
}
#endif
/*:73*//*74:*/
#line 274 "./ugen.w"

#ifdef BUILD_SPORTH_PLUGIN
static const plumber_dyn_func sporth_functions[]= {
sporth_voc,
sporth_tract,
};

int sporth_return_ugen_multi(int n,plumber_dyn_func*f)
{
if(n<0||n> 1){
return PLUMBER_NOTOK;
}
*f= sporth_functions[n];
return PLUMBER_OK;
}
#endif

/*:74*/
