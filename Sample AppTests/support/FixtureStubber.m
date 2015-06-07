//
// Created by Nick Street on 07/06/15.
// Copyright (c) 2015 Nick Street. All rights reserved.
//

#import "FixtureStubber.h"
#import "OHHTTPStubs.h"
#import "OHPathHelpers.h"


@implementation FixtureStubber


+(void)stubUrl:(NSString*)url withFilename:(NSString *)filename {

    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:url];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSBundle* bundle = [NSBundle bundleForClass:self.class];
        NSString *fixtureFilePath = [bundle pathForResource:[filename stringByDeletingPathExtension]
                                                ofType:[filename pathExtension]];

        return [OHHTTPStubsResponse responseWithFileAtPath:fixtureFilePath
                                                statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }];

}
@end