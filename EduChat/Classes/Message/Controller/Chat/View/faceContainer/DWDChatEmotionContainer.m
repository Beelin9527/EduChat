//
//  DWDChatEmotionContainer.m
//  EduChat
//
//  Created by Superman on 16/10/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatEmotionContainer.h"

#import "DWDChatEmotionDefaultCell.h"
#import "DWDChatEmotionRabbitCell.h"

#import <Masonry.h>

typedef NS_ENUM(NSUInteger,DWDChatEmotionType){
    DWDChatEmotionTypeDefault,
    DWDChatEmotionTypeRabbit
};


@interface DWDChatEmotionContainer () <UICollectionViewDelegate , UICollectionViewDataSource>
@property (nonatomic , strong) UIView *bottomToolBar;
@property (nonatomic , strong) UICollectionView *mainCollectionView;
@property (nonatomic , strong) UICollectionView *bottomCollectionView;
@property (nonatomic , strong) UIButton *sendBtn;

@property (nonatomic , strong) NSArray *faceDatas;
@property (nonatomic , strong) NSArray *menuDatas;

@property (nonatomic , assign) DWDChatEmotionType emotionType;

@property (nonatomic , strong) UICollectionViewFlowLayout *rabbitLayout;
@property (nonatomic , strong) UICollectionViewFlowLayout *defaultLayout;

@end

@implementation DWDChatEmotionContainer

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.bottomToolBar];
        [self addSubview:self.mainCollectionView];
        
        self.emotionType = DWDChatEmotionTypeRabbit;
        
        [self registCells];
        
        [self makeCons];
        
    }
    return self;
}

#pragma mark - <private>
- (void)sendBtnClick:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(sendText)]) {
        [self.delegate sendText];
    }
}

- (void)makeCons{
    [self.mainCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.bottom.equalTo(self.bottomToolBar.top);
    }];
    
    [self.bottomToolBar makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
        make.height.equalTo(@37);
    }];
    
    [self.bottomCollectionView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomToolBar.left);
        make.top.equalTo(self.bottomToolBar.top);
        make.bottom.equalTo(self.bottomToolBar.bottom);
        make.right.equalTo(self.sendBtn.left);
    }];
    
    [self.sendBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomToolBar.top);
        make.right.equalTo(self.bottomToolBar.right);
        make.bottom.equalTo(self.bottomToolBar.bottom);
        make.width.equalTo(@90);
    }];
}

- (void)registCells{
    [self.mainCollectionView registerClass:[DWDChatEmotionDefaultCell class] forCellWithReuseIdentifier:NSStringFromClass([DWDChatEmotionDefaultCell class])];
    [self.mainCollectionView registerClass:[DWDChatEmotionRabbitCell class] forCellWithReuseIdentifier:NSStringFromClass([DWDChatEmotionRabbitCell class])];
    
    [self.bottomCollectionView registerClass:[DWDChatEmotionDefaultCell class] forCellWithReuseIdentifier:NSStringFromClass([DWDChatEmotionDefaultCell class])];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == 1) {  // main
        NSArray *emotionDatas;
        switch (self.emotionType) {
            case DWDChatEmotionTypeDefault:
                emotionDatas = self.faceDatas[0];
                break;
            case DWDChatEmotionTypeRabbit:
                emotionDatas = self.faceDatas[1];
                break;
                
            default:
                break;
        }
        return emotionDatas.count;
        
    }else{
        
        return self.menuDatas.count;
        
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.tag == 1) {  // main
        
        UICollectionViewCell *emotionCell;
        DWDChatEmotionRabbitCell *rabbitCell;
        DWDChatEmotionDefaultCell *defaultCell;
        NSDictionary *dict;
        NSArray *rabbits;
        NSArray *defaults;
        NSString *imageName;
        NSString *titleText;
        
        switch (self.emotionType) {
            case DWDChatEmotionTypeRabbit:
                
                rabbitCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DWDChatEmotionRabbitCell class]) forIndexPath:indexPath];
                
                if (!rabbitCell) {
                    rabbitCell = [[DWDChatEmotionRabbitCell alloc] init];
                }
                
                // cell setting
                rabbits = self.faceDatas[1];
                dict = rabbits[indexPath.row];
                
                imageName = [[dict allKeys] firstObject];
                
                rabbitCell.imageView.image = [UIImage imageNamed:imageName];
                
                titleText = [dict valueForKey:imageName];
                
                [rabbitCell.titleLabel setText:titleText];
                
                emotionCell = rabbitCell;
                
                break;
            case DWDChatEmotionTypeDefault:
                
                defaultCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DWDChatEmotionDefaultCell class]) forIndexPath:indexPath];
                
                if (!defaultCell) {
                    defaultCell = [[DWDChatEmotionDefaultCell alloc] init];
                }
                
                // cell setting
                defaults = self.faceDatas[0];
                
                imageName = defaults[indexPath.row];
                
                defaultCell.imageView.image = [UIImage imageNamed:imageName];
                
                emotionCell = defaultCell;
                
                break;
                
            default:
                break;
        }
        
        return emotionCell;
        
    }else{  // menu
        
        DWDChatEmotionDefaultCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DWDChatEmotionDefaultCell class]) forIndexPath:indexPath];
        if (!cell) {
            cell = [[DWDChatEmotionDefaultCell alloc] init];
        }
        // cell setting
        NSString *imageName = self.menuDatas[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:imageName];
        UIView *view = [UIView new];
        view.backgroundColor = UIColorFromRGB(0xf5f5f5);
        [cell setSelectedBackgroundView:view];
        if (indexPath.row == 0) {
            [cell setSelected:YES];
        }
        return cell;
    }
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1) { // main
        DWDChatEmotionRabbitCell *rabbitCell;
        NSArray *defaultEmotions;
        
        switch (self.emotionType) {
            case DWDChatEmotionTypeRabbit:   // 直接发送图片
                rabbitCell = (DWDChatEmotionRabbitCell *)[collectionView cellForItemAtIndexPath:indexPath];
                if ([self.delegate respondsToSelector:@selector(emotionContainerDidSelectImage:)]) {
                    [self.delegate emotionContainerDidSelectImage:rabbitCell.imageView.image];
                }
                break;
            case DWDChatEmotionTypeDefault:  // 放入输入框
                
                defaultEmotions = self.faceDatas[0];
                
                if ([self.delegate respondsToSelector:@selector(emotionContainerDidSelectDefaultEmotionWithEmotionString:)]) {
                    [self.delegate emotionContainerDidSelectDefaultEmotionWithEmotionString:defaultEmotions[indexPath.row]];
                }
                break;
                
            default:
                break;
        }
        
    }else{ // 切换数据 , 切换cell layout
        if (indexPath.row == 0) {
            self.emotionType = DWDChatEmotionTypeRabbit;
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.mainCollectionView.collectionViewLayout;
            layout.itemSize = CGSizeMake(60, 60);
            layout.minimumLineSpacing = 18;
            layout.minimumInteritemSpacing = 20;
            self.mainCollectionView.contentInset = UIEdgeInsetsMake(6, 27, 7, 27);
            [self.mainCollectionView reloadData];
        }else if (indexPath.row == 1){
            self.emotionType = DWDChatEmotionTypeDefault;
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.mainCollectionView.collectionViewLayout;
            layout.itemSize = CGSizeMake(30, 30);
            layout.minimumLineSpacing = 10;
            layout.minimumInteritemSpacing = 10;
            self.mainCollectionView.contentInset = UIEdgeInsetsMake(23, 21, 23, 21);
            [self.mainCollectionView reloadData];
        }
        
    }
}

#pragma mark - <getters>

- (UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        UICollectionView *mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.rabbitLayout];
        mainCollectionView.pagingEnabled = YES;
        mainCollectionView.dataSource = self;
        mainCollectionView.delegate = self;
        mainCollectionView.tag = 1;
        mainCollectionView.backgroundColor = [UIColor whiteColor];
        mainCollectionView.contentInset = UIEdgeInsetsMake(6, 27, 7, 27);
        _mainCollectionView = mainCollectionView;
    }
    return _mainCollectionView;
}

- (UICollectionView *)bottomCollectionView{
    if (!_bottomCollectionView) {
        UICollectionViewFlowLayout *bottomLayout = [[UICollectionViewFlowLayout alloc] init];
        bottomLayout.itemSize = CGSizeMake(30, 30);
        bottomLayout.minimumInteritemSpacing = 10;
        bottomLayout.minimumLineSpacing = 10;
        bottomLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *bottomToolCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:bottomLayout];
        bottomToolCollectionView.dataSource = self;
        bottomToolCollectionView.delegate = self;
        bottomToolCollectionView.tag = 2;
        bottomToolCollectionView.backgroundColor = [UIColor whiteColor];
        bottomToolCollectionView.contentInset = UIEdgeInsetsMake(0, 13, 0, 13);
        _bottomCollectionView = bottomToolCollectionView;
    }
    return _bottomCollectionView;
}

- (UIView *)bottomToolBar{
    if (!_bottomToolBar) {
        _bottomToolBar = [[UIView alloc] init];
        [_bottomToolBar addSubview:self.bottomCollectionView];
        [_bottomToolBar addSubview:self.sendBtn];
    }
    return _bottomToolBar;
}

- (UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setBackgroundColor:DWDColorMain];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (NSArray *)faceDatas{
    if (!_faceDatas) {
        _faceDatas = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emotion" ofType:@"plist"]];
    }
    return _faceDatas;
}

- (NSArray *)menuDatas{
    if (!_menuDatas) {
        _menuDatas = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"faceMenu" ofType:@"plist"]];
    }
    return _menuDatas;
}

- (UICollectionViewFlowLayout *)rabbitLayout{
    if (!_rabbitLayout) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(60, 60);
        layout.minimumLineSpacing = 18;
        layout.minimumInteritemSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _rabbitLayout = layout;
    }
    return _rabbitLayout;
}

- (UICollectionViewFlowLayout *)defaultLayout{
    if (!_defaultLayout) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(30, 30);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _defaultLayout = layout;
    }
    return _defaultLayout;
}
@end
