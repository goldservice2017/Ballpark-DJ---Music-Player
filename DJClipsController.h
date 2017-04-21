//
//  DJClipsController.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 3/7/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJAudio.h"
#import <QuartzCore/QuartzCore.h>
#import "DJMusicEditorController.h"

@interface DJClipsController : UIViewController <UITableViewDataSource,UITableViewDelegate> {
    DJAudio *audio;
    NSDictionary *songDict;
    NSIndexPath *playerIndex;
    AVAudioPlayer *previewPlayer;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

-(id)initWithDJAudio:(DJAudio *)pAudio;

@end
