//
//  RSSController.m
//  RSSuperman
//
//  Created by Olegs on 05/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <MWFeedParser.h>
#import <PromiseKit/Promise.h>
#import "RSSController.h"

@interface RSSController () <MWFeedParserDelegate>
@property (strong, nonatomic) MWFeedParser        *feedParser;
@property (strong, nonatomic) PMKPromise          *promise;
@property (strong, nonatomic) PMKPromiseFulfiller  fulfiller;
@property (strong, nonatomic) PMKPromiseRejecter   rejecter;
@end

@implementation RSSController

- (instancetype)initWithFeedURL:(NSString *)feedURLString {
    self = [super init];
    if (self) {
        self.feedItems = [[NSMutableArray alloc] init];
        NSURL *feedUrl = [NSURL URLWithString:feedURLString];
        _feedParser = [[MWFeedParser alloc] initWithFeedURL:feedUrl];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeAsynchronously;
    }
    return self;
}

- (PMKPromise *)fetch {
    __weak RSSController *weakSelf = self;
    
    [self.feedParser parse];
    
    self.promise = [PMKPromise new:^(PMKFulfiller fulfiller, PMKRejecter rejecter) {
        weakSelf.fulfiller = fulfiller;
        weakSelf.rejecter  = rejecter;
    }];
    
    return self.promise;
}

# pragma mark - parser delegate methods

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    self.feedInfo = info;
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    [self.feedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    self.fulfiller(self);
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    self.rejecter(error);
}

@end
