//
//  FeedPostViewController.m
//  RSSuperman
//
//  Created by Olegs on 09/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "FeedPostViewController.h"
#import "Post.h"

@interface FeedPostViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation FeedPostViewController

- (void)loadWebViewContent {
    NSString *feedContent = [self.feedPost.content length] ? self.feedPost.content : self.feedPost.summary;
    
    feedContent = [feedContent stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@"<br/>"];
    
    NSString *htmlTemplatePath = [[NSBundle mainBundle] pathForResource:@"post" ofType:@"html"];
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:htmlTemplatePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *content = [htmlTemplate stringByReplacingOccurrencesOfString:@"__CONTENT__" withString:feedContent];
    
    NSString *bootstrapCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bootstrap" ofType:@"css"] encoding:NSUTF8StringEncoding error:NULL];
    content = [content stringByReplacingOccurrencesOfString:@"__BOOTSTRAP__" withString:bootstrapCSS];
    
    NSString *styleCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"] encoding:NSUTF8StringEncoding error:NULL];
    content = [content stringByReplacingOccurrencesOfString:@"__STYLE__" withString:styleCSS];
    
    [self.webView loadHTMLString:content baseURL:nil];
}

- (void)configureView {
    if (self.feedPost) {
        self.title = self.feedPost.title;
        [self loadWebViewContent];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

@end
