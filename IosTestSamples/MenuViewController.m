#import <BlindsidedStoryboard/BlindsidedStoryboard.h>
#import "MenuViewController.h"

@interface MenuViewController ()
@property(strong, nonatomic) NSString *message;
@property(weak, nonatomic) IBOutlet UILabel *messageLabel;
@property(weak, nonatomic) IBOutlet UIButton *earthquakesButton;
@property(weak, nonatomic) id <BSInjector> injector;

@end

@implementation MenuViewController

+ (BSPropertySet *)bsProperties {
    BSPropertySet *propertySet = [BSPropertySet propertySetWithClass:self propertyNames:@"message", nil];
    [propertySet bindProperty:@"message" toKey:@"theMessage"];
    return propertySet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageLabel.text = self.message;
}

- (IBAction)tapEarthquakes {
    UIStoryboard *storyboard = [BlindsidedStoryboard storyboardWithName:@"Earthquakes" bundle:nil injector:self.injector];
    UIViewController *earthquakesController = [storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:earthquakesController animated:YES];
}

@end
