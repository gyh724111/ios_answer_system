//
//  JsonArrayController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/17.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "JsonArrayController.h"
#import "ViewController.h"
#import <sqlite3.h>
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height



@interface JsonArrayController ()<NSURLConnectionDataDelegate>
{
    NSMutableData *receiveData_;
    sqlite3 *db;
    char *error;
}
@property (nonatomic,strong)UILabel *teachernameLabel;
@property (nonatomic,strong)UITextField *teachernameTextField;
@property (nonatomic,strong)UILabel *thesecoursesLabel;
@property (nonatomic,strong)UITextField *thesecoursesTextField;


@end
NSString *Server_ipfinal2;
NSMutableArray *tcidarr;
NSMutableArray *teachernamearr;
NSMutableArray *thesecoursesarr;
NSMutableArray *answertimearr;
NSMutableArray *othersarr;

@implementation JsonArrayController
@synthesize listData=_listData;
@synthesize tableView = tableView;
@synthesize tableViewCell =_tableViewCell;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70,kScreenWidth,20)];
    [titleLabel setText:@"坐班答疑安排查询"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];

    
    _teachernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,100,(kScreenWidth - 50 * 2)/3,30)];
    _teachernameLabel.backgroundColor = [UIColor clearColor];
    _teachernameLabel.textAlignment = NSTextAlignmentLeft;
    _teachernameLabel.font = [UIFont systemFontOfSize:12];
    _teachernameLabel.textColor = [UIColor blackColor];
    [_teachernameLabel setText:@"教师姓名:"];
    [self.view addSubview:_teachernameLabel];
    
    _teachernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50 + (kScreenWidth - 50 * 2)/3,102.5,2*(kScreenWidth - 100 * 2)/3,25)];
    _teachernameTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _teachernameTextField.textAlignment = NSTextAlignmentLeft;
    _teachernameTextField.font = [UIFont systemFontOfSize:12];
    _teachernameTextField.textColor = [UIColor blackColor];
    [self.view addSubview:_teachernameTextField];
    
    _thesecoursesLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,130,(kScreenWidth - 50 * 2)/3,30)];
    _thesecoursesLabel.backgroundColor = [UIColor clearColor];
    _thesecoursesLabel.textAlignment = NSTextAlignmentLeft;
    _thesecoursesLabel.font = [UIFont systemFontOfSize:12];
    _thesecoursesLabel.textColor = [UIColor blackColor];
    [_thesecoursesLabel setText:@"负责科目:"];
    [self.view addSubview:_thesecoursesLabel];
    
    _thesecoursesTextField = [[UITextField alloc] initWithFrame:CGRectMake(50 + (kScreenWidth - 50 * 2)/3,132.5,2*(kScreenWidth - 100 * 2)/3,25)];
    _thesecoursesTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _thesecoursesTextField.textAlignment = NSTextAlignmentLeft;
    _thesecoursesTextField.font = [UIFont systemFontOfSize:12];
    _thesecoursesTextField.textColor = [UIColor blackColor];
    [self.view addSubview:_thesecoursesTextField];
    
    
    
    UIButton *tcsearchButton = [[UIButton alloc] initWithFrame:CGRectMake(60 +(kScreenWidth - 50 * 2)/3 + 2*(kScreenWidth - 100 * 2)/3, 115, 100, 30)];
    tcsearchButton.backgroundColor = [UIColor redColor];
    [tcsearchButton setTitle:@"查询" forState:UIControlStateNormal];
    [tcsearchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tcsearchButton addTarget:self action:@selector(getTCsRequest:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tcsearchButton];
    
    [self getTCsRequest:self];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,160, kScreenWidth , kScreenHeight - 150) style:UITableViewStylePlain];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
     NSArray *array = [NSArray arrayWithObjects:@"张三",@"张四",@"张五",@"李三",@"李四",@"李五",@"李六",@"王三",@"王四",@"王五",@"王六",@"王七",@"王八",@"王九",@"王十", nil];
    self.listData = array;
   // NSLog(@"viewdidload listData = %@",self.listData);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getTCsRequest:(id)sender
{
    
    NSString *teachername = [_teachernameTextField text];
    NSString *thesecourses = [_thesecoursesTextField text];
    //数据库读IP
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    if (sqlite3_open([databaseFilePath UTF8String], &db)==SQLITE_OK) {
        NSLog(@"TCSearch:sqlite db is opened.");
    }
    else{ return;}
    const char *selectSql="select SERVER_IP from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"TCSearch:select ip operation is ok.");
    }
    else
    {
        NSLog(@"读IP error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        //int _id=sqlite3_column_int(statement, 0);
        char *Server_ip=(char*)sqlite3_column_text(statement, 0);
        Server_ipfinal2=[NSString stringWithCString:Server_ip encoding:NSUTF8StringEncoding];
        NSLog(@"数据库读取ip为%@",Server_ipfinal2);
    }
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    NSString *getTCsurl = [NSString stringWithFormat:@"http://%@/answer_system/getTCs.php?teacher_name=%@&these_courses=%@",Server_ipfinal2,teachername,thesecourses];
    NSLog(@"getTCsURL:getTCsurl  %@",getTCsurl);
    //NSURL *newgetTCsurl = [NSURL URLWithString:getTCsurl];
    getTCsurl = [getTCsurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *newgetTCsurl2 = [NSURL URLWithString:getTCsurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:newgetTCsurl2];
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"getTCsURL:%@",newgetTCsurl2);
    
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
    [receiveData_ resetBytesInRange:NSMakeRange(0, receiveData_.length)];
    [receiveData_ setLength:0];
    [receiveData_ appendData:data];
    NSLog(@"receiveData:%@",data);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"请求完成");
    
    id obj = [NSJSONSerialization JSONObjectWithData:receiveData_ options:0 error:nil];
    
    if([obj isKindOfClass:[NSDictionary class]]){
        NSLog(@"字典类型");

            }
    if([obj isKindOfClass:[NSArray class]]){
        NSLog(@"数组类型");
        int i = 0;
        NSArray *arr = (NSArray *)obj;
        tcidarr = [[NSMutableArray alloc] init];
        teachernamearr = [[NSMutableArray alloc] init];
        thesecoursesarr = [[NSMutableArray alloc] init];
        answertimearr = [[NSMutableArray alloc] init];
        othersarr = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in arr){
            NSString *tcid = [(NSDictionary *)dic objectForKey:@"TCs_id"];
            NSString *name = [(NSDictionary *)dic objectForKey:@"teacher_name"];
            NSString *courses = [(NSDictionary *)dic objectForKey:@"these_courses"];
            NSString *time = [(NSDictionary *)dic objectForKey:@"answer_time"];
            NSString *others = [(NSDictionary *)dic objectForKey:@"others"];
            NSLog(@"dic%d:%@",i,dic);
            NSLog(@"arr%d:%@",i,name);
            [tcidarr addObject:tcid];
            [teachernamearr addObject:name];
            [thesecoursesarr addObject:courses];
            [answertimearr addObject:time];
            [othersarr addObject:others];
            i++;
        }
        self.listData = teachernamearr;
        [tableView reloadData];
        NSLog(@"teachernamearr:%@",teachernamearr);
    }
    NSLog(@"obj:%@",obj);
}
//返回多少个section
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}


//返回行数，也就是返回数组中所存储数据，也就是section的元素
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection");
    return [self.listData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    //    声明静态字符串型对象，用来标记重用单元格
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
 
    //    用TableSampleIdentifier表示需要重用的单元
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
        //如果如果没有多余单元，则需要创建新的单元
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    }
    
    else {
        //删除cell的所有子视图
        while ([cell.contentView.subviews lastObject] != nil)
        {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
//        while ([cell.contentView.subviews lastObject ]!=nil) {
//            [(UIView*)[cell.contentView.subviews lastObject]removeFromSuperview];
//        }
    }
    //    获取当前行信息值
    NSUInteger row = [indexPath row];
    //    填充行的详细内容
    cell.detailTextLabel.text = (answertimearr[row]);
    cell.detailTextLabel.font =[UIFont boldSystemFontOfSize:10];
    //    把数组中的值赋给单元格显示出来
    cell.textLabel.text=[self.listData objectAtIndex:row];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    //    设置单元格UILabel属性背景颜色
    cell.textLabel.backgroundColor=[UIColor clearColor];

    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath");
    return 50;
    
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
    NSString *rowValue = [self.listData objectAtIndex:row];
    NSString *message = [[NSString alloc]initWithFormat:@"You selected%@",rowValue];
    //    弹出警告信息
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles: nil];
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [self.tableView reloadData];
}
@end
