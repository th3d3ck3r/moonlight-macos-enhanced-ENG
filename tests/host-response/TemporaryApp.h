#pragma once
#import <Foundation/Foundation.h>
// Minimal model boundary: the production XML parser is compiled unchanged.
@interface TemporaryApp : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *installPath;
@property(nonatomic) BOOL hdrSupported;
@end
