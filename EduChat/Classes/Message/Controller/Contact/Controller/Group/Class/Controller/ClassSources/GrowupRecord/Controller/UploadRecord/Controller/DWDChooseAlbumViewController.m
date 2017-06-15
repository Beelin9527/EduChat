//
//  DWDChooseAlbumViewController.m
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChooseAlbumViewController.h"
#import "DWDChooseAlbumCell.h"

#import "DWDChooseAlbumModel.h"

@interface DWDChooseAlbumViewController ()

@end

@implementation DWDChooseAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择相册";
    [self.collectionView registerClass:[DWDChooseAlbumCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
}

- (instancetype)init{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    NSString *str = @"艾斯";
    CGSize textSize = [str realSizeWithfont:DWDFontMin];
    
    flowLayout.itemSize = CGSizeMake(pxToW(120), pxToH(130) + textSize.height);
    flowLayout.sectionInset = UIEdgeInsetsMake(pxToH(20), pxToW(25), 0, pxToW(25));
    flowLayout.minimumLineSpacing = pxToH(20);
    flowLayout.minimumInteritemSpacing = pxToW(25);
    return [self initWithCollectionViewLayout:flowLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.members.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        // 班级
        DWDChooseAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        
        DWDChooseAlbumModel *album = [[DWDChooseAlbumModel alloc] init];
        album.name = @"三年(1)班";
        cell.albums = album;
        return cell;
    }else{
        DWDChooseAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        cell.albums = self.members[indexPath.row];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
