//
//  Feed.m
//  RSSuperman
//
//  Created by Olegs on 05/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "Feed.h"
#import "Post.h"


@implementation Feed

@dynamic title;
@dynamic updatedAt;
@dynamic link;
@dynamic summary;
@dynamic posts;

- (NSURL *)getFeedFavIconURL {
    NSString *baseURLHost = [[NSURL URLWithString:self.link] host];
    NSURL *faviconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain=%@", baseURLHost]];

    return faviconURL;
}

@end
