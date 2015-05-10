//
//  PostViewCell.h
//  RSSuperman
//
//  Created by Olegs on 10/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post;

@interface PostViewCell : UITableViewCell

- (void)displayContentForPost:(Post *)feedPost;

@end
