//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//


@import Foundation;

@protocol KZPSnapshotView <NSObject>
@required
- (BOOL)hasExtraInformation;
- (UIViewController*)extraInfoController;
@end