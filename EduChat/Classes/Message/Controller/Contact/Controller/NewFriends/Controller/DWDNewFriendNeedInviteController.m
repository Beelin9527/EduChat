//
//  DWDNewFriendNeedInviteController.m
//  EduChat
//
//  Created by Superman on 15/12/16.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNewFriendNeedInviteController.h"

#import "DWDContactCell.h"

#import "DWDAddressBookPeopleModel.h"
#import "DWDFriendVerifyClient.h"
#import "DWDAddressBookResultModel.h"

#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <YYModel.h>
@interface DWDNewFriendNeedInviteController () <DWDContactCellDelegate,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic , strong) NSMutableArray *addressBookDatas;
@property (nonatomic , strong) NSMutableArray *addressBookModels;
@property (strong, nonatomic) NSMutableArray *dataSource;
@end

@implementation DWDNewFriendNeedInviteController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"邀请朋友";
   
    [self.view addSubview:self.tableView];
    
    [self getAuthorization];
    [self loadAddressBookData];
}

#pragma makr - Getter
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)addressBookDatas{
    if (!_addressBookDatas) {
        _addressBookDatas = [NSMutableArray array];
    }
    return _addressBookDatas;
}

- (NSMutableArray *)addressBookModels{
    if (!_addressBookModels) {
        _addressBookModels = [NSMutableArray array];
    }
    return _addressBookModels;
}
#pragma mark - Helper Method
- (void)getAuthorization{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        if (err){
            DWDLog(@"%@==========", err);
            return;
        }
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error){
                DWDLog(@"%@",error);
                return;
            }
            if (granted) {
                DWDLog(@"授权成功");
                [self loadAddressBookData];
            }else{
                DWDLog(@"授权失败");
            }
        });
    }
}

- (void)loadAddressBookData{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusAuthorized) {
        CFErrorRef err;
        ABAddressBookRef addressbook = ABAddressBookCreateWithOptions(NULL, &err);
        if (err) {
            DWDLog(@"获取addressbook失败");
            return;
        }
        CFArrayRef peopleArray = ABAddressBookCopyArrayOfAllPeople(addressbook);
        
        CFIndex peopleCount = CFArrayGetCount(peopleArray);
        for (CFIndex i = 0; i < peopleCount; i ++) {
            ABRecordRef people = CFArrayGetValueAtIndex(peopleArray, i);
            
            //读取firstname
            NSString *personName = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNameProperty);
            //读取lastname
            NSString *lastname = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNameProperty);
            //读取middlename
            NSString *middlename = (__bridge NSString*)ABRecordCopyValue(people, kABPersonMiddleNameProperty);
            //读取prefix前缀
            NSString *prefix = (__bridge NSString*)ABRecordCopyValue(people, kABPersonPrefixProperty);
            //读取suffix后缀
            NSString *suffix = (__bridge NSString*)ABRecordCopyValue(people, kABPersonSuffixProperty);
            //读取nickname呢称
            NSString *nickname = (__bridge NSString*)ABRecordCopyValue(people, kABPersonNicknameProperty);
            //读取firstname拼音音标
            NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(people, kABPersonFirstNamePhoneticProperty);
            //读取lastname拼音音标
            NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(people, kABPersonLastNamePhoneticProperty);
            //读取middlename拼音音标
            NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(people, kABPersonMiddleNamePhoneticProperty);
            //读取organization公司
            NSString *organization = (__bridge NSString*)ABRecordCopyValue(people, kABPersonOrganizationProperty);
            //读取jobtitle工作
            NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(people, kABPersonJobTitleProperty);
            //读取department部门
            NSString *department = (__bridge NSString*)ABRecordCopyValue(people, kABPersonDepartmentProperty);
            //读取birthday生日
            //NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(people, kABPersonBirthdayProperty);
            //读取note备忘录
            NSString *note = (__bridge NSString*)ABRecordCopyValue(people, kABPersonNoteProperty);
            //第一次添加该条记录的时间
            NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(people, kABPersonCreationDateProperty);
            //最后一次修改該条记录的时间
            NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(people, kABPersonModificationDateProperty);
            
            //获取email多值
            ABMultiValueRef email = ABRecordCopyValue(people, kABPersonEmailProperty);
            NSString* emailContent;
            CFIndex emailcount = ABMultiValueGetCount(email);
            for (CFIndex x = 0; x < emailcount; x++)
            {
                //获取email Label
                //NSString* emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
                //获取email值
                emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
            }
            
            //读取地址多值
            ABMultiValueRef address = ABRecordCopyValue(people, kABPersonAddressProperty);
            CFIndex count = ABMultiValueGetCount(address);
            
            NSString* country;
            NSString* city;
            NSString* state;
            NSString* street;
            NSString* zip;
            NSString* coutntrycode;
            for(CFIndex j = 0; j < count; j++)
            {
                //获取地址Label
                //NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
                //获取該label下的地址6属性
                NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
                country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
                city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
                state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
                street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
                zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
                coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            }
            
            //获取dates多值
            ABMultiValueRef dates = ABRecordCopyValue(people, kABPersonDateProperty);
            CFIndex datescount = ABMultiValueGetCount(dates);
            NSString* datesContent;
            for (CFIndex y = 0; y < datescount; y++)
            {
                //获取dates Label
                //NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
                //获取dates值
                datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
            }
            
            //获取IM多值
            ABMultiValueRef instantMessage = ABRecordCopyValue(people, kABPersonInstantMessageProperty);
            NSString* username;
            NSString* service;
            for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
            {
                //获取IM Label
                //NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
                //获取該label下的2属性
                NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
                username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
                service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            }
            
            //读取电话多值
            ABMultiValueRef phone = ABRecordCopyValue(people, kABPersonPhoneProperty);
            NSString * personPhone;
            for (int k = 0; k<ABMultiValueGetCount(phone); k++)
            {
                //获取电话Label
                //NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
                //获取該Label下的电话值
                personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            }
            
            //获取URL多值
            ABMultiValueRef url = ABRecordCopyValue(people, kABPersonURLProperty);
            NSString * urlContent;
            for (int m = 0; m < ABMultiValueGetCount(url); m++)
            {
                //获取电话Label
                //NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
                //获取該Label下的电话值
                urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
            }
            
            //读取照片
            //NSData *image = (__bridge NSData*)ABPersonCopyImageData(people);
            
            
            DWDAddressBookPeopleModel *addressBookModel = [[DWDAddressBookPeopleModel alloc] init];
            addressBookModel.personName = personName;
            addressBookModel.lastname = lastname;
            addressBookModel.middlename = middlename;
            addressBookModel.prefix = prefix;
            addressBookModel.suffix = suffix;
            addressBookModel.nickname = nickname;
            addressBookModel.firstnamePhonetic = firstnamePhonetic;
            addressBookModel.lastnamePhonetic = lastnamePhonetic;
            addressBookModel.middlenamePhonetic = middlenamePhonetic;
            addressBookModel.organization = organization;
            addressBookModel.jobtitle = jobtitle;
            addressBookModel.department = department;
            addressBookModel.note = note;
            addressBookModel.firstknow = firstknow;
            addressBookModel.lastknow = lastknow;
            addressBookModel.emailContent = emailContent;
            addressBookModel.country = country;
            addressBookModel.city = city;
            addressBookModel.state = state;
            addressBookModel.street = street;
            addressBookModel.zip = zip;
            addressBookModel.coutntrycode = coutntrycode;
            addressBookModel.datesContent = datesContent;
            addressBookModel.username = username;
            addressBookModel.service = service;
            addressBookModel.mobile = personPhone;
            addressBookModel.urlContent = urlContent;
            
            NSString *jsonStr = [addressBookModel yy_modelToJSONString];
            [self.addressBookDatas addObject:jsonStr];
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:self.addressBookDatas forKey:@"phoneBook"];
        
        __block DWDProgressHUD *hud;
        dispatch_async(dispatch_get_main_queue(), ^{
            hud = [DWDProgressHUD showHUD];
            [hud showText:@"正在加载通讯录数据..."];
        });
        
        [[DWDFriendVerifyClient sharedFriendVerifyClient] postAddressBookAndGetFriendList:[DWDCustInfo shared].custId addressBook:params success:^(NSArray *invites) {
            for (int i = 0; i < invites.count; i++) {
                DWDAddressBookResultModel *result = [DWDAddressBookResultModel yy_modelWithJSON:invites[i]];
                DWDAddressBookPeopleModel *peopleModel = [DWDAddressBookPeopleModel yy_modelWithJSON:self.addressBookDatas[i]];
                if (result.type == 0) {
                    // 3
                    peopleModel.status = (int)DWDContactCellStatusInviting;
                }else if (result.type == 1){
                    // 5
                    peopleModel.status = (int)DWDContactCellStatusAdd;
                }else if (result.type == 2){
                    // 4
                    peopleModel.status = (int)DWDContactCellStatusReject;
                }else if (result.type == 3){
                    // 2
                    peopleModel.status = DWDContactCellStatusInvite;
                    [self.dataSource addObject:peopleModel];
                }
                [self.addressBookModels addObject:peopleModel];
                
            }
//            DWDLog(@"合并数据");
//            [_datas insertObjects:self.addressBookModels atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_datas.count, self.addressBookModels.count)]];
            [self.tableView reloadData];
            [hud hide:YES];
        } failure:^(NSError *error) {
            DWDLog(@"呵呵呵呵呵呵呵");
            [hud hide:YES];
        }];
        
    }else{
        DWDLog(@"你还没授权!去设置里修改");
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    DWDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
     DWDAddressBookPeopleModel *peopleModel = self.dataSource[indexPath.row];
    NSString *name = [NSString stringWithFormat:@"%@%@",peopleModel.lastname,peopleModel.personName];
    if (peopleModel.lastname == NULL) {
        name = [NSString stringWithFormat:@"%@",peopleModel.personName];
    }else if (peopleModel.personName == NULL){
        name = [NSString stringWithFormat:@"%@",peopleModel.lastname];
    }
    cell.nicknameLable.text = name;
    cell.avatarView.image = DWDDefault_MeBoyImage;
    cell.subInfoLable.text = nil;   //data[@"verifyInfo"];
    //        cell.desLabel.text = @"hehehehehe";   //data[@"count"];
    cell.status = peopleModel.status;
    cell.indexPath = indexPath;
    cell.actionDelegate = self;

    return cell;
}


#pragma mark - ContactCell Delegate
- (void)contactCellDidInviteFriend:(DWDContactCell *)cell atIndexPath:(NSIndexPath *)indexPath {
   // [self contactCellDidAddFriend:cell atIndexPath:indexPath];
    
    DWDAddressBookPeopleModel *peopleModel = self.dataSource[indexPath.row];
    NSString *name = peopleModel.mobile;
    
    //实例化MFMessageComposeViewController,并设置委托
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    
    //拼接并设置短信内容
    NSString *messageContent = @"多维度-教育社交平台ontheAppStore  https://itunes.apple.com/app/id1089148311";
    messageController.body = messageContent;
    
    //设置发送给谁
    messageController.recipients = @[name];
    
    //推到发送试图控制器
    [self presentViewController:messageController animated:YES completion:^{
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


#pragma mark - Message Delegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *alertMsg = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            alertMsg = @"短信传送成功";
            break;
        case MessageComposeResultFailed:
            alertMsg = @"短信传送失败";
            break;
        case MessageComposeResultCancelled:
            alertMsg = @"短信传送取消";
            break;
        default:
            break;
    }
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示" message:alertMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alterView show];
}


@end
