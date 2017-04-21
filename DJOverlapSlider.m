
//
//  Created by Jonathan Howard on 2/21/2013.
//  
//  Copyright (c) 2013 BallparkDJ Studios. All rights reserved.
//

#import "DJOverlapSlider.h"
#import <QuartzCore/QuartzCore.h>
//#define sliderCenter = 189

@interface DJOverlapSlider () {
    NSNotification* _valueDidChangeNotification;
}
@end
@implementation DJOverlapSlider
@synthesize announceBox;
@synthesize musicBox;
@synthesize sliderLabel;
@synthesize keyFirst;
@synthesize keyLast;
@synthesize delayLabel;
@synthesize trailingDelay = _delay;
@synthesize topFirst = _topFirst;
@synthesize maxValueTop = _maxValueTop;
@synthesize maxValueBottom = _maxValueBottom;
@synthesize touchPos;
double const _sliderCenter = 151.5;

-(void)setTrailingDelay:(double)trailingDelay{
    
    if (_topFirst) {
        if (trailingDelay <= _maxValueTop) {
            _delay = trailingDelay;
        } else {
            _delay = _maxValueTop;
        }
    } else {
        if (trailingDelay <= _maxValueBottom) {
            _delay = trailingDelay;
        } else {
            _delay = _maxValueBottom;
        }
    }
}

-(void)setMaxValueTop:(double)maxValueTop{
    if (maxValueTop > 20) {
        maxValueTop = 20;
    }
    _maxValueTop = maxValueTop;
    [self.announceBox setFrame:CGRectMake(_sliderCenter + abs(self.trailingDelay*10) + ((self.trailingDelay < 0) ? self.trailingDelay*20 : 0),
                                        self.announceBox.frame.origin.y, maxValueTop*20,
                                        self.announceBox.frame.size.height)];
    NSString* overLapDisplay = nil;
    if (_topFirst) {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
    } else {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
    }
    self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
}

-(void)setMaxValueBottom:(double)maxValueBottom{
    if (maxValueBottom > 20) {
        maxValueBottom = 20;
    }
    _maxValueBottom = maxValueBottom;
    [self.musicBox setFrame:CGRectMake(_sliderCenter - self.trailingDelay*10,
                                           self.musicBox.frame.origin.y,
                                           maxValueBottom*20,
                                           self.musicBox.frame.size.height)];
    NSString* overLapDisplay = nil;
    if (_topFirst) {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
    } else {
        overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
    }
    self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     
        NSArray* xib = [[NSBundle mainBundle] loadNibNamed:@"DJOverlapView" owner:self options:nil];
        
        self = [xib objectAtIndex:0];
        UIGestureRecognizer* slidr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlide:)];
        [self addGestureRecognizer:slidr];
        [slidr release];
        _maxValueBottom = 10.0f;
        _maxValueTop = 10.0f;
       // self.keyFirst.backgroundColor = [UIColor colorWithRed:1
                                                       /* green:1
                                                         blue:0.4
                                                        alpha:0.5];*/
        [self.keyFirst setNeedsLayout];
        self.keyLast.backgroundColor = [UIColor colorWithRed:0.7
                                                       green:0.8
                                                        blue:1
                                                       alpha:0.5];
        NSString* overLapDisplay = nil;
        if (_topFirst) {
            overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
        } else {
            overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
        }
        self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
        
        announceBox.layer.cornerRadius = 2;
        announceBox.layer.masksToBounds = YES;
        
        musicBox.layer.cornerRadius = 2;
        musicBox.layer.masksToBounds = YES;
        
        CALayer *layer = self.musicBox.layer;
        [layer setBorderColor:[[UIColor colorWithRed:23.0/255.0 green:38/255.0 blue:74/255.0 alpha:1.0] CGColor]];
        [layer setBorderWidth:1.0];
        
        CALayer *layer1 = self.announceBox.layer;
        [layer1 setBorderColor:[[UIColor colorWithRed:62.0/255.0 green:58/255.0 blue:9/255.0 alpha:1.0] CGColor]];
        [layer1 setBorderWidth:1.0];

    }
    [self retain];
    return self;
}

-(void)handleSlide:(UIPanGestureRecognizer*)gestureRecognizer{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.touchPos = [gestureRecognizer translationInView:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DJSliderDidStartChangeNotification" object:self];
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        double translation = self.touchPos.x - [gestureRecognizer translationInView:self].x;
         self.touchPos = [gestureRecognizer translationInView:self];

        
        if ((self.announceBox.frame.origin.x + translation >= 
             (self.musicBox.frame.origin.x - self.announceBox.frame.size.width - translation)) 
            && 
            (self.announceBox.frame.origin.x + translation <= 
             (self.musicBox.frame.origin.x + self.musicBox.frame.size.width - translation))) {
            
            [self.announceBox setFrame:
             CGRectMake(self.announceBox.frame.origin.x + translation / 4,
                        self.announceBox.frame.origin.y, 
                        self.announceBox.frame.size.width, 
                        self.announceBox.frame.size.height)];
            [self.musicBox setFrame:
             CGRectMake(self.musicBox.frame.origin.x - translation / 4,
                        self.musicBox.frame.origin.y, 
                        self.musicBox.frame.size.width, 
                        self.musicBox.frame.size.height)];
            if (self.announceBox.frame.origin.x  > self.musicBox.frame.origin.x + self.musicBox.frame.size.width) {
                [self.announceBox setFrame:
                 CGRectMake(self.musicBox.frame.origin.x+ self.musicBox.frame.size.width, 
                            self.announceBox.frame.origin.y, 
                            self.announceBox.frame.size.width, 
                            self.announceBox.frame.size.height)];
            }
        }
        
        self.trailingDelay = (self.announceBox.frame.origin.x - self.musicBox.frame.origin.x)/20.0;


        if (self.announceBox.frame.origin.x <= self.musicBox.frame.origin.x) {
            self.topFirst = YES;
            self.keyFirst.backgroundColor = [UIColor colorWithRed:1 
                                                            green:1 
                                                             blue:0.4
                                                            alpha:0.5];
            [self.keyFirst setNeedsLayout];
            self.keyLast.backgroundColor = [UIColor colorWithRed:0.7
                                                           green:0.8
                                                            blue:1
                                                           alpha:0.5];
            [self.keyLast setNeedsLayout];
//            self.trailingDelay = -(self.announceBox.frame.origin.x - 
//                                  self.musicBox.frame.origin.x)/10;
            NSString* overLapDisplay = nil;
            if (_topFirst) {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
            } else {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
            }
            self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
        } else {
            self.topFirst = NO;
            self.keyLast.backgroundColor = [UIColor colorWithRed:1 
                                                            green:1 
                                                             blue:0.4 
                                                            alpha:0.5];
            self.keyFirst.backgroundColor = [UIColor colorWithRed:0.7 
                                                           green:0.8 
                                                            blue:1
                                                           alpha:0.5];
//            self.trailingDelay = -(self.musicBox.frame.origin.x - 
//                                  self.announceBox.frame.origin.x)/10;
            NSString* overLapDisplay = nil;
            if (_topFirst) {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop - self.trailingDelay];
            } else {
                overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.maxValueTop + self.trailingDelay];
            }
            overLapDisplay = [NSString stringWithFormat:@"%1.1f", self.trailingDelay];

            self.delayLabel.text = [@"---> " stringByAppendingString:[overLapDisplay stringByAppendingString:@" Seconds --->"]];
        }
    }
    
#pragma mark - DEBUGGING OVERLAP VALUES
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _valueDidChangeNotification = [NSNotification notificationWithName:@"DJSliderValueDidChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:_valueDidChangeNotification];
        NSLog(@"Slider Changed:");
        NSLog(@"overlap.maxValueTop = %f", self.maxValueTop);
        NSLog(@"overlap.trailingdelay = %f", self.trailingDelay);
    }
   
}

- (void)dealloc {
    [announceBox release];
    [musicBox release];
    [sliderLabel release];
    [keyFirst release];
    [keyLast release];
    [delayLabel release];
    [super dealloc];
}
@end
