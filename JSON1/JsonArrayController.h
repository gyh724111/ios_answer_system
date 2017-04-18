//
//  JsonArrayController.h
//  JSON1
//
//  Created by 葛永晖 on 2017/4/17.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JsonArrayController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic) NSArray *listData;
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UITableViewCell *tableViewCell;

@end
