
#import <XCTest/XCTest.h>
#import <CAudioKit.h>
#import <soundpipe.h>
#import <sporth.h>
#import <plumber.h>

@interface SoundpipePerfTests : XCTestCase

@end

@implementation SoundpipePerfTests

static int sampleRate = 44100;
static int channelCount = 2;
static int iterations = 60 * 44100;

- (void) testOscPerf {
    
    sp_data *sp;
    sp_create(&sp);
    sp->sr = sampleRate;
    sp->nchan = channelCount;
    
    sp_ftbl *ftbl;
    sp_ftbl_create(sp, &ftbl, 8192);
    sp_gen_triangle(sp, ftbl);
    
    sp_osc *osc;
    sp_osc_create(&osc);
    sp_osc_init(sp, osc, ftbl, 0);
    
    osc->freq = 440;
    
    [self measureBlock:^{
        for(int i=0;i<iterations;++i) {
            float y = 0;
            sp_osc_compute(sp, osc, NULL, &y);
        }
    }];
    
    sp_ftbl_destroy(&ftbl);
    sp_osc_destroy(&osc);
    sp_destroy(&sp);
}

- (void) testSporthOscPerf {
    
    sp_data *sp;
    sp_create(&sp);
    sp->sr = sampleRate;
    sp->nchan = channelCount;
    
    plumber_data pd;
    plumber_register(&pd);
    plumber_init(&pd);
    
    pd.sp = sp;
    plumber_parse_string(&pd, "440 1 sine");
    plumber_compute(&pd, PLUMBER_INIT);
    
    auto *pdp = &pd;
    
    [self measureBlock:^{
        for(int i=0;i<iterations;++i) {
            plumber_compute(pdp, PLUMBER_COMPUTE);
            float y = sporth_stack_pop_float(&pdp->sporth.stack);
        }
    }];
    
    plumber_clean(&pd);
    sp_destroy(&sp);
}

@end
