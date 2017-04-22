//
//  RPViewController.m
//  JSON1
//
//  Created by 葛永晖 on 2017/4/19.
//  Copyright © 2017年 葛永晖. All rights reserved.
//

#import "RPViewController.h"
#import "ViewController.h"
#import <sqlite3.h>
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height



@interface RPViewController()<NSURLConnectionDataDelegate>
{
    NSMutableData *receiveData_;
    sqlite3 *db;
    char *error;
}
@property (nonatomic,strong)UILabel *roomidLabel;
@property (nonatomic,strong)UITextField *roomidTextField;
@property (nonatomic,strong)UILabel *divisionLabel;
@property (nonatomic,strong)UITextField *divisionTextField;
@property (nonatomic,strong)UILabel *phoneLabel;
@property (nonatomic,strong)UITextField *phoneTextField;

@end
NSString *Server_ipfinal3;
NSMutableArray *rpidarr;
NSMutableArray *roomidarr;
NSMutableArray *divisionarr;
NSMutableArray *phonearr;
NSMutableArray *rpothersarr;
NSString *RPsid;
NSString *RPuser_id;

@implementation RPViewController
@synthesize listData=_listData;
@synthesize tableView = _tableView;
@synthesize tableViewCell =_tableViewCell;
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
    [titleLabel setText:@"联系方式查询"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:titleLabel];
    
    
    _roomidLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,100,(kScreenWidth - 50 * 2)/3,30)];
    _roomidLabel.backgroundColor = [UIColor clearColor];
    _roomidLabel.textAlignment = NSTextAlignmentLeft;
    _roomidLabel.font = [UIFont systemFontOfSize:12];
    _roomidLabel.textColor = [UIColor blackColor];
    [_roomidLabel setText:@"门牌:"];
    [self.view addSubview:_roomidLabel];
    
    _roomidTextField = [[UITextField alloc] initWithFrame:CGRectMake(50 + (kScreenWidth - 50 * 2)/3,102.5,2*(kScreenWidth - 100 * 2)/3,25)];
    _roomidTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _roomidTextField.textAlignment = NSTextAlignmentLeft;
    _roomidTextField.font = [UIFont systemFontOfSize:12];
    _roomidTextField.textColor = [UIColor blackColor];
    [self.view addSubview:_roomidTextField];
    
    _divisionLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,130,(kScreenWidth - 50 * 2)/3,30)];
    _divisionLabel.backgroundColor = [UIColor clearColor];
    _divisionLabel.textAlignment = NSTextAlignmentLeft;
    _divisionLabel.font = [UIFont systemFontOfSize:12];
    _divisionLabel.textColor = [UIColor blackColor];
    [_divisionLabel setText:@"部门:"];
    [self.view addSubview:_divisionLabel];
    
    _divisionTextField = [[UITextField alloc] initWithFrame:CGRectMake(50 + (kScreenWidth - 50 * 2)/3,132.5,2*(kScreenWidth - 100 * 2)/3,25)];
    _divisionTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _divisionTextField.textAlignment = NSTextAlignmentLeft;
    _divisionTextField.font = [UIFont systemFontOfSize:12];
    _divisionTextField.textColor = [UIColor blackColor];
    [self.view addSubview:_divisionTextField];
    
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(50,160,(kScreenWidth - 50 * 2)/3,30)];
    _phoneLabel.backgroundColor = [UIColor clearColor];
    _phoneLabel.textAlignment = NSTextAlignmentLeft;
    _phoneLabel.font = [UIFont systemFontOfSize:12];
    _phoneLabel.textColor = [UIColor blackColor];
    [_phoneLabel setText:@"电话:"];
    [self.view addSubview:_phoneLabel];
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(50 + (kScreenWidth - 50 * 2)/3,162.5,2*(kScreenWidth - 100 * 2)/3,25)];
    _phoneTextField.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:0.5];
    _phoneTextField.textAlignment = NSTextAlignmentLeft;
    _phoneTextField.font = [UIFont systemFontOfSize:12];
    _phoneTextField.textColor = [UIColor blackColor];
    [self.view addSubview:_phoneTextField];
    
    
    
    UIButton *rpsearchButton = [[UIButton alloc] initWithFrame:CGRectMake(60 +(kScreenWidth - 50 * 2)/3 + 2*(kScreenWidth - 100 * 2)/3, 130, 100, 30)];
    rpsearchButton.backgroundColor = [UIColor redColor];
    [rpsearchButton setTitle:@"查询" forState:UIControlStateNormal];
    [rpsearchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rpsearchButton addTarget:self action:@selector(getRPsRequest:)  forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rpsearchButton];
    
    [self getRPsRequest:self];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(30,220, kScreenWidth - 60, kScreenHeight - 150) style:UITableViewStylePlain];
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

- (void)getRPsRequest:(id)sender
{
    NSString *roomid = [_roomidTextField text];
    NSString *division = [_divisionTextField text];
    NSString *phone = [_phoneTextField text];
    //数据库读IP
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"mydb"];
    if (sqlite3_open([databaseFilePath UTF8String], &db)==SQLITE_OK) {
        NSLog(@"RPsSearch:sqlite db is opened.");
    }
    else{ return;}
    const char *selectSql="select SERVER_IP,User_id from answer_system";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db,selectSql, -1, &statement, nil)==SQLITE_OK) {
        NSLog(@"RPsSearch:select ip&userid operation is ok.");
    }
    else
    {
        NSLog(@"读IP Userid error: %s",error);
        sqlite3_free(error);
    }
    while(sqlite3_step(statement)==SQLITE_ROW) {
        
        char *Server_ip=(char*)sqlite3_column_text(statement, 0);
        char *uid=(char*)sqlite3_column_text(statement, 1);
        Server_ipfinal3=[NSString stringWithCString:Server_ip encoding:NSUTF8StringEncoding];
        RPuser_id = [NSString stringWithCString:uid encoding:NSUTF8StringEncoding];
        NSLog(@"数据库读取ip为%@ user_id为%@",Server_ipfinal3,RPuser_id);
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(db);
    
    
    NSString *getRPsurl = [NSString stringWithFormat:@"http://%@/answer_system/getallRP.php?room_num=%@&room_division=%@&phone=%@",Server_ipfinal3,roomid,division,phone];
    NSLog(@"getRPsURL:getRPsurl  %@",getRPsurl);
    getRPsurl = [getRPsurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *newgetRPsurl = [NSURL URLWithString:getRPsurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:newgetRPsurl];
    [request setHTTPMethod:@"GET"];
    
    NSLog(@"newgetRPsURL:%@",newgetRPsurl);
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    NSLog(@"receiveData:%@",data);
    
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
        rpidarr = [[NSMutableArray alloc] init];
        roomidarr = [[NSMutableArray alloc] init];
        divisionarr = [[NSMutableArray alloc] init];
        phonearr = [[NSMutableArray alloc] init];
        rpothersarr = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in arr){
            NSString *rpid = [(NSDictionary *)dic objectForKey:@"allRP_id"];
            NSString *roomid = [(NSDictionary *)dic objectForKey:@"room_num"];
            NSString *division = [(NSDictionary *)dic objectForKey:@"room_division"];
            NSString *phone = [(NSDictionary *)dic objectForKey:@"phone"];
            NSString *rpothers = [(NSDictionary *)dic objectForKey:@"others"];
            NSLog(@"dic%d:%@",i,dic);
            [rpidarr addObject:rpid];
            [roomidarr addObject:roomid];
            [divisionarr addObject:division];
            [phonearr addObject:phone];
            [rpothersarr addObject:rpothers];
            i++;
        }
        self.listData = divisionarr;
        [self.tableView reloadData];
        //NSLog(@"division:%@",divisionarr);
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
    //NSLog(@"numberOfRowsInSection");
    return [self.listData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:2.0f];
    //NSLog(@"cellForRowAtIndexPath");
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
    
    NSString *rpstring1;
    rpstring1 = [divisionarr[row] stringByAppendingFormat:@"\n%@",roomidarr[row]];
    if(rpstring1.length == 0){
        NSLog(@"rpstring1 为空");
        rpstring1 = @"unknown rpstring1";
    }
    NSLog(@"rpstring1 = %@",rpstring1);
    cell.textLabel.font = [UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:rpstring1];
    int divisionlen = [divisionarr[row] length];
    [str1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,divisionlen)];
    cell.textLabel.attributedText = str1;
    cell.textLabel.numberOfLines = 0;
    //cell.textLabel.text= string1;
    
    cell.textLabel.backgroundColor=[UIColor clearColor];

    
    NSString *rpstring2;
    rpstring2 = [phonearr[row] stringByAppendingFormat:@"\n%@",rpothersarr[row]];
    if(rpstring2.length == 0){
        NSLog(@"rpstring2 为空");
        rpstring2 = @"unknown rpstring2";
    }
    NSLog(@"rpstring2 = %@",rpstring2);
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.text = string2;
    cell.detailTextLabel.font =[UIFont boldSystemFontOfSize:10];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:rpstring2];
    int phonelen = [phonearr[row] length];
    [str2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique"  size:12.0] range:NSMakeRange(0,phonelen)];
    cell.detailTextLabel.attributedText = str2;
    
    
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath");
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
    NSLog(@"didSelectRowAtIndexPath:row=%@ division=%@",row,divisionarr[row]);
}



- (void)backtoguidepage:(id)sender{
    NSLog(@"backtoguidepage");
    ViewController *vc = [[ViewController alloc] init];
    self.view.window.rootViewController = vc;
}



- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [self.tableView reloadData];
}
- (void)delayMethod{
    NSLog(@"RPdelay");
}
@end
