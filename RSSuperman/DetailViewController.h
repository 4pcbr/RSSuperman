//
//  DetailViewController.h
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Feed;
@class MWFeedInfo;

typedef void(^FeedUpdatedHandler)(MWFeedInfo *feedInfo, NSArray *feedItems);

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) Feed *feed;
@property (copy, nonatomic) FeedUpdatedHandler onFeedUpdated;

@end

