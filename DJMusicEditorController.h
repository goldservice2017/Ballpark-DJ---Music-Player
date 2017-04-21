//
//  DJMusicEditorController.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/22/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "DJAudio.h"
#import "DJDetailController.h"
#import "DJClipsController.h"

@interface DJMusicEditorController : UIViewController
    <MPMediaPickerControllerDelegate,
        UIPopoverControllerDelegate,
        UITextFieldDelegate>

@property (assign, nonatomic) double songStart;
@property (assign, nonatomic) double songLength;
@property (retain, nonatomic) NSTimer *startTimer;
@property (retain, nonatomic) NSTimer *lengthTimer;
@property (retain, nonatomic) NSTimer *replayTimer;
@property (retain, nonatomic) NSTimer *stopTimer;


//Model Properties
//@property (retain, nonatomic, readonly) AVAudioPlayer *music;
@property (assign, nonatomic) DJAudio *parentAudio;
@property (retain, nonatomic) NSURL* audioURL;
//View Properties

@property (retain, nonatomic) IBOutlet UISegmentedControl *songLibraryBtn;
@property (assign, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) IBOutlet UILabel *artistLabel;
@property (retain, nonatomic) IBOutlet UITextField *songStartTextView;
@property (retain, nonatomic) IBOutlet UITextField *songStartLabel;
@property (retain, nonatomic) IBOutlet UIButton *songStartForward;
@property (retain, nonatomic) IBOutlet UIButton *songStartBackward;
@property (retain, nonatomic) IBOutlet UISlider *songStartSlider;
@property (retain, nonatomic) IBOutlet UITextField *songLengthTextView;
@property (retain, nonatomic) IBOutlet UITextField *songLengthLabel;
@property (retain, nonatomic) IBOutlet UIButton *songLengthForward;
@property (retain, nonatomic) IBOutlet UIButton *songLengthBackward;
@property (retain, nonatomic) IBOutlet UISlider *songLengthSlider;
@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *playBtn;
@property (retain, nonatomic) IBOutlet UISwitch *wholeSongSwitch;
@property (retain, nonatomic) IBOutlet UILabel *wholeSongLabel;

-(void)showUI;
-(void)hideUITotally:(BOOL)bol;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil playerAudio:(DJAudio *) audioOrNil;
- (IBAction)songLibrarySelector:(UISegmentedControl *)sender;
- (IBAction)startButton:(id)sender;
- (IBAction)cancelStartTimer:(id)sender;
- (IBAction)songStartWillChange:(id)sender;
- (IBAction)songStartChanged:(id)sender;
- (IBAction)lengthButton:(id)sender;
- (IBAction)cancelLengthTimer:(id)sender;
- (IBAction)songLengthWillChange:(id)sender;
- (IBAction)songLengthChanged:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)replay;
- (IBAction)allSongSwitchChanged:(id)sender;

@end
