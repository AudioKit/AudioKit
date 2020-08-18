// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSTKInstrumentDSP.hpp"

#include "TubeBell.h"
#include "sinewave_raw.h"
#include "fwavblnk_raw.h"

class AKTubularBellsDSP : public AKSTKInstrumentDSP {
private:
    stk::TubeBell *tubularBells = nullptr;

public:
    AKTubularBellsDSP() {}
    ~AKTubularBellsDSP() = default;

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        NSError *error = nil;
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                      stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]
                                         isDirectory:YES];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error] == YES) {
            NSURL *sineURL = [directoryURL URLByAppendingPathComponent:@"sinewave.raw"];
            if ([manager fileExistsAtPath:sineURL.path] == NO) { // Create files once
                [[NSData dataWithBytesNoCopy:sinewave length:sinewave_len freeWhenDone:NO] writeToURL:sineURL atomically:YES];
                [[NSData dataWithBytesNoCopy:fwavblnk length:fwavblnk_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"fwavblnk.raw"] atomically:YES];
            }
        } else {
            NSLog(@"Failed to create temporary directory at path %@ with error %@", directoryURL, error);
        }

        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);

        stk::Stk::setSampleRate(sampleRate);
        tubularBells = new stk::TubeBell();
    }

    stk::Instrmnt* getInstrument() override {
        return tubularBells;
    }

    void deinit() override {
        AKDSPBase::deinit();
        delete tubularBells;
        tubularBells = nullptr;
    }

};

AK_REGISTER_DSP(AKTubularBellsDSP);
