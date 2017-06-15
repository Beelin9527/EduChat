//
//  DWDContactsInviteViewController.m
//  EduChat
//
//  Created by KKK on 16/11/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDContactsInviteViewController.h"
#import "DWDContactsInviteSearchResultTableViewController.h"

#import "DWDContactsInviteCell.h"
#import "DWDContactInviteModel.h"

#import "DWDPUCLoadingView.h"

#import <MBProgressHUD.h>
#import <YYModel.h>
#import <SDVersion.h>

@import AddressBook;
@import Contacts;


@interface DWDContactsInviteViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, DWDContactsInviteCellDelegate, DWDContactsInviteSearchResultTableViewControllerDelegate, DWDPUCLoadingViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) DWDContactsInviteSearchResultTableViewController *resultController;

@property (nonatomic, weak) DWDPUCLoadingView *loadingView;

@property (nonatomic, strong) NSArray <DWDContactInviteModel *>*contactsArray;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@end

@implementation DWDContactsInviteViewController


static NSString *cellId = @"cellId";


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"邀请朋友";
    
    UITableView *view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    view.dataSource = self;
    view.delegate = self;
    view.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:view];
    _tableView = view;
    
    self.tableView.backgroundColor = DWDColorBackgroud;
    [self.tableView registerClass:[DWDContactsInviteCell class] forCellReuseIdentifier:cellId];
    
//    //create search controller
//    DWDContactsInviteSearchResultTableViewController *resultVc = [[DWDContactsInviteSearchResultTableViewController alloc] init];
//    _resultController = resultVc;
//    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:resultVc];
//    self.tableView.tableHeaderView = searchController.searchBar;
//    
//    searchController.searchResultsUpdater = resultVc;
//    searchController.dimsBackgroundDuringPresentation = NO; // default is YES
//    [searchController.searchBar sizeToFit];
//    self.definesPresentationContext = YES;
//    _searchController = searchController;
    
    _resultController = [[DWDContactsInviteSearchResultTableViewController alloc] init];
    _resultController.controllerDelegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultController];
    [_searchController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
//    self.resultController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    self.searchController.searchBar.placeholder = @"搜索";
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.extendedLayoutIncludesOpaqueBars = YES;
//    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    
    [self requestDisplayArray];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

#pragma mark - Event Response


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDContactsInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell setDataWithModel:_contactsArray[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - DWDContactsInviteSearchResultTableViewControllerDelegate
- (void)contactsInviteSearchResultControllerDidScrollTableView:(DWDContactsInviteSearchResultTableViewController *)vc {
    [self.searchController.searchBar resignFirstResponder];
}

- (void)contactsInviteSearchResultController:(DWDContactsInviteSearchResultTableViewController *)vc didInvited:(DWDContactInviteModel *)model {
    NSUInteger index = [_contactsArray indexOfObject:model];
    if (index != NSNotFound) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

#pragma mark - DWDPUCLoadingViewDelegate
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self requestDisplayArray];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    DWDLog(@"updateSearchController:%@", searchController.searchBar.text);
    NSArray *resultArray;
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchController.searchBar.text];
    if (searchController.searchBar.text.length > 0) {
        resultArray = [[_contactsArray filteredArrayUsingPredicate:searchPredicate] copy];
    }
    
    [self.resultController reloadResultArray:resultArray];
}

#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - DWDContactsInviteCellDelegate
- (void)inviteCell:(DWDContactsInviteCell *)cell didClickInviteButtonWithModel:(DWDContactInviteModel *)model {
    [self requestInvitationWithModel:model];
}

#pragma mark - Private Method
- (void)requestDisplayArray {
    //本地拿到数据
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
        DWDPUCLoadingView *loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 271 * 0.5) * 0.5, 310 * 0.5, 271 * 0.5 + 100}];;
        loadingView.delegate = self;
        [self.view insertSubview:loadingView aboveSubview:self.tableView];
        loadingView.layer.zPosition = MAXFLOAT;
        _loadingView = loadingView;
    
    WEAKSELF;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *originArray = [self allAvailableContactsArray];
        
        /******** test code *********/
        //        NSMutableArray *ar = [NSMutableArray array];
        //        for (int i = 0; i < 300; i ++) {
        //            @autoreleasepool {
        //                [ar addObjectsFromArray:[originArray copy]];
        //            }
        //        }
        //        originArray = ar;
        /******** test code ********/
        
        if (originArray.count) {
            //发送到后端
            NSDictionary *params = @{
                                     @"cid" : [DWDCustInfo shared].custId,
                                     @"type" : @1,
                                     @"phoneBook" : [originArray yy_modelToJSONObject],
                                     };
            [[DWDWebManager sharedManager] postInviteContactsListWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
                
                NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[responseObject[@"data"] count]];
                [(NSArray *)responseObject[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DWDContactInviteModel *model = [DWDContactInviteModel new];
                    model.name = obj[@"name"];
                    //                model.mobile = [NSArray yy_modelWithJSON:obj[@"mobile"]];
                    model.mobile = (NSArray *)obj[@"mobile"];
                    model.image = [weakSelf headImageWithId:obj[@"identifier"]];
                    [resultArray addObject:model];
                }];
                weakSelf.contactsArray = resultArray;
                //回调数据展示
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                [hud hide:YES];
                    if (weakSelf.contactsArray.count) {
                        [weakSelf.loadingView removeFromSuperview];
                        weakSelf.loadingView = nil;
                        [weakSelf.tableView reloadData];
                    } else {
                        [weakSelf.loadingView.descriptionLabel setText:@"暂无邀请的好友"];
                        [weakSelf.loadingView changeToBlankView];
                    }
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                hud.labelText = @"加载失败";
                    //                hud.mode = MBProgressHUDModeText;
                    //                [hud hide:YES afterDelay:1.5f];
                    [weakSelf.loadingView changeToFailedView];
                    [weakSelf.tableView reloadData];
                    DWDLog(@"\nAPI:%@\nError:%@\n", task.currentRequest.URL, error);
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView.descriptionLabel setText:@"暂无邀请的好友"];
                [self.loadingView changeToBlankView];
            });
        }
    });
}

- (void)requestInvitationWithModel:(DWDContactInviteModel *)model {
    WEAKSELF;
    NSDictionary *params = @{
                             @"cid" : [DWDCustInfo shared].custId,
                             @"phoneBook" : @[[model yy_modelToJSONObject]],
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在邀请";
    [[DWDWebManager sharedManager] postContactInviteWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSUInteger index = [_contactsArray indexOfObject:model];
        model.invited = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            hud.labelText = @"邀请发送成功";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1.5f];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"邀请发送失败";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1.5f];
        });
    }];
}


#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}
@end

@implementation DWDContactsInviteViewController (dwd_contactsCategory)
- (NSArray *)allAvailableContactsArray {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    
    if (iOSVersionLessThan(@"9.0")) {
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                                   numberOfPeople,
                                                                   people);
        CFArraySortValues(peopleMutable,
                          CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          (void *)kABPersonSortByLastName);
        CFRelease(people);
        
        for (int personCount = 0; personCount < numberOfPeople; personCount ++) {
            DWDContactInviteModel *model = [DWDContactInviteModel new];
            ABRecordRef person = CFArrayGetValueAtIndex(peopleMutable, personCount);
            int32_t identifier = ABRecordGetRecordID(person);
            model.identifier = [NSString stringWithFormat:@"%d", identifier];
            NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
            model.name = name;
            //            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSMutableArray<NSString *> *phoneNumberArray = [NSMutableArray array];
            ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (int phoneCount = 0; phoneCount < ABMultiValueGetCount(phone); phoneCount ++) {
                NSString *phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, phoneCount);
                [phoneNumberArray addObject:phoneNumber];
            }
            if (phoneNumberArray.count)
                model.mobile = phoneNumberArray;
            else
                continue;
//            [model setImage:[self headImageWithId:model.identifier]];
            model.invited = NO;
            [resultArray addObject:model];
        }
    } else {
        CNContactStore *store = [[CNContactStore alloc] init];
        NSArray <id<CNKeyDescriptor>>*keyDescriptor = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName], CNContactPhoneNumbersKey, CNContactIdentifierKey];
        CNContactFetchRequest *contactRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keyDescriptor];
        NSError *error = [NSError new];
        __block NSMutableArray *contactArray = [NSMutableArray array];
        BOOL success = [store enumerateContactsWithFetchRequest:contactRequest error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            [contactArray addObject:contact];
            DWDContactInviteModel *model = [DWDContactInviteModel new];
            model.identifier = contact.identifier;
            static CNContactFormatter *formatter;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                formatter = [[CNContactFormatter alloc] init];
                formatter.style = CNContactFormatterStyleFullName;
            });
            
            model.name = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
            NSMutableArray <NSString *>*phoneNumberArray = [NSMutableArray array];
            if (contact.phoneNumbers.count > 0) {
            for (CNLabeledValue<CNPhoneNumber*>* labeledValue in contact.phoneNumbers) {
                [phoneNumberArray addObject:[[labeledValue value] stringValue]];
            }
            model.mobile = phoneNumberArray;
            model.invited = NO;
//            [model setImage:[self headImageWithId:model.identifier]];
            [resultArray addObject:model];
            }
        }];
//        if (success) {
//            for (CNContact *contact in contactArray) {
//  
//            }
//        } else {
//            return nil;
//        }
        if (!success) {
            return nil;
        }
    }
    return resultArray;
}

- (UIImage *)headImageWithId:(NSString *)identifier {
    UIImage *headImage;
    UIImage *localImage = [self contact_imageWithIdentifier:identifier];
    if (localImage != nil) {
        headImage = localImage;
    } else {
        headImage = nil;
    }
    return headImage;
}

//- (UIImage *)defaultHeadImageWithName:(NSString *)name {
//    UIImage *img;
//    CGFloat scale = [UIScreen mainScreen].scale;
//    CGSize size = CGSizeMake(60, 60);
//    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, UIColorFromRGB(0xe9f0ff).CGColor);
//    CGContextFillRect(context, (CGRect){0, 0, size});
//    NSString *drawChar = [name substringFromIndex:name.length - 1];
//    NSDictionary *textAttr = @{
//                               NSFontAttributeName : [UIFont systemFontOfSize:30],
//                               NSForegroundColorAttributeName : DWDColorMain
//                               };
//    CGSize textSize = [drawChar sizeWithAttributes:textAttr];
//    
//    [drawChar drawInRect:(CGRect){(60 - textSize.width) * 0.5, (60 - textSize.height) * 0.5, textSize}
//          withAttributes:textAttr];
//    img = UIGraphicsGetImageFromCurrentImageContext();
//    
//    return img;
//}

- (UIImage *)contact_imageWithIdentifier:(NSString *)identifier {
    UIImage *img;
    if (iOSVersionLessThan(@"9.0")) {
        static ABAddressBookRef addressBook;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        });
        int32_t intId = [identifier intValue];
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, intId);
        if (ABPersonHasImageData(person)) {
            CFDataRef cData = ABPersonCopyImageData(person);
            NSData *data = (__bridge NSData *)cData;
            img = [UIImage imageWithData:data];
        } else {
            img = nil;
        }
    } else {
        NSError *error = [NSError new];
        CNContact *contact = [[[CNContactStore alloc] init] unifiedContactWithIdentifier:identifier keysToFetch:@[CNContactIdentifierKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] error:&error];
        if ([contact imageDataAvailable]) {
            img = [UIImage imageWithData:[contact thumbnailImageData]];
        } else {
            img = nil;
        }
    }
    return img;
}


@end
