//
//  DJRecorderController.h
//  BallparkDJ
//
//  Created by Kevin Gross on 3/6/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJRecorderController.h"
#import <CoreAudio/CoreAudioTypes.h>
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"
#import "DJAppDelegate.h"

@interface DJRecorderController ()<UIAlertViewDelegate>{
    NSTimer* _timer;
    NSInteger _count;
    float _tmrSeconds;
    NSURL *announceURL;
    
}
@end

@implementation DJRecorderController

@synthesize cancelDoneButton;
@synthesize recordButton;
@synthesize mainPic;
@synthesize elapsedTimeMeter;
@synthesize recordPauseButton;
@synthesize playButton;
@synthesize powerMeterL0;
@synthesize powerMeterL1;
@synthesize powerMeterL2;
@synthesize powerMeterL3;
@synthesize powerMeterL4;
@synthesize powerMeterL5;
@synthesize powerMeterL6;
@synthesize powerMeterL7;
@synthesize powerMeterL8;
@synthesize powerMeterL9;
@synthesize powerMeterL10;
@synthesize powerMeterL11;
@synthesize powerMeterL12;
@synthesize powerMeterL13;
@synthesize powerMeterL14;
@synthesize powerMeterL15;
@synthesize powerMeterL16;
@synthesize powerMeterL17;
@synthesize powerMeterL18;
@synthesize powerMeterL19;
@synthesize powerMeterL20;
@synthesize powerMeterL21;
@synthesize powerMeterL22;
@synthesize powerMeterL23;
@synthesize powerMeterL24;
@synthesize powerMeterL25;
@synthesize powerMeterL26;
@synthesize powerMeterL27;
@synthesize recorder = _recorder;
@synthesize isRecording;
@synthesize musicPlayer = _musicPlayer;
@synthesize filename;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

//Despite the name, this is NOT a class init, it just sets the recorder up for use
-(void)initRecorderWithFileName:(NSString *)fileName{
//    announceURL = [[NSURL alloc] init];
    self.filename = fileName;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@", fileName);
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSURL* soundFileURL = [NSURL fileURLWithPath:dPath];
    announceURL = [self.announcement announcementURL];
    NSError* recordError = nil;
    
    NSMutableDictionary* recorderSettings = [[NSMutableDictionary alloc] init];
    
    [recorderSettings setValue:[NSNumber numberWithInt:'ima4'] forKey:AVFormatIDKey];
    [recorderSettings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recorderSettings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recorderSettings setValue:[NSNumber numberWithInt:32] forKey:AVLinearPCMBitDepthKey];
    [recorderSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recorderSettings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    [recorderSettings setValue:[NSNumber numberWithInt:96] forKey:AVEncoderBitRateKey];
    [recorderSettings setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitDepthHintKey];
    [recorderSettings setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVSampleRateConverterAudioQualityKey];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recorderSettings error:&recordError];
    if (recordError) {
        NSLog(@"error: %@", recordError);
    }
    else{
        [_recorder prepareToRecord];
    }
    if (![self.recorder prepareToRecord]) {
        NSLog(@"error creating stream - recorder");
    }
    [recorderSettings release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishPurchase)
                                                 name:@"InAppPurchase" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishRestore)
                                                 name:@"RestoreInAppPurchase" object:nil];
//    SVSegmentedControl *redSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Cancel", @"No Audio", @"Done", nil]];
//    [redSC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
//	
//	redSC.crossFadeLabelsOnDrag = YES;
//	redSC.thumb.tintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1];
//	redSC.selectedIndex = 1;
//	redSC.center = CGPointMake(160, 420);
//
//	[self.view addSubview:redSC];

}

- (void)viewDidUnload
{
    self.elapsedTimeMeter = nil;
    self.recordPauseButton = nil;
    self.powerMeterL0 = nil;
    self.powerMeterL1 = nil;
    self.powerMeterL2 = nil;
    self.powerMeterL3 = nil;
    self.powerMeterL4 = nil;
    self.powerMeterL5 = nil;
    self.powerMeterL6 = nil;
    self.powerMeterL7 = nil;
    self.powerMeterL8 = nil;
    self.powerMeterL9 = nil;
    self.powerMeterL8 = nil;
    self.powerMeterL9 = nil;
    self.powerMeterL10 = nil;
    self.powerMeterL11 = nil;
    self.powerMeterL12 = nil;
    self.powerMeterL13 = nil;
    self.powerMeterL14 = nil;
    self.powerMeterL15 = nil;
    self.powerMeterL16 = nil;
    self.powerMeterL17 = nil;
    self.powerMeterL18 = nil;
    self.powerMeterL19 = nil;
    self.powerMeterL20 = nil;
    self.powerMeterL21 = nil;
    self.powerMeterL22 = nil;
    self.powerMeterL23 = nil;
    self.powerMeterL24 = nil;
    self.powerMeterL25 = nil;
    self.powerMeterL26 = nil;
    self.powerMeterL27 = nil;
    self.cancelDoneButton = nil;
    self.recordButton = nil;
    self.mainPic = nil;
    [self setPlayButton:nil];
    [super viewDidUnload];
}
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (void)dealloc {
    [elapsedTimeMeter release];
    [recordPauseButton release];
    /*[powerMeterL0 release];
    [powerMeterL1 release];
    [powerMeterL2 release];
    [powerMeterL3 release];
    [powerMeterL4 release];
    [powerMeterL5 release];
    [powerMeterL6 release];
    [powerMeterL7 release];
    [powerMeterL8 release];
    [powerMeterL9 release];
    [powerMeterL8 release];
    [powerMeterL9 release];
    [powerMeterL10 release];
    [powerMeterL11 release];
    [powerMeterL12 release];
    [powerMeterL13 release];
    [powerMeterL14 release];
    [powerMeterL15 release];
    [powerMeterL16 release];
    [powerMeterL17 release];
    [powerMeterL18 release];
    [powerMeterL19 release];
    [powerMeterL20 release];
    [powerMeterL21 release];
    [powerMeterL22 release];
    [powerMeterL23 release];
    [powerMeterL24 release];
    [powerMeterL25 release];
    [powerMeterL26 release];
    [powerMeterL27 release];*/
    [cancelDoneButton release];
    [recordButton release];
    [mainPic release];
    [playButton release];
    [_tapToStop release];
    [super dealloc];
}

-(void)countdownToRecord{
    
    if (_count > 0) {
        
        switch (_count) {
            case 2:
                self.mainPic.image = [UIImage imageNamed:@"RecCount2"];
                break;
            case 1:
                self.mainPic.image = [UIImage imageNamed:@"RecCount1"];
                break;
            default:
                break;
        }
        _count--;
    } else {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *audioSessionError = nil;
        [session setCategory:AVAudioSessionCategoryRecord
                 withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                       error:&audioSessionError];
        self.recordButton.hidden = NO;
        
        if(_timer)
        {
            [_timer invalidate];
            _timer = nil;
        }
        self.recorder.meteringEnabled = YES;
        
        self.elapsedTimeMeter.textColor = [UIColor greenColor];
        [self.recordButton setImage:[UIImage imageNamed:@"stopButton.png"]
                           forState:UIControlStateNormal];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                  target:self
                                                selector:@selector(updateUI)
                                                userInfo:nil
                                                 repeats:YES];
        [self.recorder record];
        self.tapToStop.enabled = YES;
    }
    
}

- (IBAction)recordPauseButtonDidGetPressed:(id)sender {
    
    if(!self.recorder){
        
    }
    if (!self.recorder.isRecording) {
        
        self.recordButton.hidden = YES;

        _count = 2;
        self.mainPic.image = [UIImage imageNamed:@"RecCount3"];
        _timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(countdownToRecord)
                                                userInfo:nil
                                                 repeats:YES] retain];
        
        CGRect rect = self.recordButton.frame;
        rect.origin.x = 104;
        self.recordButton.frame = rect;

        self.cancelDoneButton.hidden = YES;
        self.playButton.hidden = YES;
    }else {
        
        [self recordFinalize];
    }
}
-(void)recordFinalize {
    [_timer invalidate];
    self.recorder.meteringEnabled = NO;
    [self.recordButton setImage:[UIImage imageNamed:@"recButton.png"]
                       forState:UIControlStateNormal];
    [self.recorder stop];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *audioSessionError = nil;
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:&audioSessionError];
    
    CGRect rect = self.recordButton.frame;
    rect.origin.x = 41;
    self.recordButton.frame = rect;
    
    self.cancelDoneButton.hidden = NO;
    self.playButton.hidden = NO;
    
    self.elapsedTimeMeter.textColor = [UIColor redColor];
    announceURL = [self.recorder url];
    self.tapToStop.enabled = NO;
    
    for (UIImageView* img in powerMeterL0) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }
    for (UIImageView* img in powerMeterL1) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL2) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL3) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL4) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL5) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL6) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL7) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL8) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL9) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL10) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL11) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL12) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL13) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL14) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL15) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL16) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL17) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL18) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL19) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL20) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL21) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL22) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL23) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL24) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL25) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL26) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }            for (UIImageView* img in powerMeterL27) {
        [img setImage:[UIImage imageNamed:@"clearBar.png"]];
    }
}
-(void)initializeRecordedAnnouncement{
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dPath = [documentsDirectory stringByAppendingPathComponent:self.filename];
    NSURL* soundFileURL = [NSURL fileURLWithPath:dPath];
    NSError* playerError = nil;
    if (_musicPlayer) {
        [_musicPlayer release];
    }
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&playerError];
    [self.musicPlayer setDelegate:self];
    
    
    if (playerError) {
        NSLog(@"error assigning recording file: %@", playerError);
    }
    
    if (![self.musicPlayer prepareToPlay]) {
        NSLog(@"error creating stream");
    }
    
    
}

- (IBAction)playButtonDidGetPressed:(id)sender {
    if (self.musicPlayer.isPlaying) {
        [self.musicPlayer stop];
        [self.playButton setImage:[UIImage imageNamed:@"playButton.png"]
                         forState:UIControlStateNormal];
    } else {
        [self initializeRecordedAnnouncement];
        [self.musicPlayer play];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateUIForPlayer) userInfo:nil repeats:YES];
        [self.playButton setImage:[UIImage imageNamed:@"stopButton.png"]
                         forState:UIControlStateNormal];
    }
    
}

//-(IBAction)cancelButtonPressed:(UIButton *)sender{
//    [self.recorder stop];
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"ANNOUNCEMENTNOTSAVED" object:nil];
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//-(IBAction)doneButtonPressed:(UIButton *)sender{
//    [self.recorder stop];
//    
//    //Only set announcement URL if it has changed
//    if(announceURL != [self.announcement announcementURL]) 
//        [self.announcement setAnnouncementClipPath:announceURL];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAnnounceDidSave" object:nil];
//    [self dismissModalViewControllerAnimated:YES];
//}

- (IBAction)cancelDoneButtonPressed:(UISegmentedControl *)sender {
    if (self.recorder.isRecording)
        [self.recorder stop];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *audioSessionError = nil;
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:&audioSessionError];
    if (2 == sender.selectedSegmentIndex) {
        if(announceURL != [self.announcement announcementURL])
            [self.announcement setAnnouncementClipPath:announceURL];
        self.announcement.overlap = 0; //reset the overlap
    } else if (1 == sender.selectedSegmentIndex) {
        [self.announcement setEmptyAnnounceClip];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if(2 == sender.selectedSegmentIndex)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAnnounceDidSave" object:nil];

}

-(void)updateUIForPlayer{
    
    if (self.musicPlayer.isPlaying) {
        _tmrSeconds = [[NSNumber numberWithDouble:[self.musicPlayer currentTime]] floatValue];;
        [self.playButton setImage:[UIImage imageNamed:@"pauseButton.png"]
                         forState:UIControlStateNormal];
        self.elapsedTimeMeter.text = [NSString stringWithFormat:@"%1.1f", _tmrSeconds];
    } else {
        [_timer invalidate];
        _tmrSeconds = 0;
        self.elapsedTimeMeter.text = [NSString stringWithFormat:@"%1.1f", _tmrSeconds];
        [self.playButton setImage:[UIImage imageNamed:@"playButton.png"]
                         forState:UIControlStateNormal];
    }
}

-(void)updateUI{
    
    if ([self.recorder isRecording]) {
        _tmrSeconds = [[NSNumber numberWithDouble:[self.recorder currentTime]] floatValue];
        
        self.elapsedTimeMeter.text = [NSString stringWithFormat:@"%1.1f", _tmrSeconds];
        self.mainPic.image = [UIImage imageNamed:@"RecordingMic"];
        //update power meter LEDs levels are in dB
        [self.recorder updateMeters];
        if ([self.recorder averagePowerForChannel:0] > -30.0) {
            for (UIImageView* img in powerMeterL0) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  ////
            }
        }else{
            for (UIImageView* img in powerMeterL0) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -26.0) {
            for (UIImageView* img in powerMeterL1) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL1) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -22.5) {
            for (UIImageView* img in powerMeterL2) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL2) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -21.0) {
            for (UIImageView* img in powerMeterL3) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL3) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -19.1) {
            for (UIImageView* img in powerMeterL4) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  /////
            }
        }else{
            for (UIImageView* img in powerMeterL4) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -16.8) {
            for (UIImageView* img in powerMeterL5) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL5) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -15.5) {
            for (UIImageView* img in powerMeterL6) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL6) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -14.6) {
            for (UIImageView* img in powerMeterL7) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]]; //////
            }
        }else{
            for (UIImageView* img in powerMeterL7) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -13.3) {
            for (UIImageView* img in powerMeterL8) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL8) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -12.4) {
            for (UIImageView* img in powerMeterL9) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL9) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -11.0) {
            for (UIImageView* img in powerMeterL10) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL10) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -10.1) {
            for (UIImageView* img in powerMeterL11) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  /////////
            }
        }else{
            for (UIImageView* img in powerMeterL11) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -9.7) {
            for (UIImageView* img in powerMeterL12) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL12) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -9.1) {
            for (UIImageView* img in powerMeterL13) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL13) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -8.3) {
            for (UIImageView* img in powerMeterL14) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]]; ///////
            }
        }else{
            for (UIImageView* img in powerMeterL14) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -6.1) {
            for (UIImageView* img in powerMeterL15) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL15) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -5.2) {
            for (UIImageView* img in powerMeterL16) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL16) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -4.8) {
            for (UIImageView* img in powerMeterL17) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];   /////////
            }
        }else{
            for (UIImageView* img in powerMeterL17) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -4.0) {
            for (UIImageView* img in powerMeterL18) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL18) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -3.6) {
            for (UIImageView* img in powerMeterL19) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL19) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -3.0) {
            for (UIImageView* img in powerMeterL20) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];    /////////
            }
        }else{
            for (UIImageView* img in powerMeterL20) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -2.5) {
            for (UIImageView* img in powerMeterL21) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL21) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -2.0) {
            for (UIImageView* img in powerMeterL22) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL22) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -1.7) {
            for (UIImageView* img in powerMeterL23) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];
            }
        }else{
            for (UIImageView* img in powerMeterL23) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -1.3) {
            for (UIImageView* img in powerMeterL24) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];   ////////
            }
        }else{
            for (UIImageView* img in powerMeterL24) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > -0.8) {
            for (UIImageView* img in powerMeterL25) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];    /////
            }
        }else{
            for (UIImageView* img in powerMeterL25) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > 0.4) {
            for (UIImageView* img in powerMeterL26) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];    /////
            }
        }else{
            for (UIImageView* img in powerMeterL26) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        if ([self.recorder averagePowerForChannel:0] > 0.7) {
            for (UIImageView* img in powerMeterL27) {
                [img setImage:[UIImage imageNamed:@"greenBar.png"]];  ///////
            }
        }else{
            for (UIImageView* img in powerMeterL27) {
                [img setImage:[UIImage imageNamed:@"clearBar.png"]];
            }
        }
        
        
        
    } else {
        for (UIImageView* img in powerMeterL0) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL1) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL2) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL3) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL4) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL5) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL6) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL7) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL8) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL9) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL10) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL11) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL12) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL13) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL14) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL15) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL16) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL17) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL18) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL19) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL20) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL21) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL22) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL23) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL24) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL25) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL26) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
        for (UIImageView* img in powerMeterL27) {
            [img setImage:[UIImage imageNamed:@"clearBar.png"]];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        NSLog(@"Cancel");
    }
    else if(buttonIndex == 1) {
        NSLog(@"Purchase");
        HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
        [[DJAppDelegate sharedDelegate].window addSubview:HUD];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Loading...";
        [HUD show:YES];
        
        
        SKProduct *product = _products[0];
        
        NSLog(@"Buying %@...", product.productIdentifier);
        [[RageIAPHelper sharedInstance] buyProduct:product];
        
        [self performSelector:@selector(stopHUDLoop) withObject:nil afterDelay:12.0];
    }
    else if(buttonIndex == 2) {
        HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
        [[DJAppDelegate sharedDelegate].window addSubview:HUD];
        HUD.delegate = self;
        HUD.dimBackground = YES;
        HUD.labelText = @"Loading...";
        [HUD show:YES];
        
        
        [[RageIAPHelper sharedInstance] restoreCompletedTransactions];
        
        [self performSelector:@selector(stopHUDLoop) withObject:nil afterDelay:12.0];
    }
    
    
}
-(void)stopHUDLoop
{
    if(HUD == nil)
        return;
    
    [HUD show:NO];
    [HUD removeFromSuperview];
    HUD = nil;
}
- (void) onFinishPurchase
{
    [self stopHUDLoop];
}

- (void) onFinishRestore
{
    [self stopHUDLoop];
    
    [[[UIAlertView alloc] initWithTitle:@"Congratulation!" message:@"Successfully Restored" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}
- (void)presentIAPAlertView {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Upgrade!" message:@"The free version of BallparkDJ allows playback of voice recordings up to 15 seconds. Click below to purchase the full version for unlimited voice duration." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upgrade to Pro ($6.99)", @"I've Already Upgraded!", nil];
    [a show];
    [a release];
}
- (void)reload {
    _products = nil;
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = [products retain];
        }
    }];
    
    NSLog(@"_products in reload : %@", _products);
}
- (void)removeHud
{
    sleep(4);
    
    //    [self.navigationController popViewControllerAnimated:YES];
}
- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            *stop = YES;
        }
    }];
}
@end
