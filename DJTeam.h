//
//  DJTeam.h
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/22/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJPlayer.h"

@interface DJTeam : NSObject <NSCoding> {
    
}

@property (retain, nonatomic) NSMutableArray *players;
@property (retain, nonatomic) NSString *teamName;

-(id)initWithName:(NSString *)name;

-(id)initWithCoder:(NSCoder *)coder;
//-(id)initWithUnarchiver:(NSKeyedUnarchiver *)unarchiver withPath:(NSString *) index;
//-(void)encodeWithArchiver:(NSKeyedArchiver *)archiver withPath:(NSString *) index;
-(void)encodeWithCoder:(NSCoder *)coder;
-(void)insertObject:(DJPlayer *)player inPlayersAtIndex:(NSInteger)index;
-(DJPlayer*)objectInPlayersAtIndex:(NSUInteger)index;
@end
