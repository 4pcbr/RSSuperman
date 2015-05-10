//
//  Post.h
//  RSSuperman
//
//  Created by Olegs on 10/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;

@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Feed *feed;

@end
