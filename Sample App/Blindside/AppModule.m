//
//  AppModule.m
//  Sample App
//
//  Created by Nick Street on 06/06/2015.
//  Copyright (c) 2015 Nick Street. All rights reserved.
//

#import "AppModule.h"

@implementation AppModule 

- (void)configure:(id<BSBinder>)binder {
    [binder bind:@"theMessage" toInstance:@"Hello world"];
}

@end
