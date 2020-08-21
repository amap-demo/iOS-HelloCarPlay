//
//  DriveViewController.m
//  HelloCarPlay
//
//  Created by eidanlin on 2020/8/21.
//  Copyright © 2020 autonavi. All rights reserved.
//

#import "DriveViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>

@interface DriveViewController ()<AMapNaviDriveManagerDelegate, AMapNaviDriveDataRepresentable, AMapNaviDriveViewDelegate>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@property (nonatomic, weak) IBOutlet AMapNaviDriveView *driveView;

@end

@implementation DriveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //为了方便展示,选择了固定的起终点
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993253 longitude:116.473195];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:39.918058 longitude:116.397026];
    
    //driveView
    self.driveView.delegate = self;
    self.driveView.showGreyAfterPass = YES;
    self.driveView.autoZoomMapLevel = YES;
    self.driveView.mapViewModeType = AMapNaviViewMapModeTypeDayNightAuto;
    self.driveView.autoSwitchShowModeToCarPositionLocked = YES;
    self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
    
    //driveManager 请在 dealloc 函数中执行 [AMapNaviDriveManager destroyInstance] 来销毁单例
    [[AMapNaviDriveManager sharedInstance] setDelegate:self];
    [[AMapNaviDriveManager sharedInstance] setIsUseInternalTTS:YES];
    
    [[AMapNaviDriveManager sharedInstance] setAllowsBackgroundLocationUpdates:YES];
    [[AMapNaviDriveManager sharedInstance] setPausesLocationUpdatesAutomatically:NO];
    
    //将self 、driveView、trafficBarView 添加为导航数据的Representative，使其可以接收到导航诱导数据
    [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self.driveView];
    [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self];
    
    //算路
    [[AMapNaviDriveManager sharedInstance] calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                                    endPoints:@[self.endPoint]
                                                                    wayPoints:nil
                                                              drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager {
    NSLog(@"onCalculateRouteSuccess");
    
    //算路成功后开始导航
    [[AMapNaviDriveManager sharedInstance] startEmulatorNavi];
}

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView {
    [[AMapNaviDriveManager sharedInstance] stopNavi];
    [[AMapNaviDriveManager sharedInstance] removeDataRepresentative:self.driveView];
    [[AMapNaviDriveManager sharedInstance] removeDataRepresentative:self];
    [[AMapNaviDriveManager sharedInstance] setDelegate:nil];

    BOOL success = [AMapNaviDriveManager destroyInstance];
    NSLog(@"单例是否销毁成功 : %d",success);
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
