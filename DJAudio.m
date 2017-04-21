//
//  DJAudio.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/21/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJAudio.h"

@implementation DJAudio

@synthesize overlap,musicStartTime,announcementDuration;
@synthesize shouldFade;
@synthesize title;
@synthesize announcementClip;
@synthesize musicClip;

//Very confusing name–songDuration is the duration of the song
// musicDuration is the duration of the music subclip
-(double)songDuration {
    return self.musicClip.duration;
}

#pragma mark - Initialization:

-(id)init {
    self = [super init];
    self.announcementClip = nil;
    self.musicClip   = nil;
    
    overlap = -0.5;
    self.musicStartTime = 0.0;
    self.musicDuration = 8.0;
    shouldFade = false;
    self.shouldPlayAll = NO;
    self.musicVolume = 1.0;
    self.announcementVolume = 1.0;
    self.currentVolumeMode = 2;
    
    timer = [[NSTimer alloc] init];
    return self;
    self.isDJClip = NO;
    self.title = @"Test";
    
}

-(id)initFromAnnouncePath:(NSURL *)aPath andMusicPath:(NSURL *)mPath {
    self = [super init];
    
    NSError *err = nil;
    self.announcementClip    =  [[[AVAudioPlayer alloc]
                                initWithContentsOfURL:aPath
                                    error:&err] retain];
    if(err){
        self.announcementClip = nil;
        err = nil;
    }
    self.musicClip           =  [[[AVAudioPlayer alloc]
                                initWithContentsOfURL:mPath
                                    error:&err] retain];
    if (err) {
        NSLog(@"%@", err);
        self.musicClip = nil;
        err = nil;
    }
    [self.announcementClip prepareToPlay];
    [self.musicClip prepareToPlay];
    
    overlap = 0.0;
    musicStartTime = 0.0;
    self.musicDuration = 8.0;
    shouldFade = false;
    timer = [[NSTimer alloc] init];
    
    [self play];
    [self stop];
    
    return self;
}

#pragma mark - Serialization:

-(id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    NSLog(@"%@", [coder decodeObjectForKey:@"_musicURL"]);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

//    NSLog(@"TEST: %@", [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:basePath, [[coder decodeObjectForKey:@"_announcementURL"] lastPathComponent], nil]]);
    
    
    self.announcementClip =  [[AVAudioPlayer alloc]
                         initWithContentsOfURL:[NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:basePath, [[coder decodeObjectForKey:@"_announcementURL"] lastPathComponent], nil]]
                                error:nil];
    
    if([[[coder decodeObjectForKey:@"_musicURL"] scheme] isEqual:@"ipod-library"]) {
        
//        NSURL *url = [NSURL URLWithString:[coder decodeObjectForKey:@"_musicURL"]];
        
        self.musicClip =         [[AVAudioPlayer alloc]
                            initWithContentsOfURL:[coder decodeObjectForKey:@"_musicURL"]
                                error:nil];
    } else {
        
        NSLog(@"Title /=/%@", [coder decodeObjectForKey:@"_title"]);
        
        NSString *path = nil;
        
        if([[coder decodeObjectForKey:@"_title"] length] > 0)
            path = [[NSBundle mainBundle] pathForResource:[coder decodeObjectForKey:@"_title"] ofType:@"m4a"];

        if(path)
            self.musicClip = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] error:nil];
        else
            self.musicClip =         [[AVAudioPlayer alloc]
                                initWithContentsOfURL:[NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:[[NSBundle mainBundle] resourcePath], [[coder decodeObjectForKey:@"_musicURL"] lastPathComponent], nil]]
                                     error:nil];
        
//        NSLog(@"Generated URL: %@", musicClip.url);
//        NSLog(@"TESTMUSIC: %@", [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:basePath, [[coder decodeObjectForKey:@"_musicURL"] lastPathComponent], nil]]);
        
    }
    
    [self.announcementClip prepareToPlay];
    [self.musicClip prepareToPlay];
    
//    [announcementClip play];
//    [musicClip play];
    
    self.musicURL =         [[coder decodeObjectForKey:@"_musicURL"] retain];
    self.title =         [[coder decodeObjectForKey:@"_title"] retain];
    
//    self.announcementURL =  [coder decodeObjectForKey:@"_announcementURL"];
    self.overlap =          [coder decodeDoubleForKey:@"_overlap"];
    self.musicStartTime =   [coder decodeDoubleForKey:@"_musicStartTime"];
    self.musicDuration =    [coder decodeDoubleForKey:@"_duration"];
    self.shouldFade =       [coder decodeBoolForKey:@"_shouldFade"];
    self.isDJClip =         [coder decodeBoolForKey:@"_djClip"];
    self.shouldPlayAll =    [coder decodeBoolForKey:@"_playAll"];
    self.currentVolumeMode = [coder decodeIntForKey:@"_volumeMode"];
    self.announcementVolume = [coder decodeFloatForKey:@"_voiceVolume"];
    self.musicVolume = [coder decodeFloatForKey:@"_musicVolume"];
    self.announcementDuration = [coder decodeDoubleForKey:@"_voiceDuration"];
//    [self play];
    [self stop];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[self.announcementClip url] forKey:@"_announcementURL"];
    [coder encodeObject:[self.musicClip url] forKey:@"_musicURL"];
    [coder encodeDouble:self.overlap forKey:@"_overlap"];
    [coder encodeDouble:self.musicStartTime forKey:@"_musicStartTime"];
    [coder encodeDouble:self.musicDuration forKey:@"_duration"];
    [coder encodeBool:self.shouldFade forKey:@"_shouldFade"];
    [coder encodeBool:self.isDJClip forKey:@"_djClip"];
    [coder encodeBool:self.shouldPlayAll forKey:@"_playAll"];
   [coder encodeObject:self.title forKey:@"_title"];
    [coder encodeFloat:self.announcementVolume forKey:@"_voiceVolume"];
    [coder encodeFloat:self.musicVolume forKey:@"_musicVolume"];
    [coder encodeInt:self.currentVolumeMode forKey:@"_volumeMode"];
    [coder encodeDouble:self.announcementDuration forKey:@"_voiceDuration"];
}

#pragma mark - Setter/Getters

-(void)setAnnouncementClipPath:(NSURL *)aPath {
    NSError *err = nil;
    AVAudioPlayer *temp = [[AVAudioPlayer alloc] initWithContentsOfURL:aPath error:&err];
    [self.announcementClip prepareToPlay];
    //TODO: profile and make sure this doesn't leak the previous AVAudioPlayer
    if(temp) announcementClip = temp;
    if(self.announcementClip) self.announcementDuration = self.announcementClip.duration;
}

-(void)setMusicClipPath:(NSURL *)mPath {
    if (self.musicClip) {
        [self.musicClip stop];
    }
    NSError *err = nil;
    AVAudioPlayer *temp = [[AVAudioPlayer alloc] initWithContentsOfURL:mPath error:&err];
    [temp prepareToPlay];
    //TODO: profile and make sure this doesn't leak the previous AVAudioPlayer
    if(temp) {
        self.musicClip = temp;
    }
}

-(void)setEmptyAnnounceClip {
    [self.announcementClip release];
    self.announcementClip = nil;
    [self.announcementURL release];
    self.announcementURL = nil;
    
    self.overlap = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioAnnounceRemoved" object:self];
}

-(void)setEmptyMusicClip {
    [self.musicClip release];
    self.musicClip = nil;
    [self.musicURL release];
    self.musicURL = nil;
    
    self.title = @"Test";
    
    self.overlap = 0;
    self.musicDuration = 0;
    self.musicStartTime = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioMusicRemoved" object:self];
}

#pragma mark - Playback:

-(void)updateClips:(id)sender {
    if(isFading && self.musicClip.volume > 0.0) {
        self.musicClip.volume -= volumeInc;
        self.announcementClip.volume -= volumeInc;
    }
    else if(!self.shouldPlayAll) {
        if(self.musicClip.currentTime >= ((self.musicStartTime + self.musicDuration) - FADEOUT_TIME))
            isFading = YES;
    } else {
        if(self.musicClip.currentTime >= (self.musicClip.duration - FADEOUT_TIME))
            isFading = YES;
    }
    if((endPoint <= fabs([startDate timeIntervalSinceNow])) || (self.musicClip.volume <= 0.0 || self.announcementClip.volume <= 0.0)) {
        [self stop];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioDidFinish" object:self];
    }
}
-(void)play {
    if(self.isPlaying) return;
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
    self.announcementClip.volume = self.announcementVolume;
    self.musicClip.volume = self.musicVolume;
    
    volumeInc = [self.musicClip volume] / (FADEOUT_TIME * 100);
    //    endPoint = ((musicDuration > (overlap + announcementClip.duration))
//                 ? musicDuration : (overlap + announcementClip.duration)) +
//                ((overlap > 0) ? overlap : 0);
//
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioDidStart" object:self];
    if (!self.announcementClip && self.musicClip) {
        [self playMusic];
        return;
    } else if (!self.musicClip && self.announcementClip) {
        [self playAnnnouncement];
        return;
    } else if (self.overlap >= 0) {
        [self.announcementClip playAtTime:self.announcementClip.deviceCurrentTime + fabs(overlap)];
        if(self.musicDuration > (fabs(overlap) + self.announcementClip.duration)){
            endPoint = (!self.shouldPlayAll) ? self.musicDuration : self.musicClip.duration;
        } else endPoint = fabs(overlap) + ((!self.shouldPlayAll) ? self.announcementDuration : self.musicClip.duration);
        [self.musicClip play];
    }
    else {
        [self.musicClip playAtTime:self.musicClip.deviceCurrentTime + fabs(overlap)];
        endPoint = fabs(overlap) + ((!self.shouldPlayAll) ? self.musicDuration : self.musicClip.duration);

        [self.announcementClip play];
    }

    startDate = [[NSDate date] retain];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateClips:) userInfo:nil repeats:YES];
}

-(void)playAnnnouncement {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioDidStart" object:self];
    [self.announcementClip play];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateAnnouncePlay) userInfo:nil repeats:YES];
}

-(void)playMusic {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioDidStart" object:self];
    [self.musicClip play];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateMusicPlay) userInfo:nil repeats:YES];
}

-(void)updateMusicPlay {
    if((self.musicClip.currentTime >= (((self.shouldPlayAll) ? self.musicClip.duration : (self.musicDuration + self.musicStartTime)))) || musicClip.volume <= 0.0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioDidFinish" object:self];
        [self stop];
    }
    if(isFading)
        self.musicClip.volume -= volumeInc;
    else if (!self.shouldPlayAll && (self.musicClip.currentTime - self.musicStartTime) >= (self.musicDuration - FADEOUT_TIME))
        isFading = YES;
}

-(void)updateAnnouncePlay {
    if ((self.announcementClip.currentTime >= self.announcementDuration-0.11) || self.announcementClip.volume <= 0.0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DJAudioDidFinish" object:self];
        [self stop];
    }
    if(isFading)
        self.announcementClip.volume -= volumeInc;
}

-(bool)isPlaying{
    return ([self.musicClip isPlaying] || [self.announcementClip isPlaying]);
}

//The next two functions were added to allow checking the state of the individual
//avaudio objects so that we can properly display ui elements when they are first displayed
//For example: navigating to the edit view of a player that has had audio.music set up but not audio.announcement
- (bool)isMusicClipValid {
    if (self.musicClip)
        return YES;
    else
        return NO;
}

- (bool)isAnnouncementClipValid {
    if(self.announcementClip)
        return YES;
    else
        return NO;
}

-(void)stop {
    [self.musicClip pause];
    [self.announcementClip pause];
    if (timer) {
        [timer invalidate];
        timer = nil;
//        NSLog(@"Timer should stop!");
    }
    
    self.musicClip.currentTime = musicStartTime;
    self.announcementClip.currentTime = 0;
    
    self.musicClip.volume = self.musicVolume;
    self.announcementClip.volume = self.announcementVolume;
    
    isFading = NO;
}

-(void)stopWithFade {
    volumeInc = 1.0 / ((FADEOUT_TIME - 0.5) * 100);
    isFading = YES;
}

@end
