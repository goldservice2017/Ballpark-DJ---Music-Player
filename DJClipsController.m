//
//  DJClipsController.m
//  BallparkDJ
//
//  Created by Jonathan Howard on 3/7/13.
//  Copyright (c) 2013 BallparkDJ. All rights reserved.
//

#import "DJClipsController.h"
#import "DJAppDelegate.h"

#define BUTTON_TAG 117

@interface DJClipsController ()

@end

@implementation DJClipsController

-(id)initWithDJAudio:(DJAudio *)pAudio {
    if(!pAudio) return nil;
    self = [super initWithNibName:@"DJClipsView" bundle:nil];
    if(self) {
        audio = pAudio;
        NSString *pathString = [[NSBundle mainBundle] pathForResource:@"songs" ofType:@"plist"];
        songDict = [[NSDictionary alloc] initWithContentsOfFile:pathString];
    }
    return self;
}

-(void) addGradient:(UIButton *) _button {
    
    // Add Border
    CALayer *layer = _button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.75f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.4f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer insertSublayer:shineLayer atIndex:0];
}

#pragma mark - Table Data Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[songDict allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"clipsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[songDict allKeys] objectAtIndex:indexPath.row];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playButton.tag = BUTTON_TAG;
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton setTitle:@"Stop" forState:UIControlStateSelected];
    [playButton setTitleColor:[UIColor colorWithWhite:0.0 alpha:1.0] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO: THIS IS UNTESTED
    //[self addGradient:playButton];
    [cell.contentView addSubview:playButton];
    
    return cell;
}

#pragma mark - Button Event

-(IBAction)buttonPressed:(id)sender {
    UIView *contentView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if(playerIndex) {
        [previewPlayer stop];
        [previewPlayer release];
        previewPlayer = nil;
        [(UIButton *)[[[(UITableView *)[cell superview] cellForRowAtIndexPath:playerIndex] contentView] viewWithTag:BUTTON_TAG]
            setSelected:NO];
    }
    if(playerIndex != indexPath) {
        if((previewPlayer =
            [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[[songDict objectForKey:(NSDictionary *)[[songDict allKeys] objectAtIndex:indexPath.row]] objectForKey:@"file"]] error:nil])) {
            [previewPlayer prepareToPlay];
            [previewPlayer play];
            playerIndex = indexPath;
            ((UIButton *)sender).selected = YES;
        }
    }
    else {
        [playerIndex release];
        playerIndex = nil;
    }
    
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [songDict objectForKey:(NSDictionary *)[[songDict allKeys] objectAtIndex:indexPath.row]];
    NSString *path = [[NSBundle mainBundle] pathForResource:[object objectForKey:@"file"] ofType:nil];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        DJMusicEditorController *editor = [[self.navigationController viewControllers] objectAtIndex:([[self.navigationController viewControllers] indexOfObject:self]-1)];
        
        [editor setAudioURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [editor showUI];
        [editor hideUITotally:NO];
        [editor.titleLabel setText:[NSString stringWithFormat:@" Title: %@", [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]]];
        [editor.artistLabel setText:@" Artist: Ballpark DJ"];
        
        editor.parentAudio.isDJClip = YES;
        [editor setSongLength:[(NSNumber *)[object objectForKey:@"length"] doubleValue]];
        [editor setSongStart:[(NSNumber *)[object objectForKey:@"start"] doubleValue]];

        if(editor.parentAudio.isAnnouncementClipValid) {
            editor.parentAudio.overlap = 0.5 - editor.parentAudio.announcementDuration;
        }
        else {
            editor.parentAudio.overlap = 0;
        }
        
        
        [editor replay];
        [self resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - View Delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [audio release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
