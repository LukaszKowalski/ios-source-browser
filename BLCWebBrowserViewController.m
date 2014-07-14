//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Łukasz Kowalski on 7/13/14.
//  Copyright (c) 2014 Lukasz. All rights reserved.
//

#import "BLCWebBrowserViewController.h"


@interface BLCWebBrowserViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation BLCWebBrowserViewController

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    
    [mainView addSubview:self.webView];
    self.view = mainView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.frame;
} 

@end
