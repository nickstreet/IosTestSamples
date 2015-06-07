#import <Cedar/Cedar.h>
#import "ViewController.h"
#import "AppModule.h"
#import "BlindsidedStoryboard.h"
#import "TestModule.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

SPEC_BEGIN(ViewControllerSpec)

describe(@"ViewController", ^{
    __block ViewController *controller;

    describe(@"A basic blindside injector test", ^{
        beforeEach(^{
            id injector = [Blindside injectorWithModule:[[AppModule alloc] init]];
            UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Main" bundle:nil injector:injector];
            controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];

            UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            window.rootViewController = controller;
            [window makeKeyAndVisible];
            [window layoutIfNeeded];
        });

        it(@"displays a message to the user", ^{
            controller.label.text should equal(@"Hello world");
        });
    });

    describe(@"Overriding injector properties in a test module", ^{
        beforeEach(^{
            id injector = [Blindside injectorWithModule:[[TestModule alloc] init]];
            UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Main" bundle:nil injector:injector];
            controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];

            UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            window.rootViewController = controller;
            [window makeKeyAndVisible];
            [window layoutIfNeeded];
        });

        it(@"displays a message to the user", ^{
            controller.label.text should equal(@"Hello Earth");
        });
    });

    describe(@"Overriding injector properties in a specific test", ^{
        beforeEach(^{
            id injector = [Blindside injectorWithModule:[[AppModule alloc] init]];

            [injector bind:@"theMessage" toInstance:@"Hello Mars"];

            UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Main" bundle:nil injector:injector];
            controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];

            UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            window.rootViewController = controller;
            [window makeKeyAndVisible];
            [window layoutIfNeeded];
        });

        it(@"displays a message to the user", ^{
            controller.label.text should equal(@"Hello Mars");
        });
    });

});

SPEC_END
