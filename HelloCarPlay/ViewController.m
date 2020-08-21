//
//  ViewController.m
//  HelloCarPlay
//
//  Created by eidan on 2018/9/4.
//  Copyright © 2018年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import "DriveViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startNavi:(id)sender {
    DriveViewController *driveVC = [[DriveViewController alloc] initWithNibName:@"DriveViewController" bundle:nil];
    [self.navigationController pushViewController:driveVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

@end
