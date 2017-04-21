//
//  DJMusicEditorController.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 3/17/13
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJMusicEditorController.h"
#import "DJPlayer.h"


@interface DJMusicEditorController (){
    UIButton *currentStartBtn;
    UIButton *currentLengthBtn;
    int increment;
    NSDate *startDate;
}

@end

@implementation DJMusicEditorController


#pragma mark - Setters and Getters:
/*
 * Setters and Getters
 */

-(void)setParentAudio:(DJAudio *)parentAudio {
    _parentAudio = parentAudio;
    if(_parentAudio.musicURL) self.audioURL = _parentAudio.musicURL;
    self.songLength = _parentAudio.musicDuration;
    self.songStart  = _parentAudio.musicStartTime;
    [self.wholeSongSwitch setOn:_parentAudio.shouldPlayAll];
}

-(void)setSongStart:(double)dbl {
    if (dbl < 0.0) _songStart = 0.0;
    else if (dbl > (self.parentAudio.songDuration - self.songLength))
        _songStart = (self.parentAudio.songDuration - self.songLength);
    else _songStart = dbl;

    //Manipulate sliders and text boxes:
    self.songStartTextView.text = [NSString stringWithFormat:@"%1.1f", _songStart];
    
    self.songStartSlider.value = _songStart;
    self.parentAudio.musicStartTime = _songStart;
}

-(void)setSongLength:(double)dbl {
    if (dbl < 5.0) _songLength = 5.0;
    else if (dbl > 16.0) _songLength = 16.0;
    
    //Reset overlap if song length changes
//    self.parentAudio.overlap = 1.0 - self.parentAudio.announcementDuration;
    
    // Move song start if needed.
    if ((_songLength + self.songStart) > self.parentAudio.songDuration) {
        self.songStart = self.parentAudio.songDuration - _songLength;
    }
    _songLength = dbl;
    
    //Manipulate sliders and text boxes:
    self.songLengthTextView.text = [NSString stringWithFormat:@"%1.1f", _songLength];
    self.songLengthSlider.value = _songLength;
    self.parentAudio.musicDuration = _songLength;
}

-(void)setAudioURL:(NSURL *)url {
    NSError *err;
    if(!url) return;
    
    AVAudioPlayer *tmp = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];

    if(err && !tmp) {
        [NSException raise:@"failure to create audio "
                    format:@"failure to create audio from url '%@' with error '%@'", url, err];
    }
    else {
        _audioURL = url;
        
        self.songStartSlider.maximumValue = self.parentAudio.songDuration;
        [self.parentAudio setMusicClipPath:url];
        
        [self.songStartSlider setMaximumValue:tmp.duration];
        
        //Change labels
        
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        if([[url scheme] isEqualToString:@"ipod-library"]){
            NSRange r = NSMakeRange(0, 32);
            NSString *pid = [[url absoluteString] stringByReplacingCharactersInRange:r withString:@""];
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:pid forProperty:MPMediaItemPropertyPersistentID];
            MPMediaQuery *songQuery = [[MPMediaQuery alloc] init];
            [songQuery addFilterPredicate:predicate];
            for (MPMediaItem *song in [songQuery items]) {
                self.titleLabel.text = [NSString stringWithFormat:@" Title: %@",[song valueForProperty:MPMediaItemPropertyTitle]];
                self.artistLabel.text = [NSString stringWithFormat:@" Artist: %@",[song valueForProperty:MPMediaItemPropertyArtist]];
            }
        } else {
            for (NSString *format in [asset availableMetadataFormats]) {
                for (AVMetadataItem *metaItem in [asset metadataForFormat:format]) {
                    if([metaItem.commonKey isEqual: @"artist"]){
                        self.artistLabel.text = [NSString stringWithFormat:@" Artist: %@",[metaItem stringValue]];
                        if([[metaItem stringValue] isEqual:@"Ballpark DJ"]) {
                            [self showUI];
//                            [self hideUITotally:NO];
//                            self.wholeSongLabel.hidden = YES;
//                            self.wholeSongSwitch.hidden = YES;
                        }
                    }
                    if([metaItem.commonKey isEqualToString:@"title"]){
                        self.titleLabel.text = [NSString stringWithFormat:@" Title: %@",[metaItem stringValue]];
                    }
                    NSLog(@"KEY: %@ - %@", metaItem.commonKey, metaItem.stringValue);
                }
            }
        }
    }
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil playerAudio:(DJAudio *)audio
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       // Custom initialization
        
        if(audio)
        {
            self.parentAudio = audio;
        }
        
        UIBarButtonItem *cancelBtn = [[[UIBarButtonItem alloc] initWithTitle:@"      CANCEL      " style:UIBarButtonItemStyleDone target:self action:@selector(cancel)] autorelease];
        UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithTitle:@"        DONE        " style:UIBarButtonItemStyleDone target:self action:@selector(done)] autorelease];
    
        [doneBtn setWidth: self.view.frame.size.width/2];
        [cancelBtn setWidth: self.view.frame.size.width/2];
//        [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
//        [self.navigationItem setRightBarButtonItem:doneBtn animated:YES];
    }
    return self;
}

#pragma mark - View Pre&Post
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Recursive assignment to kick off the helper methods within the setter
    self.parentAudio = self.parentAudio;
    
    if(self.parentAudio.isDJClip)
    {
        self.titleLabel.text = [NSString stringWithFormat:@" Title: %@", [[self.parentAudio.musicURL.lastPathComponent componentsSeparatedByString:@"."] objectAtIndex:0]];
    }
    
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:@"Player Detail" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)]autorelease];
    [self.navigationItem setBackBarButtonItem:backButton];

}

- (void)viewWillAppear:(BOOL)animated {

    if(self.parentAudio.isDJClip)
    {
        [self showUI];
        self.artistLabel.text = @" Artist: Ballpark DJ";

        if(self.parentAudio.shouldPlayAll)
            [self hideLengthView];

    }
    else if (self.audioURL == nil) {
        [self showUI];
        [self hideUITotally:YES];
    }
    else if (self.parentAudio.shouldPlayAll) {
        [self showUI];
        [self hideUITotally:NO];
        [self.wholeSongSwitch setOn:YES animated:NO];
        
        self.songStartLabel.hidden = NO;
        self.songStartTextView.hidden = NO;
        self.songStartSlider.hidden = NO;
        self.songStartForward.hidden = NO;
        self.songStartBackward.hidden = NO;

        [self hideLengthView];
    }
    else {
        self.songLength = self.parentAudio.musicDuration;
        self.songStart  = self.parentAudio.musicStartTime;
        [self showUI];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToSongFinished) name:@"DJAudioDidFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToSongStarted) name:@"DJAudioDidStart" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJMusicDidSelect" object:nil];
    NSLog(@"%@",self.audioURL);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.parentAudio stop];
    
    self.parentAudio.musicStartTime = self.songStart;
    self.parentAudio.musicDuration  = self.songLength;
    
    if(![self.audioURL isEqual:self.parentAudio.musicURL])
        self.parentAudio.musicURL = self.audioURL;
    
    if([self.titleLabel.text length] > 0)
        self.parentAudio.title = [self.titleLabel.text stringByReplacingOccurrencesOfString:@" Title: " withString:@""];
    else
        self.parentAudio.title = @"Test";
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Helper Functions
-(void)showUI {
    self.artistLabel.hidden = NO;
    self.titleLabel.hidden = NO;
    self.songStartLabel.hidden = NO;
    self.songStartTextView.hidden = NO;
    self.songStartSlider.hidden = NO;
    self.songStartForward.hidden = NO;
    self.songStartBackward.hidden = NO;
    self.songLengthBackward.hidden = NO;
    self.songLengthForward.hidden = NO;
    self.songLengthLabel.hidden = NO;
    self.songLengthSlider.hidden = NO;
    self.songLengthTextView.hidden = NO;
    self.wholeSongSwitch.hidden = NO;
    self.wholeSongLabel.hidden = NO;
}

-(void)hideUITotally:(BOOL)bol {
    if(bol) {
        self.artistLabel.hidden = YES;
        self.titleLabel.hidden = YES;
        self.wholeSongSwitch.hidden = YES;
        self.wholeSongLabel.hidden = YES;
    }
    self.songStartLabel.hidden = YES;
    self.songStartTextView.hidden = YES;
    self.songStartSlider.hidden = YES;
    self.songStartForward.hidden = YES;
    self.songStartBackward.hidden = YES;
    self.songLengthBackward.hidden = YES;
    self.songLengthForward.hidden = YES;
    self.songLengthLabel.hidden = YES;
    self.songLengthSlider.hidden = YES;
    self.songLengthTextView.hidden = YES;
}

- (void) hideLengthView
{
    self.songLengthBackward.hidden =YES;
    self.songLengthForward.hidden = YES;
    self.songLengthLabel.hidden = YES;
    self.songLengthSlider.hidden = YES;
    self.songLengthTextView.hidden = YES;

}
//============================
//
//  Button functions!
//
//============================
-(void)done{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJMusicDidSelect" object:nil];
    [self.parentAudio stop];
    NSLog(@"%@",self.audioURL);
    
//    self.parentAudio.musicStartTime = self.songStart;
//    self.parentAudio.musicDuration  = self.songLength;
//    self.parentAudio.musicURL       = self.audioURL;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel{
    [self.parentAudio stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitingMusicView" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - iTunes

- (IBAction)songLibrarySelector:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex == 0){
        MPMediaPickerController* mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = NO;
        mediaPicker.showsCloudItems = NO;
        mediaPicker.prompt = @"Choose a song";
        [self presentViewController:mediaPicker animated:YES completion:nil];
        [mediaPicker release];
    }
    else if(sender.selectedSegmentIndex == 1) {
        DJClipsController *clips = [[DJClipsController alloc] initWithDJAudio:_parentAudio];
        [self.navigationController pushViewController:clips animated:YES];
    }
    else if(sender.selectedSegmentIndex == 2) {
        [self hideUITotally:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [self.parentAudio setEmptyMusicClip];
    }
}

#pragma mark - Button Increment:
- (IBAction)startButton:(id)sender {
    currentStartBtn = (UIButton *)sender;
    increment = [sender tag];
    
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(waitForTrackIncrement) userInfo:nil repeats:NO];
    [self.parentAudio stop];
    switch ([sender tag]) {
        case -1:
            if(self.songStartSlider.value >= 0.1)
                [self setSongStart:(self.songStartSlider.value - 0.1f)];
            break;
        case -2:
            [self setSongStart:(self.songStartSlider.value - 1.0f)];
            break;
        case 1:
            [self setSongStart:(self.songStartSlider.value + 0.1f)];
            break;
        case 2:
            [self setSongStart:(self.songStartSlider.value - 1.0f)];
            break;
        default:
            NSLog(@"Position adjust");
            break;
    }
    self.songStart = self.songStartSlider.value;
}

- (void)waitForTrackIncrement{
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(trackIncrement) userInfo:nil repeats:YES];
}

- (void)trackIncrement{
    switch(currentStartBtn.tag){
        case -1:
            if(self.songStartSlider.value >= 0.1){
                
                [self.songStartSlider setValue:self.songStartSlider.value - 0.1f];
            }
            break;
        case 1:
            [self.songStartSlider setValue:self.songStartSlider.value + 0.1f];
            break;
    }
    self.songStart = self.songStartSlider.value;
}

- (IBAction)cancelStartTimer:(id)sender {
    [self.startTimer invalidate];
    [self replay];
}

- (IBAction)songStartWillChange:(id)sender {
    [self.parentAudio stop];
    [self.playBtn setTitle:@"Play"];
}

- (IBAction)songStartChanged:(id)sender {
    self.songStart = self.songStartSlider.value;
    if(self.replayTimer){
        [self.replayTimer invalidate];
    }
    
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(replay) userInfo:nil repeats:NO];
}

- (IBAction)lengthButton:(id)sender {
    currentStartBtn = (UIButton*)sender;
    self.lengthTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(waitForLengthIncrement) userInfo:nil repeats:NO];
    [self.parentAudio stop];
    switch ([sender tag]) {
        case -1:
            self.songLength -= 0.1;
            break;
        case -2:
            self.songLength -= 1.0;
            break;
        case 1:
            self.songLength += 0.1;
            break;
        case 2:
            self.songLength += 1.0;
            break;
        default:
            NSLog(@"Clip Length Adjust");
            break;
    }
}

- (void)waitForLengthIncrement{
    self.lengthTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(lengthIncrement) userInfo:nil repeats:YES];
}

- (void)lengthIncrement{
    switch(currentStartBtn.tag){
        case -1:
            self.songLength -= 0.1;
            break;
        case 1:
            self.songLength += 0.1;
            break;
    }
}

- (IBAction)cancelLengthTimer:(id)sender {
    [self.lengthTimer invalidate];
    [self.parentAudio playMusic];
    [self.playBtn setTitle:@"Stop"];
}

- (IBAction)songLengthWillChange:(id)sender {
    [self.parentAudio stop];
}

- (IBAction)songLengthChanged:(id)sender {
    [self.parentAudio stop];
    NSNumberFormatter* numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setPositiveFormat:@"##.#"];
    
    if (self.replayTimer) {
        [self.replayTimer invalidate];
    }
    self.songLength = self.songLengthSlider.value;
    self.replayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(replay)
                                                      userInfo:nil
                                                       repeats:NO];
}

#pragma mark - Audio Control
- (IBAction)play:(id)sender {
    if(self.parentAudio.isPlaying){
        [self.parentAudio stop];
        [self.playBtn setTitle:@"Play"];
    }
    else {
        [self.parentAudio playMusic];
        [self.playBtn setTitle:@"Stop"];
    }
}

- (IBAction)allSongSwitchChanged:(id)sender {
    self.playBtn.title = @"Play";
    [self.parentAudio stop];
    if(TRUE == self.wholeSongSwitch.isOn)
    {
        [self hideLengthView];
        
        self.parentAudio.shouldPlayAll = YES;
    }
    else {
        [self showUI];
        self.parentAudio.shouldPlayAll = NO;
    }
    
}

-(void)respondToSongFinished {
    self.playBtn.title = @"Play";
}

-(void)respondToSongStarted {
    self.playBtn.title = @"Stop";
}

-(void)replay {
    [self.parentAudio stop];
    [self.playBtn setTitle:@"Play"];
    [self.parentAudio playMusic];
    [self.playBtn setTitle:@"Stop"];
}

//============================
//
//  MediaPicker functions!
//
//============================

-(void)mediaPicker :(MPMediaPickerController*)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    if (mediaItemCollection) {
        if ([[[mediaItemCollection.items objectAtIndex:0] valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
            //iCloud item, handle gracefully
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Streaming Unsupported"
                                                            message:@"To use the song you selected, please first download it from iCloud in the Music app."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        NSURL *assetURL = [[mediaItemCollection.items objectAtIndex:0] valueForProperty: MPMediaItemPropertyAssetURL];
        if(nil == assetURL) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DRM Unsupported"
                                                            message:@"Due to the FairPlay DRM on this song, it cannot be played using BallparkDJ. Visit BallparkDJ.com for more info."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self showUI];
        self.audioURL = assetURL;

        [self.songLengthSlider setMaximumValue:16.0f];
        [self.songLengthSlider setMinimumValue:5.0f];
        self.songLength = 10;
        self.songStart = 0;

        self.parentAudio.isDJClip = NO;
        
        if(self.parentAudio.isAnnouncementClipValid) {
            self.parentAudio.overlap = 1.0 - self.parentAudio.announcementDuration;
        }
        else {
            self.parentAudio.overlap = -0.5;
        }
    }
    [self.parentAudio play];
    [self.parentAudio stop];
    
    [self play:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handle_ClipPickerDidMakeSelectionNotification{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"%f, %f", self.parentAudio.musicStartTime, self.parentAudio.musicDuration);
}

-(void)mediaPickerDidCancel :(MPMediaPickerController*)mediaPicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
     
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField == self.songLengthTextView) {
        self.songLength = [textField.text floatValue];
    }
    else if(textField == self.songStartTextView) {
        self.songStart = [textField.text floatValue];
    }
}

#pragma mark - Apple Unload

- (void)dealloc {
    [_startTimer release];
    [_lengthTimer release];
    [_replayTimer release];
    [_stopTimer release];
    [_audioURL release];
    [_songStartTextView release];
    [_songLengthTextView release];
    [_toolbar release];
    [_playBtn release];
    [_titleLabel release];
    [_artistLabel release];
    [_songLibraryBtn release];
    [_songLengthSlider release];
    [_songStartSlider release];
    [_audioURL release];
    [_songStartLabel release];
    [_songLengthLabel release];
    [_songStartForward release];
    [_songStartBackward release];
    [_songLengthBackward release];
    [_songLengthForward release];
    [_wholeSongSwitch release];
    [_wholeSongLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setStartTimer:nil];
    [self setLengthTimer:nil];
    [self setReplayTimer:nil];
    [self setStopTimer:nil];
//    [self setAudioURL:nil];
    [self setSongStartTextView:nil];
    [self setSongLengthTextView:nil];
    [self setToolbar:nil];
    [self setPlayBtn:nil];
    [self setTitleLabel:nil];
    [self setArtistLabel:nil];
//    [self setAudioURL:nil];
    self.songLibraryBtn = nil;
    [self setSongLengthSlider:nil];
    [self setSongStartSlider:nil];
    [self setSongStartLabel:nil];
    [self setSongLengthLabel:nil];
    [self setSongStartForward:nil];
    [self setSongStartBackward:nil];
    [self setSongLengthBackward:nil];
    [self setSongLengthForward:nil];
    [self setWholeSongSwitch:nil];
    [self setWholeSongLabel:nil];
    [super viewDidUnload];
}
@end
