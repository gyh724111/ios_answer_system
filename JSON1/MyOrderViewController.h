//
//  MyOrderViewController.h
//  JSON1
//
//  Created by 葛永晖 on 2017/4/19.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderViewController : UINavigationController<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic) NSArray *listData4;
@property(strong,nonatomic)UITableView *tableView4;
@property(strong,nonatomic)UITableViewCell *tableViewCell4;
@end
