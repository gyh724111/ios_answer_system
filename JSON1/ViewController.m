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

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()

@property (nonatomic,strong)UIButton *btn_to_TCSearch;
@property (nonatomic,strong)UIButton *btn_to_RPSearch;
@property (nonatomic,strong)UIButton *btn_to_MOsSearch;
@property (nonatomic,strong)UIButton *btn_to_MOedSearch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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



@end
