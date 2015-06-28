# Introduction

This project aims to provide some patterns for how to test common scenarios in iOS projects using the test framework Cedar.

With the objective of getting a simple testable app and running I have included a number of different libraries, including Blindside for dependency injection, Cedar for BDD testing, Robot for inspecting views, OHHTTPStubs for testing HTTP interactions and PivotalCoreKit for tapping cells. There are many styles of iOS testing so the full collection may not fit your project, but they should demonstrate potential solutions to common problems and I hope that the approaches will be more valuable than the particular tools.

In the preparing of this, I have had many discussions and it is clear that I have been writing more user-driven tests than some of my colleagues within Pivotal Labs. For an alternative (and far more experienced) perspective, I encourage you to review the [best practices](https://github.com/cbguder/BestPractices) project put together by Can Berk Güder. 

I can however say that I have used these approaches successfully on a small project with around 300 tests that run in under 1 minute on a modern iMac. We have also found the tests to be reliable, with very few flaky tests and affording a six-week run of uninterrupted green test runs on our CI.

## Integration testing

Many of the tests in this guide reach inside the classes they test, and don't provide as pure a form of testing as web testing tools like Capybra/WebDriver. There are many teams working on solutions to this, such as Appium and Kif. Apple has also recently released new testings tools in XCode 7 which approximate this, and may be the future of integration testing. This is an area undergoing significant change, but currently without compelling solutions. If you want to know more, I suggest doing further research and also checking out a [post by Joe Masilotti](https://github.com/joemasilotti/ios-feature-testing) that reviews various testing options on iOS.

## Cocoapods

We have used [CocoaPods](https://cocoapods.org) for this example application, which makes adding and updating dependencies extremely easy, as well as providing access to a respository of libraries via cocoapods.org. Cocoapods achieves this goal very well, but imposes changes on your project structure via the xcworkspace that some developers are not keen on. For a lighter-weight approach consider using [Carthage](https://github.com/Carthage/Carthage) which makes it easy for library developers to build dynamic frameworks that you can include in your applications however you choose.


## Blindside

We recommend using a dependency injection framework when developing iOS apps. Without dependency injection apps become more complex to manage. Knowledge of how to construct service objects ends up inside controllers, and they get manually passed between controllers increasing coupling. One of the challenges in iOS development is keeping controllers small, so dependency injection is a worthwhile tool. Using dependency injection also helps in the development of focused unit tests.

[Blindside](https://github.com/jbsf/blindside) is a very simple dependency injection framework created by JB Steadman from Pivotal Labs. You simply create a module with all the bindings that you require, and then create a hook in each class to automatically inject desired objects into properties in your classes.

To install, add this to your Podfile:

    target 'IosTestSamples' do
      pod 'Blindside', :git => 'https://github.com/jbsf/blindside.git', :tag => 'v1.0.1'
    end

## Cedar

[Cedar](https://github.com/pivotal/cedar) is a behaviour driven development testing tool developed by Pivotal Labs. It supports hierarchical testing that will be familiar to Rspec users, and is similar to another iOS testing tool called Kiwi. A comparison of BDD tools and introduction to using them can be found [here](http://www.objc.io/issues/15-testing/behavior-driven-development/). 

To install, add this to your Podfile:

    target 'IosTestSamplesTests' do
      pod 'Cedar'
    end

There are also some hooks that can be installed to improve integration with XCode

    $ curl -L https://raw.github.com/pivotal/cedar/master/install.sh | bash

## Hello World

The first test is to validate that a ViewController gets values injected from Blindside. To demonstrate this we will create a simple ViewController which displays a message in a label in the center of the screen.

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

To get a test working, we need to create an instance of your view controller and put it inside a UIWindow instance so that Cedar can interact with it. How this is achieved will change depending on whether you are using storyboards, xib files or just plain DIY UIViewControllers. Below we describe how to achieve this with a simple XIB file. Please see [Testing Storyboards] for an overview of how to test against storyboards.

## Testing ViewController's backed by a xib

To get Blindside to work, we need to provide it with a BSModule, which will hold all the bindings for our app. We don't have any bindings yet, so let's just create a shell class so that everything will compile:

    // AppModule.h
    @interface AppModule : NSObject <BSModule>
   
    @end

    // AppModule.m
    @implementation AppModule 
    
    - (void)configure:(id<BSBinder>)binder {
    }
    
    @end

Next we need to write the test to assert the expected message is being displayed. To do this we can either inspect the window hierarchy using a tool like Robot, or simply access the UILabel directly. For this example we will use the direct option. Since the label should be declared privately, we will re-open the ViewController using a spec category declared at the top of the spec file:

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

To implement the ViewController, add a label in the ViewController.xib, and connect this to a UILabel outlet in your ViewController. Then create an NSString property to hold your message, and configure Blindside to inject the value of the message into this property.

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

A working example of this can be found in MenuViewController and MenuViewControllerSpec.

## Testing Storyboards
  
 If a UIViewController is backed by a Storyboard, we need to use another library [BlindsidedStoryboard](https://github.com/pivotal-brian-croom/BlindsidedStoryboard) to build the ViewController.

To achieve this you need to add BlindsidedStoryboard to your podfile:

    target 'IosTestSamples' do
      ...
      pod 'BlindsidedStoryboard', :git => 'https://github.com/pivotal-brian-croom/BlindsidedStoryboard', :tag => 'v0.1.0'
    end

And then run `pod install` to update your project file.

In this project we have a simple application which renders the latest earthquakes that have been felt in the vicinity of an area of Earth. For this example we will run through the EarthquakeControllerSpec used to test this functionality.

To add your first test, you need to create an instance of your view controller, and set it as the root view controller for a UIWindow object:

    beforeEach(^{
        id injector = [Blindside injectorWithModule:[[TestEarthquakeModule alloc] init]];
        UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Earthquakes" bundle:nil injector:injector];
        controller = [storyboard instantiateViewControllerWithIdentifier:@"EarthquakeController"];
    
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = navigationController;
    });
    
By instantiating your ViewController through BlindsidedStoryboard, all your dependencies will be injected in automatically. In this case, the API URL is provided through Blindside.
 

## Testing Asynchronous behaviour

Testing asynchronous behaviour can be very tricky in iOS. There are different schools of thought on how to achieve this, so the below is not necessarily "best practice", but does provide an example of how this can be achieved. In this example we will use OHHTTPStubs to stub out the API calls, and provide a JSON response via fixture.

As with the other examples, you can add the OHHTTPStubs dependency via CocoaPods:

    target 'IosTestSamples' do
      ...
      pod 'OHHTTPStubs', '4.0.1'
    end

Remember to run `pod install` to pull in the dependency


Then add the following beforeEach block:

    describe(@"When connectivity succeeds", ^{
        beforeEach(^{
            [FixtureStubber stubUrl:@"http://localhost:6666/earthquakesJSON?north=44.2&south=-9.9&east=-22.4&west=55.2&username=nstreet"
                       withFilename:@"earthquakes.json"];
            [window makeKeyAndVisible];
            [window layoutIfNeeded];
            in_time(controller.tableView.visibleCells.count) should be_greater_than(0);
        });
    });

This beforeEach block stubs the URL the app will hit when the EarthquakesController is loaded and provides the JSON in earthquakes.json as the response. Note that the stubbed URL hits "localhost:6666", which is provided via Blindside. By overriding the API host in the tests we can ensure that tests don't unknowingly hit the real server. Only once the stub is in place do we call `[window makeKeyAndVisible]` to bring the view controller on-screen and initiate the ViewController's lifecycle.

Even though the HTTP request is stubbed so the result appears to come back instantly, it is still made via Apple's asynchronous API calls. Consequently the result will not be available within the current iteration of the event loop. To work around this we are using a tool called CedarAsync, and adding an "in_time" assertion against a predicate that will only pass once the result has been received and the screen updated. We have made this assertion in the beforeEach block so that the screen is fully prepared when each "it" block is hit.

Next we write a test to assert that the data from the fixture appears in the first cell as expected:

    it(@"Displays the earthquake name and magnitude", ^{
        UITableViewCell *firstCell = controller.tableView.visibleCells[0];;
        firstCell.textLabel.text should contain(@"c0001xgp");
        firstCell.detailTextLabel.text should contain(@"8.8");
    });

The test itself simply grabs the first visible cell and checks the values from the first result in the fixture are rendered. The test directly inspects the properties, so is tightly bound to the implementation. Note that to write this test we had to expose the tableView property from the EarthquakeController in the spec category at the top of the spec file: 

    @interface EarthquakeController ()<UITableViewDelegate>
    @property(nonatomic, strong) UITableView *tableView;
    @end

## Testing off-screen cells

What if you want to check the content of the last cell in the list? This is more complex because we need to scroll the screen, and wait for the cells to be re-rendered. This can also be tricky when running tests on different devices, since some may need to scroll, but others may not. To make this kind of testing a lot easier, we make use of a library called [Robot](https://github.com/jeffh/Robot/).

    target 'IosTestSamples' do
      ...
      pod 'Robot'
    end

Robot provides you with a "proxy" class for the cells, and behind the scenes will scroll the screen to ensure that the cell you ask for appears on the screen. This makes the tests simpler to both write and read. Usefully the proxy class always returns the latest up to date data meaning you can reuse the instance between actions. This means you can load the proxy class your beforeEach class and share it between tests. It can however complicate debugging, and in my experience I have occasionally found it necessary to access the "real" cell that backs the proxy. The below test demonstrates inspecting the last cell with the proxy class loaded inline:

    it(@"Displays the earthquake name and magnitude in the last cell", ^{
        RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
        UITableViewCell *lastCell = cells[9];
        lastCell.textLabel.text should contain(@"a00043nx");
        lastCell.detailTextLabel.text should contain(@"7.7");
    });


## Testing cell interactions and pushing a ViewController

Often you will want to test what happens when the user taps on a cell. Here you have a few choices, you could simply call tableView:didSelectRowAtIndexPath: directly, or perhaps the interaction is controlled via a segue, so maybe you need to somehow intersect prepareForSegue:. Either way, this approach requires reaching inside your class into implementation detail rather than relying on behaviour. It also won't respect details such as whether the cell has user interaction enabled or not. Such tests provide less confidence that the app works as expected and any refactoring of the code is likely to require test rewrites too. An alternative is to simply tap on the cell...

Unfortunately this is not as easy as it should be. Robot includes a tapOn() method to simulate tapping on controls, and ensure this correctly reflects behaviour such as whether the control is on screen and visible. At time of writing, this does not play well with cells. In the example below we make use of a simulated tap implementation which is provided via a category found in the PivotalCoreKit library.

    target 'IosTestSamplesTests' do
      ...
      pod 'PivotalCoreKit'
      pod 'PivotalCoreKit/UIKit/SpecHelper/Extensions'
    end

Once this is installed, you can simply call "tap" on the cell:

    #import "UITableViewCell+Spec.h"
    ...
    
    it(@"Tapping on a cell shows the detail view", ^{
        RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
        UITableViewCell *selectedCell = cells[0];
        [selectedCell tap];
        tickRunLoop();

        EarthquakeDetailController *detailController = (EarthquakeDetailController *) controller.navigationController.topViewController;
        detailController.depthLabel.text should equal(@"24.4");
    });

Note that to perform the assertion that tapping launches the earthquake detail screen, we have to tick the run loop and then reach in to the navigation controller to pull out the new top view controller. 


## Additional libraries

- [CedarAsync](https://github.com/shake-apps/CedarAsync) allows you to easily write tests that poll the run loop for a short period of time to inspect for change. This is important when a callback is made via a background thread, as occurs in asynchronous HTTP calls. Note that this is necessary even when stubbing requests, as the callback will only be invoked after the next cycle of the runloop.
- [OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs) is used to stub out the HTTP call and replace the response with a fixture. Another library that you may wish to consider using is [Nocilla](https://github.com/luisobo/Nocilla)
- [Robot](https://github.com/jeffh/Robot/) is a library that can be used to search the view hierarchy to support validating tests. Using a tool like Robot avoids having to reach into classes to pick out individual views in order to apply assertions. Robot also provides table cell proxy methods, which simplifies table testing by automatically scrolling the table view.
- [PivotalCoreKit](https://github.com/pivotal/PivotalCoreKit) is a collection of useful utility methods and tools for use throughout both deployed and test code. The library is modular, allowing you to load in subpods so that you only pull in the functionality you are actually making use of in your application. In this guide we use this tool to simulate tapping on table cells.