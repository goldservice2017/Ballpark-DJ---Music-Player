//
//  DJVoiceRecorderViewController.h
//  BallparkDJ
//
//  Created by Timothy Goodson on 6/6/12.
//  Copyright (c) 2012 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioSettings.h>
#import "DJAppDelegate.h"
#import "MBProgressHUD.h"

@interface DJRecorderController : UIViewController <AVAudioPlayerDelegate,UIPopoverControllerDelegate, MBProgressHUDDelegate>{
@private
    AVAudioRecorder* _recorder;
    MBProgressHUD *HUD;
    
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}
@property (strong, nonatomic) DJAppDelegate* parentDelegate;
@property(strong, nonatomic) AVAudioRecorder* recorder;
@property (retain, nonatomic) DJAudio *announcement;
@property(assign, nonatomic) BOOL isRecording;

@property (retain, nonatomic) IBOutlet UILabel *elapsedTimeMeter;
@property (retain, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *cancelDoneButton;
@property (retain, nonatomic) IBOutlet UIButton *recordButton
;
@property (retain, nonatomic) IBOutlet UIImageView *mainPic;

@property(copy, nonatomic) NSString* filename;
@property(strong, nonatomic) AVAudioPlayer* musicPlayer;

@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *tapToStop;

- (void)initRecorderWithFileName:(NSString*)fileName;
- (IBAction)recordPauseButtonDidGetPressed:(id)sender;
- (IBAction)playButtonDidGetPressed:(id)sender;
//- (IBAction)cancelDoneButtonPressed:(UISegmentedControl *)sender;
//- (IBAction)cancelButtonPressed:(UIButton *)sender;
//- (IBAction)doneButtonPressed:(UIButton *)sender;

@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL0;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL1;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL2;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL3;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL4;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL5;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL6;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL7;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL8;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL9;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL10;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL11;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL12;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL13;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL14;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL15;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL16;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL17;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL18;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL19;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL20;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL21;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL22;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL23;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL24;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL25;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL26;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *powerMeterL27;


@end
