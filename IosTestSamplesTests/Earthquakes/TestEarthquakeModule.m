#import <Blindside/BSBinder.h>
#import "TestEarthquakeModule.h"


@implementation TestEarthquakeModule

- (void)configure:(id <BSBinder>)binder {
    [super configure:binder];
    [binder bind:@"apiHost" toInstance:TEST_API_HOST];
}

@end