#import "TestModule.h"


@implementation TestModule

- (void)configure:(id<BSBinder>)binder {
    [super configure:binder];
    [binder bind:@"theMessage" toInstance:@"Hello Earth"];
}

@end