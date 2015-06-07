#import <Cedar/Cedar.h>
#import <BlindsidedStoryboard/BlindsidedStoryboard.h>
#import "EarthquakeController.h"
#import "EarthquakeModule.h"
#import "FixtureStubber.h"
#import "RBTableViewCellsProxy.h"
#import <CedarAsync/CedarAsync.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface EarthquakeController ()
@property(nonatomic, strong) UITableView *tableView;
@end

SPEC_BEGIN(EarthquakeControllerSpec)

    describe(@"EarthquakeController", ^{
        __block EarthquakeController *controller;
        __block UIWindow *window;

        beforeEach(^{
            id injector = [Blindside injectorWithModule:[[EarthquakeModule alloc] init]];
            UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Earthquakes" bundle:nil injector:injector];
            controller = [storyboard instantiateViewControllerWithIdentifier:@"EarthquakeController"];

            window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            window.rootViewController = controller;
        });


        describe(@"When connectivity succeeds", ^{
            __block RBTableViewCellsProxy *cells;

            beforeEach(^{
                [FixtureStubber stubUrl:@"http://api.geonames.org/earthquakesJSON?north=44.2&south=-9.9&east=-22.4&west=55.2&username=nstreet"
                           withFilename:@"earthquakes.json"];
                [window makeKeyAndVisible];
                [window layoutIfNeeded];
                cells = [RBTableViewCellsProxy cellsFromTableView:controller.tableView];
                in_time(cells.count) should be_greater_than(0);
            });

            it(@"Displays the 10 latest earthquakes", ^{
                cells.count should equal(10);
            });

            it(@"Displays the earthquare name and magnitude", ^{
                UITableViewCell *firstCell = cells[0];
                firstCell.textLabel.text should contain(@"c0001xgp");
                firstCell.detailTextLabel.text should contain(@"8.8");
            });
        });

    });

SPEC_END
