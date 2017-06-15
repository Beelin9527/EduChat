//
//  DWDClassStudentsListController.m
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define deleteContainerViewHeight 56

#import "DWDClassStudentsListController.h"

#import "DWDPUCLoadingView.h"
#import "DWDClassStudentsListCell.h"

#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDClassModel.h"

#import <YYModel.h>
#import <Masonry.h>

@interface DWDClassStudentsListController () <UITableViewDelegate, UITableViewDataSource, DWDPUCLoadingViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

// enter delete mode when normal state click, return normal mode when selected state click
@property (nonatomic, weak) UIBarButtonItem *editButton;

// edit button state control, default is NO
@property (nonatomic, assign) BOOL editButtonSelected;

// delete button show when tableView.editing is YES
@property (nonatomic, weak) UIButton *deleteButton;

// delete button container view , for animation
@property (nonatomic, weak) UIView *deleteContainerView;

// laoding view
@property (nonatomic, weak) DWDPUCLoadingView *loadingView;

@end

@implementation DWDClassStudentsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"学生管理";
    self.view.backgroundColor = DWDColorBackgroud;
    // right bar button item
    _editButtonSelected = NO;
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"移除" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClick:)];
    [self.navigationItem setRightBarButtonItem:editButton];
    _editButton = editButton;
    
    // tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0, DWDScreenW, DWDScreenH - 64} style:UITableViewStylePlain];
    [tableView setAllowsSelection:NO];
    [tableView setBackgroundColor:[UIColor clearColor]];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    tableView.allowsMultipleSelectionDuringEditing = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    [tableView registerClass:[DWDClassStudentsListCell class] forCellReuseIdentifier:@"cellId"];
    
    // delete bar
    [self addDeleteView];
    
    // request all students
    [self requestAllStudents];
    
}

#pragma mark - Init Subviews

- (void)addDeleteView {
    UIView *view = [[UIView alloc] initWithFrame:(CGRect){0, _tableView.bounds.size.height, DWDScreenW, deleteContainerViewHeight}];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.14f;
    view.layer.shadowOffset = CGSizeMake(0, -4);
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height + 2)].CGPath;
    view.clipsToBounds = NO;
    [self.view insertSubview:view aboveSubview:_tableView];
    _deleteContainerView = view;
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"确定移除班级"
                                                              attributes:@{NSForegroundColorAttributeName : DWDRGBColor(255, 254, 254),
                                                                           NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    [deleteButton setAttributedTitle:str forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf96269)] forState:UIControlStateNormal];
    [view addSubview:deleteButton];
    deleteButton.layer.cornerRadius = 40 * 0.5;
    deleteButton.layer.masksToBounds = YES;
    deleteButton.clipsToBounds = YES;
    [deleteButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(view);
        make.width.mas_equalTo(DWDScreenW - 60);
        make.height.mas_equalTo(deleteContainerViewHeight - 16);
    }];
    [deleteButton setEnabled:NO];
    [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton = deleteButton;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDClassStudentsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    DWDTeacherGoSchoolStudentDetailModel *model = _dataArray[indexPath.row];
    [cell setCellData:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self ifDeleteButtonEnabled:tableView];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self ifDeleteButtonEnabled:tableView];
}

#pragma mark - DWDPUCLoadingViewDelegate
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self requestAllStudents];
}

#pragma mark - Event Response
- (void)editButtonClick:(UIBarButtonItem *)editButton {
    _editButtonSelected = !_editButtonSelected;
    [_tableView setEditing:_editButtonSelected animated:YES];
    CGRect bottomframe = _deleteContainerView.frame;
    CGRect tableViewFrame = _tableView.frame;
    if (_editButtonSelected) {
        //enter edit mode
        [_tableView setAllowsSelection:YES];
        [_editButton setTitle:@"取消"];
        bottomframe.origin.y = DWDScreenH - 64 - deleteContainerViewHeight;
        tableViewFrame.size.height = DWDScreenH - 64 - deleteContainerViewHeight;
    } else {
        //exit edit mode
        [_tableView setAllowsSelection:NO];
        [_deleteButton setEnabled:NO];
        [_editButton setTitle:@"移除"];
        bottomframe.origin.y = DWDScreenH - 64;
        tableViewFrame.size.height = DWDScreenH - 64;
    }
    [UIView animateWithDuration:0.25f animations:^{
        _deleteContainerView.frame = bottomframe;
        _tableView.frame = tableViewFrame;
    }];
}

- (void)deleteButtonClick:(UIButton *)deleteButton {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"将学生移除后, 关联的家长将一并移除班级" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteRequest];
    }];
    [alertController addAction:doneAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)deleteRequest {
    //get selected array
    NSArray<NSIndexPath *> *selectedIndexArray = [_tableView indexPathsForSelectedRows];
    if (selectedIndexArray.count)
        _editButton.enabled = NO;
    else
        return;
    
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSMutableIndexSet *deleteSet = [NSMutableIndexSet indexSet];
    for (NSIndexPath *indexPath in selectedIndexArray) {
        DWDTeacherGoSchoolStudentDetailModel *model = _dataArray[indexPath.row];
        [deleteArray addObject:model.custId];
        [deleteSet addIndex:indexPath.row];
    }
    if (deleteSet.count == 0) return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在移除...";
    //post delete request
    NSDictionary *params = @{
                             @"clsid" : _classId,
                             @"cid" : [DWDCustInfo shared].custId,
                             @"uids" : deleteArray,
                             };
    WEAKSELF;
    [[DWDWebManager sharedManager] postDeleteStudentsWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [weakSelf.dataArray removeObjectsAtIndexes:deleteSet];
        dispatch_async(dispatch_get_main_queue(), ^{

            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"移除成功";
            [hud hide:YES afterDelay:1.5f];
            //`delete rows` when end
            [weakSelf.tableView deleteRowsAtIndexPaths:selectedIndexArray withRowAnimation:UITableViewRowAnimationAutomatic];
            //`end editing` mode when end
            weakSelf.editButton.enabled = YES;
            
            if (weakSelf.dataArray.count == 0) {
                if (weakSelf.editButtonSelected == YES) {
                    [weakSelf editButtonClick:weakSelf.editButton];
                }
                
                if (weakSelf.loadingView) {
                    [weakSelf.loadingView removeFromSuperview];
                    weakSelf.loadingView = nil;
                }
                
                DWDPUCLoadingView *loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 64 - 271 * 0.5 - 15) * 0.5, 310 * 0.5, 271 * 0.5 + 100}];;
                [loadingView.blankImgView setImage:[UIImage imageNamed:@"img_student_default"]];
                loadingView.blankImgView.frame = (CGRect){(310 * 0.5 - 292 * 0.5) * 0.5, 0, 292 * 0.5, 258 * 0.5};
                loadingView.delegate = weakSelf;
                [weakSelf.view insertSubview:loadingView aboveSubview:weakSelf.tableView];
                
                [weakSelf.deleteButton setEnabled:NO];
                [weakSelf.loadingView.descriptionLabel setText:@"暂无学生名单"];
                [weakSelf.loadingView changeToBlankView];
                
                [weakSelf.editButton setEnabled:NO];
            }
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"移除失败";
            [hud hide:YES afterDelay:1.5f];
        });
        
    }];
    

}

#pragma mark - Private Method
- (void)requestAllStudents {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
    DWDPUCLoadingView *loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 64 - 271 * 0.5 - 15) * 0.5, 310 * 0.5, 271 * 0.5 + 100}];;
    [loadingView.blankImgView setImage:[UIImage imageNamed:@"img_student_default"]];
    loadingView.blankImgView.frame = (CGRect){(310 * 0.5 - 292 * 0.5) * 0.5, 0, 292 * 0.5, 258 * 0.5};
    loadingView.delegate = self;
    [self.view insertSubview:loadingView aboveSubview:self.tableView];
    //    loadingView.layer.zPosition = MAXFLOAT;
    _loadingView = loadingView;
    
    
    NSDictionary *params = @{@"classId": _classId};
//    NSDictionary *params = @{@"classId": @8010000001381};
    WEAKSELF;
    [[HttpClient sharedClient] getClassStudentsWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<DWDTeacherGoSchoolStudentDetailModel *> *students = [NSArray yy_modelArrayWithClass:[DWDTeacherGoSchoolStudentDetailModel class] json:responseObject[@"data"]];
        weakSelf.dataArray = [students mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.dataArray.count) {
                [weakSelf.loadingView removeFromSuperview];
                weakSelf.loadingView = nil;
                [weakSelf.tableView reloadData];
                [weakSelf.editButton setEnabled:YES];
                
                // fuck damn
//                if (weakSelf.editButtonSelected == NO) {
//                    [weakSelf editButtonClick:weakSelf.editButton];
//                }
            } else {
                [weakSelf.deleteButton setEnabled:NO];
                [weakSelf.editButton setEnabled:NO];
                [weakSelf.loadingView.descriptionLabel setText:@"暂无学生名单"];
                [weakSelf.loadingView changeToBlankView];
                [weakSelf.tableView reloadData];
                if (weakSelf.editButtonSelected == YES) {
                    [weakSelf editButtonClick:weakSelf.editButton];
                }
            }
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.deleteButton setEnabled:NO];
            [weakSelf.editButton setEnabled:NO];
            [weakSelf.loadingView changeToFailedView];
            [weakSelf.tableView reloadData];
            if (weakSelf.editButtonSelected == YES) {
                [weakSelf editButtonClick:weakSelf.editButton];
            }
        });
    }];
}

- (void)ifDeleteButtonEnabled:(UITableView *)tableView {
    NSArray *indexesArray = [tableView indexPathsForSelectedRows];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (indexesArray.count == 0 || indexesArray == nil) {
            [_deleteButton setEnabled:NO];
        } else {
            [_deleteButton setEnabled:YES];
        }
    });
}



@end
