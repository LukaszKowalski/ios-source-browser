//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Łukasz Kowalski on 7/13/14.
//  Copyright (c) 2014 Lukasz. All rights reserved.
//

#import "BLCWebBrowserViewController.h"


@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *forwardButton;
@property (strong, nonatomic) UIButton *reloadButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (assign, nonatomic) BOOL isLoading;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation BLCWebBrowserViewController

#pragma mark - UIViewController

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@" Wyszukaj lub wpisz url", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setEnabled:NO];
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setEnabled:NO];
    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.stopButton setEnabled:NO];
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.reloadButton setEnabled:NO];
    
    [self.backButton setTitle:NSLocalizedString(@"back", @"back button") forState:UIControlStateNormal];
    [self.forwardButton setTitle:NSLocalizedString(@"forward", @"forward button") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLocalizedString(@"stop", @"stop button") forState:UIControlStateNormal];
    [self.reloadButton setTitle:NSLocalizedString(@"reload", @"reload button") forState:UIControlStateNormal];
    
    
    for (UIView *subview in @[self.webView, self.textField, self.backButton, self.forwardButton, self.reloadButton, self.stopButton]){
        [mainView addSubview:subview];
    };
    
    self.view = mainView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];

    
    
    
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    static CGFloat itemHight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHight = CGRectGetHeight(self.view.bounds) - itemHight - itemHight;
    CGFloat buttonWidth = CGRectGetWidth(self.view.bounds) /4;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHight);
    
    CGFloat buttonCurrentX = 0;
    
    for (UIButton *thisButton in @[self.backButton, self.reloadButton, self.stopButton, self.forwardButton]){
        thisButton.frame = CGRectMake(buttonCurrentX, CGRectGetMaxY(self.webView.frame), buttonWidth, itemHight);
        buttonCurrentX += buttonWidth;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    NSString *typedURL = textField.text;
    
    if ([typedURL rangeOfString:@"."].location != NSNotFound) {
        typedURL = textField.text;
    }else{
        NSLog(@"google search %@", typedURL);
        typedURL = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", textField.text];
        NSLog(@"google URL search %@", typedURL);
    }
    
 //   int spaceIsThere = [[typedURL componentsSeparatedByString:@" "] count];
 //   if (spaceIsThere != 0) {
 //       typedURL = [NSString stringWithFormat:@"http://www.onet.pl"];
 //   }
    
    NSURL *URL = [NSURL URLWithString:typedURL];
    
    if (!URL.scheme) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",typedURL]];
    }
    
    if (URL) {
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:urlRequest];
    }
    return NO;
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"okey button") otherButtonTitles:nil, nil];
    [alert show];
    [self updateButtonsAndTitle];
    [self.webView stopLoading];
}

-(void) updateButtonsAndTitle {
    NSString *webSiteTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.tile"];
    if (webSiteTitle) {
        self.navigationItem.title = webSiteTitle;
        
    }else{
        self.navigationItem.title = self.webView.request.URL.absoluteString;
    }
    
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.reloadButton.enabled = !self.isLoading;
    self.stopButton.enabled = self.isLoading;
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.isLoading = YES;
    [self updateButtonsAndTitle];
    [self.activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.isLoading = NO;
    [self updateButtonsAndTitle];
    [self.activityIndicator stopAnimating];
}
- (void) resetWebView{
    [self.webView removeFromSuperview];
    UIWebView *newWebView = [[UIWebView alloc] init];
    
    newWebView.delegate= self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    [self addButtonTargets];
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    UIAlertView *welcomeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title") message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") otherButtonTitles:nil, nil];
    [welcomeAlert show];
}
-(void) addButtonTargets {
    for (UIButton *button in @[self.backButton, self.forwardButton, self.stopButton, self.reloadButton]) {
        [button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    }
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(stopLoading) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    

}

@end
