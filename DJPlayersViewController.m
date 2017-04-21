//
//  DJPlayersViewController.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 2/22/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJPlayersViewController.h"
//#import "MKStoreKitConfigs.h"
//#import "MKStoreManager.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>

#define SINGLE_LABEL @"Single Play"
#define CONTINUOUS_LABEL @"Continuous Play"

@interface NSMutableArray (MoveArray)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;

@end

@implementation NSMutableArray (MoveArray)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [obj retain];
        [self removeObjectAtIndex:from];
        if (to >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:to];
        }
        [obj release];
    }
}
@end


@interface DJPlayersViewController (){
    bool playerEditing;
}

@end

@implementation DJPlayersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishPurchase)
                                                 name:@"InAppPurchase" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFinishRestore)
                                                 name:@"RestoreInAppPurchase" object:nil];

    
    playerEditing = false;
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(callDetailViewForNewPlayer:)]autorelease];
    UIBarButtonItem * backButton = [[[UIBarButtonItem alloc] initWithTitle:@"Players" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)]autorelease];
    [self.navigationItem setBackBarButtonItem:backButton];
    //[self.navigationItem setLeftBarButtonItem:backButton animated:YES];
    self.editButtonItem.action = @selector(setEditing);
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.editButtonItem, addButton, nil] animated:YES];
    [self.playerTable reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeRespondsToNotification:) name:@"DJAudioDidFinish" object:nil];
    
    //Set up nextUp view
    CGRect frame = CGRectMake(150, 0, 160, 40);
    UILabel *view = [[UILabel alloc] initWithFrame:frame];
    view.textAlignment = NSTextAlignmentRight;
//    view.text = @"Next Up";
    view.tag = NEXT_UP_TAG;
    view.backgroundColor = [UIColor clearColor];
    
    nextUpLabel = view;
    
    // Set up colors:
    upnextColor = [UIColor colorWithRed:147.0/255.0 green:201.0/255.0 blue:255.0/255.0 alpha:1.0f];
    
	// Do any additional setup after loading the view.
    self.title = @"Players";
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelQueue];
    [super viewWillDisappear:animated];
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for (int i = 0; i < [self.team.players count]; i++)
    {
        DJPlayer *player = [self.team.players objectAtIndex:i];
        
        if(player.b_isBench == YES)
        {
            [self.team.players moveObjectFromIndex:i toIndex:[self.team.players count]];
        }
    }
    
    
    for(DJPlayer *player in self.team.players)
    {
        NSLog(@"%@", player.name);
    }
    
    [self.playerTable reloadData];
}



//===========================
//
//  IBActions for buttons!
//
//===========================
-(IBAction)backButtonPressed:(id)sender{
    if([[self.team objectInPlayersAtIndex:self.playerIndex].audio isPlaying]){
        [[[[self team] objectInPlayersAtIndex:self.playerIndex] audio] stop];
        [self cancelQueue];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setEditing {
    playerEditing = !playerEditing;
    [super setEditing:playerEditing animated:YES];
    [self.playerTable setEditing:playerEditing animated:YES];
    
    [[[upNext contentView] viewWithTag:NEXT_UP_TAG] removeFromSuperview];
    [upNext setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    upNext = nil;
}

-(void)callDetailViewForNewPlayer:(id)sender{
    //TODO: add better receipt checking to IAP
    
    NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];

    BOOL isPurchased = [userDefaults boolForKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
    
    if (self.team.players.count >= 3 && (isPurchased != YES))
    {
        
        HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
        [[DJAppDelegate sharedDelegate].window addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Loading..";
        
        [HUD showWhileExecuting:@selector(removeHud) onTarget:self withObject:nil animated:YES];

        
        [self reload];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
        [self performSelector:@selector(presentIAPAlertView) withObject:nil afterDelay:5.0];

        return;
        
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    DJDetailController *detailViewController = [[[DJDetailController alloc] initWithNibName:@"DJDetailView" bundle:nil]autorelease];
    detailViewController.parent = self;
    detailViewController.team = self.team;
    detailViewController.playerIndex = [self.playerTable numberOfRowsInSection:0]-2;
    [self.navigationController pushViewController:detailViewController animated:YES];

}

- (void)removeHud
{
    sleep(4);
    
//    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.team.teamName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.team.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayerCell";
    
    UITableViewCell *cell = nil;
    
    UILabel *label;
    
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                   reuseIdentifier:CellIdentifier] autorelease];
    CGRect rect = cell.bounds;
    rect.origin.x = 20;
    rect.size.width = 280;

    label = [[UILabel alloc] initWithFrame:rect];
    label.tag = indexPath.row + 2000;

    [cell.contentView addSubview:label];

    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.showsReorderControl = YES;
//    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    DJPlayer *tempPlayer = [self.team objectInPlayersAtIndex:indexPath.row];

    if(tempPlayer.b_isBench == NO)
        label.textColor = [UIColor blackColor];
    else
        label.textColor = [UIColor colorWithRed:129.0 / 255.0 green:129.0 / 255.0 blue:129.0 / 255.0 alpha:1.0];
//        label.textColor = [UIColor colorWithRed:220.0 / 255.0 green:220.0 / 255.0 blue:220.0 / 255.0 alpha:1.0];

    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    if(tempPlayer.b_isBench == YES)
        selectedBackgroundView.backgroundColor = [UIColor clearColor];
    else
//        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:183.0 / 255.0 green:246.0 / 255.0 blue:150.0 / 255.0 alpha:1.0];
        label.textColor = [UIColor blackColor];
    

    cell.selectedBackgroundView = selectedBackgroundView;

    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if(tempPlayer.b_isBench == YES)
        backgroundView.backgroundColor = [UIColor colorWithRed:192.0 / 255.0 green:192.0 / 255.0 blue:192.0 / 255.0 alpha:1.0];
    else
        backgroundView.backgroundColor = [UIColor clearColor];
    
    cell.backgroundView= backgroundView;


    NSString *topDigits;
    if([tempPlayer.name isKindOfClass:[NSString class]]){
        if(tempPlayer.number != -42) {
            NSString *allDigits = [NSString stringWithFormat:@"%d", tempPlayer.number];
            if(allDigits.length >= 3){
                topDigits = [@"#" stringByAppendingString:[allDigits substringToIndex:3]];
            }
            else{
                topDigits = [@"#" stringByAppendingString:allDigits];
            }
            topDigits = [[topDigits stringByPaddingToLength:4 withString:@" " startingAtIndex:0] stringByAppendingString:@"\t"];;
        }
        else {  topDigits = [NSString stringWithFormat:@"\t     "];
        }

        label.text = [topDigits stringByAppendingString:tempPlayer.name];
    }
    
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"Scroll Event");
//    return YES;
//}



- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell  *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:indexPath.row + 2000];
    
    CGRect rect = label.frame;
    rect.origin.x = 100;
//    rect.size.width = 190;
    
    label.frame = rect;
    
    NSLog(@"Swipe Start");
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onFinish:) userInfo:indexPath repeats:NO];
    

    NSLog(@"Swipe End");
}

- (void) onFinish:(NSTimer*)timer
{
    [UIView beginAnimations:@"moveScrollView" context:nil];
    [UIView setAnimationDuration:0.2];

    NSIndexPath *indexPath = (NSIndexPath*)timer.userInfo;
    
    UITableViewCell  *cell = [self.playerTable cellForRowAtIndexPath:timer.userInfo];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:indexPath.row + 2000];
    
    CGRect rect = label.frame;
    rect.origin.x = 20;
    rect.size.width = 280;
    label.frame = rect;
    
    [UIView commitAnimations];

}
//UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//
//cell.contentView.backgroundColor = [UIColor lightTextColor];
//cell.backgroundColor = [UIColor lightTextColor];


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.playerIndex = indexPath.row;
//    [self cancelQueue];
    
    
    if(playerEditing) {
        if(self.active) {
            [self setActive:nil];
        }
        playerEditing = !playerEditing;
        [self callDetailViewOnRow:indexPath.row];
        [self setEditing:NO animated:YES];
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //        [defaults setBool:NO forKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
        //        [defaults synchronize];
        BOOL isPurchased = [defaults boolForKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
        DJAudio* audio = [[self.team.players objectAtIndex:indexPath.row] audio];;
        
        if (audio.announcementDuration >= 10.0 && isPurchased == NO){
            //        [self ShowIAPAlert];
            HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
            [[DJAppDelegate sharedDelegate].window addSubview:HUD];
            
            HUD.delegate = self;
            HUD.labelText = @"Loading..";
            
            [HUD showWhileExecuting:@selector(removeHud) onTarget:self withObject:nil animated:YES];
            
            
            [self reload];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
            
            [self performSelector:@selector(presentIAPAlertViewForVoice) withObject:nil afterDelay:5.0];
            [[self playBtn] setTitle:@"Play"];
            return;
        }
        DJPlayer    *player = [self.team.players objectAtIndex:indexPath.row];
        if(player.b_isBench == YES)
            return;

        if([self.continuousBtn.title isEqualToString:CONTINUOUS_LABEL])
        {
            [self cancelQueue];
            upNext = [self.playerTable cellForRowAtIndexPath:indexPath];
            [self playSet];
        }
        else
        {
            [self playSingle:[self.playerTable cellForRowAtIndexPath:indexPath]];
            if(self.active) [[self playBtn] setTitle:@"Stop"];
            else [[self playBtn] setTitle:@"Play"];
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //_setPlaying = NO;
    if(self.active){
        [self setActive:nil];
        [[self playBtn] setTitle:@"Play"];
    }
}

-(void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (int) getFirstBenchIndex
{
    int benchIndex = -1;
    for (int i = 0; i < [self.team.players count]; i++)
    {
        DJPlayer *player = [self.team.players objectAtIndex:i];
        if(player.b_isBench == YES)
        {
            benchIndex = (i - 1 == 0) ? 0 : (i -1);
            break;
        }
    }
    
    return benchIndex;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    int benchIndex = [self getFirstBenchIndex];
    
    DJPlayer *object = [[self.team.players objectAtIndex:sourceIndexPath.row] retain];
    
    int val = destinationIndexPath.row;
    
    if(destinationIndexPath.row <= benchIndex)
        object.b_isBench = NO;
    
    [self.team.players removeObjectAtIndex:sourceIndexPath.row];
    [self.team.players insertObject:object atIndex:destinationIndexPath.row];
    [object release];
    
    [tableView reloadData];

}



//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.team.players removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

-(void)save{
    [self.parentDelegate.league encode];
}

-(void)addNewPlayerToTeam:(DJPlayer *) p{
    NSLog(@"%@",self.team.teamName);
    NSLog(@"%d", self.team.players.count);
    NSLog(@"%d", [self.playerTable numberOfRowsInSection:0]-1);
    int lastPlayerIdx;
    NSIndexPath *indexPath;
    
    if(self.team.players.count > 0)
    {
        lastPlayerIdx = self.team.players.count;
        BOOL isDuplicate = false;
        for (int i = 0 ; i < self.team.players.count; i++) {
            DJPlayer* player = [self.team.players objectAtIndex:i];
            int player_number = player.number;
            NSString* player_name = player.name;
            if ([p.name isEqualToString:player_name] && p.number == player_number) {
                isDuplicate = true;
            }
        }
        if (isDuplicate == true) {
            return;
        }
        [self.team insertObject:p inPlayersAtIndex:lastPlayerIdx];
        indexPath = [NSIndexPath indexPathForRow:[self.playerTable numberOfRowsInSection:0]-1 inSection:0];
        [self.playerTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.playerTable reloadData];
        
        [[self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.playerTable numberOfRowsInSection:0]inSection:0]] setHidden:FALSE];
    } else {
        lastPlayerIdx = 0;
        [self.team insertObject:p inPlayersAtIndex:lastPlayerIdx];
        indexPath = [NSIndexPath indexPathForRow:[self.playerTable numberOfRowsInSection:0] inSection:0];
        [self.playerTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.playerTable reloadData];
        [[self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.playerTable numberOfRowsInSection:0]inSection:0]] setHidden:FALSE];
 
    }
}

-(void)callDetailViewOnRow:(NSInteger)selectedRow{
    
    DJDetailController *detailViewController = [[[DJDetailController alloc] initWithNibName:@"DJDetailView" bundle:nil withPlayer:[self.team objectInPlayersAtIndex:selectedRow]]autorelease];
    detailViewController.parent = self;
    detailViewController.team = self.team;
    detailViewController.playerIndex = self.playerIndex;
    
    [self.playerTable setEditing:NO animated:YES];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_playerTable release];
//    [_team release];
//    [_audioPlayer release];
//    [_parentDelegate release];
    [_playBtn release];
    [_continuousBtn release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPlayerTable:nil];
    [self setTeam:nil];
    [self setAudioPlayer:nil];
    [self setParentDelegate:nil];
    [self setPlayBtn:nil];
    [self setContinuousBtn:nil];
    [super viewDidUnload];
}

#pragma mark - Song Queue:

- (IBAction)play:(id)sender {
//    [[[[self team] objectInPlayersAtIndex:self.playerIndex] audio] stop];
//    [[self.playerTable cellForRowAtIndexPath:[self.playerTable indexPathForSelectedRow]] setSelected:NO];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //        [defaults setBool:NO forKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
    //        [defaults synchronize];
    BOOL isPurchased = [defaults boolForKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
    DJAudio* audio = [[self.team.players objectAtIndex:self.playerIndex] audio];;

    if (audio.announcementDuration >= 10.0 && isPurchased == NO){
//        [self ShowIAPAlert];
        HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
        [[DJAppDelegate sharedDelegate].window addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Loading..";
        
        [HUD showWhileExecuting:@selector(removeHud) onTarget:self withObject:nil animated:YES];
        
        
        [self reload];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
        [self performSelector:@selector(presentIAPAlertViewForVoice) withObject:nil afterDelay:5.0];
        [[self playBtn] setTitle:@"Play"];
        return;
    }
    [sender setEnabled:NO];
    if([[self.playBtn title] isEqual:@"Play"]) {
//        if (UIBarButtonItemStyleDone == self.continuousBtn.style) { //continuous
        if([self.continuousBtn.title isEqualToString:CONTINUOUS_LABEL]) {
            [self playSet];
        } else {
            if(nil != upNext) {
                [self playSingle:upNext];
            } else {
                [self playSingle:[self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
            }
        }
    } else {
        [self cancelQueue];
    }
    [sender setEnabled:YES];
}

- (void)playSingle:(UITableViewCell *)sender {
    self.playBtn.title = @"Stop";
    
    NSIndexPath *indexPath = [self.playerTable indexPathForCell:sender];
    [self setActive:[[self.team.players objectAtIndex:indexPath.row] audio]];
    [self.playerTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];


    //Remove content view:
    for (int i = 0; i < [self.playerTable numberOfRowsInSection:0]; i++) {
        [[[[self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]  ]contentView] viewWithTag:NEXT_UP_TAG] removeFromSuperview];
        [[self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]] setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    }
    
    [[[sender contentView] viewWithTag:NEXT_UP_TAG] removeFromSuperview];
    [sender setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    
    
    currPlay = [self.playerTable cellForRowAtIndexPath:indexPath];
    [currPlay setBackgroundColor:[UIColor colorWithRed:154.0 / 255.0 green:250.0 / 255.0 blue:114.0 / 255.0 alpha:1.0]];
    
    //Increment the index path and determine if we're at the end
    
    int benchIndex= [self getFirstBenchIndex];
    
    NSInteger row = [indexPath indexAtPosition:indexPath.length-1]+1;
    if (row > [self.team.players count]-1 || row == (benchIndex + 1)) row = 0;
    
    indexPath = [[indexPath indexPathByRemovingLastIndex] indexPathByAddingIndex:row];
    
    //Add the contentview to the new up next
    upNext = [self.playerTable cellForRowAtIndexPath:indexPath];
    [[upNext contentView] addSubview:nextUpLabel];
    [upNext setBackgroundColor:[UIColor colorWithRed:191/255.0f green:238/255.0f blue:252/255.0f alpha:1.0f]];
}

- (void)playSet {
    if([[self.playBtn title] isEqual:@"Play"]) {
        //Get the relevant subset of the playlist
        
        int benchIndex = [self getFirstBenchIndex] == -1 ? [self.team.players count] : [self getFirstBenchIndex] + 1;
        
        NSRange range;
        range.location = (upNext) ? [[self.playerTable indexPathForCell:upNext] row] : 0;
        range.length = (benchIndex)-range.location;
        
        songQueue = range;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(nextQueueSong:) name:@"DJAudioDidFinish" object:nil];
        
        [self nextQueueSong:nil];
        [[self playBtn] setTitle:@"Stop"];
    }
    else if([[self.playBtn title] isEqual:@"Stop"]) {
        [[self playBtn] setTitle:@"Play"];
        [self cancelQueue];
    }
}

- (IBAction)setContinuous:(id)sender {
    if ([self.continuousBtn.title isEqualToString:CONTINUOUS_LABEL]) {
        self.continuousBtn.title = SINGLE_LABEL; //is enabled, disable
    } else {
        self.continuousBtn.title = CONTINUOUS_LABEL; //is disabled, enable
    }
}

-(void)cancelQueue {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeRespondsToNotification:) name:@"DJAudioDidFinish" object:nil];
    if (self.active) {
        [self setActive:nil];
    }
//    [[self.playerTable cellForRowAtIndexPath:[self.playerTable indexPathForSelectedRow]] setSelected:NO];
    [self.playerTable deselectRowAtIndexPath:[self.playerTable indexPathForSelectedRow] animated:YES];
    
    [[self playBtn] setTitle:@"Play"];
}

-(void)nextQueueSong:(NSNotification *)notification {
    if(notification) {
        songQueue = NSMakeRange(++songQueue.location, --songQueue.length);
    }
    if (0 == songQueue.length) {
        [self cancelQueue];
        return;
    }
    UITableViewCell* cell = [self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:songQueue.location inSection:0]];
    NSIndexPath *indexPath = [self.playerTable indexPathForCell:cell];
    DJAudio* audio = [[self.team.players objectAtIndex:indexPath.row] audio];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //        [defaults setBool:NO forKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
    //        [defaults synchronize];
    BOOL isPurchased = [defaults boolForKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
    if (audio.announcementDuration >= 10.0 && isPurchased == NO){
//        songQueue = NSMakeRange(++songQueue.location, --songQueue.length);
//        if (0 == songQueue.length) {
//            [self cancelQueue];
//            return;
//        }
        HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
        [[DJAppDelegate sharedDelegate].window addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Loading..";
        
        [HUD showWhileExecuting:@selector(removeHud) onTarget:self withObject:nil animated:YES];
        
        
        [self reload];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
        
        [self performSelector:@selector(presentIAPAlertViewForVoice) withObject:nil afterDelay:5.0];
        return;
    }
    
    [self playSingle:[self.playerTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:songQueue.location inSection:0]]];
//    [self setActive:[[songQueue objectAtIndex:0] audio]];
    
}

-(void)setActive:(DJAudio *)active {
    if (_active.isPlaying) [_active stopWithFade];
    _active = active;
    if(nil != _active) {
        
        [_active play];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"_ActiveDidPlay" object:self];
    }
    NSLog(@"Active changed: %@", active);
}

-(void)activeRespondsToNotification:(NSNotification *)notification {
    if(notification.object == self.active) {
        [self setActive:nil];

        self.playBtn.title = @"Play";
        currPlay = [self.playerTable cellForRowAtIndexPath:[self.playerTable indexPathForSelectedRow]];
        [currPlay setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        [self.playerTable deselectRowAtIndexPath:[self.playerTable indexPathForSelectedRow] animated:YES];
    }
}



# pragma marks - In App Purchase.

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            *stop = YES;
        }
    }];
}
- (void)presentIAPAlertViewForVoice {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Upgrade!" message:@"The free version of BallparkDJ allows playback of voice recordings up to 10 seconds. Click below to purchase the full version for unlimited voice duration." delegate:self cancelButtonTitle:@"Continue Evaluating" otherButtonTitles:@"Upgrade to Pro ($6.99)", @"I've Already Upgraded!", nil];
    [a show];
    [a release];
}
- (void)presentIAPAlertView {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Upgrade!" message:@"BallparkDJ is free for evaluation allowing up to 3 teams and 3 players per team.  Upgrade to the Pro version which allows full functionality with unlimited teams and unlimited players per team." delegate:self cancelButtonTitle:@"Continue Evaluating" otherButtonTitles:@"Upgrade to Pro ($6.99)", @"I've Already Upgraded!", nil];
    [a show];
}

-(void)stopHUDLoop
{
    if(HUD == nil)
        return;
    
    [HUD show:NO];
    [HUD removeFromSuperview];
    HUD = nil;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    self.playBtn.title = @"Play";
    switch (buttonIndex) {
        case 0:
            return;
        case 1:
        {
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

            break;
        }
        case 2:
        {
            HUD = [MBProgressHUD showHUDAddedTo:[DJAppDelegate sharedDelegate].window animated:YES];
            [[DJAppDelegate sharedDelegate].window addSubview:HUD];
            HUD.delegate = self;
            HUD.dimBackground = YES;
            HUD.labelText = @"Loading...";
            [HUD show:YES];

            
            [[RageIAPHelper sharedInstance] restoreCompletedTransactions];

            [self performSelector:@selector(stopHUDLoop) withObject:nil afterDelay:12.0];

            break;
        }
        default:
            return;
    }
}

- (void) CallIAPPopup
{

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

- (void)reload {
    _products = nil;
    [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = [products retain];
        }
    }];
    
    NSLog(@"_products in reload : %@", _products);
}

@end
