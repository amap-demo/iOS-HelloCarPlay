//
//  MainViewController.m
//  HelloCarPlay
//
//  Created by eidan on 2018/9/4.
//  Copyright © 2018年 autonavi. All rights reserved.
//

#import "MainViewController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAMapKit.h>

@interface MainViewController () <AMapNaviDriveManagerDelegate, AMapNaviDriveDataRepresentable, AMapNaviDriveViewDelegate, MAMapViewDelegate>

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@property (nonatomic, weak) IBOutlet AMapNaviDriveView *driveView;

@property (nonatomic, weak) IBOutlet UIView *topInfoBgView;
@property (nonatomic, weak) IBOutlet UIImageView *topTurnImageView;
@property (nonatomic, weak) IBOutlet UILabel *topRemainLabel;
@property (nonatomic, weak) IBOutlet UILabel *topRoadLabel;

@property (nonatomic, weak) IBOutlet UIView *routeRemianInfoView;
@property (nonatomic, weak) IBOutlet UILabel *routeRemainInfoLabel;

@property (nonatomic, weak) IBOutlet AMapNaviTrafficBarView *trafficBarView;
@property (nonatomic, weak) IBOutlet UIImageView *crossImageView;

@property (nonatomic, weak) MAMapView *mapView;

@property (nonatomic, strong) CPMapButton *browserBtn;
@property (nonatomic, strong) CPBarButton *zoomInBtn;
@property (nonatomic, strong) CPBarButton *zoomOutBtn;
@property (nonatomic, strong) CPBarButton *panningBtn;
@property (nonatomic, strong) CPBarButton *doneBtn;

@end

@implementation MainViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //为了方便展示,选择了固定的起终点
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993253 longitude:116.473195];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:39.918058 longitude:116.397026];
    
    //初始化xib界面上的元素
    [self updateViewsWhenInit];
    
    //driveView
    self.driveView.delegate = self;
    self.driveView.mapViewDelegate = self;
    self.driveView.showUIElements = NO;
    self.driveView.showGreyAfterPass = YES;
    self.driveView.autoZoomMapLevel = YES;
    self.driveView.mapViewModeType = AMapNaviViewMapModeTypeDayNightAuto;
    self.driveView.autoSwitchShowModeToCarPositionLocked = YES;
    self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
    self.driveView.logoCenter = CGPointMake(self.driveView.logoCenter.x - 3, self.driveView.logoCenter.y + 30);
    
    //driveManager 请在 dealloc 函数中执行 [AMapNaviDriveManager destroyInstance] 来销毁单例
    [[AMapNaviDriveManager sharedInstance] setDelegate:self];
    [[AMapNaviDriveManager sharedInstance] setIsUseInternalTTS:YES];
    
    [[AMapNaviDriveManager sharedInstance] setAllowsBackgroundLocationUpdates:YES];
    [[AMapNaviDriveManager sharedInstance] setPausesLocationUpdatesAutomatically:NO];
    
    //将self 、driveView、trafficBarView 添加为导航数据的Representative，使其可以接收到导航诱导数据
    [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self.driveView];
    [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self.trafficBarView];
    [[AMapNaviDriveManager sharedInstance] addDataRepresentative:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateMapViewScreenAnchor:NO];  // 设置锚点
}

- (void)dealloc {
    
}

#pragma mark - Interface

- (void)initMapTemplate {
    
    //CPMapTemplate
    self.mapTemplate = [[CPMapTemplate alloc] init];
    self.mapTemplate.mapDelegate = self;
    self.mapTemplate.automaticallyHidesNavigationBar = NO;
    
    //mapButtons
    self.browserBtn = [self createMapButton:0]; //全览
    self.mapTemplate.mapButtons = @[self.browserBtn];
    
    //NavigationBarButtons
    self.doneBtn = [self createBarButton:0];
    self.panningBtn = [self createBarButton:1];
    self.zoomInBtn = [self createBarButton:2];  //放大
    self.zoomOutBtn = [self createBarButton:3];  //缩小
    self.mapTemplate.trailingNavigationBarButtons = @[[self createBarButton:1]];
}

#pragma mark - CPMapTemplate Handler

- (CPMapButton *)createMapButton:(int )type {
    CPMapButton *mapButton = [[CPMapButton alloc] initWithHandler:^(CPMapButton * _Nonnull mapButton) {
        if (type == 0) {
            if (self.driveView.showMode == AMapNaviDriveViewShowModeOverview) {
                self.driveView.showMode = AMapNaviDriveViewShowModeCarPositionLocked;
            } else {
                self.driveView.showMode = AMapNaviDriveViewShowModeOverview;
            }
        }
    }];
    
    UIImage *image = nil;
    if (type == 0) {
        image = [UIImage imageNamed:@"default_navi_browse_ver_normal"];
    }

    mapButton.image = image;
    
    return mapButton;
}

- (CPBarButton *)createBarButton:(int )type {
    CPBarButton *barButton = [[CPBarButton alloc] initWithType:CPBarButtonTypeText handler:^(CPBarButton * _Nonnull barButton) {
        if (type == 0) {  //done
            [self.mapTemplate dismissPanningInterfaceAnimated:YES];
            self.mapTemplate.leadingNavigationBarButtons = @[];
            self.mapTemplate.trailingNavigationBarButtons = @[self.panningBtn];
            self.mapTemplate.mapButtons = @[self.browserBtn];
            
            self.driveView.showMode = AMapNaviDriveViewShowModeCarPositionLocked;
            self.driveView.autoSwitchShowModeToCarPositionLocked = YES;
            self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
            self.driveView.logoCenter = CGPointMake(self.driveView.logoCenter.x, self.driveView.logoCenter.y - 27);
            
            self.topInfoBgView.hidden = self.routeRemianInfoView.hidden = NO;
            [self updateMapViewScreenAnchor:NO];
            
        } else if (type == 1) {  //panning
            [self.mapTemplate showPanningInterfaceAnimated:YES];
            self.mapTemplate.leadingNavigationBarButtons = @[self.doneBtn];
            self.mapTemplate.trailingNavigationBarButtons = @[self.zoomInBtn,self.zoomOutBtn];
            self.mapTemplate.mapButtons = @[];
            
            self.driveView.showMode = AMapNaviDriveViewShowModeNormal;
            self.driveView.autoSwitchShowModeToCarPositionLocked = NO;
            self.driveView.trackingMode = AMapNaviViewTrackingModeMapNorth;
            self.driveView.logoCenter = CGPointMake(self.driveView.logoCenter.x, self.driveView.logoCenter.y + 27);
            
            self.topInfoBgView.hidden = self.routeRemianInfoView.hidden = YES;
            [self updateMapViewScreenAnchor:YES];
            [self handleWhenCrossImageShowAndHide:nil];
            
        } else if (type == 2) {
            [self.driveView setMapZoomLevel:self.driveView.mapZoomLevel + 1];
        } else if (type == 3) {
            [self.driveView setMapZoomLevel:self.driveView.mapZoomLevel - 1];
        }
    }];
    
    if (type == 0) {
        barButton.title = @"退出";
    } else if (type == 1) {
        barButton.title = @"拖动";
    } else if (type == 2) {
        barButton.title = @"放大";
    } else if (type == 3) {
        barButton.title = @"缩小";
    }
    
    return barButton;
}

#pragma mark - CPMapTemplateDelegate

- (void)mapTemplate:(CPMapTemplate *)mapTemplate panWithDirection:(CPPanDirection)direction {
    
    CGPoint viewPoint =  [self.mapView convertCoordinate:self.mapView.centerCoordinate toPointToView:self.mapView];
    CGFloat offset = 30;
    
    if (direction == CPPanDirectionLeft) {
        viewPoint = CGPointMake(viewPoint.x - offset, viewPoint.y);
    } else if (direction == CPPanDirectionRight) {
        viewPoint = CGPointMake(viewPoint.x + offset, viewPoint.y);
    } else if (direction == CPPanDirectionUp) {
        viewPoint = CGPointMake(viewPoint.x , viewPoint.y - offset);
    } else if (direction == CPPanDirectionDown) {
        viewPoint = CGPointMake(viewPoint.x , viewPoint.y + offset);
    }
    
    CLLocationCoordinate2D coor = [self.mapView convertPoint:viewPoint toCoordinateFromView:self.mapView];
    
    [self.mapView setCenterCoordinate:coor animated:YES];
}

#pragma mark - View Handler

//setup
- (void)updateViewsWhenInit {
    
    self.topInfoBgView.layer.cornerRadius = self.crossImageView.layer.cornerRadius = 6;
    self.routeRemianInfoView.layer.cornerRadius = 4;
    self.topInfoBgView.backgroundColor = self.routeRemianInfoView.backgroundColor = [UIColor colorWithRed:30 / 255.0 green:30 / 255.0  blue:30 / 255.0  alpha:0.9];
    self.trafficBarView.borderWidth = 2;
    
    //hide
    self.topInfoBgView.alpha = self.routeRemianInfoView.alpha = 0;
    self.crossImageView.hidden = YES;
}

//更新地图锚点
- (void)updateMapViewScreenAnchor:(BOOL)center {
    
    [self.view layoutIfNeeded];
    
    CGFloat x = 0.5;
    CGFloat y = 0.8;
    
    if (!center) {
        CGFloat xStart = self.topInfoBgView.frame.origin.x + self.topInfoBgView.frame.size.width;
        CGFloat xEnd = self.trafficBarView.frame.origin.x;
        CGFloat xAreaMiddleInAll = (xEnd - xStart) / 2 + xStart - self.driveView.frame.origin.x;
        x = xAreaMiddleInAll / self.driveView.bounds.size.width;
        
        if (x <= 0 || x >= 1 ) {
            x = 0.5;
        }
    }
    
    if (self.driveView.screenAnchor.x != x || self.driveView.screenAnchor.y != y) {
        self.driveView.screenAnchor = CGPointMake(x, y);
    }
}

//处理路口放大图
- (void)handleWhenCrossImageShowAndHide:(UIImage *)crossImage {
    if (crossImage && self.driveView.showMode == AMapNaviDriveViewShowModeCarPositionLocked) {
        self.crossImageView.hidden = NO;
        self.crossImageView.image = crossImage;
    } else {
        self.crossImageView.hidden = YES;
        self.crossImageView.image = nil;
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    //由于目前 AMapNaviDriveView 没有透出 MAMapView，可以通过以下方法拿一下 MAMapView，后续版本会通过接口支持。
    //拿到 MAMapView 主要是为了做地图的滑动，如果不需要该功能，可以不拿。注意：不要对 MAMapView 做过多操作，如重新设置delegate，会导致 AMapNaviDriveView 功能不可用
    self.mapView = mapView;
}

#pragma mark - AMapNaviDriveViewDelegate

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode {
    if (showMode == AMapNaviDriveViewShowModeOverview) {
        self.browserBtn.image = [UIImage imageNamed:@"default_navi_browse_ver_selected"];
    } else {
        self.browserBtn.image = [UIImage imageNamed:@"default_navi_browse_ver_normal"];
    }
}

//返回边界Padding，来规定可见区域
- (UIEdgeInsets)driveViewEdgePadding:(AMapNaviDriveView *)driveView {
    
    CGFloat top = 80;
    CGFloat left = self.topInfoBgView.frame.origin.x + self.topInfoBgView.bounds.size.width;
    CGFloat bottom = 40;
    CGFloat right = 40;
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    
    return insets;
}

#pragma mark - AMapNaviDriveDataRepresentable

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateNaviInfo:(AMapNaviInfo *)naviInfo {
    if (naviInfo) {
        
        if (!self.routeRemianInfoView.alpha) {
            self.topInfoBgView.alpha = self.routeRemianInfoView.alpha = 1;
        }
        
        self.topRemainLabel.text = [NSString stringWithFormat:@"%@后",[self normalizedRemainDistance:naviInfo.segmentRemainDistance]];
        self.topRoadLabel.text = naviInfo.nextRoadName;
        
        NSString *remainTime = [self normalizedRemainTime:naviInfo.routeRemainTime];
        NSString *remainDis = [self normalizedRemainDistance:naviInfo.routeRemainDistance];
        self.routeRemainInfoLabel.text = [NSString stringWithFormat:@"剩余 %@ %@",remainDis,remainTime];
        
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager updateTurnIconImage:(UIImage *)turnIconImage turnIconType:(AMapNaviIconType)turnIconType {
    if (turnIconImage) {
        self.topTurnImageView.image = turnIconImage;
    }
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager showCrossImage:(UIImage *)crossImage {
    [self handleWhenCrossImageShowAndHide:crossImage];
}

- (void)driveManagerHideCrossImage:(AMapNaviDriveManager *)driveManager {
    [self handleWhenCrossImageShowAndHide:nil];
}

#pragma mark - Utility

- (NSString *)normalizedRemainDistance:(NSInteger)remainDistance {
    
    if (remainDistance < 0) {
        return nil;
    }
    
    if (remainDistance >= 1000) {
        CGFloat kiloMeter = remainDistance / 1000.0;
        return [NSString stringWithFormat:@"%.1f公里", kiloMeter];
    } else {
        return [NSString stringWithFormat:@"%ld米", (long)remainDistance];
    }
}

- (NSString *)normalizedRemainTime:(NSInteger)remainTime {
    if (remainTime < 0) {
        return nil;
    }
    
    if (remainTime < 60) {
        return [NSString stringWithFormat:@"< 1分钟"];
    } else if (remainTime >= 60 && remainTime < 60*60) {
        return [NSString stringWithFormat:@"%ld分钟", (long)remainTime/60];
    } else {
        NSInteger hours = remainTime / 60 / 60;
        NSInteger minute = remainTime / 60 % 60;
        if (minute == 0) {
            return [NSString stringWithFormat:@"%ld小时", (long)hours];
        } else {
            return [NSString stringWithFormat:@"%ld小时%ld分钟", (long)hours, (long)minute];
        }
    }
}


@end
