//
//  BLCAwsomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Łukasz Kowalski on 7/17/14.
//  Copyright (c) 2014 Lukasz. All rights reserved.
//

#import "BLCAwesomeFloatingToolbar.h"

@interface BLCAwesomeFloatingToolbar ()

@property (strong, nonatomic) NSArray *currentTitles;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *label;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end

@implementation BLCAwesomeFloatingToolbar

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UILabel *label = [self.label objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}

- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
        }
        
        self.label = labelsArray;
        
        for (UILabel *thisLabel in self.label) {
            [self addSubview:thisLabel];
        }
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFire:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFire:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFire:)];
    }
    
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UILabel *thisLabel in self.label) {
        NSUInteger currentLabelIndex = [self.label indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
        NSLog(@"%@", NSStringFromCGRect(thisLabel.frame));
    }
    
}

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {

    CGPoint location = [[touches anyObject] locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}
- (void) tapFire:(UITapGestureRecognizer *)recognizer{
    NSLog(@"taped");
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint tapPoint = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:tapPoint withEvent:nil];
        
        if ([self.label containsObject:tappedView]){
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTile:)]){
                [self.delegate floatingToolbar:self didSelectButtonWithTile:((UILabel *)tappedView).text];
                NSLog(@"%@", ((UILabel *)tappedView).text);
            }
        }
    }
}
- (void) panFire:(UIPanGestureRecognizer *)recognizer{
    NSLog(@"paned");
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint translation = [recognizer translationInView:self];
            
            NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
            
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
                [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
            }
            
            [recognizer setTranslation:CGPointZero inView:self];
        }
}
- (void) pinchFire:(UIPinchGestureRecognizer *)recognizer{
    NSLog(@"pinched"); // does not work : ( - i don't know why
    
    
//    CGFloat factor = [(UIPinchGestureRecognizer *) recognizer scale ];
//    NSLog(@"pinched, %f", factor);
//    
//    if ([self.delegate respondsToSelector:@selector(pinchFire:)]){
//        [self.delegate floatingToolbar:self didTryToPinchWithScale:factor];
//    }
    
    
}




@end

