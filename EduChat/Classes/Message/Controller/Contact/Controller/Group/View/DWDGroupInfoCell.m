//
//  DWDGroupInfoCell.m
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGroupInfoCell.h"
#import "DWDGroupInfoModel.h"

@interface DWDGroupInfoCell ()
@property (strong, nonatomic) UIImageView *img;
@end
@implementation DWDGroupInfoCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = DWDFontBody;
        self.textLabel.textColor = DWDColorBody;
        
        self.detailTextLabel.font = DWDFontBody;
        self.detailTextLabel.textColor = DWDColorContent;
    }
    return self;
}

-(void)setGroupInfoModel:(DWDGroupInfoModel *)groupInfoModel
{
    _groupInfoModel = groupInfoModel;
    self.textLabel.text = groupInfoModel.title;
    //判断
    switch (groupInfoModel.type) {
        case DWDGroupTypeNone:
        {
            self.detailTextLabel.text = nil;
            self.accessoryView = nil;
            
        }break;
        case DWDGroupTypeDetailTitle:
        {
            self.detailTextLabel.text = groupInfoModel.detailTitle;
            
            self.accessoryView = nil;
        }break;
        case DWDGroupTypeImg:
        {
            if ([groupInfoModel.imgName isEqualToString:@"Common_qr-code_normal"])//二维码
            {
                self.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:groupInfoModel.imgName]];
            }
            else //群组头像
            {
                UIImageView *imv = [[UIImageView alloc] init];
                [imv setSize:CGSizeMake(60, 60)];
                [imv sd_setImageWithURL:[NSURL URLWithString:groupInfoModel.imgName] placeholderImage:DWDDefault_GroupImage];
                self.accessoryView = imv;
            }
            self.detailTextLabel.text = nil;
            
        }break;
        case DWDGroupTypeSwitch:
        {
              UISwitch *switchControl = [[UISwitch alloc]init];
            [switchControl addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventValueChanged];
            self.accessoryView = switchControl;
            [switchControl setOn:groupInfoModel.isOpen animated:YES];
            
            self.detailTextLabel.text = nil;
        }break;
        case DWDGroupTypeIndicator:
        {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            self.accessoryView = nil;
            self.detailTextLabel.text = nil;
        }break;
            
        default:
            break;
    }
}

-(void)changeAction:(UISwitch*)sender
{
    _groupInfoModel.isOpen = !self.groupInfoModel.isOpen;
    NSInteger i = 0;//需要int类型，bool后台会报错。
    if (_groupInfoModel.isOpen) {
        i = 1;
    }else{
        i = 0;
    }
    !self.clickShowNicknameButton ?: self.clickShowNicknameButton(@(i));
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
