//
//  DJDetailController.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/22/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJLeague.h"
#import "DJAppDelegate.h"
#import "DJTeam.h"
#import "DJPlayer.h"
#import "DJOverlapSlider.h"
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"

@interface DJDetailController : UIViewController <UIAlertViewDelegate,UIPopoverControllerDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSArray *_products;
}

//Model objects
@property (retain, nonatomic) DJTeam *team;
@property (retain, nonatomic) DJPlayer *player;
@property (assign, nonatomic) int playerIndex;
@property (assign, nonatomic) UIViewController *parent;

//View Objects
@property (retain, nonatomic) IBOutlet UITextField *playerNumberField;
@property (retain, nonatomic) IBOutlet UITextField *playerNameField;
@property (retain, nonatomic) IBOutlet UIButton *announceEditBtn;
@property (retain, nonatomic) IBOutlet UIButton *announcePlayBtn;
@property (retain, nonatomic) IBOutlet UIView *announceEdit;
@property (retain, nonatomic) DJOverlapSlider* overlapSlider;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *playBtn;

@property (retain, nonatomic) IBOutlet UIButton *musicEditBtn;
@property (retain, nonatomic) IBOutlet UIButton *musicPlayBtn;
@property (retain, nonatomic) IBOutlet UIView *musicEdit;
@property (retain, nonatomic) IBOutlet UISwitch *benchSlider;
@property (retain, nonatomic) IBOutlet UIView *vwRelativeVolume;
@property (retain, nonatomic) IBOutlet UISlider *sliderVolumeMode;
@property (retain, nonatomic) IBOutlet UILabel *lblRoudestMusic;
@property (retain, nonatomic) IBOutlet UIButton *btnRoudestMusic;
@property (retain, nonatomic) IBOutlet UILabel *lblRouderMusic;
@property (retain, nonatomic) IBOutlet UIButton *btnRouderMusic;
@property (retain, nonatomic) IBOutlet UILabel *lblEven;
@property (retain, nonatomic) IBOutlet UIButton *btnEven;
@property (retain, nonatomic) IBOutlet UILabel *lblRouderVoice;
@property (retain, nonatomic) IBOutlet UIButton *btnRouderVoice;
@property (retain, nonatomic) IBOutlet UILabel *lblRoudestVoice;
@property (retain, nonatomic) IBOutlet UIButton *btnRoudestVoice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withPlayer:(DJPlayer *)p;

- (IBAction)musicEdit:(id)sender;
- (IBAction)musicPlay:(id)sender;
- (IBAction)announceEdit:(id)sender;
- (IBAction)announcePlay:(id)sender;

- (IBAction)playAudio:(id)sender;
- (IBAction)stopAudio:(id)sender;

-(void)respondToRemovedAnnounce:(id)sender;
-(void)respondToRemovedAudio:(id)sender;
@end
