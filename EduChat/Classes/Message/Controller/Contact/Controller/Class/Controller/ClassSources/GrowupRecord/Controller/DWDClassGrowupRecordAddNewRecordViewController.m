//
//  DWDClassGrowupRecordAddNewRecordViewController.m
//  EduChat
//
//  Created by Superman on 15/11/27.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassGrowupRecordAddNewRecordViewController.h"
#import <Masonry.h>

@interface DWDClassGrowupRecordAddNewRecordViewController()
@property (nonatomic , weak) UIView *recordContainerView;
@end

@implementation DWDClassGrowupRecordAddNewRecordViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = DWDRandomColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(barBtnClick)];
    
    // add subviews
    UITextField *namefield = [[UITextField alloc] init];
    namefield.backgroundColor = DWDRandomColor;
    namefield.placeholder = @"请输入档案名称";
    
    UITextField *detailField = [[UITextField alloc] init];
    detailField.backgroundColor = DWDRandomColor;
    detailField.placeholder = @"添加说明";
    
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = DWDRandomColor;
    
    UILabel *recordLabel = [[UILabel alloc] init];
    recordLabel.text = @"添加记录封面";
    [container addSubview:recordLabel];
    
    // 在这里创建添加后的图片,使用数组加入数据
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = DWDRandomColor;
    [btn setTitle:@"添加图片" forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"AvatarOther"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn addTarget:self action:@selector(addPictureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:btn];
    
    
    [self.view addSubview:namefield];
    [self.view addSubview:detailField];
    [self.view addSubview:container];
    
    [namefield makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.top.equalTo(self.view.top).offset(84);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@(50));
    }];
    
    
    [detailField makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(detailField.superview.left);
        make.top.equalTo(namefield.bottom).offset(10);
        make.right.equalTo(detailField.superview.right);
        make.height.equalTo(@(200));
    }];
    
    [container makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailField.bottom);
        make.left.equalTo(container.superview.left);
        make.right.equalTo(container.superview.right);
        make.height.equalTo(@(150));
    }];
    
    // 此label不给宽度和高度 让其自适应
    [recordLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(recordLabel.superview.top).offset(10);
        make.left.equalTo(recordLabel.superview.left).offset(10);
    }];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(recordLabel.left);
        make.top.equalTo(recordLabel.bottom).offset(10);
        make.width.equalTo(@(150));
        make.height.equalTo(@(50));
    }];
}

- (void)barBtnClick{
    DWDLogFunc;
}
- (void)addPictureBtnClick{
    DWDLogFunc;
    // 弹出相面多选控制器(访问系统相册)
}

@end
