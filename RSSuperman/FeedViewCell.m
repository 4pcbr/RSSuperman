//
//  FeedViewCell.m
//  RSSuperman
//
//  Created by Olegs on 10/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "FeedViewCell.h"
#import "Feed.h"

@interface FeedViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *feedFavicon;
@property (weak, nonatomic) IBOutlet UILabel *feedTitle;
@property (weak, nonatomic) IBOutlet UILabel *updatedAtTitle;

@end

@implementation FeedViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayContentForFeed:(Feed *)feed {
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[feed getFeedFavIconURL]];
    [self.feedFavicon setImage:[UIImage imageWithData:imageData]];
    self.feedTitle.text = feed.title;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd MMMM hh:mm"];
    self.updatedAtTitle.text = [dateFormatter stringFromDate:feed.updatedAt];
}

@end
