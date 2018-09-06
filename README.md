# iOS-HelloCarPlay
工程是基于iOS导航SDK实现的支持CarPlay的导航Demo

## 前述 ##
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[开发指南](http://lbs.amap.com/api/ios-navi-sdk/summary/).
- 通过iOS导航SDK实现了支持CarPlay的导航Demo

## 功能描述 ##
Demo中主要演示了 AMapNaviDriveView 如何适配CarPlay的UI界面，并通过模拟导航展示了整个导航过程，包含了诱导面板、路口放大图的展示、全览、放大缩小拖动地图等操作。

## 核心类/接口 ##
| 类 | 说明 |
| -----|:-----:|
| AMapNaviDriveView	| 驾车导航界面 |
| AMapNaviDriveManager sharedInstance] | 驾车导航管理类 |

## 核心难点 ##

`Objective-C`
```
/* 连接CarPlay */
- (void)application:(nonnull UIApplication *)application didConnectCarInterfaceController:(nonnull CPInterfaceController *)interfaceController toWindow:(nonnull CPWindow *)window {
    NSLog(@"AMapNavi Connected To Carplay!");

    self.interfaceController = interfaceController;
    self.carWindow = window;

    self.mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.mainVC initMapTemplate];
    self.carWindow.rootViewController = self.mainVC;

    [self.interfaceController setRootTemplate:self.mainVC.mapTemplate animated:YES];
}

/* 创建CPMapTemplate */
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

/* CPBarButton */
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
        barButton.title = @"进入拖动地图模式";
    } else if (type == 2) {
        barButton.title = @"放大";
    } else if (type == 3) {
        barButton.title = @"缩小";
    }

    return barButton;
}

```
