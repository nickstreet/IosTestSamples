#import "EarthquakeDetailController.h"


@interface EarthquakeDetailController ()
@property (weak, nonatomic) IBOutlet UILabel *earthquakeIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *magnitudeIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *depthLabel;
@end

@implementation EarthquakeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.earthquakeIdLabel.text = self.earthquake[@"eqid"];
    self.magnitudeIdLabel.text = [self.earthquake[@"magnitude"] stringValue];
    self.depthLabel.text = [self.earthquake[@"depth"] stringValue];
}

@end