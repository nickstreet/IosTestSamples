#import "AppModule.h"

@implementation AppModule 

- (void)configure:(id<BSBinder>)binder {
    [binder bind:@"theMessage" toInstance:@"Hello world"];
}

@end
