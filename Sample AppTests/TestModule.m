//
// Created by Nick Street on 07/06/15.
// Copyright (c) 2015 Nick Street. All rights reserved.
//

#import "TestModule.h"


@implementation TestModule

- (void)configure:(id<BSBinder>)binder {
    [super configure:binder];
    [binder bind:@"theMessage" toInstance:@"Hello Earth"];
}

@end