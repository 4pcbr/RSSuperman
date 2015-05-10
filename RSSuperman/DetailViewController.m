//
//  DetailViewController.m
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "DetailViewController.h"
#import "FeedPostViewController.h"
#import "PostViewCell.h"
#import "Feed.h"
#import "Post.h"
#import "RSSController.h"
#import <PromiseKit/Promise.h>

@interface DetailViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) RSSController    *rssController;
@property (strong, nonatomic) NSArray *feedPosts;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setFeed:(Feed *)newFeed {
    if (_feed != newFeed) {
        _feed = newFeed;
        [self configureView];
    }
}

- (void)configureView {
    if (self.feed) {
        self.title = self.feed.title;
    }
}

- (void)feedPostDidChange:(NSNotification *)notification {
    [self reloadFeedPosts];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.feed) {
        [self reloadFeedPosts];
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor darkGrayColor];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateFeed)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedPostDidChange:)
                                                 name:@"FeedPostDidChange"
                                               object:nil];
    
    [self configureView];
}

- (void)reloadFeedPosts {
    self.feedPosts = [[self.feed.posts allObjects] sortedArrayUsingComparator:^NSComparisonResult(Post *post1, Post *post2) {
        
        int v1 = [post1.isPinned intValue] || ([post1.isRead boolValue] ? 0 : 1);
        v1 = v1 << 1;
        v1 += post1.date > post2.date ? 1 : 0;
        
        int v2 = [post2.isPinned intValue] || ([post2.isRead boolValue] ? 0 : 1);
        v2 = v2 << 1;
        v2 += post2.date > post1.date ? 1 : 0;
        
        return [[NSNumber numberWithInt:v2] compare:[NSNumber numberWithInt:v1]];
    }];
}

- (void)updateFeed {
    if (self.feed) {
        self.rssController = [[RSSController alloc] initWithFeedURL:self.feed.link];
        __weak DetailViewController *weakSelf = self;
        [self.rssController fetch].then(^{
            if (weakSelf) {
                if (weakSelf.onFeedUpdated) {
                    weakSelf.onFeedUpdated(weakSelf.rssController.feedInfo, weakSelf.rssController.feedItems);
                }
                [weakSelf.refreshControl endRefreshing];
                [weakSelf reloadFeedPosts];
                [weakSelf.tableView reloadData];
            }
        }).catch(^(NSError *error) {
            NSLog(@"Error while fetching the feed: %@", error);
            if (weakSelf) {
                [weakSelf.refreshControl endRefreshing];
            }
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.feedPosts count]) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        if (self.feed) {
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            
            messageLabel.text = @"No feeds are currently available. Please pull down to refresh.";
            messageLabel.textColor = [UIColor blackColor];
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentCenter;
            [messageLabel sizeToFit];
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feed) {
        return [self.feedPosts count];
    } else {
        return 0;
    }
}

- (PostViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPostCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(PostViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.feed) {
        Post *feedPost = [self.feedPosts objectAtIndex:[indexPath row]];
        [cell displayContentForPost:feedPost];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (self.feed == nil) {
        return;
    }
    if ([[segue identifier] isEqualToString:@"showFeedPost"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Post *feedPost = [self.feedPosts objectAtIndex:[indexPath row]];
        FeedPostViewController *feedPostVC = (FeedPostViewController *)[[segue destinationViewController] topViewController];
        [feedPostVC setFeedPost:feedPost];
    }
}

@end
