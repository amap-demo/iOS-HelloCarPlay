//
//  AppDelegate.m
//  HelloCarPlay
//
//  Created by eidan on 2018/9/4.
//  Copyright © 2018年 autonavi. All rights reserved.
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <CarPlay/CarPlay.h>
#import "MainViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface AppDelegate () <CPApplicationDelegate>

@property (nonatomic, strong) CPInterfaceController *interfaceController;
@property (nonatomic, strong) CPWindow *carWindow;
@property (nonatomic, strong) MainViewController *mainVC;

@end

@implementation AppDelegate

#pragma mark - CPApplicationDelegate

- (void)application:(nonnull UIApplication *)application didConnectCarInterfaceController:(nonnull CPInterfaceController *)interfaceController toWindow:(nonnull CPWindow *)window {
    NSLog(@"AMapNavi Connected To Carplay!");
    
    self.interfaceController = interfaceController;
    self.carWindow = window;
    
    self.mainVC = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.mainVC initMapTemplate];
    self.carWindow.rootViewController = self.mainVC;
    
    [self.interfaceController setRootTemplate:self.mainVC.mapTemplate animated:YES];
}

- (void)application:(nonnull UIApplication *)application didDisconnectCarInterfaceController:(nonnull CPInterfaceController *)interfaceController fromWindow:(nonnull CPWindow *)window {
    NSLog(@"AMapNavi Disconnected To Carplay!");
}

- (void)application:(UIApplication *)application didSelectManeuver:(CPManeuver *)maneuver {
    
}

- (void)application:(UIApplication *)application didSelectNavigationAlert:(CPNavigationAlert *)navigationAlert {
    
}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [AMapServices sharedServices].apiKey = @"ef219b7c59224731c6c37dd6484ac3ba";
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
