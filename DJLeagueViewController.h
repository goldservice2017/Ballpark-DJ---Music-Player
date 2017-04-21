//
//  DJLeagueViewController.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 3/1/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJAppDelegate.h"
#import "MBProgressHUD.h"


@interface DJLeagueViewController : UIViewController<UIPopoverControllerDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
    
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;

}

@property (retain, nonatomic) IBOutlet UITableView *teamTable;
@property (strong, nonatomic) DJAppDelegate* parentDelegate;
@property (retain, nonatomic) IBOutlet UIView *teamNameView;
@property (retain, nonatomic) IBOutlet UITextField *teamNameField;
@end
