//
//  DJLeagueViewController.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 3/1/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJLeagueViewController.h"
#import "DJTeam.h"
#import "DJPlayer.h"
#import "DJPlayersViewController.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface DJLeagueViewController (){
    int selectedTeamIdx;
    bool editingTeam;
}

@end

@implementation DJLeagueViewController
@synthesize parentDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Teams"];
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

    
    selectedTeamIdx = -1;
    editingTeam = false;
    UIBarButtonItem *addteamBTN = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showTeamNameView:)];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationItem setRightBarButtonItem: addteamBTN animated:YES];
    
    //[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target: self action:@selector(setEditing)], addteamBTN, nil]];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"Teams";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];
    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showTeamNameView:)];
    longPressRecognizer.minimumPressDuration = 0.4;
//    [teamTable addGestureRecognizer:longPressRecognizer];
    [longPressRecognizer release];
//    [self.view sendSubviewToBack:teamTable];
    [addteamBTN release];
	// Do any additional setup after loading the view.
    self.editButtonItem.action = @selector(setEditing);
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

-(bool)textFieldShouldReturn:(UITextField*)textField{
    if(selectedTeamIdx != -1){
        [[self.parentDelegate.league getObjectAtIndex:selectedTeamIdx] setTeamName:textField.text];
        selectedTeamIdx = -1;
        [self.teamTable reloadData];
    } else if(textField.text.length > 0){
        [self addNewTeam];
    }
    [textField resignFirstResponder];
    [self.teamNameView setHidden:TRUE];
    return YES;
}


#pragma mark - TABLE VIEW FUNCTIONS
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//	return self.theTeam.teamName;
    return @"Teams";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.parentDelegate.league.teams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TeamCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell setEditingAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.showsReorderControl = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    if([self.parentDelegate.league getObjectAtIndex:indexPath.row]){
//        NSLog(@"%d",indexPath.row);
        DJTeam *tempTeam = [self.parentDelegate.league getObjectAtIndex:indexPath.row];
        if([tempTeam.teamName isKindOfClass:[NSString class]]){
            cell.textLabel.text = tempTeam.teamName;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
         [self.parentDelegate.league.teams removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setEditing:FALSE];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

//Row selection
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
      
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingTeam){
        selectedTeamIdx = indexPath.row;
        self.teamNameField.text = [self.teamTable cellForRowAtIndexPath:indexPath].textLabel.text;
        [self editTeamOnRow:selectedTeamIdx];
    }
    else{
        DJPlayersViewController *playersView = [[[DJPlayersViewController alloc] initWithNibName:@"DJPlayersView" bundle:nil]autorelease];
        [playersView setParentDelegate:self.parentDelegate];
        [playersView setTeam: [self.parentDelegate.league getObjectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:playersView animated:YES];
        
    }
    [self.teamTable deselectRowAtIndexPath:indexPath animated: YES];

}

//"Edit" Button touched
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
 
    [self cellAccesoryButtonPressed:indexPath];
}

//Setting the editing state of the team table
-(void)setEditing{
    editingTeam = !editingTeam;
    
    [super setEditing:editingTeam animated:YES];
    [self.teamTable setEditing:editingTeam animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.parentDelegate.league reorderTeams:sourceIndexPath toIndexPath:destinationIndexPath];
}



-(void)cellAccesoryButtonPressed:(NSIndexPath*) index{
    selectedTeamIdx = index.row;
   
    [self editTeamOnRow:selectedTeamIdx];
}


#pragma mark - End of table view functions

#pragma mark - Non-Delegate Functions

//======================================
//
//  Add a new Team to the league!
//
//======================================
- (IBAction)addNewTeam {
    DJTeam *t = [[[DJTeam alloc] initWithName:self.teamNameField.text] autorelease];
//    [t setTeamName: self.teamNameField.text];
    [self.parentDelegate.league addTeam:t];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow: [self.teamTable numberOfRowsInSection:0] inSection:0];
    [self.teamTable insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self.teamTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.teamTable numberOfRowsInSection:0]inSection:0]] setHidden:FALSE];
    self.teamNameField.text = @"";
    DJPlayersViewController *playersView = [[[DJPlayersViewController alloc] initWithNibName:@"DJPlayersView" bundle:nil]autorelease];
    [playersView setParentDelegate:self.parentDelegate];
    [playersView setTeam: t];
 
#pragma mark - THIS IS A PLACE WHERE NEW SAVE DATA FOR A NEW TEAM SHOULD BE HANDLED IN SOME WAY SHAPE OR FORM
}

-(void)editTeamName:(UIGestureRecognizer*)gestureRecognizer{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.teamTable];
        [self editTeamOnRow:[self.teamTable indexPathForRowAtPoint:p].row];
        
    }
}

-(void)editTeamOnRow:(NSInteger)selectedRow{
    selectedTeamIdx = selectedRow;
    [self.teamNameView setHidden:FALSE];
    [self.teamNameField becomeFirstResponder];
}

-(void) showTeamNameView:(UIBarButtonItem *)sender{

    NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isPurchased = [userDefaults boolForKey:@"IS_ALLREADY_PURCHASED_FULL_VERSION"];
    
    if ([self.parentDelegate.league.teams count] >= 3&& (isPurchased != YES))
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
    
    self.teamNameField.text = @"";
    [self.teamNameView setHidden:FALSE];
    [self.teamNameField becomeFirstResponder];
}

- (void)removeHud
{
    sleep(4);
    
    //    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_teamNameField release];
    [_teamNameView release];
    [_teamTable release];
    [parentDelegate release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTeamNameField:nil];
    [self setTeamNameView:nil];
    [self setTeamTable:nil];
    [self setParentDelegate:nil];
    [super viewDidUnload];
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
