//
//  ViewController.m
//  Sample App
//
//  Created by Nick Street on 05/06/2015.
//  Copyright (c) 2015 Nick Street. All rights reserved.
//

#import "ViewController.h"
#import "Blindside.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label.text = self.message;
}

@end
