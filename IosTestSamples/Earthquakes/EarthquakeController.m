#import "EarthquakeController.h"
#import "EarthquakeDetailController.h"

@interface EarthquakeController () <UITableViewDelegate, UITableViewDataSource>
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSArray *earthquakes;
@end

@implementation EarthquakeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshEarthquakes];
}

- (void)refreshEarthquakes {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:[self buidApiUrl]]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                self.earthquakes = json[@"earthquakes"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }] resume];
}

- (NSString *const)buidApiUrl {
    return EARTHQUAKES_API_URL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.earthquakes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *earthquake = self.earthquakes[indexPath.row];
    cell.textLabel.text = earthquake[@"eqid"];
    cell.detailTextLabel.text = [earthquake[@"magnitude"] stringValue];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    EarthquakeDetailController *detailController = segue.destinationViewController;
    detailController.earthquake = self.earthquakes[indexPath.row];
}

@end
