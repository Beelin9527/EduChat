//
//  DWDAccountSourceCell.m
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAccountSourceCell.h"

@interface DWDAccountSourceCell ()



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separetorHeight;

@end

@implementation DWDAccountSourceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separetorHeight.constant = .5;
}

@end
