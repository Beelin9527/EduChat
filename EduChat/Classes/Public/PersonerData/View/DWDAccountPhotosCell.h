//
//  DWDAccountPhotosCell.h
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDAccountPhotosCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageOne;
@property (weak, nonatomic) IBOutlet UIImageView *imageTow;
@property (weak, nonatomic) IBOutlet UIImageView *imageThree;

@property (weak, nonatomic) IBOutlet UILabel *photoTitleLabel;
@end
