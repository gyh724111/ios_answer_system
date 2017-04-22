//
//  MyOrderedViewController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/20.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "MyOrderedViewController.h"
#import "ViewController.h"
#import "MyOrderedDetailViewController.h"
#import <sqlite3.h>
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height



@interface MyOrderedViewController()<NSURLConnectionDataDelegate>
{
    NSMutableData *receiveData_;
    sqlite3 *db;
    char *error;
}


@end
NSString *Server_ipfinal5;
NSMutableArray *moedidarr;
NSMutableArray *moedwaidarr;
NSMutableArray *moedcoursesarr;
NSMutableArray *moedanswertimearr;
NSMutableArray *moedanswerpositionarr;
NSMutableArray *moedothersarr;
NSMutableArray *moedcountarr;
NSString *moedid;
NSString *MOeduser_id;
NSString *moedstring1;
NSString *moedstring2;

@implementation MyOrderedViewController
@synthesize listData5 =_listData5;
@synthesize tableView5 = _tableView5;
@synthesize tableViewCell5 =_tableViewCell5;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewdidload");
    
    moedstring1 = @"无";
    moedstring2 = @"无";
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *moedbackButton = [[UIButton alloc] initWithFrame:CGRectMake(10,30, 40, 30)];
    moedbackButton.backgroundColor = [UIColor clearColor];
    [moedbackButton setTitle:@"< 返回" forState:UIControlStateNormal];
    [moedbackButton sizeToFit];
    [moedbackButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [moedbackButton addTarget:self action:@selector(backtoguidepage:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moedbackButton];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70,kScreenWidth,20)];
    [titleLabel setText:@"我被预约的答疑"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    
    [self getMOedRequest:self];
    
    self.tableView5 = [[UITableView alloc] initWithFrame:CGRectMake(30,100, kScreenWidth - 60, kScreenHeight - 150) style:UITableViewStylePlain];
    self.tableView5.delegate=self;
    self.tableView5.dataSource=self;
    [self.view addSubview:self.tableView5];
    NSArray *array = [NSArray arrayWithObjects:@"张三",@"张四",@"张五",@"李三",@"李四",@"李五",@"李六",@"王三",@"王四",@"王五",@"王六",@"王七",@"王八",@"王九",@"王十", nil];
    self.listData5 = array;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMOedRequest:(id)sender
{
    
    //数据库读IP
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath5;
    databaseFilePath5 = [[NSString alloc] init];
    databaseFilePath5 = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    if (sqlite3_open([databaseFilePath5 UTF8String], &db)==SQLITE_OK) {
        NSLog(@"MOedSearch:sqlite db is opened.");
    }
    else{ return;}
    const char *selectSql="select SERVER_IP,User_id from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"MOedSearch:select ip&userid operation is ok.");
    }
    else
    {
        NSLog(@"MOedSearch:读IP,Userid error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        
        char *Server_ip=(char*)sqlite3_column_text(statement, 0);
        char *uid=(char*)sqlite3_column_text(statement, 1);
        Server_ipfinal5=[NSString stringWithCString:Server_ip encoding:NSUTF8StringEncoding];
        MOeduser_id = [NSString stringWithCString:uid encoding:NSUTF8StringEncoding];
        NSLog(@"数据库读取ip为%@ user_id为%@",Server_ipfinal5,MOeduser_id);
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    NSString *getMOedurl = [NSString stringWithFormat:@"http://%@/answer_system/getMyOrdered.php?teacher_id=%@",Server_ipfinal5,MOeduser_id];
    NSLog(@"getMOedURL: %@",getMOedurl);
    //getMOsurl = [getMOsurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *newgetMOedurl = [NSURL URLWithString:getMOedurl];
    NSMutableURLRequest *getmoedrequest = [NSMutableURLRequest requestWithURL:newgetMOedurl];
    [getmoedrequest setHTTPMethod:@"GET"];
    
    NSLog(@"newgetMOedURL:%@",newgetMOedurl);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:getmoedrequest delegate:self];
    
    [connection start];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"connection didReceiveResponse:%@",response);
}


//多次调用 分批次调用 多次调用完成之后调用didfinishloading
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"connection didReceiveData");
    if (receiveData_ ==nil){
        receiveData_ = [[NSMutableData alloc] init];
    }
    [receiveData_ resetBytesInRange:NSMakeRange(0, receiveData_.length)];
    [receiveData_ setLength:0];
    [receiveData_ appendData:data];
    //NSLog(@"receiveData:%@",data);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"connectionDidFinishLoading请求完成");
    
    id obj = [NSJSONSerialization JSONObjectWithData:receiveData_ options:0 error:nil];
    
    if([obj isKindOfClass:[NSDictionary class]]){
        NSLog(@"字典类型");
        
    }else if([obj isKindOfClass:[NSArray class]]){
        NSLog(@"数组类型");
        int i = 0;
        NSArray *arr = (NSArray *)obj;
        
        moedidarr = [[NSMutableArray alloc] init];
        moedwaidarr = [[NSMutableArray alloc] init];
        moedcoursesarr = [[NSMutableArray alloc] init];
        moedanswertimearr = [[NSMutableArray alloc] init];
        moedanswerpositionarr = [[NSMutableArray alloc] init];
        moedothersarr = [[NSMutableArray alloc] init];
        moedcountarr = [[NSMutableArray alloc] init];

        
        for (NSDictionary *dic in arr){
            NSString *moedid = [(NSDictionary *)dic objectForKey:@"My_Ordered_id"];
            NSString *moedwaid = [(NSDictionary *)dic objectForKey:@"wait_answer_id"];
            NSString *moedcourse = [(NSDictionary *)dic objectForKey:@"these_courses"];
            NSString *moedat = [(NSDictionary *)dic objectForKey:@"answer_time"];
            NSString *moedap = [(NSDictionary *)dic objectForKey:@"answer_position"];
            NSString *moedothers = [(NSDictionary *)dic objectForKey:@"others"];
            NSString *moedcount = [(NSDictionary *)dic objectForKey:@"count"];
            NSLog(@"dic%d:%@",i,dic);
            [moedidarr addObject:moedid];
            [moedwaidarr addObject:moedwaid];
            [moedcoursesarr addObject:moedcourse];
            [moedanswertimearr addObject:moedat];
            [moedanswerpositionarr addObject:moedap];
            [moedothersarr addObject:moedothers];
            [moedcountarr addObject:moedcount];
            i++;
        }
        self.listData5 = moedcoursesarr;
        [self.tableView5 reloadData];
        NSLog(@"moedidarr:%@",moedidarr);
        NSLog(@"moedcoursearr:%@",moedcoursesarr);
    }else{NSLog(@"未知类型");}
    NSLog(@"obj:%@",obj);
}
//返回多少个section
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"numberOfSectionsInTableView");
    return 1;
}


//返回行数，也就是返回数组中所存储数据，也就是section的元素
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection");
    return [self.listData5 count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:2.0f];
    NSLog(@"cellForRowAtIndexPath");
    //[NSThread sleepForTimeInterval:1.0f]; [self delayMethod];
    //    声明静态字符串型对象，用来标记重用单元格
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    
    //    用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    //如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
    }
    
    else {
        
        while ([cell.contentView.subviews lastObject ]!=nil) {
            [(UIView*)[cell.contentView.subviews lastObject]removeFromSuperview];
        }
    }
    //    获取当前行信息值
    NSUInteger row = [indexPath row];
    //    填充行的详细内容
    NSLog(@"moedstring1 made by %@ & %@",moedcoursesarr[row],moedanswerpositionarr[row]);
    moedstring1 = [[NSString alloc] init];
    moedstring1 = [moedcoursesarr[row] stringByAppendingFormat:@"\n%@",moedanswerpositionarr[row]];
    if(moedstring1.length == 0){
        NSLog(@"moedstring1 为空");
        moedstring1 = @"无";
    }
    NSLog(@"moedstring1 = %@",moedstring1);
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:moedstring1];
    int courselen = [moedcoursesarr[row] length];
    [str1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:14.0] range:NSMakeRange(0,courselen)];
    cell.textLabel.attributedText = str1;
    cell.textLabel.numberOfLines = 0;
    //cell.textLabel.text= string1;
    
    cell.textLabel.backgroundColor=[UIColor clearColor];
    
    
    
    moedstring2 = [[NSString alloc] init];
    moedstring2 = [moedanswertimearr[row] stringByAppendingFormat:@"\n%@",moedothersarr[row]];
    NSMutableString *cellcount1;
    cellcount1 = (@"已预约人数:");
    cellcount1 = [cellcount1 stringByAppendingFormat:@"%@",moedcountarr[row]];
    moedstring2 = [cellcount1 stringByAppendingFormat:@"\n%@",moedstring2];
    if(moedstring2.length == 12){
        NSLog(@"moedstring2 为空");
        moedstring2 = @"无";
    }
    NSLog(@"moedstring2 = %@",moedstring2);
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.text = string2;
    cell.detailTextLabel.font =[UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:moedstring2];
        if(cellcount1.length == 0){
        NSLog(@"cellcount1 为空");
        moedstring2 = @"unknown cellcount1";
    }
    int countlen = [cellcount1 length];
    NSLog(@"cellcount = %@",cellcount1);
    NSLog(@"cellcountlen = %d",countlen);
    NSLog(@"str2 = %@",str2);
    [str2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,countlen)];
    cell.detailTextLabel.attributedText = str2;
    
    
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"heightForRowAtIndexPath");
    return 100;
    
}

//设置单元格缩进
-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indentationLevelForRowAtIndexPath");
    NSInteger row = [indexPath row];
    if (row % 2==0) {
        return 0;
    }
    return 0;
}

//选中单元格所产生事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    //    首先是用indexPath获取当前行的内容
    NSInteger row = [indexPath row];
    //    从数组中取出当前行内容
    NSLog(@"didSelectRowAtIndexPath:row=%@ MOcourses=%@",row,moedcoursesarr[row]);
    
    NSArray *documentsPaths6=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath6=[[documentsPaths6 objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    //上面两句已经比较熟悉了吧！
    //打开数据库
    if (sqlite3_open([databaseFilePath6 UTF8String], &db)==SQLITE_OK) {
        NSLog(@"sqlite db is opened.");
    }
    else{ return;}//打开不成功就返回
    //删表answer_system
    
    //插入数据
    NSString *insertwaidSql=@"update answer_system set wait_answer_id = ";
    insertwaidSql = [insertwaidSql stringByAppendingString:[NSString stringWithFormat:@"'%@' where SERVER_IP is not NULL",moedwaidarr[row]]];
    NSLog(@"insert wait_answer_id sql:%@",insertwaidSql);
    const char *insertSql2 = [insertwaidSql UTF8String];
    
    NSLog(@"insert sql2:%s",insertSql2);
    if (sqlite3_exec(db, insertSql2, NULL, NULL, &error)==SQLITE_OK) {
        NSLog(@"insert operation is ok.");
    }else
    {
        NSLog(@"error: %s",error);
        sqlite3_free(error);//每次使用完毕清空error字符串，提供给下一次使用
    }
    
    //跳转到预约详情
    MyOrderedDetailViewController *moeddc = [[MyOrderedDetailViewController alloc] init];
    self.view.window.rootViewController = moeddc;


}



- (void)backtoguidepage:(id)sender{
    NSLog(@"backtoguidepage");
    ViewController *vc = [[ViewController alloc] init];
    //[self dismissViewControllerAnimated:YES completion:nil];
    self.view.window.rootViewController = vc;
}



- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [self.tableView5 reloadData];
}


- (void)delayMethod
{
    NSLog(@"MOed delay");
}

@end
