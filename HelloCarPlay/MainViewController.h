//
//  MainViewController.h
//  HelloCarPlay
//
//  Created by eidan on 2018/9/4.
//  Copyright © 2018年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CarPlay/CarPlay.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController <CPMapTemplateDelegate>

@property (nonatomic, strong) CPMapTemplate *mapTemplate;

- (void)initMapTemplate;

@end

NS_ASSUME_NONNULL_END
