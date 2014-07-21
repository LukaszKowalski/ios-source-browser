//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Łukasz Kowalski on 7/13/14.
//  Copyright (c) 2014 Lukasz. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"


#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UITextField *textField;
@property (assign, nonatomic) BOOL isLoading;
@property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;
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
    
    self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    for (UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]){
        [mainView addSubview:viewToAdd];
         }
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
    CGFloat browserHight = CGRectGetHeight(self.view.bounds)  - itemHight;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHight);
    
    self.awesomeToolbar.frame = CGRectMake(20, 100, 280, 60);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    NSString *typedURL = textField.text;
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
   
    
    NSRange range = [typedURL rangeOfCharacterFromSet:whitespace];
    NSRange range1 = [typedURL rangeOfString:@"\\."];
    if (range.location == NSNotFound && range1.location == NSNotFound) {
        NSLog(@"test");
        typedURL = textField.text;
    }else{
        NSLog(@"google search %@", typedURL);
        typedURL = [typedURL stringByReplacingOccurrencesOfString:@" " withString:@"\%20"];
        typedURL = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", textField.text];
        NSLog(@"google URL search %@", typedURL);
    }

   
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
    NSString *webSiteTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (webSiteTitle) {
        self.title = webSiteTitle;
        
    }else{
        self.title = self.webView.request.URL.absoluteString;
    }
    
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];

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
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
    UIAlertView *welcomeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title") message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") otherButtonTitles:nil, nil];
    [welcomeAlert show];
}

- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
    if ([title isEqual:NSLocalizedString(@"Back", @"Back command")]) {
        [self.webView goBack];
    } else if ([title isEqual:NSLocalizedString(@"Forward", @"Forward command")]) {
        [self.webView goForward];
    } else if ([title isEqual:NSLocalizedString(@"Stop", @"Stop command")]) {
        [self.webView stopLoading];
    } else if ([title isEqual:NSLocalizedString(@"Refresh", @"Reload command")]) {
        [self.webView reload];
    }
}

@end
