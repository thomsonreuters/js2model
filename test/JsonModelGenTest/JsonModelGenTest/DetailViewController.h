//
//  DetailViewController.h
//  JsonModelGenTest
//
//  Created by Kevin on 9/26/14.
//  Copyright (c) 2014 Thomson Reuters. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

