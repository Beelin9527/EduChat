//
//  DWDSearchClassInfoViewController.m
//  EduChat
//
//  Created by Superman on 16/2/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSearchClassInfoViewController.h"
#import "DWDClassVerifyController.h"
#import "DWDParentClassVerifyViewController.h"
#import "DWDChatController.h"

#import "DWDClassModel.h"

#import "DWDSearchClassInfoIntroduceCell.h"

#import "NSString+extend.h"
@interface DWDSearchClassInfoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImv;
@property (weak, nonatomic) IBOutlet UILabel *classNameLab;
@property (weak, nonatomic) IBOutlet UILabel *classEduAccLab;
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLab;
@property (weak, nonatomic) IBOutlet UILabel *classIntrolLab;
@property (weak, nonatomic) IBOutlet UIButton *sendApplyBtn;

@end

@implementation DWDSearchClassInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.classModel.className;
    
    //如果是班级主页进来，隐藏发送按钮
    if (self.isHideButton) self.sendApplyBtn.hidden = YES;
    
    //setup
    _sendApplyBtn.layer.masksToBounds = YES;
    _sendApplyBtn.layer.cornerRadius = _sendApplyBtn.h/2;
    
    [_avatarImv sd_setImageWithURL:[NSURL URLWithString:self.classModel.photoKey] placeholderImage:DWDDefault_GradeImage];
    _classNameLab.text = self.classModel.className;
    _classEduAccLab.text = [self.classModel.classAcct stringValue];
    _schoolNameLab.text = self.classModel.schoolName;
    if ([self.classModel.introduce isEqualToString:@""] || !self.classModel.introduce) {
        _classIntrolLab.text = [NSString stringWithFormat:@"班级介绍:   暂无介绍"];
    }else{
        _classIntrolLab.text = [NSString stringWithFormat:@"班级介绍:   %@",self.classModel.introduce]; 
    }
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:self.classIntrolLab.text];
    [attriStr addAttribute:NSForegroundColorAttributeName value:DWDColorContent range:NSMakeRange(0, 5)];
    _classIntrolLab.attributedText = attriStr;
   
    
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    //扫描的显示
    if(self.type == DWDSacnClassResultTypeApply){
        [_sendApplyBtn setTitle:@"申请加入班级" forState:UIControlStateNormal];
    }else{
         [_sendApplyBtn setTitle:@"进入班级" forState:UIControlStateNormal];
    }
}


#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    }
    else if (indexPath.row == 2) {
        return [_classIntrolLab.text boundingRectWithfont:DWDFontContent sizeMakeWidth:DWDScreenW - 120 ].height + 25;
    }
    return 44;
}

-(IBAction)btnClick:(UIButton *)sender{
    //区别老师与家长 弹出验证控制器
    if(self.type == DWDSacnClassResultTypeApply){
        if([DWDCustInfo shared].isTeacher){
            DWDClassVerifyController *verifyVc = [[DWDClassVerifyController alloc] init];
            verifyVc.classModel = self.classModel;
            [self.navigationController pushViewController:verifyVc animated:YES];
        }else{
            DWDParentClassVerifyViewController *verifyVC = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDParentClassVerifyViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDParentClassVerifyViewController class])];
            verifyVC.classId = self.classModel.classId;
            [self.navigationController pushViewController:verifyVC animated:YES];
            
        }
    }else{
        //进入班级
        DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        
        chatController.chatType = DWDChatTypeClass;
        chatController.toUserId = self.classModel.classId;
        chatController.myClass = self.classModel;
        
        [self.navigationController pushViewController:chatController animated:NO];
    }
}
@end
