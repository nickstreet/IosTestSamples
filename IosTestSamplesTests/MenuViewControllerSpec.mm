#import <Cedar/Cedar.h>
#import "MenuViewController.h"
#import "AppModule.h"
#import "TestModule.h"
#import "CedarAsync.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MenuViewController ()
@property(weak, nonatomic) IBOutlet UILabel *messageLabel;
@property(weak, nonatomic) IBOutlet UIButton *earthquakesButton;
@end

SPEC_BEGIN(MenuViewControllerSpec)

    describe(@"MenuViewController", ^{
        __block MenuViewController *controller;

        describe(@"A basic blindside injector test", ^{
            beforeEach(^{
                id <BSInjector> injector = [Blindside injectorWithModule:[[AppModule alloc] init]];
                controller = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                [injector injectProperties:controller];

                UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                window.rootViewController = controller;
                [window makeKeyAndVisible];
                [window layoutIfNeeded];
            });

            it(@"displays a message to the user", ^{
                controller.messageLabel.text should equal(@"Hello world");
            });
        });

        describe(@"Overriding injector properties in a test module", ^{
            beforeEach(^{
                id <BSInjector> injector = [Blindside injectorWithModule:[[TestModule alloc] init]];
                controller = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                [injector injectProperties:controller];

                UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                window.rootViewController = controller;
                [window makeKeyAndVisible];
                [window layoutIfNeeded];
            });

            it(@"displays a message to the user", ^{
                controller.messageLabel.text should equal(@"Hello Earth");
            });
        });

        describe(@"Overriding injector properties in a specific test", ^{
            beforeEach(^{
                id <BSInjector, BSBinder> injector = (id <BSInjector, BSBinder>) [Blindside injectorWithModule:[[AppModule alloc] init]];
                [injector bind:@"theMessage" toInstance:@"Hello Mars"];

                controller = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                [injector injectProperties:controller];

                UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                window.rootViewController = controller;
                [window makeKeyAndVisible];
                [window layoutIfNeeded];
            });

            it(@"displays a message to the user", ^{
                controller.messageLabel.text should equal(@"Hello Mars");
            });
        });

        describe(@"Transitioning between screens", ^{
            __block UINavigationController *navigationController;

            void(^tickRunLoop)() = ^{
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
            };

            beforeEach(^{
                id <BSInjector, BSBinder> injector = (id <BSInjector, BSBinder>) [Blindside injectorWithModule:[[AppModule alloc] init]];
                controller = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
                [injector injectProperties:controller];

                navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                window.rootViewController = navigationController;
                [window makeKeyAndVisible];
                [window layoutIfNeeded];
            });

            it(@"displays the title correctly if you tick the runloop", ^{
                [controller.earthquakesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                navigationController.topViewController.title should be_nil;
                tickRunLoop();

                navigationController.topViewController.title should equal(@"Earthquakes!");
            });

            it(@"displays the title correctly if you use in_time", ^{
                [controller.earthquakesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                navigationController.topViewController.title should be_nil;

                in_time(navigationController.topViewController.title) should equal(@"Earthquakes!");
            });

            it(@"displays the title correctly if you use invoke viewWillAppear manually", ^{
                [controller.earthquakesButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                navigationController.topViewController.title should be_nil;
                [navigationController.topViewController viewDidLoad];

                in_time(navigationController.topViewController.title) should equal(@"Earthquakes!");
            });

        });
    });

SPEC_END
