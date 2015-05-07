//
//  DetailViewController.m
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "DetailViewController.h"
#import "Feed.h"
#import "Post.h"
#import "RSSController.h"
#import <PromiseKit/Promise.h>

@interface DetailViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) RSSController    *rssController;
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
    // Update the user interface for the detail item.
    if (self.feed) {
//        self.detailDescriptionLabel.text = self.feed.title;
        self.title = self.feed.title;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateFeed)
                  forControlEvents:UIControlEventValueChanged];
    
    [self configureView];
}

- (void)updateFeed {
    // TODO: implement me!
    if (self.feed) {
        self.rssController = [[RSSController alloc] initWithFeedURL:self.feed.link];
        __weak DetailViewController *weakSelf = self;
        [self.rssController fetch].then(^{
            if (weakSelf) {
                if (weakSelf.onFeedUpdated) {
                    weakSelf.onFeedUpdated(weakSelf.rssController.feedInfo, weakSelf.rssController.feedItems);
                }
                [weakSelf.refreshControl endRefreshing];
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
    if ([self.feed.posts count]) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feed) {
        return [[self.feed.posts allObjects] count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedPostCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.feed) {
        Post *feedPost = [[self.feed.posts allObjects] objectAtIndex:[indexPath row]];
        cell.textLabel.text = feedPost.title;
    }
}

@end
