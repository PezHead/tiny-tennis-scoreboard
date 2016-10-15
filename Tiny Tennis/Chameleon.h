//
//  Chameleon.h
//  Tiny Tennis
//
//  Created by David Bireta on 10/15/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Chameleon : NSObject

+ (UIColor *)colorWithHexString:(NSString *)string;
+ (UIColor *)colorWithHexString:(NSString *)string withAlpha:(CGFloat)alpha;
+ (unsigned)hexValueToUnsigned:(NSString *)hexValue;

@end
