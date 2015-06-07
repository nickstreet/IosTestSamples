#import <OHHTTPStubs/OHHTTPStubs.h>
#import "ResetHttpStubs.h"


@implementation ResetHttpStubs

+ (void)beforeEach {
    [OHHTTPStubs removeAllStubs];
}

@end