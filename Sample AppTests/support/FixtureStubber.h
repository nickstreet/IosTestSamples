#import <Foundation/Foundation.h>


@interface FixtureStubber : NSObject
+ (void)stubUrl:(NSString *)url withFilename:(NSString *)filename;
@end