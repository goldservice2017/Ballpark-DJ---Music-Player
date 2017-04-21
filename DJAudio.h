#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define FADEOUT_TIME 2.0

@interface DJAudio : NSObject <NSCoding> {
//    AVAudioPlayer *announcementClip;
//    AVAudioPlayer *musicClip;
    
    bool isFading;
    double volumeInc;
    NSTimer *timer;
    NSTimer *musicTimer;
    NSTimer *announcementTimer;
    double endPoint;
    
    
    NSDate *startDate;
}
@property (retain,nonatomic) AVAudioPlayer *announcementClip;
@property (retain,nonatomic) AVAudioPlayer *musicClip;
@property (retain,nonatomic) NSURL *announcementURL;
@property (retain,nonatomic) NSURL *musicURL;
@property (retain, nonatomic) NSString    *title;
@property (assign, nonatomic) CGFloat announcementVolume;
@property (assign, nonatomic) CGFloat musicVolume;
@property (assign, nonatomic) int currentVolumeMode;
@property (assign,readonly,nonatomic) double songDuration;

/*
 * Negative value = announcement first
 * Positive value = music first
 */
@property (assign,nonatomic) double overlap;
@property (assign,nonatomic) double musicStartTime;
@property (assign,nonatomic) double musicDuration;
@property (assign,nonatomic) double announcementDuration;
@property (assign,nonatomic) BOOL shouldFade;
@property (assign,nonatomic) BOOL isDJClip;
@property (assign, nonatomic) BOOL shouldPlayAll;

/*
 * NSCoding methods
 */
-(id)init;
-(id)initFromAnnouncePath:(NSURL *)aPath andMusicPath:(NSURL *)mPath;
-(bool)isPlaying;
-(id)initWithCoder:(NSCoder *)coder;
-(void)encodeWithCoder:(NSCoder *)coder;
/*
 * Instance methods
 */
-(void)setAnnouncementClipPath:(NSURL *)aPath;
-(void)setMusicClipPath:(NSURL *)mPath;
-(void)setEmptyAnnounceClip;
-(void)setEmptyMusicClip;
-(void)play;
-(bool)isMusicClipValid;
-(bool)isAnnouncementClipValid;
-(void)playAnnnouncement;
-(void)playMusic;
-(void)stop;
-(void)stopWithFade;

@end
