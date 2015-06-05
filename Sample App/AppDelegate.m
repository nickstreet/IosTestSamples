//
//  AppDelegate.m
//  Sample App
//
//  Created by Nick Street on 05/06/2015.
//  Copyright (c) 2015 Nick Street. All rights reserved.
//

#import "AppDelegate.h"
#import "BlindsidedStoryboard.h"
#import "AppModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    id<BSModule> module = [AppModule new];
    id<BSInjector> injector = [Blindside injectorWithModule:module];
     
    UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Main" bundle:nil injector:injector];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
