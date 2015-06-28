#import <Cedar/Cedar.h>
#import <BlindsidedStoryboard/BlindsidedStoryboard.h>
#import "EarthquakeController.h"
#import "FixtureStubber.h"
#import "RBTableViewCellsProxy.h"
#import "EarthquakeDetailController.h"
#import "UITableViewCell+Spec.h"
#import "TestEarthquakeModule.h"
#import <CedarAsync/CedarAsync.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface EarthquakeController ()<UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@end

@interface EarthquakeDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *depthLabel;
@end

SPEC_BEGIN(EarthquakeControllerSpec)

    describe(@"EarthquakeController", ^{
        __block EarthquakeController *controller;
        __block UIWindow *window;

        void(^tickRunLoop)() = ^{
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        };

        beforeEach(^{
            id injector = [Blindside injectorWithModule:[[TestEarthquakeModule alloc] init]];
            UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Earthquakes" bundle:nil injector:injector];
            controller = [storyboard instantiateViewControllerWithIdentifier:@"EarthquakeController"];

            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            window.rootViewController = navigationController;
        });

        describe(@"When connectivity succeeds", ^{

            beforeEach(^{
                [FixtureStubber stubUrl:@"http://localhost:6666/earthquakesJSON?north=44.2&south=-9.9&east=-22.4&west=55.2&username=nstreet"
                           withFilename:@"earthquakes.json"];
                [window makeKeyAndVisible];
                [window layoutIfNeeded];
                in_time(controller.tableView.visibleCells.count) should be_greater_than(0);
            });

            it(@"Displays the 10 latest earthquakes", ^{
                RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
                cells.count should equal(10);
            });

            it(@"Displays the earthquake name and magnitude", ^{
                UITableViewCell *firstCell = controller.tableView.visibleCells[0];;
                firstCell.textLabel.text should contain(@"c0001xgp");
                firstCell.detailTextLabel.text should contain(@"8.8");
            });

            it(@"Displays the earthquake name and magnitude in the last cell", ^{
                RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
                UITableViewCell *lastCell = cells[9];
                lastCell.textLabel.text should contain(@"a00043nx");
                lastCell.detailTextLabel.text should contain(@"7.7");
            });

            it(@"Tapping on a cell shows the detail view", ^{
                RBTableViewCellsProxy *cells = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
                UITableViewCell *selectedCell = cells[0];
                [selectedCell tap];
                tickRunLoop();

                EarthquakeDetailController *detailController = (EarthquakeDetailController *) controller.navigationController.topViewController;
                detailController.depthLabel.text should equal(@"24.4");
            });
        });
    });

SPEC_END
