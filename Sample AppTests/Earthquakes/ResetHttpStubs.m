//
// Created by Nick Street on 07/06/15.
// Copyright (c) 2015 Nick Street. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "ResetHttpStubs.h"


@implementation ResetHttpStubs

+ (void)beforeEach {
    [OHHTTPStubs removeAllStubs];
}

@end