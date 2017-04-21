//
//  DJTeam.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 3/1/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJTeam.h"

@implementation DJTeam

@synthesize players;
@synthesize teamName;

#pragma mark - Initialization:

-(id)init{
    self = [super init];
    self.teamName = @"";
    self.players = [[[NSMutableArray alloc] init] autorelease];
    return self;
}

-(id)initWithName:(NSString *)name {
    self = [super init];
    self.teamName = name;
    self.players = [[[NSMutableArray alloc] init] autorelease];
    return self;
}

#pragma mark - Serialization:

//-(id)initWithUnarchiver:(NSKeyedUnarchiver *)unarchiver withPath:(NSString *) index{
//    self = [super init];
//    self.players = [[NSMutableArray alloc] init];
//    self.teamName = [unarchiver decodeObjectForKey:[index stringByAppendingString:@"_name"]];
//    NSInteger playerCount = [unarchiver decodeIntForKey:[index stringByAppendingString:@"_playerCount"]];
//    NSLog(@"%@",[unarchiver decodeObjectForKey:[index stringByAppendingString:@"_name"]]);
//    NSLog(@"playerCount = %d",playerCount);
//    for(int i = 0; i < playerCount; ++i){
//        NSString *playerKey = [index stringByAppendingString:[NSString stringWithFormat:@"/player_%d", i]];
//        NSLog(@"%@",playerKey);
//        DJPlayer *p = [[DJPlayer alloc] initWithUnarchiver:unarchiver withPath:playerKey];
//        [self insertObject:p inPlayersAtIndex:i];
//        [p release];
//    }
//    return self;
//}

-(id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    
    self.players = [[NSMutableArray alloc] init];
    self.players = [[coder decodeObjectForKey:@"_players"] retain];
    self.teamName = [[coder decodeObjectForKey:@"_name"] retain];
    
    return self;
}

-(void)insertObject:(DJPlayer *)player inPlayersAtIndex:(NSInteger)index{
    [self.players insertObject:player atIndex:index];
}

-(DJPlayer*)objectInPlayersAtIndex:(NSUInteger)index{
    return [self.players objectAtIndex:index];
}

//-(void)encodeWithArchiver:(NSKeyedArchiver *)archiver withPath:(NSString *) index{
//    [archiver encodeObject:self.teamName forKey:[index stringByAppendingString:@"_name"]];
//    NSInteger playerCount = self.players.count;
//    [archiver encodeInt:playerCount forKey:[index stringByAppendingString:@"_playerCount"]];
//     NSLog(@"playerCount = %d",self.players.count);
//    for(int i = 0; i < self.players.count; ++i){
//        NSString *playerKey = [index stringByAppendingString:[NSString stringWithFormat:@"/player_%d", i]];
//        NSLog(@"%@",playerKey);
//        [[self objectInPlayersAtIndex:i] encodeWithArchiver:archiver withPath:playerKey];
//    }
//}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:players forKey:@"_players"];
    //[coder encodeObject:[NSKeyedArchiver archivedDataWithRootObject:players] forKey:@"_players"];
    [coder encodeObject:teamName forKey:@"_name"];
}

@end
