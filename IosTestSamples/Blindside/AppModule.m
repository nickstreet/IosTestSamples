#import "AppModule.h"

@implementation AppModule 

- (void)configure:(id<BSBinder>)binder {
    [binder bind:@"theMessage" toInstance:@"Hello world"];
    [binder bind:@"apiHost" toInstance:@"http://api.geonames.org"];
}

@end
