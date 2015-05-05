//
//  Post.h
//  RSSuperman
//
//  Created by Olegs on 05/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Feed *feed;

@end
