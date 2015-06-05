#import <Cedar/Cedar.h>
#import "ViewController.h"
#import "AppModule.h"
#import "BlindsidedStoryboard.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

SPEC_BEGIN(ViewControllerSpec)

describe(@"ViewController", ^{
    __block ViewController *controller;

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

SPEC_END
