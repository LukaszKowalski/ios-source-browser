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
    }
}

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {

    CGPoint location = [[touches anyObject] locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    return (UILabel *)subview;
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    if (self.currentLabel != label) {
        self.currentLabel.alpha = 1;
    }else{
        self.currentLabel.alpha = 0.5;
    }
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel == label) {
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTile:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTile:self.currentLabel.text];
        }
    }
    
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}


@end

