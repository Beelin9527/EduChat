//
//  DWDLeavePaperApproveViewController.m
//  EduChat
//
//  Created by apple on 15/12/9.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDLeavePaperApproveViewController.h"

#import "DWDNoteDetailEntity.h"

#import "DWDLaevePaperApproveCell.h"
#import "DWDLaevePaperApproveDisagreeCell.h"

#import "UIImage+Utils.h"
@interface DWDLeavePaperApproveViewController ()<UITextViewDelegate>

@property (nonatomic,strong) UIButton *selectBtn;
@property (strong, nonatomic) DWDNoteDetailEntity *noteDetailEntity;
@property (strong, nonatomic) DWDLaevePaperApproveDisagreeCell *laevePaperApproveDisagreeCell;
@property (strong, nonatomic) UIView *tableFootView;
@end

static NSString *laevePaperApproveCellId = @"DWDLaevePaperApproveCell";
static NSString *laevePaperApproveDisagreeCellId = @"DWDLaevePaperApproveDisagreeCell";
@implementation DWDLeavePaperApproveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@的假条",self.authorEntity.name];
    
    [self registerCell];
    
    //区分权限
    if ([DWDCustInfo shared].isTeacher) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commit)];
        self.tableView.tableFooterView = self.tableFootView;
    }
    
    [self requestData];
}


#pragma mark - view
-(UIView*)setupTableFootView
{
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, DWDScreenH-DWDPadding*5-DWDTopHight, DWDScreenW, DWDPadding*4)];
    footView.backgroundColor = [UIColor clearColor];
    
    NSArray *arrBtntitles = @[@"同意",@"不同意"];
    
    for (int i = 0; i < arrBtntitles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*DWDScreenW/2+DWDScreenW/4-DWDPadding*10/2, 0, DWDPadding*10, footView.bounds.size.height);
        
        btn.tag = i;
        btn.titleLabel.font = DWDFontBody;
        [btn setTitle:arrBtntitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateSelected];
        btn.layer.borderColor = DWDColorMain.CGColor;
        btn.layer.borderWidth = 1.5;
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = btn.bounds.size.height/2;
        [btn addTarget:self action:@selector(licked:) forControlEvents:UIControlEventTouchDown];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
               [footView addSubview:btn];
       }
    return footView;
}


-(void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLaevePaperApproveCell" bundle:nil] forCellReuseIdentifier:laevePaperApproveCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLaevePaperApproveDisagreeCell" bundle:nil] forCellReuseIdentifier:laevePaperApproveDisagreeCellId];
}

#pragma mark - Getter
- (UIView *)tableFootView
{
    if (!_tableFootView) {
       _tableFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DWDScreenW, 140)];
        _tableFootView.backgroundColor = [UIColor clearColor];
        
        NSArray *arrBtntitles = @[@"同意",@"不同意"];
        
        for (int i = 0; i < arrBtntitles.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(i*DWDScreenW/2+DWDScreenW/4-DWDPadding*10/2, DWDPadding * 6, DWDPadding*10, DWDPadding * 4);
            
            btn.tag = i;
            btn.titleLabel.font = DWDFontBody;
            [btn setTitle:arrBtntitles[i] forState:UIControlStateNormal];
            [btn setTitleColor:DWDColorContent forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateSelected];
            btn.layer.borderColor = DWDColorMain.CGColor;
            btn.layer.borderWidth = 1.5;
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = btn.bounds.size.height/2;
            [btn addTarget:self action:@selector(licked:) forControlEvents:UIControlEventTouchDown];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [_tableFootView addSubview:btn];
        }

    }
    return _tableFootView;
}


#pragma mark - action
-(void)licked:(UIButton*)sender
{
    self.selectBtn.selected = NO;
    sender.selected = YES;
    self.selectBtn = sender;
    
    if (sender.tag == 0) {
        
        if (self.leavePaperType == agreeType) {
            return;
        }
        
        self.leavePaperType = agreeType;
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
        
    }else if (sender.tag == 1) {
        
        if (self.leavePaperType == disagreeType) {
            return;
        }
        
        self.leavePaperType = disagreeType;
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationBottom];
        
        return;
    }
}
-(void)commit
{
    [self requestApproveDidselectbutton:self.selectBtn];
}
#pragma mark - TableViewdDasourData

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.noteDetailEntity) {
        return 0;
    }
    return 2;
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        
        if (self.leavePaperType == disagreeType) {
            DWDLaevePaperApproveDisagreeCell *approveDisagreeCell = [tableView dequeueReusableCellWithIdentifier:laevePaperApproveDisagreeCellId forIndexPath:indexPath];
            
            self.laevePaperApproveDisagreeCell = approveDisagreeCell;
            approveDisagreeCell.createTime.text = [NSString stringFromTimeStampWithYYYYMMddHHmmss:self.authorEntity.addTime];
            
            return approveDisagreeCell;
        }
        
        DWDLaevePaperApproveCell *applyTimeCell = [tableView dequeueReusableCellWithIdentifier:laevePaperApproveCellId forIndexPath:indexPath];
        applyTimeCell.createTime.text = [NSString stringFromTimeStampWithYYYYMMddHHmmss:self.authorEntity.addTime];

        return applyTimeCell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    
}

#pragma mark - TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        return  self.leavePaperType==disagreeType?220:85;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



#pragma mark - request

// get entity
- (void)requestData
{
    __weak __typeof(self) weakSelf = self;
    [[DWDRequestServerLeavePaper sharedDWDRequestServerLeavePaper] requestGetEntityCustId:[DWDCustInfo shared].custId  classId:self.classId noteId:self.noteEntity.noteId success:^(id responseObject) {
        
        weakSelf.noteDetailEntity = responseObject;
        
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

// approve
- (void)requestApproveDidselectbutton:(UIButton *)sender
{
    
    NSNumber *state = sender.tag == 0 ? @1 : @2;
    NSString *opinion = sender.tag == 0 ? @"" : self.laevePaperApproveDisagreeCell.disagreeOpinion.text;
    
     __weak __typeof(self) weakSelf = self;
    [[DWDRequestServerLeavePaper sharedDWDRequestServerLeavePaper] requestApproveNoteCustId:[DWDCustInfo shared].custId classId:self.classId noteId:self.noteEntity.noteId state:state opinion:opinion success:^(id responseObject) {
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        
    }];
    
   
}
@end
