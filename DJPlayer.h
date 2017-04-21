//
//  DJPlayer.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/22/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJAudio.h"

@interface DJPlayer : NSObject <NSCoding> {
    
}

@property (nonatomic,retain) DJAudio *audio;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,assign) int number;
@property BOOL  b_isBench;

-(id)init;
-(id)initWithName:(NSString *)pName andWithNumber:(int)number;

/*
 * NSCoding methods
 */
-(id)initWithCoder:(NSCoder *)coder;
-(void)encodeWithCoder:(NSCoder *)coder;
@end
