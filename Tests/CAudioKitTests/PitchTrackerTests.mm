
#import <XCTest/XCTest.h>
#import <CAudioKit.h>

@interface PitchTrackerTests : XCTestCase

@end

@implementation PitchTrackerTests

static int sampleRate = 44100;

- (void) testPitchTrackerBasic {

    auto tracker = akPitchTrackerCreate(sampleRate, 4096, 20);
    auto frameCount = sampleRate;

    std::vector<float> frames(frameCount);

    // Generate 440Hz sine wave.
    for(int i=0;i<frameCount;++i) {
        frames[i] = sin( 2 * M_PI * 440.0 * (double(i) / sampleRate) );
    }

    akPitchTrackerAnalyze(tracker, frames.data(), frameCount);
    akPitchTrackerDestroy(tracker);

    float amp, freq;
    akPitchTrackerGetResults(tracker, &amp, &freq);

    float epilon = 0.1;
    XCTAssertEqualWithAccuracy(amp, 2.0, epilon);
    XCTAssertEqualWithAccuracy(freq, 440.0, epilon);

}

@end
