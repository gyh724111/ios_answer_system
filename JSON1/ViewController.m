//
//  ViewController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/11.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "ViewController.h"
#import "JsonArrayController.h"
#import "RPViewController.h"
#import "MyOrderViewController.h"
#import "MyOrderedViewController.h"
#import <sqlite3.h>

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()
{
    sqlite3 *db;
    char *error;
}


@property (nonatomic,strong)UIButton *btn_to_TCSearch;
@property (nonatomic,strong)UIButton *btn_to_RPSearch;
@property (nonatomic,strong)UIButton *btn_to_MOsSearch;
@property (nonatomic,strong)UIButton *btn_to_MOedSearch;

@end
int guideUsertype;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //读usertype
    NSArray *documentsPaths8=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath8=[[documentsPaths8 objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    //打开数据库
    if (sqlite3_open([databaseFilePath8 UTF8String], &db)==SQLITE_OK) {
        NSLog(@"sqlite db is opened.");
    }
    else{ return;}//打开不成功就返回
    const char *selectSql="select User_type from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"select user_type operation is ok.");
    }
    else
    {
        NSLog(@"error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        //int _id=sqlite3_column_int(statement, 0);
        int usertype=sqlite3_column_int(statement, 0);
        guideUsertype=usertype;
        NSLog(@"数据库读取usertype为%d",guideUsertype);
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,100,kScreenWidth,20)];
    [titleLabel setText:@"导航界面"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];

    
    _btn_to_TCSearch = [[UIButton alloc] initWithFrame:CGRectMake(100,200,(kScreenWidth - 100 * 2),30)];
    _btn_to_TCSearch.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];;
    
    _btn_to_TCSearch.font = [UIFont systemFontOfSize:18];
    [_btn_to_TCSearch setTitle:@"坐班答疑查询" forState:nil];
    [_btn_to_TCSearch setTitleColor:[UIColor blackColor] forState:nil];
    [_btn_to_TCSearch addTarget:self action:@selector(click_btn_to_TCSearch:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_to_TCSearch];
    
    
    
    _btn_to_RPSearch = [[UIButton alloc] initWithFrame:CGRectMake(100,250,(kScreenWidth - 100 * 2),30)];
    _btn_to_RPSearch.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];;
    
    _btn_to_RPSearch.font = [UIFont systemFontOfSize:18];
    [_btn_to_RPSearch setTitle:@"联系方式查询" forState:nil];
    [_btn_to_RPSearch setTitleColor:[UIColor blackColor] forState:nil];
    [_btn_to_RPSearch addTarget:self action:@selector(click_btn_to_RPSearch:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_to_RPSearch];
    
    _btn_to_MOsSearch = [[UIButton alloc] initWithFrame:CGRectMake(100,300,(kScreenWidth - 100 * 2),30)];
    _btn_to_MOsSearch.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];;
    
    _btn_to_MOsSearch.font = [UIFont systemFontOfSize:18];
    [_btn_to_MOsSearch setTitle:@"我预约的答疑" forState:nil];
    [_btn_to_MOsSearch setTitleColor:[UIColor blackColor] forState:nil];
    [_btn_to_MOsSearch addTarget:self action:@selector(click_btn_to_MOsSearch:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_to_MOsSearch];
    
    _btn_to_MOedSearch = [[UIButton alloc] initWithFrame:CGRectMake(100,350,(kScreenWidth - 100 * 2),30)];
    _btn_to_MOedSearch.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];;
    
    _btn_to_MOedSearch.font = [UIFont systemFontOfSize:18];
    [_btn_to_MOedSearch setTitle:@"被预约的答疑" forState:nil];
    [_btn_to_MOedSearch setTitleColor:[UIColor blackColor] forState:nil];
    [_btn_to_MOedSearch addTarget:self action:@selector(click_btn_to_MOedSearch:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn_to_MOedSearch];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)click_btn_to_TCSearch:(id)sender
{
    NSLog(@"guide:跳转坐班答疑查询界面");
    

    
    JsonArrayController *jac = [[JsonArrayController alloc] init];
    self.view.window.rootViewController = jac;
}

- (void)click_btn_to_RPSearch:(id)sender
{
    NSLog(@"guide:跳转联系方式界面");
    RPViewController *RPvc = [[RPViewController alloc] init];
    

    self.view.window.rootViewController = RPvc;
}

- (void)click_btn_to_MOsSearch:(id)sender
{
    if(guideUsertype == 2){
    NSLog(@"guide:跳转我的预约界面");
    MyOrderViewController *moc = [[MyOrderViewController alloc] init];
    self.view.window.rootViewController = moc;
    }else{
        NSLog(@"guide:不跳转我的预约界面");
        UIAlertView *alertViewresult = [[UIAlertView alloc] initWithTitle:@"登录结果"
                                                                  message:@"您是教师，无该模块权限"
                                                                 delegate:self
                                                        cancelButtonTitle:@"ok"
                                        otherButtonTitles:@"确定", nil];
        // 显示弹出框
        [alertViewresult show];
    }
}

- (void)click_btn_to_MOedSearch:(id)sender
{
    if(guideUsertype == 2){
        NSLog(@"guide:不跳转我被预约界面");
        UIAlertView *alertViewresult = [[UIAlertView alloc] initWithTitle:@"登录结果"
                                                                  message:@"您是学生，无该模块权限"
                                                                 delegate:self
                                                        cancelButtonTitle:@"ok"
                                                        otherButtonTitles:@"确定", nil];
        // 显示弹出框
        [alertViewresult show];

    }else{
    NSLog(@"guide:跳转我被预约界面");
    
    MyOrderedViewController *moedc = [[MyOrderedViewController alloc] init];
    self.view.window.rootViewController = moedc;
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 此处根据buttonIndex参数获取当前点击的是哪一个按钮，处理相应的逻辑。
}

@end
