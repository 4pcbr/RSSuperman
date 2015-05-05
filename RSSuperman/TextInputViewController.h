//
//  TextInputViewController.h
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TextInputViewControllerCancel)(void);
typedef void(^TextInputViewControllerSave)(NSString *feedURL, NSString *feedTitle);

@interface TextInputViewController : UIViewController
@property (copy, nonatomic) TextInputViewControllerCancel cancel;
@property (copy, nonatomic) TextInputViewControllerSave   save;
@property (strong, nonatomic) NSString *pageTitle;
@property (strong, nonatomic) NSString *placeholderText;
@end
