//
//  Feed+Favicon.m
//  RSSuperman
//
//  Created by Olegs on 10/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "Feed+Favicon.h"

@implementation Feed (Favicon)

- (NSURL *)getFeedFavIconURL {
    NSString *baseURLHost = [[NSURL URLWithString:self.link] host];
    NSURL *faviconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain=%@", baseURLHost]];
    
    return faviconURL;
}

@end
