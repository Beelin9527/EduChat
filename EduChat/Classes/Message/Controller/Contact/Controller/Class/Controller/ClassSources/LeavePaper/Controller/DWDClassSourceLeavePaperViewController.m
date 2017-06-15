//
//  DWDClassSourceLeavePaperViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDLeavePaperLookViewController.h"
#import "DWDLeavePaperApproveViewController.h"

#import "DWDLeavePaperCell.h"
#import "DWDSegmentedControl.h"

#import "DWDRequestServerLeavePaper.h"
#import "DWDAuthorEntity.h"
#import "DWDNoteEntity.h"

typedef enum {
    NotApproveType,approveType
}ApproveType;

@interface DWDClassSourceLeavePaperViewController()<DWDSegmentedControlDelegate>
@property (weak, nonatomic) UIView *indexLine;
@property (weak, nonatomic) UIButton *selectBtn;//标记按钮
@property (assign, nonatomic) ApproveType type;

@property (strong, nonatomic) DWDSegmentedControl *sc;

@property (strong, nonatomic) NSDictionary *arrDataSource;
@property (strong, nonatomic) NSDictionary *arrType_1;
@property (strong, nonatomic) NSDictionary*arrType_2;

@end
static NSString *ID = @"Cell";
@implementation DWDClassSourceLeavePaperViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"假条";
    DWDSegmentedControl *sc = [[DWDSegmentedControl alloc]init];
    self.sc = sc;
    sc.frame = CGRectMake(0, 0, DWDScreenW,DWDPadding *4);
    sc.arrayTitles = @[@"待审批",@"已审批"];
    sc.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    [self registerCell];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //remove array allobject , pop reload data
    self.arrType_1 = nil;
    self.arrType_2 = nil;
    
    //if selectBtn
      NSNumber *type = self.selectBtn.tag == 0 ? @2 : @1;
    //request  获取范围 1-已审批  2-待审批
    [self requestDataType:type];

}


#pragma mark - view
//注册Cell
-(void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLeavePaperCell" bundle:nil]forCellReuseIdentifier:ID];
}


#pragma mark - action


#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (!self.arrDataSource) return 0;
    
    NSArray *temp = self.arrDataSource[@"author"];
    return temp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDLeavePaperCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];

    cell.type = (DWDLeavePaperCellType) self.type;
    
    cell.authorEntity = self.arrDataSource[@"author"][indexPath.row];//get author entity
    cell.noteEntity = self.arrDataSource[@"note"][indexPath.row];//get note entity
    return cell;
}
#pragma mark - <UITableViewDelegate>
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return DWDPadding *6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }
    return 0;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.sc;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.type == NotApproveType) {
        
        DWDLeavePaperApproveViewController *vc = [[DWDLeavePaperApproveViewController alloc]init];
        
        vc.authorEntity = self.arrDataSource[@"author"][indexPath.row];
        vc.noteEntity = self.arrDataSource[@"note"][indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        DWDLeavePaperLookViewController *vc = [[DWDLeavePaperLookViewController alloc]init];
        
        vc.authorEntity = self.arrDataSource[@"author"][indexPath.row];
        vc.noteEntity = self.arrDataSource[@"note"][indexPath.row];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

#pragma mark - DWDSegmentedControlDelegate
-(void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView lickBtn:(UIButton *)sender
{
    self.selectBtn = sender;
    
    if (sender.tag == 0) {//待审批
        
        self.type = NotApproveType;
        DWDLog(@"%@",self.arrType_1);
        self.arrDataSource = self.arrType_1;
        
         [self.tableView reloadData];
        
        
        //request  获取范围 1-已审批  2-待审批
        if (self.arrType_1) return;
        [self requestDataType:@2];

    }else{
        
        self.type = approveType;
        self.arrDataSource = self.arrType_2;

         [self.tableView reloadData];
        
        //request  获取范围 1-已审批  2-待审批
        if (self.arrType_2) return;
        [self requestDataType:@1];
    
    }
    
    
    
}

#pragma mark - request
- (void)requestDataType:(NSNumber *)type
{
    __weak DWDClassSourceLeavePaperViewController *weakSele = self;
    
    [[DWDRequestServerLeavePaper sharedDWDRequestServerLeavePaper] requestGetListCustId:@4010000005410 classId:@8010000001047 type:type pageIndex:@1 pageCount:@25 success:^(id responseObject) {
        
        if ([type isEqualToNumber:@2]) {
            
            self.arrType_1 = responseObject;
            
            
        }else if([type isEqualToNumber:@1]) {
            
            self.arrType_2 = responseObject;
        }
        
        weakSele.arrDataSource = responseObject;
        [weakSele.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}
@end
