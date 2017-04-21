//
//  DJAppDelegate.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/21/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DJLeague.h"
@interface DJAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) DJLeague* league;

@property (nonatomic) BOOL IS_IN_APP;
@property (nonatomic) BOOL IS_PURCHASED_FULL_VERSION;

- (void)presentIAPAlertView;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

+ (DJAppDelegate*)sharedDelegate;

@end
