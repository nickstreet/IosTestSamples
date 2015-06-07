
## Blindside

We recommend using a dependency injection framework when developing iOS apps. Without dependency injection apps become more complex to manage. Knowledge of how to construct service objects ends up inside controllers, and they get manually passed between controllers increasing coupling. One of the challenges in iOS development is keeping controllers small, so dependency injection is a worthwhile tool. Using dependency injection also helps in the development of focused unit tests.

[Blindside](https://github.com/jbsf/blindside) is a very simple dependency injection framework created by JB Steadman from Pivotal Labs. You simply create a module with all the bindings that you require, and then create a hook in each class to automatically inject desired objects into properties in your classes.

To install, add this to your Podfile:

    target 'Sample App' do
      pod 'Blindside', :git => 'https://github.com/jbsf/blindside.git', :tag => 'v1.0.1'
    end


## Cedar

[Cedar](https://github.com/pivotal/cedar) is a behaviour driven development testing tool developed by Pivotal Labs. It supports hierarchical testing that will be familiar to Rspec users, and is similar to another iOS testing tool called Kiwi. A comparison of BDD tools and introduction to using them can be found [here](http://www.objc.io/issues/15-testing/behavior-driven-development/)

To install, add this to your Podfile:

    target 'Sample AppTests' do
      pod 'Cedar'
    end

There are also some hooks that can be installed to improve integration with XCode

    $ curl -L https://raw.github.com/pivotal/cedar/master/install.sh | bash


## Hello World

The first test is to validate that a ViewController backed by a storyboard gets values injected from Blindside. To demonstrate this we will create a simple ViewController which displays a message in a label in the center of the screen.

### Creating the test

Create a base spec file. If you have installed the Cedar XCode support tools then you can make the Cedar file by selecting Cedar template from the New File dialog.

The file looks something like this:

    #import <Cedar/Cedar.h>
    
    using namespace Cedar::Matchers;
    using namespace Cedar::Doubles;
    
    SPEC_BEGIN(ViewControllerSpec)
    
    describe(@"ViewController", ^{
        __block ViewController *controller;
    
        beforeEach(^{
        });
        
    });
    
    SPEC_END

To get a test working, we need to create an instance of your view controller and put it inside a UIWindow instance so that Cedar can interact with it. Because the base ViewController is backed by a Storyboard, we need to use another library [BlindsidedStoryboard](https://github.com/pivotal-brian-croom/BlindsidedStoryboard) to build the ViewController.

To achieve this you need to add BlindsidedStoryboard as Blindside to your podfile:

    target 'Sample App' do
      ...
      pod 'BlindsidedStoryboard', :git => 'https://github.com/pivotal-brian-croom/BlindsidedStoryboard', :tag => 'v0.1.0'
    end

And then run `pod install` to update your project file.

To add your first test, you need to create an instance of your view controller, and set it as the root view controller for a UIWindow object:

    beforeEach(^{
        id injector = [Blindside injectorWithModule:[[AppModule alloc] init]];
        UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Main" bundle:nil injector:injector];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = controller;
        [window makeKeyAndVisible];
        [window layoutIfNeeded];
    });
    
To get Blindside to work, you we need to provide it with a BSModule, which will hold all the bindings for our app. We don't have any bindings yet, so let's just create a shell class so that everything will compile:

    // AppModule.h
    @interface AppModule : NSObject <BSModule>
   
    @end

    // AppModule.m
    @implementation AppModule 
    
    - (void)configure:(id<BSBinder>)binder {
    }
    
    @end

 
Next we need to write the test to assert the expected message is being displayed. To do this we can either inspect the window hierarchy using a tool like Robot, or simply access the UILabel directly. For this example we will use the direct option. Since the label should be declared privately, we will re-open the ViewController using a test category declared at the top of the spec file:

    ...
    using namespace Cedar::Doubles;
    
    @interface ViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *label;
    @end
    
    SPEC_BEGIN(ViewControllerSpec)
    ...

Now we can access this label in the test:

    it(@"displays a message to the user", ^{
        controller.label.text should equal(@"Hello world");
    });

We can now run this test and see it fail:

    -[ViewController label]: unrecognized selector sent to instance 0x7fcec4164f30


### Creating the implementation

To implement the ViewController, add a label in the Storyboard, and connect this to a UILabel outlet in your ViewController. Then create an NSString property to hold your message, and configure Blindside to inject the value of the message into this property.

    @interface ViewController ()
    @property (strong, nonatomic) NSString *message;
    @property (weak, nonatomic) IBOutlet UILabel *label;
    @end
    
    @implementation ViewController
    
    + (BSPropertySet *)bsProperties {
        BSPropertySet *propertySet = [BSPropertySet propertySetWithClass:self propertyNames:@"message", nil];
        [propertySet bindProperty:@"message" toKey:@"theMessage"];
        return propertySet;
    }

Blindside will look for this bsProperties class when it creates your ViewController, and inject the value it holds for the key "theMessage" into a property in the ViewController called "message". Let's add this value into our AppModule:

    - (void)configure:(id<BSBinder>)binder {
        [binder bind:@"theMessage" toInstance:@"Hello world"];
    }

Finally add a viewDidLoad: hook to set the label's value from the message property when the ViewController starts:

    - (void)viewDidLoad {
        [super viewDidLoad];
        self.label.text = self.message;
    }

The test should now run and pass!