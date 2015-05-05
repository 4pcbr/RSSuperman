//
//  RSSController.h
//  RSSuperman
//
//  Created by Olegs on 05/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MWFeedParser;
@class PMKPromise;

@interface RSSController : NSObject

@property (strong, nonatomic) NSMutableArray      *feedItems;
@property (strong, nonatomic) MWFeedInfo          *feedInfo;

- (instancetype)initWithFeedURL:(NSString *)feedURLString;
- (PMKPromise *)fetch;
@end
