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
#import "DWDClassSourcePersonalRecordViewController.h"
#import "DWDClassModel.h"
#import "DWDClassMember.h"
#import <YYModel.h>
@interface DWDClassMemberViewController ()
@property (nonatomic , strong) NSMutableArray *members;

@end

@implementation DWDClassMemberViewController

- (NSMutableArray *)members{
    if (!_members) {
        _members = [NSMutableArray array];
    }
    return _members;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"班群成员";
    NSDictionary *params = @{@"classId" : self.myClass.classId};
    [[HttpClient sharedClient] getApi:@"ClassMemberRestService/getList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *arr = responseObject[@"data"];
        for (int i = 0; i < arr.count; i++) {
            DWDClassMember *member = [DWDClassMember yy_modelWithJSON:arr[i]];
            [self.members addObject:member];
        }
        [self.collectionView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    [self.collectionView registerClass:[DWDClassSourceGrowupRecordCell class] forCellWithReuseIdentifier:@"cell"];
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
    return self.members.count;
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
