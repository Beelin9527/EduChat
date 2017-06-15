//
//  DWDAccountPhotosCell.m
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAccountPhotosCell.h"

@implementation DWDAccountPhotosCell

- (void)awakeFromNib {
    self.photoTitleLabel.text = NSLocalizedString(@"Photos", nil);
}

@end
