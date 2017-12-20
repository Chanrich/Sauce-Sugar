//
//  BlogViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 12/17/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "BlogViewController.h"
#import <WebKit/WebKit.h>

@interface BlogViewController ()
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) WKWebView *webView;
@end

@implementation BlogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create the webview programatically
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
    
    // Add the webview to main view
    [self.mainView addSubview:self.webView];
    //[self.webView setTranslatesAutoresizingMaskIntoConstraints:false];
    self.webView.frame = self.view.frame;
    
    // Create a url and pass it to webview
    NSURL *targetBlog = [NSURL URLWithString:@"https://sauceandsoda.com/"];
    NSURLRequest *loadReq = [NSURLRequest requestWithURL:targetBlog];
    [self.webView loadRequest:loadReq];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
