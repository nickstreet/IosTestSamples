#import "AppDelegate.h"
#import "BlindsidedStoryboard.h"
#import "AppModule.h"
#import "EarthquakeModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    id<BSModule> module = [EarthquakeModule new];
    id<BSInjector> injector = [Blindside injectorWithModule:module];
     
    UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Earthquakes" bundle:nil injector:injector];
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = viewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
