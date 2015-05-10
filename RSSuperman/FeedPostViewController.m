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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *linkButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoriteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *readButton;
@end

@implementation FeedPostViewController

- (IBAction)readButtonDidClick:(UIBarButtonItem *)sender {

}

- (IBAction)pinButtonDidTap:(UIBarButtonItem *)sender {

}

- (IBAction)favoriteButtonDidTap:(UIBarButtonItem *)sender {
    if (self.feedPost) {
        if ([self.feedPost.isFavorite boolValue]) {
            self.feedPost.isFavorite = [NSNumber numberWithBool:NO];
        } else {
            self.feedPost.isFavorite = [NSNumber numberWithBool:YES];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedPostHasBeenFavorited" object:self.feedPost];
        [self configureFavoriteButton];
    }
}

- (IBAction)linkButtonDidTap:(UIBarButtonItem *)sender {
    if (self.feedPost && self.feedPost.link) {
        NSURL *feedPostURL = [NSURL URLWithString:self.feedPost.link];
        [[UIApplication sharedApplication] openURL:feedPostURL];
    }
}

- (void)loadWebViewContent {
    NSString *feedContent = [self.feedPost.content length] ? self.feedPost.content : self.feedPost.summary;
    
    feedContent = [feedContent stringByReplacingOccurrencesOfString:@"&nbsp;"
                                                         withString:@"<br/>"];
    
    NSString *htmlTemplatePath = [[NSBundle mainBundle] pathForResource:@"post" ofType:@"html"];
    NSString *htmlTemplate = [NSString stringWithContentsOfFile:htmlTemplatePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
    
    NSString *content = [htmlTemplate stringByReplacingOccurrencesOfString:@"__CONTENT__"
                                                                withString:feedContent];
    
    NSString *bootstrapCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bootstrap"
                                                                                                ofType:@"css"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];

    content = [content stringByReplacingOccurrencesOfString:@"__BOOTSTRAP__"
                                                 withString:bootstrapCSS];
    
    NSString *styleCSS = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"style"
                                                                                            ofType:@"css"]
                                                   encoding:NSUTF8StringEncoding
                                                      error:NULL];

    content = [content stringByReplacingOccurrencesOfString:@"__STYLE__"
                                                 withString:styleCSS];
    
    [self.webView loadHTMLString:content
                         baseURL:nil];
}

- (void)configureFavoriteButton {
    if (self.feedPost) {
        self.favoriteButton.enabled = YES;
        if ([self.feedPost.isFavorite boolValue]) {
            [self.favoriteButton setImage:[UIImage imageNamed:@"FavoriteActive"]];
        } else {
            [self.favoriteButton setImage:[UIImage imageNamed:@"Favorite"]];
        }
    } else {
        self.favoriteButton.enabled = NO;
    }
}

- (void)configureView {
    if (self.feedPost) {
        self.title = self.feedPost.title;
        if (self.feedPost.link) {
            self.linkButton.enabled = YES;
        } else {
            self.linkButton.enabled = NO;
        }

        [self loadWebViewContent];
    } else {
        self.linkButton.enabled = NO;
    }
    
    [self configureFavoriteButton];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configureView];
}

- (void) toggleReadButton {
    // TODO: the animation doesn't work ((
    __weak FeedPostViewController *weakSelf = self;
    [UIView animateWithDuration:2.0f animations:^{
        UIColor *currentColor = weakSelf.readButton.tintColor;
        weakSelf.readButton.tintColor = [currentColor colorWithAlphaComponent:0.0f];
    } completion:^(BOOL finished) {
        if (weakSelf.feedPost) {
            NSString *newImageName = [weakSelf.feedPost.read boolValue] ? @"Checked" : @"New";
            weakSelf.readButton.image = [UIImage imageNamed:newImageName];
            [UIView animateWithDuration:2.0f animations:^{
                UIColor *currentColor = weakSelf.readButton.tintColor;
                weakSelf.readButton.tintColor = [currentColor colorWithAlphaComponent:1.0f];
            }];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    self.feedPost.read = [NSNumber numberWithBool:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FeedPostHasBeenRead"
                                                        object:self.feedPost];
    [self toggleReadButton];
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
