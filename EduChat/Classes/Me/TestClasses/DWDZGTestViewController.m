//
//  DWDZGTestViewController.m
//  EduChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDZGTestViewController.h"
#import "DWDVideoRecordView.h"
#import "DWDVideoPlayView.h"
#import "DWDZGVideoPlayView.h"

@interface DWDZGTestViewController () <UITableViewDataSource,UITableViewDelegate>

{
    UITableView *_tableView;
}

@property (nonatomic, strong) DWDVideoRecordView *videoRecordView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation DWDZGTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSubviews];
}

- (void)setSubviews
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"视频" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 250;
    [self.view addSubview:_tableView];
}

- (void)rightAction:(UIButton *)sender
{
    [self.videoRecordView showVideoRecordViewWithCompletionHandler:^(NSString *fileName, UIImage *thumbImage) {
        
        DWDZGVideoPlayView *playView = [[DWDZGVideoPlayView alloc] initWithFrame:CGRectMake(60, 100, DWDScreenW - 120, (DWDScreenW - 120) * 3/4)];
        playView.videoNameStr = fileName;
        [self.view addSubview:playView];
    }];

}

- (void)sendVideo:(NSURL *)url
{
//    [_dataArray insertObject:url atIndex:0];
//    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    DWDVideoPlayView *playView = [[DWDVideoPlayView alloc] initWithFrame:CGRectMake(DWDScreenW/2 - 150, 10, 300, 250)];
    playView.videoUrl = url;
    [self.view addSubview:playView];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    if ([self.dataArray[indexPath.row] isKindOfClass:[NSString class]]) {
        cell.textLabel.text = _dataArray[indexPath.row];
    }else {
        DWDVideoPlayView *playView = [[DWDVideoPlayView alloc] initWithFrame:CGRectMake(DWDScreenW/2 - 150, 0, 300, 250)];
        playView.videoUrl = self.dataArray[indexPath.row];
        [cell addSubview:playView];
    }
    
    return cell;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
        [_dataArray addObject:@"=======1"];
        [_dataArray addObject:@"=======2"];
        [_dataArray addObject:@"=======3"];
        [_dataArray addObject:@"=======4"];
        [_dataArray addObject:@"=======5"];
    }
    return _dataArray;
}

- (DWDVideoRecordView *)videoRecordView
{
    if (!_videoRecordView) {
        _videoRecordView = [[DWDVideoRecordView alloc] init];
        [_videoRecordView setDissmisBlock:^{
        }];
        [self.view addSubview:_videoRecordView];
    }
    return _videoRecordView;
}

@end
