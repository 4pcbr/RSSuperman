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
        self.detailDescriptionLabel.text = self.feed.title;
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

@end
