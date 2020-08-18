// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSTKInstrumentDSP.hpp"

#include "Mandolin.h"
#include "mand_raw.h"

class AKMandolinStringDSP : public AKSTKInstrumentDSP {
private:
    stk::Mandolin *mandolin = nullptr;

public:
    AKMandolinStringDSP() {}
    ~AKMandolinStringDSP() = default;

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        // Create temporary raw files
        NSError *error = nil;
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                      stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]
                                         isDirectory:YES];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error] == YES) {
            NSURL *mand1URL = [directoryURL URLByAppendingPathComponent:@"mand1.raw"];
            if ([manager fileExistsAtPath:mand1URL.path] == NO) { // Create files once
                [[NSData dataWithBytesNoCopy:mand1 length:mand1_len freeWhenDone:NO] writeToURL:mand1URL atomically:YES];
                [[NSData dataWithBytesNoCopy:mand2 length:mand2_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand2.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand3 length:mand3_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand3.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand4 length:mand4_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand4.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand5 length:mand5_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand5.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand6 length:mand6_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand6.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand7 length:mand7_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand7.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand8 length:mand8_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand8.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand9 length:mand9_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand9.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand10 length:mand10_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand10.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand11 length:mand11_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand11.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand12 length:mand12_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand12.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mandpluk length:mandpluk_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mandpluk.raw"] atomically:YES];
            }
        } else {
            NSLog(@"Failed to create temporary directory at path %@ with error %@", directoryURL, error);
        }

        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);

        stk::Stk::setSampleRate(sampleRate);
        mandolin = new stk::Mandolin(/*lowestFrequency*/100);
    }

    stk::Instrmnt* getInstrument() override {
        return mandolin;
    }

    void deinit() override {
        AKDSPBase::deinit();
        delete mandolin;
        mandolin = nullptr;
    }

};

AK_REGISTER_DSP(AKMandolinStringDSP);
