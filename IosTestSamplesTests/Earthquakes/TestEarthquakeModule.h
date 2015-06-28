#import <Foundation/Foundation.h>
#import <Blindside/BSModule.h>
#import "AppModule.h"


static NSString *const TEST_API_HOST = @"http://localhost:6666";

@interface TestEarthquakeModule : AppModule <BSModule>
@end