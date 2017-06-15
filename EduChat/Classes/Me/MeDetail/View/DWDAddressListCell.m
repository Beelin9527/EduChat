//
//  DWDAddressListCell.m
//  EduChat
//
//  Created by Gatlin on 15/12/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddressListCell.h"
#import "DWDLocationEntity.h"
@interface DWDAddressListCell ()
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labAddress;

@end
@implementation DWDAddressListCell

- (void)setEntity:(DWDLocationEntity *)entity
{
    _entity = entity;
    
    _labName.text = entity.name;
    _labAddress.text = entity.address;
}

@end
