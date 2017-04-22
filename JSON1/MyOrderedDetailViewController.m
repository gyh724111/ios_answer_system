//
//  MyOrderedDetailViewController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/21.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "MyOrderedDetailViewController.h"
#import "MyOrderedViewController.h"
#import "ViewController.h"
#import <sqlite3.h>
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height



@interface MyOrderedDetailViewController()<NSURLConnectionDataDelegate>
{
    NSMutableData *receiveData_;
    sqlite3 *db;
    char *error;
}


@end
NSString *Server_ipfinal6;
NSMutableArray *moeddoaidarr;
NSMutableArray *moeddwaidarr;
NSMutableArray *moeddstuidarr;
NSMutableArray *moeddstunamearr;
NSMutableArray *moeddothersarr;
NSMutableArray *moeddcoursesarr;
NSString *MOeddid;
NSString *MOedduser_id;
NSString *MOeddwaid;
UILabel *titleLabel;

@implementation MyOrderedDetailViewController
@synthesize listData6=_listData6;
@synthesize tableView6 = _tableView6;
@synthesize tableViewCell6 =_tableViewCell6;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *moeddetailbackButton = [[UIButton alloc] initWithFrame:CGRectMake(10,30, 40, 30)];
    moeddetailbackButton.backgroundColor = [UIColor clearColor];
    [moeddetailbackButton setTitle:@"< 返回" forState:UIControlStateNormal];
    [moeddetailbackButton sizeToFit];
    [moeddetailbackButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [moeddetailbackButton addTarget:self action:@selector(backtoguide:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moeddetailbackButton];
    
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70,kScreenWidth,20)];
    [titleLabel setText:@"单个课程预约答疑详情"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    
    [self getMOeddRequest:self];
    
    self.tableView6 = [[UITableView alloc] initWithFrame:CGRectMake(30,100, kScreenWidth - 60, kScreenHeight - 150) style:UITableViewStylePlain];
    self.tableView6.delegate=self;
    self.tableView6.dataSource=self;
    [self.view addSubview:self.tableView6];
    NSArray *array = [NSArray arrayWithObjects:@"张三",@"张四",@"张五",@"李三",@"李四",@"李五",@"李六",@"王三",@"王四",@"王五",@"王六",@"王七",@"王八",@"王九",@"王十", nil];
    self.listData6 = array;
    
    // NSLog(@"viewdidload listData = %@",self.listData);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMOeddRequest:(id)sender
{
    //数据库读IP
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath6;
    databaseFilePath6 = [[NSString alloc] init];
    databaseFilePath6 = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    if (sqlite3_open([databaseFilePath6 UTF8String], &db)==SQLITE_OK) {
        NSLog(@"MOsSearch:sqlite db is opened.");
    }
    else{ return;}
    const char *selectSql="select SERVER_IP,wait_answer_id from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"MOeddSearch:select SERVER_IP waid operation is ok.");
    }
    else
    {
        NSLog(@"MOsSearch:读SERVER_IP,wait_answer_id error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        char *moeddip=(char*)sqlite3_column_text(statement, 0);
        char *waid=(char*)sqlite3_column_text(statement, 1);
        Server_ipfinal6 = [NSString stringWithCString:moeddip encoding:NSUTF8StringEncoding];
        MOeddwaid = [NSString stringWithCString:waid encoding:NSUTF8StringEncoding];
        NSLog(@"数据库读取ip为%@ waid为%@",Server_ipfinal6 ,MOeddwaid);
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    NSString *getMOeddurl = [NSString stringWithFormat:@"http://%@/answer_system/getMyOrderedDetail.php?wait_answer_id=%@",Server_ipfinal6,MOeddwaid];
    NSLog(@"getMOeddURL: %@",getMOeddurl);
    //getMOsurl = [getMOsurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *newgetMOeddurl = [NSURL URLWithString:getMOeddurl];
    NSMutableURLRequest *getmoeddrequest = [NSMutableURLRequest requestWithURL:newgetMOeddurl];
    [getmoeddrequest setHTTPMethod:@"GET"];
    
    NSLog(@"newgetMOeddURL:%@",newgetMOeddurl);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:getmoeddrequest delegate:self];
    
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
        
    }
    if([obj isKindOfClass:[NSArray class]]){
        NSLog(@"数组类型");
        int i = 0;
        NSArray *arr = (NSArray *)obj;
        moeddoaidarr = [[NSMutableArray alloc] init];
        moeddwaidarr = [[NSMutableArray alloc] init];
        moeddstuidarr = [[NSMutableArray alloc] init];
        moeddstunamearr = [[NSMutableArray alloc] init];
        moeddothersarr = [[NSMutableArray alloc] init];
        moeddcoursesarr = [[NSMutableArray alloc] init];

        
        for (NSDictionary *dic in arr){
            NSString *moeddoaid = [(NSDictionary *)dic objectForKey:@"My_Ordered_id"];
            NSString *moeddwaid = [(NSDictionary *)dic objectForKey:@"wait_answer_id"];
            NSString *moeddstuid = [(NSDictionary *)dic objectForKey:@"stu_id"];
            NSString *moeddstuname = [(NSDictionary *)dic objectForKey:@"stu_name"];
            NSString *moeddothers = [(NSDictionary *)dic objectForKey:@"others"];
            NSString *moeddcourse = [(NSDictionary *)dic objectForKey:@"these_courses"];
            NSLog(@"dic%d:%@",i,dic);
            [moeddoaidarr addObject:moeddoaid];
            [moeddwaidarr addObject:moeddwaid];
            [moeddstuidarr addObject:moeddstuid];
            [moeddstunamearr addObject:moeddstuname];
            [moeddothersarr addObject:moeddothers];
            [moeddcoursesarr addObject:moeddcourse];
            i++;
        }
        self.listData6 = moeddcoursesarr;
        [self.tableView6 reloadData];
        NSLog(@"moeddstunamearr:%@",moeddstunamearr);
    }
    [titleLabel setText:self.listData6[0]];
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
    return [self.listData6 count];
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
    NSString *moeddstring1;
    moeddstring1 = [moeddstuidarr[row] stringByAppendingFormat:@"\n%@",moeddstunamearr[row]];
    if(moeddstring1.length == 0){
        NSLog(@"moeddstring1 为空");
        moeddstring1 = @"unknown moeddstring1";
    }
    NSLog(@"moeddstring1 = %@",moeddstring1);
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:moeddstring1];
    int stuidlen = [moeddstuidarr[row] length];
    [str1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,stuidlen)];
    cell.textLabel.attributedText = str1;
    cell.textLabel.numberOfLines = 0;
    //cell.textLabel.text= string1;
    
    cell.textLabel.backgroundColor=[UIColor clearColor];
    
    
    NSString *moeddstring2;
    moeddstring2 = moeddothersarr[row];
    if(moeddstring2.length == 0){
        NSLog(@"moeddstring2 为空");
        moeddstring2 = @"unknown moeddstring2";
    }
    NSLog(@"moeddstring2 = %@",moeddstring2);
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.text = string2;
    cell.detailTextLabel.font =[UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:moeddstring2];
    int moeddotherlen = [moeddothersarr[row] length];
    [str2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,moeddotherlen)];
    cell.detailTextLabel.attributedText = str2;
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"heightForRowAtIndexPath");
    return 70;
    
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
    NSLog(@"didSelectRowAtIndexPath:row=%@ MOcourses=%@",row,moeddstunamearr[row]);
}



- (void)backtomyordered:(id)sender{
    NSLog(@"backtomyordered");
    MyOrderedViewController *vc = [[MyOrderedViewController alloc] init];
    //[self dismissViewControllerAnimated:YES completion:nil];
    self.view.window.rootViewController = vc;
}
- (void)backtoguide:(id)sender{
    NSLog(@"backtoguide");
    ViewController *vc = [[ViewController alloc] init];
    //[self dismissViewControllerAnimated:YES completion:nil];
    self.view.window.rootViewController = vc;
}


- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [self.tableView6 reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"左滑");
    NSInteger row2 = [indexPath row];
    MOeddid = moeddoaidarr[row2];
    [self finishorderRequest:self];
    [moeddoaidarr removeObjectAtIndex:indexPath.row];
    [moeddwaidarr removeObjectAtIndex:indexPath.row];
    [moeddstunamearr removeObjectAtIndex:indexPath.row];
    [moeddstuidarr removeObjectAtIndex:indexPath.row];
    [moeddothersarr removeObjectAtIndex:indexPath.row];
    [moeddcoursesarr removeObjectAtIndex:indexPath.row];
    
    [self.tableView6 deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"完成答疑";
}
- (void)finishorderRequest:(id)sender
{
    
    NSLog(@"finishorder数据库读取ip为%@",Server_ipfinal6);
    NSLog(@"finishorder数据库读取user_id为%@",MOedduser_id);
    NSString *finishorderurl = [NSString stringWithFormat:@"http://%@/answer_system/cancel_order_answer.php?order_answer_id=%@",Server_ipfinal6,MOeddid];
    NSLog(@"finishorderURL:%@",finishorderurl);
    finishorderurl = [finishorderurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"finishorderURL 转义中文:%@",finishorderurl);
    NSURL *finishorderurl2 = [NSURL URLWithString:finishorderurl];
    NSLog(@"finishorderurl2定义:%@",finishorderurl2);
    NSMutableURLRequest *request6 = [NSMutableURLRequest requestWithURL:finishorderurl2];
    [request6 setHTTPMethod:@"GET"];
    NSURLConnection *connection6 = [[NSURLConnection alloc] initWithRequest:request6 delegate:self];
    
    [connection6 start];
    
}
- (void)delayMethod
{
    NSLog(@"MOedd delay");
}

@end
