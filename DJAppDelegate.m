//
//  DJAppDelegate.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/21/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJAppDelegate.h"
#import "DJDetailController.h"
#import "DJLeagueViewController.h"
#import "DJMusicEditorController.h"
#import "DJPlayersViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioServices.h>
#include "TestFlight.h"
//#import "MKStoreManager.h"

@implementation DJAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // implicitly initializes your audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *audioSessionError = nil;
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:&audioSessionError];
     
    self.league = [[DJLeague alloc] init];
    [self switchViewToLeague];
    
    [TestFlight takeOff:@"b94a4e80-cdd2-4cde-a84d-819ff93c571a"];
    
//    [MKStoreManager sharedManager];
//    [[MKStoreManager sharedManager] purchasableObjectsDescription];

    
    return YES;
}

//- (void)presentIAPAlertView {
//    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Upgrade!" message:@"BallparkDJ Free only allows 3 teams and 3 players." delegate:self cancelButtonTitle:@"Don't Upgrade" otherButtonTitles:@"Upgrade to Pro ($6.99)", @"I've already upgraded!", nil];
//    [a show];
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    switch (buttonIndex) {
//        case 0:
//            return;
//        case 1:
//            [[MKStoreManager sharedManager] buyFeature:kBallparkFullVersion
//                onComplete:^(NSString* purchasedFeature, NSData*purchasedReceipt, NSArray* availableDownloads)
//                 {
//                     NSLog(@"Purchased: %@", purchasedFeature);
//                     [[NSNotificationCenter defaultCenter] postNotificationName:@"DJIAPPurchaseDidComplete" object:nil];
//                 }
//                onCancelled:^{}
//             ];
//            break;
//        case 2:
//            [[MKStoreManager sharedManager] restorePreviousTransactionsOnComplete:^()
//                {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJIAPPurchaseDidComplete" object:nil];
//                }
//                onError:^(NSError* error)
//                {
//                    NSLog(@"Error with purchase: %@", error);
//                }
//            ];
//            break;
//        default:
//            return;
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.league encode];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}


-(void)switchViewToLeague{
    DJLeagueViewController* leagueViewController = [[DJLeagueViewController alloc] initWithNibName:@"DJLeagueView" bundle:nil];
    
    [leagueViewController setParentDelegate:self];
    [leagueViewController autorelease];
    
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:leagueViewController] autorelease];
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:.2 blue:0.2 alpha:1.0];
    [self.window setRootViewController:navigationController];
}


+ (DJAppDelegate*)sharedDelegate
{
    return (DJAppDelegate*)[[UIApplication sharedApplication] delegate];
}

@end
