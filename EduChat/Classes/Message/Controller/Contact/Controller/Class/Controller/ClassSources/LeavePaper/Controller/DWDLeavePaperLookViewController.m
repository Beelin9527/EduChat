//
//  DWDLeavePaperLookViewController.m
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//  

#import "DWDLeavePaperLookViewController.h"

#import "DWDLeavePaperApplyTimeCell.h"
#import "DWDLeavePaperApplyDisagreeShowCell.h"

@interface DWDLeavePaperLookViewController ()

@property (strong, nonatomic) DWDNoteDetailEntity *noteDetailEntity;
@end
static NSString *leavePaperApplyTimeCell = @"DWDLeavePaperApplyTimeCell";
static NSString *leavePaperApplyDisagreeShowCell = @"DWDLeavePaperApplyDisagreeShowCell";
@implementation DWDLeavePaperLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = [NSString stringWithFormat:@"%@的假条",self.authorEntity.name];
    
    [self registerCell];
    

    
   }

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestData];

    
}

-(void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLeavePaperApplyTimeCell" bundle:nil] forCellReuseIdentifier:leavePaperApplyTimeCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"DWDLeavePaperApplyDisagreeShowCell" bundle:nil] forCellReuseIdentifier:leavePaperApplyDisagreeShowCell];
}

#pragma mark - TableViewdDasourData
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.noteDetailEntity.state isEqualToNumber:@1]){
        return 2;
    }else if ([self.noteDetailEntity.state isEqualToNumber:@2]){
        return 3;
    }
   return 0;
   
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        DWDLeavePaperApplyTimeCell *applyTimeCell = [tableView dequeueReusableCellWithIdentifier:leavePaperApplyTimeCell forIndexPath:indexPath];
        
        applyTimeCell.aprdName.text = self.noteDetailEntity.aprdName;
        applyTimeCell.aprdTime.text = self.noteDetailEntity.aprdTime;
        applyTimeCell.state.text = [self.noteDetailEntity.state isEqualToNumber:@1]? @"同意" : @"不同意";
        return applyTimeCell;
    }
    
    if (self.leavePaperType==disagreeType) {
        if (indexPath.row==2) {
            DWDLeavePaperApplyDisagreeShowCell *applyDisagreeShowCell = [tableView dequeueReusableCellWithIdentifier:leavePaperApplyDisagreeShowCell forIndexPath:indexPath];
            
            applyDisagreeShowCell.labOpinion.text = self.noteDetailEntity.opinion;
            return applyDisagreeShowCell;
        }
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    
}

#pragma mark - TableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 1) {
        return DWDPadding *17;
    }
    if (self.leavePaperType==disagreeType) {
        if (indexPath.row==2) {
            return 100;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - request

// get entity
- (void)requestData
{
    
    __weak __typeof(self) weakSelf = self;
    
    [[DWDRequestServerLeavePaper sharedDWDRequestServerLeavePaper] requestGetEntityCustId:@4010000005410 classId:@8010000001047 noteId:self.noteEntity.noteId success:^(id responseObject) {
        
        weakSelf.noteDetailEntity = responseObject;
        
        if ([weakSelf.noteDetailEntity.state isEqualToNumber:@1]) {
            
            weakSelf.leavePaperType = agreeType;
        }else{
            
            weakSelf.leavePaperType = disagreeType;
        }
       
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}



@end
