//
//  BLCAwsomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Łukasz Kowalski on 7/17/14.
//  Copyright (c) 2014 Lukasz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCAwesomeFloatingToolbar;

@protocol BLCAwesomeFloatingToolbarDelegate <NSObject>

@optional

-(void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTile:(NSString *)title;

@end

@interface BLCAwesomeFloatingToolbar : UIView

- (instancetype) initWithFourTitles:(NSArray *)titles;

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property (nonatomic, strong) id <BLCAwesomeFloatingToolbarDelegate> delegate;

@end
