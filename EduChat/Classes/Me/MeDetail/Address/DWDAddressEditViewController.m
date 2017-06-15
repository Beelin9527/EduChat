//
//  DWDAddressEditViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDAddressEditViewController.h"

#import "DWDAreaEntity.h"

@interface DWDAddressEditViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *address;
@property (weak, nonatomic) IBOutlet UILabel *districtCode;
@property (weak, nonatomic) IBOutlet UITextField *postCode;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *arrProvinces;
@property (strong, nonatomic) NSArray *arrCitys;
@property (strong, nonatomic) NSArray *arrAreas;

@end

@implementation DWDAddressEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    _name.text = self.entity.name;
    _address.text = self.entity.address;
    _districtCode.text = self.entity.districtCode;
    _postCode.text = self.entity.postCode;
   
    [self showPickerView];
    
   
}

- (void)dealloc
{
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
}

#pragma mark - pickerView
// add pickerView
- (void)showPickerView
{
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, DWDScreenH-216, DWDScreenW, 216)];
    pickerView.backgroundColor = [UIColor whiteColor];
    _pickerView = pickerView;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.hidden = YES;
     pickerView.showsSelectionIndicator=YES;
    [[UIApplication sharedApplication].keyWindow addSubview:pickerView];
    
    
    [self requestAreaDataParams:@{@"districtCode":@"000000",@"subdistrict":@3}];
}

// pickerView dataSour
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component==0) {
        
        return self.arrProvinces.count;
        
    }else if (component==1) {
        
        return self.arrCitys.count;
        
    }else{
        
        return self.arrAreas.count;
    }

}
//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0) {
        
       DWDAreaEntity *entity = [self.arrProvinces objectAtIndex:row];
        return entity.name;
        
    }else if (component==1) {
        
        DWDAreaEntity *entity = [self.arrCitys objectAtIndex:row];
        return entity.name;
        
    }else{
      
        DWDAreaEntity *entity = [self.arrAreas objectAtIndex:row];
        return entity.name;
    }
     
}
// pickerView delagete
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return DWDScreenW/3;
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    if (component == 0) {
        
        DWDAreaEntity *entity = [self.arrProvinces objectAtIndex:row];
        _arrCitys = [DWDAreaEntity initWithArray:entity.districtList];
        
        
    }else if (component == 1){
        
        DWDAreaEntity *entity = [self.arrCitys objectAtIndex:row];
        _arrAreas = [DWDAreaEntity initWithArray:entity.districtList];
        
    }
    
    [self.pickerView reloadAllComponents];
}


#pragma mark - Table view data source



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:i forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        self.pickerView.hidden = NO;
    }
}


#pragma mark - request
// request area data
- (void)requestAreaDataParams:(NSDictionary *)params
{
    __weak DWDAddressEditViewController *weakSelf = self;
    [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
         NSArray *arrProVinces = responseObject[DWDApiDataKey][@"districtList"];
        
        weakSelf.arrProvinces = [DWDAreaEntity initWithArray:arrProVinces];

        [weakSelf.pickerView reloadAllComponents];
       
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
    }];

}

@end
