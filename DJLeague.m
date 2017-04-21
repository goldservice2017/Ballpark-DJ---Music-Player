//
//  DJLeague.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/22/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJLeague.h"
#import <Foundation/Foundation.h>

@implementation DJLeague {
    bool saving;
}

#pragma mark - Serialization:
#define djTeams @"teamsKey"
#define djDataFile @"data.plist"
#define djTeamCount @"teamCount"

-(id)init{
    self = [super init];
    if(self) {
        self.teams = [[NSMutableArray alloc] init];
        if([[NSFileManager defaultManager] fileExistsAtPath:[[self dataPath]
                                                             stringByAppendingPathComponent:@"teams"]]) {
            NSNumber *num = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self dataPath]
                                        stringByAppendingPathComponent:@"teams"]];

            for(int i = 0; i < [num integerValue]; i++) {
                [[self teams] addObject:[NSKeyedUnarchiver
                                         unarchiveObjectWithFile:
                                         [[self dataPath] stringByAppendingPathComponent:
                                          [NSString stringWithFormat:@"%i", i]]]];
            }
        }
    }
    return self;
}

-(void)encode {
    for(int i = 0; i < [self.teams count]; i++) {
        [NSKeyedArchiver archiveRootObject:[self.teams objectAtIndex:i]
                                    toFile:[[self dataPath]
                                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", i]]];
    }
    [NSKeyedArchiver archiveRootObject:[NSNumber numberWithUnsignedInteger:[self.teams count]] toFile:[[self dataPath]
         stringByAppendingPathComponent:@"teams"]];
}

-(NSString *)dataPath {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        return [paths objectAtIndex:0];
}

#pragma mark - Teams:

-(DJTeam *)getObjectAtIndex:(int)idx {
    return [self.teams objectAtIndex:idx];
}

-(void)addTeam:(DJTeam *)team {
    [self.teams addObject:team];
}

- (void)insertObject:(DJTeam *)object inTeamsAtIndex:(int)index{
    [self.teams insertObject:object atIndex:index];
}

- (void)reorderTeams:(NSIndexPath *)origin toIndexPath:(NSIndexPath *)destination{
    [self.teams exchangeObjectAtIndex:origin.row withObjectAtIndex:destination.row];
}

@end
