//
//  MyOrderViewController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/19.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "MyOrderViewController.h"
#import "ViewController.h"
#import <sqlite3.h>
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height



@interface MyOrderViewController()<NSURLConnectionDataDelegate>
{
    NSMutableData *receiveData_;
    sqlite3 *db;
    char *error;
}


@end
NSString *Server_ipfinal4;
NSMutableArray *moidarr;
NSMutableArray *mocoursesarr;
NSMutableArray *moteachernamearr;
NSMutableArray *moothersarr;
NSString *moid;
NSString *MOuser_id;

@implementation MyOrderViewController
@synthesize listData4=_listData4;
@synthesize tableView4 = _tableView4;
@synthesize tableViewCell4 =_tableViewCell4;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *rpsearchbackButton = [[UIButton alloc] initWithFrame:CGRectMake(10,30, 40, 30)];
    rpsearchbackButton.backgroundColor = [UIColor clearColor];
    [rpsearchbackButton setTitle:@"< 返回" forState:UIControlStateNormal];
    [rpsearchbackButton sizeToFit];
    [rpsearchbackButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rpsearchbackButton addTarget:self action:@selector(backtoguidepage:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rpsearchbackButton];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70,kScreenWidth,20)];
    [titleLabel setText:@"我的预约"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    
    [self getMOsRequest:self];
    
    self.tableView4 = [[UITableView alloc] initWithFrame:CGRectMake(30,100, kScreenWidth - 60, kScreenHeight - 150) style:UITableViewStylePlain];
    self.tableView4.delegate=self;
    self.tableView4.dataSource=self;
    [self.view addSubview:self.tableView4];
    NSArray *array = [NSArray arrayWithObjects:@"张三",@"张四",@"张五",@"李三",@"李四",@"李五",@"李六",@"王三",@"王四",@"王五",@"王六",@"王七",@"王八",@"王九",@"王十", nil];
    self.listData4 = array;
    // NSLog(@"viewdidload listData = %@",self.listData);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMOsRequest:(id)sender
{
    //数据库读IP
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath3;
    databaseFilePath3 = [[NSString alloc] init];
    databaseFilePath3 = [[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    if (sqlite3_open([databaseFilePath3 UTF8String], &db)==SQLITE_OK) {
        NSLog(@"MOsSearch:sqlite db is opened.");
    }
    else{ return;}
    const char *selectSql="select SERVER_IP,User_id from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"MOsSearch:select ip&userid operation is ok.");
    }
    else
    {
        NSLog(@"MOsSearch:读IP,Userid error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        
        char *Server_ip=(char*)sqlite3_column_text(statement, 0);
        char *uid=(char*)sqlite3_column_text(statement, 1);
        Server_ipfinal4=[NSString stringWithCString:Server_ip encoding:NSUTF8StringEncoding];
        MOuser_id = [NSString stringWithCString:uid encoding:NSUTF8StringEncoding];
        NSLog(@"数据库读取ip为%@ user_id为%@",Server_ipfinal4,MOuser_id);
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    NSString *getMOsurl = [NSString stringWithFormat:@"http://%@/answer_system/getmyorders.php?user_id=%@",Server_ipfinal4,MOuser_id];
    NSLog(@"getMOsURL: %@",getMOsurl);
    //getMOsurl = [getMOsurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *newgetMOsurl = [NSURL URLWithString:getMOsurl];
    NSMutableURLRequest *getmosrequest = [NSMutableURLRequest requestWithURL:newgetMOsurl];
    [getmosrequest setHTTPMethod:@"GET"];
    
    NSLog(@"newgetMOsURL:%@",newgetMOsurl);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:getmosrequest delegate:self];
    
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
        moidarr = [[NSMutableArray alloc] init];
        mocoursesarr = [[NSMutableArray alloc] init];
        moteachernamearr = [[NSMutableArray alloc] init];
        moothersarr = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in arr){
            NSString *moid = [(NSDictionary *)dic objectForKey:@"MOs_id"];
            NSString *thesecourse = [(NSDictionary *)dic objectForKey:@"these_courses"];
            NSString *teachername = [(NSDictionary *)dic objectForKey:@"teacher_name"];
            NSString *moothers = [(NSDictionary *)dic objectForKey:@"others"];
            NSLog(@"dic%d:%@",i,dic);
            [moidarr addObject:moid];
            [mocoursesarr addObject:thesecourse];
            [moteachernamearr addObject:teachername];
            [moothersarr addObject:moothers];
            i++;
        }
        self.listData4 = moteachernamearr;
        [self.tableView4 reloadData];
        NSLog(@"moidarr:%@",moidarr);
        NSLog(@"moteachernamearr:%@",moteachernamearr);
        NSLog(@"mocoursesarr:%@",mocoursesarr);
        NSLog(@"moothers:%@",moothersarr);
    }
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
    return [self.listData4 count];
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
    //NSLog(@"mostring1 made by %@ & %@",moteachernamearr[row],mocoursesarr[row]);
    NSString *mostring1;
    mostring1 = [moteachernamearr[row] stringByAppendingFormat:@"\n%@",mocoursesarr[row]];
    if(mostring1.length == 0){
        NSLog(@"mostring1 为空");
        mostring1 = @"unknown mostring1";
    }
    NSLog(@"mostring1 = %@",mostring1);
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:mostring1];
    int namelen = [moteachernamearr[row] length];
    [str1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,namelen)];
    cell.textLabel.attributedText = str1;
    cell.textLabel.numberOfLines = 0;
    //cell.textLabel.text= string1;
    
    cell.textLabel.backgroundColor=[UIColor clearColor];

    
    NSString *mostring2;
    mostring2 = moothersarr[row];
    if(mostring2.length == 0){
        NSLog(@"mostring2 为空");
        mostring2 = @"unknown mostring2";
    }
    NSLog(@"string2 = %@",mostring2);
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.text = string2;
    cell.detailTextLabel.font =[UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:mostring2];
    int mootherlen = [moothersarr[row] length];
    [str2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,mootherlen)];
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
    NSLog(@"didSelectRowAtIndexPath:row=%@ MOcourses=%@",row,mocoursesarr[row]);
}



- (void)backtoguidepage:(id)sender{
    NSLog(@"backtoguidepage");
    ViewController *vc = [[ViewController alloc] init];
    //[self dismissViewControllerAnimated:YES completion:nil];
    self.view.window.rootViewController = vc;
}



- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [self.tableView4 reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"左滑");
    NSInteger row2 = [indexPath row];
    moid = moidarr[row2];
    [self cancelorderRequest:self];
    [moidarr removeObjectAtIndex:indexPath.row];
    [moteachernamearr removeObjectAtIndex:indexPath.row];
    [moothersarr removeObjectAtIndex:indexPath.row];
    [mocoursesarr removeObjectAtIndex:indexPath.row];
    
    [self.tableView4 deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消预约";
}
- (void)cancelorderRequest:(id)sender
{
    
    NSLog(@"cancelorder数据库读取ip为%@",Server_ipfinal4);
    NSLog(@"cancelorder数据库读取user_id为%@",MOuser_id);
    NSString *cancelorderurl = [NSString stringWithFormat:@"http://%@/answer_system/cancel_order_answer.php?order_answer_id=%@",Server_ipfinal4,moid];
    NSLog(@"cancelorderURL:%@",cancelorderurl);
    cancelorderurl = [cancelorderurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"cancelorderURL 转义中文:%@",cancelorderurl);
    NSURL *cancelorderurl2 = [NSURL URLWithString:cancelorderurl];
    NSLog(@"cancelorderurl2定义:%@",cancelorderurl2);
    NSMutableURLRequest *request3 = [NSMutableURLRequest requestWithURL:cancelorderurl2];
    [request3 setHTTPMethod:@"GET"];
    NSURLConnection *connection4 = [[NSURLConnection alloc] initWithRequest:request3 delegate:self];
    
    [connection4 start];
    
}
- (void)delayMethod
{
    NSLog(@"MO delay");
}

@end
