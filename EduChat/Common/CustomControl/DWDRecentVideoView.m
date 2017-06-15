//
//  DWDRecentVideoView.m
//  EduChat
//
//  Created by apple on 16/5/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRecentVideoView.h"
#import "DWDRecentVideoCell.h"
#import "DWDVideoPlayView.h"

//NSString *const VIDEO_FOLDER = @"videoFolder";

@interface DWDRecentVideoView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView                   *navBar;
@property (nonatomic, strong) UIView                   *coverView;
@property (nonatomic, strong) UILabel                  *sendLbl;
@property (nonatomic, strong) DWDVideoPlayView         *prePlayView;
@property (nonatomic, strong) UICollectionView         *collectionView;
@property (nonatomic, strong) NSMutableArray           *currentVDs;
@property (nonatomic, strong) NSMutableArray           *recentVDName;
@property (nonatomic, strong) NSURL                    *selectedVD;
@property (nonatomic, strong) NSString                 *selectedVDName;
@property (nonatomic, assign) DWDRecentVideoViewStatus status;

@property (nonatomic, weak) UIButton *editBtn;
@property (nonatomic, weak) UIButton *foldBtn;
@property (nonatomic, weak) UIButton *cancelBtn;


@end

@implementation DWDRecentVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = DWDRGBColor(29, 30, 31);
        [self setSubviews];
    }
    return self;
}

- (void)setSubviews
{
    [self addSubview:self.collectionView];
    [self addSubview:self.navBar];
}

- (UIView *)navBar
{
    if (!_navBar) {
        _navBar                   = [[UIView alloc] init];
        _navBar.frame             = CGRectMake(0, 0, DWDScreenW, 30.0);
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effectView.frame = _navBar.bounds;
        [_navBar addSubview:effectView];

        UIButton *foldBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        foldBtn.frame             = CGRectMake(0, 0, 55.0, 30.0);
        [foldBtn setImage:[UIImage imageNamed:@"msg_small_video_close"] forState:UIControlStateNormal];
        foldBtn.imageEdgeInsets   = UIEdgeInsetsMake(0, -5, 0, 5);
        [foldBtn addTarget:self action:@selector(dismissBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _foldBtn                  = foldBtn;

        UIButton *cancelBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame           = CGRectMake(0, 0, 55.0, 30.0);
        cancelBtn.titleLabel.font = DWDFontContent;
        [cancelBtn setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateNormal];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.hidden          = YES;
        _cancelBtn                = cancelBtn;

        UIButton *editBtn         = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame             = CGRectMake(DWDScreenW - 55.0, 0, 55.0, 30.0);
        editBtn.titleLabel.font   = DWDFontContent;
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [editBtn setTitle:@"完成" forState:UIControlStateSelected];
        [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editBtn setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateSelected];
        [editBtn addTarget:self action:@selector(editBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _editBtn                  = editBtn;

        UILabel *titleLbl         = [[UILabel alloc] init];
        titleLbl.frame            = CGRectMake((DWDScreenW - 80.0) * 0.5, 0, 80.0, 30.0);
        titleLbl.font             = DWDFontContent;
        titleLbl.textAlignment    = NSTextAlignmentCenter;
        titleLbl.textColor        = DWDRGBColor(153, 153, 153);
        titleLbl.text             = @"小视频";
        
        [_navBar addSubview:foldBtn];
        [_navBar addSubview:cancelBtn];
        [_navBar addSubview:editBtn];
        [_navBar addSubview:titleLbl];
    }
    return _navBar;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout             = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection                         = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing                 = 0;
        layout.minimumLineSpacing                      = 0;
        layout.itemSize                                = CGSizeMake(DWDScreenW/3, 80.0);
        layout.sectionInset                            = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        layout.footerReferenceSize                     = CGSizeMake(DWDScreenW, 60.0);

        _collectionView                                = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 30, DWDScreenW, self.h - 30)
                                             collectionViewLayout:layout];
        _collectionView.dataSource                     = self;
        _collectionView.delegate                       = self;
        _collectionView.backgroundColor                = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator   = NO;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[DWDRecentVideoCell class] forCellWithReuseIdentifier:@"cell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footView"];
        _collectionView.layer.masksToBounds            = NO;
        _collectionView.alpha                          = 0;
        
    }
    return _collectionView;
}

- (DWDVideoPlayView *)prePlayView
{
    if (!_prePlayView) {
        _prePlayView = [[DWDVideoPlayView alloc] init];
        _prePlayView.frame = CGRectMake(1, 1, (DWDScreenW - 10.0)/3.0 - 2, 90.0 - 2);
        _prePlayView.layer.cornerRadius  = 8.0;
        _prePlayView.layer.borderWidth   = 1.0;
        _prePlayView.layer.borderColor   = [UIColor whiteColor].CGColor;
        _prePlayView.layer.masksToBounds = YES;
        _prePlayView.forbidVolume = YES;
        
        UIImageView *coverImgV = [[UIImageView alloc] initWithFrame:_prePlayView.bounds];
        coverImgV.contentMode = UIViewContentModeScaleAspectFill;
        coverImgV.tag = 9999;
        [_prePlayView addSubview:coverImgV];
        
        WEAKSELF;
        [_prePlayView setHandleTapBlock:^{
            if (weakSelf.block) {
                
                NSString *thumbPath = [[weakSelf.selectedVD absoluteString] stringByReplacingOccurrencesOfString:@".mp4" withString:@".png"];
                thumbPath           = [thumbPath stringByReplacingOccurrencesOfString:@"file:///" withString:@""];
                UIImage *image      = [UIImage imageWithContentsOfFile:thumbPath];
                
                weakSelf.block(DWDRecentVideoViewHandleTypeSendVideo, weakSelf.selectedVDName, image);
                weakSelf.prePlayView.hidden = YES;
                weakSelf.sendLbl.hidden     = YES;
                weakSelf.cancelBtn.hidden   = YES;
                weakSelf.foldBtn.hidden     = NO;
                weakSelf.editBtn.hidden     = NO;
                weakSelf.coverView.alpha    = 0;
            }
        }];
    }
    return _prePlayView;
}

- (UILabel *)sendLbl
{
    if (!_sendLbl) {
        _sendLbl               = [[UILabel alloc] init];
        _sendLbl.frame         = CGRectMake(0, _prePlayView.h - 20.0, _prePlayView.w, 13.0);
        _sendLbl.font          = [UIFont boldSystemFontOfSize:13.0];
        _sendLbl.textAlignment = NSTextAlignmentCenter;
        _sendLbl.textColor     = [UIColor whiteColor];
        _sendLbl.text          = @"轻触发送";
    }
    return _sendLbl;
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:_collectionView.bounds];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;
        _coverView.userInteractionEnabled = NO;
    }
    return _coverView;
}

- (NSMutableArray *)currentVDs
{
    if (!_currentVDs) {
        _currentVDs = [NSMutableArray arrayWithCapacity:0];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"videoFolder"];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *array = [fm contentsOfDirectoryAtPath:path error:&error];
        DWDLog(@"%@",array);
        
        for (NSString * vd in array) {
            if ([vd hasSuffix:@".mp4"]) {
                NSString *VDPath = [path stringByAppendingPathComponent:vd];
                NSURL *VDURL = [NSURL fileURLWithPath:VDPath];
                [_currentVDs addObject:VDURL];
                if (!_recentVDName) {
                    _recentVDName = [NSMutableArray arrayWithCapacity:0];
                }
                [_recentVDName addObject:vd];
            }
        }
    }
    return _currentVDs;
}


#pragma mark - UICollectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.status == DWDRecentVideoViewStatusEdit) {
        return self.currentVDs.count;
    }
    return self.currentVDs.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DWDRecentVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row < self.currentVDs.count) {
        cell.videoUrl = self.currentVDs[indexPath.row];
        [cell setDeleteBlock:^(NSURL *videoUrl) {
            NSInteger row = [self.currentVDs indexOfObject:videoUrl];
            [self.currentVDs removeObjectAtIndex:row];
            [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
            [self deleteFile:videoUrl];
        }];
    }else {
        cell.isLastCell = YES;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((DWDScreenW - 10.0)/3.0, 90.0);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    DWDLog(@"kind = %@", kind);
    if (kind == UICollectionElementKindSectionFooter){
        
        UICollectionReusableView *footerView = (UICollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footView" forIndexPath:indexPath];
        if ([footerView viewWithTag:998] == nil) {
            UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40.0)];
            footerLbl.textColor = [UIColor grayColor];
            footerLbl.textAlignment = NSTextAlignmentCenter;
            footerLbl.text = @"最近14天拍摄的小视频";
            footerLbl.font = DWDFontContent;
            footerLbl.tag = 998;
            [footerView addSubview:footerLbl];
        }
        reusableview = footerView;
    }
    
    return reusableview;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.currentVDs.count) {
        
        [self dismissRecentVideo];
        
    }else {
        
        if (self.status == DWDRecentVideoViewStatusEdit) {
            return;
        }
        self.status = DWDRecentVideoViewStatusSend;
        
        DWDRecentVideoCell *cell = (DWDRecentVideoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *coverImgV = [self.prePlayView viewWithTag:9999];
        coverImgV.image = cell.thumbImageV.image;
        
        self.selectedVD = self.currentVDs[indexPath.row];
        self.selectedVDName = self.recentVDName[indexPath.row];
        self.prePlayView.videoUrl = self.selectedVD;
        
        self.prePlayView.hidden = NO;
        self.sendLbl.hidden = NO;
        
        CGRect newRect = [self.collectionView convertRect:cell.frame toView:self.collectionView];
        self.prePlayView.frame = CGRectMake(newRect.origin.x + 1, newRect.origin.y + 1, newRect.size.width - 2, newRect.size.height - 2);
        
        [self.collectionView addSubview:self.coverView];
        [self.collectionView addSubview:self.prePlayView];
        [self.prePlayView addSubview:self.sendLbl];
        [cell thumbImgVScaleAnimate];
        self.cancelBtn.hidden = NO;
        self.foldBtn.hidden = YES;
        self.editBtn.hidden = YES;
        
        self.prePlayView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _prePlayView.transform = CGAffineTransformIdentity;
            _coverView.alpha = 0.5;
        } completion:^(BOOL finished) {
            [self.prePlayView play];
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.status == DWDRecentVideoViewStatusSend) {
        self.status             = DWDRecentVideoViewStatusNomal;
        self.prePlayView.hidden = YES;
        self.sendLbl.hidden     = YES;
        self.cancelBtn.hidden   = YES;
        self.foldBtn.hidden     = NO;
        self.editBtn.hidden     = NO;
        self.coverView.alpha    = 0;
        [self.prePlayView performSelector:@selector(stop) withObject:nil afterDelay:0.05 inModes:@[NSDefaultRunLoopMode]];
    }
}

#pragma mark - 显示视频列表
- (void)showRecentVideo
{
    _collectionView.transform = CGAffineTransformMakeScale(2, 2);
    [UIView animateWithDuration:0.3 animations:^{
        _collectionView.alpha = 1.0;
        _collectionView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissRecentVideo
{
    [UIView animateWithDuration:0.3 animations:^{
        _collectionView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        _collectionView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1;
        if (self.block) {
            self.block(DWDRecentVideoViewHandleTypeTransfrom, nil, nil);
        }
    }];
}

#pragma mark - 导航条按钮事件
- (void)dismissBtnAction:(UIButton *)sender
{
    if (sender.selected) {
        sender.selected = !sender.selected;
        [sender setImage:[UIImage imageNamed:@"msg_small_video_close"] forState:UIControlStateNormal];
    }else {
        if (self.block) {
            self.block(DWDRecentVideoViewHandleTypeDismiss, nil, nil);
        }
    }
}

- (void)editBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
    if (sender.selected) {
        self.foldBtn.hidden = YES;
        self.status = DWDRecentVideoViewStatusEdit;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_EDITRECENTVIDEO object:nil];
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentVDs.count inSection:0]]];
    }else {
        self.foldBtn.hidden = NO;
        self.status = DWDRecentVideoViewStatusNomal;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CANCELEDITRECENTVIDEO object:nil];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentVDs.count inSection:0]]];
    }
}

- (void)cancelBtnAction:(UIButton *)sender
{
    sender.hidden           = YES;
    self.foldBtn.hidden     = NO;
    self.editBtn.hidden     = NO;
    self.prePlayView.hidden = YES;
    self.sendLbl.hidden     = YES;
    self.coverView.alpha    = 0;
    [self.prePlayView stop];
}

- (BOOL)deleteFile:(NSURL *)fileURL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isSuccess = [fm removeItemAtURL:fileURL error:nil];
    return isSuccess;
}

@end
