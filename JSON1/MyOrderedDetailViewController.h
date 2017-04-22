//
//  MyOrderedDetailViewController.h
//  JSON1
//
//  Created by 葛永晖 on 2017/4/21.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderedDetailViewController : UINavigationController<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic) NSArray *listData6;
@property(strong,nonatomic)UITableView *tableView6;
@property(strong,nonatomic)UITableViewCell *tableViewCell6;

@end
