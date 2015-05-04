//
//  DetailViewController.h
//  RSSuperman
//
//  Created by Olegs on 04/05/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

