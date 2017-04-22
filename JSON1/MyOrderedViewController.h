//
//  MyOrderedViewController.h
//  JSON1
//
//  Created by 葛永晖 on 2017/4/20.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderedViewController : UINavigationController<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic) NSArray *listData5;
@property(strong,nonatomic)UITableView *tableView5;
@property(strong,nonatomic)UITableViewCell *tableViewCell5;
@end
