//
//  DWDClassMemberViewController.m
//  EduChat
//
//  Created by Superman on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassMemberViewController.h"
#import "DWDClassSourceGrowupRecordViewController.h"
#import "DWDClassSourceGrowupRecordCell.h"
#import "DWDClassGrowupRecordAddNewRecordViewController.h"
#import "DWDClassSourcePersonalRecordViewController.h"
@interface DWDClassMemberViewController ()

@end

@implementation DWDClassMemberViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"班级成员";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    
    [self.collectionView registerClass:[DWDClassSourceGrowupRecordCell class] forCellWithReuseIdentifier:@"cell"];
}

- (void)rightBarBtnClick{
    DWDLogFunc;
    DWDClassGrowupRecordAddNewRecordViewController * classNewRecordVc = [[DWDClassGrowupRecordAddNewRecordViewController alloc] init];
    [self.navigationController pushViewController:classNewRecordVc animated:YES];
}

- (instancetype)init{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(pxToW(120), pxToH(160));
    flowLayout.minimumInteritemSpacing = pxToW(25);
    flowLayout.minimumLineSpacing = pxToH(20);
    
    return [self initWithCollectionViewLayout:flowLayout];
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 100;
}

- (DWDClassSourceGrowupRecordCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    DWDClassSourceGrowupRecordCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    cell.backgroundColor = DWDRandomColor;
    return cell;
}

#pragma mark -<UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DWDClassSourcePersonalRecordViewController *personRecordVc = [[DWDClassSourcePersonalRecordViewController alloc] init];
    DWDClassSourceGrowupRecordCell *cell = (DWDClassSourceGrowupRecordCell *)[collectionView cellForItemAtIndexPath:indexPath];
    personRecordVc.name = cell.nameLabel.text;
    [self.navigationController pushViewController:personRecordVc animated:YES];
}


@end
