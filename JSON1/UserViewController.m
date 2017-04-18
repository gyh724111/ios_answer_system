//
//  UserViewController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/11.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "UserViewController.h"
#import "ViewController.h"
#import <sqlite3.h>
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface UserViewController ()<NSURLConnectionDataDelegate>
{
    NSMutableData *receiveData_;
    sqlite3 *db;
    char *error;
    
}

@property (nonatomic,strong)UILabel *useridLabel;
@property (nonatomic,strong)UITextField *useridTextField;
@property (nonatomic,strong)UILabel *passwordLabel;
@property (nonatomic,strong)UITextField *passwordTextField;

@end

//static NSString *IP;
NSString *Server_ipfinal;

@implementation UserViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,100,kScreenWidth,20)];
    [titleLabel setText:@"教师坐班答疑查询系统"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] init];  // 创建imageView对象
    imageView.frame = CGRectMake(70, 140, kScreenWidth - 70*2, 120);  // 设置imageView的尺寸
//    imageView.center = self.view.center;  // 让图片在中间位置显示
    imageView.image = [UIImage imageNamed:@"SMU.png"];  // 加载图片
    [self.view addSubview:imageView];  // 显示图片
    

    _useridLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,280,(kScreenWidth - 100 * 2)/3,30)];
    _useridLabel.backgroundColor = [UIColor clearColor];
    _useridLabel.textAlignment = NSTextAlignmentLeft;
    _useridLabel.font = [UIFont systemFontOfSize:12];
    _useridLabel.textColor = [UIColor blackColor];
    [_useridLabel setText:@"学/工号："];
    [self.view addSubview:_useridLabel];

    _useridTextField = [[UITextField alloc] initWithFrame:CGRectMake(100 + (kScreenWidth - 100 * 2)/3,280,2*(kScreenWidth - 100 * 2)/3,30)];
    _useridTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _useridTextField.textAlignment = NSTextAlignmentLeft;
    _useridTextField.font = [UIFont systemFontOfSize:12];
    _useridTextField.textColor = [UIColor blackColor];
    _useridTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_useridTextField];
    
    _passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,330,(kScreenWidth - 100 * 2)/3,30)];
    _passwordLabel.backgroundColor = [UIColor clearColor];
    _passwordLabel.textAlignment = NSTextAlignmentLeft;
    _passwordLabel.font = [UIFont systemFontOfSize:12];
    _passwordLabel.textColor = [UIColor blackColor];
    [_passwordLabel setText:@"密码："];
    [self.view addSubview:_passwordLabel];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(100 + (kScreenWidth - 100 * 2)/3,330,2*(kScreenWidth - 100 * 2)/3,30)];
    _passwordTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _passwordTextField.textAlignment = NSTextAlignmentLeft;
    _passwordTextField.font = [UIFont systemFontOfSize:12];
    _passwordTextField.textColor = [UIColor blackColor];
    [self.view addSubview:_passwordTextField];
    

    
    UIButton *setLoginInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 380, kScreenWidth - 100 * 2, 30)];
    setLoginInfoButton.backgroundColor = [UIColor redColor];
    [setLoginInfoButton setTitle:@"登录" forState:UIControlStateNormal];
    [setLoginInfoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [setLoginInfoButton addTarget:self action:@selector(loginRequest:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setLoginInfoButton];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"绑定IP"
                message:@"请输入同一局域网服务器的IP地址"
                delegate:self
                cancelButtonTitle:@"取消"
                otherButtonTitles:@"绑定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    // 显示弹出框
    [alertView show];
  
}

- (void)loginRequest:(id)sender
{
 
    NSString *userid = [_useridTextField text];
    NSString *password = [_passwordTextField text];
    //数据库读IP
    const char *selectSql="select SERVER_IP from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"select operation is ok.");
    }
    else
    {
        NSLog(@"error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        //int _id=sqlite3_column_int(statement, 0);
        char *Server_ip=(char*)sqlite3_column_text(statement, 0);
        Server_ipfinal=[NSString stringWithCString:Server_ip encoding:NSUTF8StringEncoding];
        NSLog(@"数据库读取ip为%@",Server_ipfinal);
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    NSString *url = [NSString stringWithFormat:@"http://%@/answer_system/LoginApi.php?user_id=%@&password=%@&user_type=2",Server_ipfinal,userid,password];
    NSURL *newurl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:newurl];
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"loginURL:%@",newurl);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"%@",response);
}


//多次调用 分批次调用 多次调用完成之后调用didfinishloading
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if (receiveData_ ==nil){
        receiveData_ = [[NSMutableData alloc] init];
    }
    
    [receiveData_ appendData:data];
    //NSLog(@"%@",data);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"请求完成");
    
    id obj = [NSJSONSerialization JSONObjectWithData:receiveData_ options:0 error:nil];
    
    if([obj isKindOfClass:[NSDictionary class]]){
        id LoginInfo = [(NSDictionary *)obj objectForKey:@"0"];
        
        NSNumber *loginStat = [(NSDictionary *)LoginInfo objectForKey:@"stat"];
        NSString *StringStat = [NSString stringWithFormat:@"%@",loginStat];
        //[_loginStatView setupKey:@"状态" value:StringStat];
        NSLog(@"loginStat=%@",loginStat);
        NSLog(@"StringStat=%@",StringStat);
        NSString *loginFinal = [(NSDictionary *)LoginInfo objectForKey:@"final"];
        //[_loginFinalView setupKey:@"结果" value:loginFinal];
        NSLog(@"%@",loginFinal);
        
        NSString *loginUsername = [(NSDictionary *)LoginInfo objectForKey:@"username"];
        //[_loginUsernameView setupKey:@"姓名" value:loginUsername];
        NSLog(@"%@",loginUsername);
        
        UIAlertView *alertViewresult = [[UIAlertView alloc] initWithTitle:@"登录结果"
                                message:loginFinal
                                delegate:self
                                cancelButtonTitle:@"取消"
                                otherButtonTitles:@"确定", nil];
        // 显示弹出框
        [alertViewresult show];
        if ([StringStat isEqualToString:@"0"]){
        ViewController *vc = [[ViewController alloc] init];
        self.view.window.rootViewController = vc;
        }
    }
    NSLog(@"%@",obj);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    NSString *inputip = [[alertView textFieldAtIndex:inputip] text];
    
    //NSString *gServer_IP = @"http://";
    
    if ([btnTitle isEqualToString:@"绑定"]) {
                 NSLog(@"你点击了绑定ip按钮");
        NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
        NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
        //上面两句已经比较熟悉了吧！
        //打开数据库
        if (sqlite3_open([databaseFilePath UTF8String], &db)==SQLITE_OK) {
            NSLog(@"sqlite db is opened.");
        }
        else{ return;}//打开不成功就返回
        //删表answer_system
        
        const char *deleteSql = "DROP TABLE `answer_system`";
        if (sqlite3_exec(db, deleteSql, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"drop table is ok.");
        }
        else
        {
            NSLog(@"error: %s",error);
            sqlite3_free(error);//每次使用完毕清空error字符串，提供给下一次使用
        }
        //建表answer_system
        

        const char *createSql = "CREATE TABLE `answer_system` ( `SERVER_IP` CHAR(15) , `User_id` INT(12), `Username` CHAR(20), `User_type` INT(2), `wait_answer_id` INT(10))";
        if (sqlite3_exec(db, createSql, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"create table is ok.");
        }
        else
        {
            NSLog(@"error: %s",error);
            sqlite3_free(error);//每次使用完毕清空error字符串，提供给下一次使用
        }
        //插入数据
        NSString *insertSql=@"insert into answer_system (SERVER_IP) values(";
        insertSql = [insertSql stringByAppendingString:[NSString stringWithFormat:@"'%@')",inputip]];
        NSLog(@"insert sql:%@",insertSql);
        const char *insertSql2 = [insertSql UTF8String];
        
        NSLog(@"insert sql2:%s",insertSql2);
        if (sqlite3_exec(db, insertSql2, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"insert operation is ok.%@",insertSql);
        }else
        {
            NSLog(@"error: %s",error);
            sqlite3_free(error);//每次使用完毕清空error字符串，提供给下一次使用
        }


        }
    }

@end
