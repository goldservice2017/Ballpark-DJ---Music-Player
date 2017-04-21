
//
//  Created by Jonathan Howard on 2/21/2013.
//
//  Copyright (c) 2013 BallparkDJ Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DJOverlapSlider : UIView{
}
@property (retain, nonatomic) IBOutlet UIView *announceBox;
@property (retain, nonatomic) IBOutlet UIView *musicBox;
@property (retain, nonatomic) IBOutlet UILabel *sliderLabel;
@property (retain, nonatomic) IBOutlet UIView *keyFirst;
@property (retain, nonatomic) IBOutlet UIView *keyLast;
@property (retain, nonatomic) IBOutlet UILabel *delayLabel;

@property(assign, nonatomic) double trailingDelay;
@property(assign, nonatomic) bool topFirst;
@property(assign, nonatomic) double maxValueTop;
@property(assign, nonatomic) double maxValueBottom;
@property(assign, nonatomic) CGPoint touchPos;
@end
