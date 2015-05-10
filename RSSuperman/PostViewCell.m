//
//  PostViewCell.m
//  RSSuperman
//
//  Created by Olegs on 10/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "PostViewCell.h"
#import "Post.h"

@interface PostViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *feedPostTitle;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (strong, nonatomic) NSString *feedPostIdentifier;
@end

@implementation PostViewCell

- (void)configureView:(Post *)feedPost {
    self.feedPostTitle.text = feedPost.title;
    if ([feedPost.isRead boolValue] != YES) {
        self.statusImage.hidden = NO;
        self.statusImage.image = [UIImage imageNamed:@"New"];
    } else if ([feedPost.isPinned boolValue]) {
        self.statusImage.hidden = NO;
        self.statusImage.image = [UIImage imageNamed:@"PinActive"];
    } else if ([feedPost.isFavorite boolValue]) {
        self.statusImage.hidden = NO;
        self.statusImage.image = [UIImage imageNamed:@"FavoriteActive"];
    } else {
        self.statusImage.hidden = YES;
    }
}

- (void)displayContentForPost:(Post *)feedPost {
    [self configureView:feedPost];
    self.feedPostIdentifier = feedPost.identifier;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedPostHasBeenFavorited:)
                                                 name:@"FeedPostHasBeenFavorited"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedPostHasBeenRead:)
                                                 name:@"FeedPostHasBeenRead"
                                               object:nil];
}

- (void)feedPostHasBeenFavorited:(NSNotification *)notification {
    Post *feedPost = (Post *)[notification object];
    if (feedPost != nil) {
        if ([feedPost.identifier isEqualToString:self.feedPostIdentifier]) {
            [self configureView:feedPost];
        }
    }
}

- (void)feedPostHasBeenRead:(NSNotification *)notification {
    Post *feedPost = (Post *)[notification object];
    if (feedPost != nil) {
        if ([feedPost.identifier isEqualToString:self.feedPostIdentifier]) {
            [self configureView:feedPost];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
