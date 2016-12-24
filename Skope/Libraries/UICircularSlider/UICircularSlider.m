//
//  UICircularSlider.m
//  UICircularSlider
//
//  Created by Zouhair Mahieddine on 02/03/12.
//  Copyright (c) 2012 Zouhair Mahieddine.
//  http://www.zedenem.com
//  
//  This file is part of the UICircularSlider Library, released under the MIT License.
//

#import "UICircularSlider.h"

#define DEVIATION 5.5

@interface UICircularSlider() {
    CGFloat tempValue;
    CGFloat angle;
    NSInteger currentMaxLimitRange;
}

@property (nonatomic) CGPoint thumbCenterPoint;

#pragma mark - Init and Setup methods
- (void)setup;

#pragma mark - Thumb management methods
- (BOOL)isPointInThumb:(CGPoint)point;

#pragma mark - Drawing methods
- (CGFloat)sliderRadius;
- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context;
- (CGPoint)drawCircularTrack:(float)track atPoint:(CGPoint)point withRadius:(CGFloat)radius inContext:(CGContextRef)context;
- (CGPoint)drawPieTrack:(float)track atPoint:(CGPoint)point withRadius:(CGFloat)radius inContext:(CGContextRef)context;

@end

#pragma mark -
@implementation UICircularSlider

@synthesize rotationLimits = _rotationLimits;

@synthesize value = _value;
- (void)setValue:(float)value {
    
	if (value != _value) {
        
//		if (value > self.maximumValue) { value = self.maximumValue; }
//		if (value < self.minimumValue) { value = self.minimumValue; }
        
        if (value > [self.rotationLimits.lastObject floatValue]) { value = [self.rotationLimits.lastObject floatValue]; }
        if (value < [self.rotationLimits.firstObject floatValue]) { value = [self.rotationLimits.firstObject floatValue]; }
        

		_value = value;
		[self setNeedsDisplay];
        if (self.isContinuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
	}
}

@synthesize startValue = _startValue;
- (void)setStartValue:(float)startValue {
    if (startValue != _startValue) {
        
        NSInteger minRangeIndex =  self.rotationLimits.count - 1;
        CGFloat range = [self.rotationLimits.lastObject floatValue];
        for (NSInteger i = minRangeIndex; i>=0; i--) {
            range = [self.rotationLimits[i] floatValue];
            if (range < startValue) {
                minRangeIndex = i;
                break;
            }
        }
        currentMaxLimitRange = minRangeIndex + 1;
        [self reconfigSlider];
                
        CGFloat additiontempValue = (startValue - range)/(self.maximumValue - self.minimumValue) * 2 * M_PI;
        tempValue = additiontempValue;
        [self setValue:startValue];
    }
}
@synthesize minimumValue = _minimumValue;
- (void)setMinimumValue:(float)minimumValue {
	if (minimumValue != _minimumValue) {
		_minimumValue = minimumValue;
		if (self.maximumValue < self.minimumValue)	{ self.maximumValue = self.minimumValue; }
		if (self.value < self.minimumValue)			{ self.value = self.minimumValue; }
	}
}
@synthesize maximumValue = _maximumValue;
- (void)setMaximumValue:(float)maximumValue {
	if (maximumValue != _maximumValue) {
		_maximumValue = maximumValue;
		if (self.minimumValue > self.maximumValue)	{ self.minimumValue = self.maximumValue; }
		if (self.value > self.maximumValue)			{
            self.value = self.maximumValue;
        }
	}
}

@synthesize minimumTrackTintColor = _minimumTrackTintColor;
- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
	if (![minimumTrackTintColor isEqual:_minimumTrackTintColor]) {
		_minimumTrackTintColor = minimumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize maximumTrackTintColor = _maximumTrackTintColor;
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
	if (![maximumTrackTintColor isEqual:_maximumTrackTintColor]) {
		_maximumTrackTintColor = maximumTrackTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize thumbTintColor = _thumbTintColor;
- (void)setThumbTintColor:(UIColor *)thumbTintColor {
	if (![thumbTintColor isEqual:_thumbTintColor]) {
		_thumbTintColor = thumbTintColor;
		[self setNeedsDisplay];
	}
}

@synthesize continuous = _continuous;

@synthesize sliderStyle = _sliderStyle;
- (void)setSliderStyle:(UICircularSliderStyle)sliderStyle {
	if (sliderStyle != _sliderStyle) {
		_sliderStyle = sliderStyle;
		[self setNeedsDisplay];
	}
}

@synthesize thumbCenterPoint = _thumbCenterPoint;

/** @name Init and Setup methods */
#pragma mark - Init and Setup methods
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    } 
    return self;
}
- (void)awakeFromNib {
	[self setup];
}

- (void)setup {
    
    currentMaxLimitRange = 1;
    tempValue = 0;//2 * M_PI;    //Changed by Nguyen Truong Luu
    angle = 0.0;
    self.value = 0.0;
    
	self.minimumTrackTintColor = [UIColor blueColor];
	self.maximumTrackTintColor = [UIColor whiteColor];
	self.thumbTintColor = [UIColor darkGrayColor];
	self.continuous = YES;
	self.thumbCenterPoint = CGPointZero;
	
    /**
     * This tapGesture isn't used yet but will allow to jump to a specific location in the circle
     */
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHappened:)];
	[self addGestureRecognizer:tapGestureRecognizer];
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHappened:)];
	panGestureRecognizer.maximumNumberOfTouches = panGestureRecognizer.minimumNumberOfTouches;
	[self addGestureRecognizer:panGestureRecognizer];
}

/** @name Drawing methods */
#pragma mark - Drawing methods
#define kLineWidth 5.0
#define kThumbRadius 12.0
- (CGFloat)sliderRadius {
	CGFloat radius = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
	radius -= MAX(kLineWidth, kThumbRadius);	
	return radius;
}
- (void)drawThumbAtPoint:(CGPoint)sliderButtonCenterPoint inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
	CGContextMoveToPoint(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y);
	CGContextAddArc(context, sliderButtonCenterPoint.x, sliderButtonCenterPoint.y, kThumbRadius, 0.0, 2*M_PI, NO);
	
	CGContextFillPath(context);
	UIGraphicsPopContext();
}

- (CGPoint)drawCircularTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	CGContextBeginPath(context);
	
	float angleFromTrack = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, 0, 2*M_PI);
	
	CGFloat startAngle = -M_PI_2;
	CGFloat endAngle = startAngle + angleFromTrack;
	CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, NO);
	
	CGPoint arcEndPoint = CGContextGetPathCurrentPoint(context);
	
	CGContextStrokePath(context);
	UIGraphicsPopContext();
	
	return arcEndPoint;
}

- (CGPoint)drawPieTrack:(float)track atPoint:(CGPoint)center withRadius:(CGFloat)radius inContext:(CGContextRef)context {
	UIGraphicsPushContext(context);
	
	float angleFromTrack = translateValueFromSourceIntervalToDestinationInterval(track, self.minimumValue, self.maximumValue, 0, 2*M_PI);
	
	CGFloat startAngle = -M_PI_2;
	CGFloat endAngle = startAngle + angleFromTrack;
	CGContextMoveToPoint(context, center.x, center.y);
	CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, NO);
	
	CGPoint arcEndPoint = CGContextGetPathCurrentPoint(context);
	
	CGContextClosePath(context);
	CGContextFillPath(context);
	UIGraphicsPopContext();
	
	return arcEndPoint;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGPoint middlePoint;
	middlePoint.x = self.bounds.origin.x + self.bounds.size.width/2;
	middlePoint.y = self.bounds.origin.y + self.bounds.size.height/2;
	
	CGContextSetLineWidth(context, kLineWidth);
	
	CGFloat radius = [self sliderRadius];
	switch (self.sliderStyle) {
		case UICircularSliderStylePie:
			[self.maximumTrackTintColor setFill];
			[self drawPieTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
			[self.minimumTrackTintColor setStroke];
			[self drawCircularTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
			[self.minimumTrackTintColor setFill];
			self.thumbCenterPoint = [self drawPieTrack:self.value atPoint:middlePoint withRadius:radius inContext:context];
			break;
		case UICircularSliderStyleCircle:
		default:
			[self.maximumTrackTintColor setStroke];
			[self drawCircularTrack:self.maximumValue atPoint:middlePoint withRadius:radius inContext:context];
			[self.minimumTrackTintColor setStroke];
			self.thumbCenterPoint = [self drawCircularTrack:self.value atPoint:middlePoint withRadius:radius inContext:context];
			break;
	}
	
	[self.thumbTintColor setFill];
	[self drawThumbAtPoint:self.thumbCenterPoint inContext:context];
}

/** @name Thumb management methods */

#pragma mark - Thumb management methods

- (BOOL)isPointInThumb:(CGPoint)point {
	CGRect thumbTouchRect = CGRectMake(self.thumbCenterPoint.x - kThumbRadius, self.thumbCenterPoint.y - kThumbRadius, kThumbRadius*2, kThumbRadius*2);
	return CGRectContainsPoint(thumbTouchRect, point);
}

/** @name UIGestureRecognizer management methods */

#pragma mark - UIGestureRecognizer management methods

- (void)panGestureHappened:(UIPanGestureRecognizer *)panGestureRecognizer {
	CGPoint tapLocation = [panGestureRecognizer locationInView:self];
	switch (panGestureRecognizer.state) {
            
		case UIGestureRecognizerStateChanged: {
			CGFloat radius = [self sliderRadius];
            
			CGPoint sliderCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
			CGPoint sliderStartPoint = CGPointMake(sliderCenter.x, sliderCenter.y - radius);
            angle = angleBetweenThreePoints(sliderCenter, sliderStartPoint, tapLocation);
			
			if (angle < 0) {
				angle = -angle;
			}
			else {
				angle = 2*M_PI - angle;
			}
            
            // here we put tempValue = angle in every conditions instead of putting it after if...else as general use
            // because we need to update tempValue ASAP due to that pan gesture will update very quickly
            // then we have to do like that to make sure tempValue have the latest value
            
            if (tempValue > angle) {
                
                if ((tempValue - angle) > DEVIATION) {        // increase count
                    
                    tempValue = angle;
                    [self increaseCount];
                    
                } else {                                // turn left
                    
                    if (currentMaxLimitRange > 0) {                        // if minimum, stop
                        
                        tempValue = angle;
                        self.value = translateValueFromSourceIntervalToDestinationInterval(angle, 0, 2*M_PI, self.minimumValue, self.maximumValue);
                        
                    } else {
                        
                        //Stop slider
                    }
                }
                
            } else {
                
                if (angle - tempValue > DEVIATION) {
                    
                    // decrease mark
                    
                    tempValue = angle;
                    [self decreaseCount];
                    
                } else {
                    
                    // turn right
                    
                    //if (currentMaxLimitRange < self.rotationLimits.count) {
                    if (currentMaxLimitRange < self.rotationLimits.count - 1) {
                        // if maximum, stop
                        
                        tempValue = angle;
                        self.value = translateValueFromSourceIntervalToDestinationInterval(angle, 0, 2*M_PI, self.minimumValue, self.maximumValue);
                        
                    } else {
                        
                        //Stop slider
                    }
                }
            }
			break;
		}
        case UIGestureRecognizerStateEnded:
            if (!self.isContinuous) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
            if ([self isPointInThumb:tapLocation]) {
//                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else {
//                [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
            }
            break;
		default:
			break;
	}
}
- (void)tapGestureHappened:(UITapGestureRecognizer *)tapGestureRecognizer {
    
	if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
		CGPoint tapLocation = [tapGestureRecognizer locationInView:self];
		if ([self isPointInThumb:tapLocation]) {
		}
		else {
		}
	}
}

- (void) increaseCount {
    
    //if (currentMaxLimitRange < self.rotationLimits.count) {         //For stop at 7000Km
    if (currentMaxLimitRange < self.rotationLimits.count - 1) {   //For stop at 6000Km
        currentMaxLimitRange++;
        [self reconfigSlider];
        if (currentMaxLimitRange < self.rotationLimits.count) {
            self.value = translateValueFromSourceIntervalToDestinationInterval(angle, 0, 2*M_PI, self.minimumValue, self.maximumValue);
        }
    }
}

- (void) decreaseCount {
    
    if (currentMaxLimitRange > 0) {
        currentMaxLimitRange--;
        [self reconfigSlider];
        if (currentMaxLimitRange > 0) {
            self.value = translateValueFromSourceIntervalToDestinationInterval(angle, 0, 2*M_PI, self.minimumValue, self.maximumValue);
        }
    }
}

- (void)reconfigSlider {
    
    if (self.rotationLimits.count > 0
        && currentMaxLimitRange > 0
        && currentMaxLimitRange < self.rotationLimits.count   //For stop at 7000Km
        ) {

        self.maximumValue = [self.rotationLimits[currentMaxLimitRange] floatValue];
        self.minimumValue = [self.rotationLimits[currentMaxLimitRange - 1] floatValue] + 1;
        
    }
    
    /*switch (count) {
        case 1:
            self.minimumValue = 1.0;
            self.maximumValue = 100.0;
            break;
        case 2:
            self.minimumValue = 101.0;
            self.maximumValue = 250.0;
            break;
        case 3:
            self.minimumValue = 251.0;
            self.maximumValue = 500.0;
            break;
        case 4:
            self.minimumValue = 501.0;
            self.maximumValue = 1000.0;
            break;
        case 5:
            self.minimumValue = 1001.0;
            self.maximumValue = 3000.0;
            break;
        case 6:
            self.minimumValue = 3001.0;
            self.maximumValue = 6000.0;
            break;
        default:
            break;
    }*/
    
}

/** @name Touches Methods */
#pragma mark - Touches Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if ([self isPointInThumb:touchLocation]) {
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    }
}

@end

/** @name Utility Functions */
#pragma mark - Utility Functions
float translateValueFromSourceIntervalToDestinationInterval(float sourceValue, float sourceIntervalMinimum, float sourceIntervalMaximum, float destinationIntervalMinimum, float destinationIntervalMaximum) {
	float a, b, destinationValue;
	
	a = (destinationIntervalMaximum - destinationIntervalMinimum) / (sourceIntervalMaximum - sourceIntervalMinimum);
	b = destinationIntervalMaximum - a*sourceIntervalMaximum;
	
	destinationValue = a*sourceValue + b;
	
	return destinationValue;
}

CGFloat angleBetweenThreePoints(CGPoint centerPoint, CGPoint p1, CGPoint p2) {
	CGPoint v1 = CGPointMake(p1.x - centerPoint.x, p1.y - centerPoint.y);
	CGPoint v2 = CGPointMake(p2.x - centerPoint.x, p2.y - centerPoint.y);
	
	CGFloat angle = atan2f(v2.x*v1.y - v1.x*v2.y, v1.x*v2.x + v1.y*v2.y);
	
	return angle;
}
