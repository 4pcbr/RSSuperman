//
//  DetailViewController.m
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "DetailViewController.h"
#import "Feed.h"

@interface DetailViewController ()

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
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.feed.posts count]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
//        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feed) {
        return [self.feed.posts count];
    } else {
        return 0;
    }
}

@end
