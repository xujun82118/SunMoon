//
//  SunSentenceManagerViewController.m
//  SunMoon
//
//  Created by songwei on 14-5-11.
//  Copyright (c) 2014年 xujun. All rights reserved.
//

#import "SunSentenceManagerViewController.h"

@interface SunSentenceManagerViewController ()

@end

@implementation SunSentenceManagerViewController
@synthesize   user, addNewSentence,addNewSentenceBtn, sunSentenceTable;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.opaque = YES;
    
    
    //加返回按钮
    NSInteger backBtnWidth = 18;
    NSInteger backBtnHeight = 22;
    UIButton *backBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回-黄.png"] forState:UIControlStateNormal];
    [backBtn setFrame:CGRectMake(LEFT_NAVI_BTN_TO_SIDE_X, NAVI_BAR_BTN_Y-backBtnHeight/2+10, backBtnWidth, backBtnHeight)];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    
    //加编辑按钮
    NSInteger editeBtnWidth = 20;
    NSInteger editeBtnHeight = 20;
    UIButton *editeBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    [editeBtn setImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];
    [editeBtn setFrame:CGRectMake(RIGHT_NAVI_BTN_TO_SIDE_X-editeBtnWidth, NAVI_BAR_BTN_Y-editeBtnHeight/2+7, editeBtnWidth, editeBtnHeight)];
    [editeBtn addTarget:self action:@selector(canEditSentence:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editeBtn];
    
    [sunSentenceTable setBackgroundColor:[UIColor clearColor]];
    [addNewSentence setText:@""];
    
    
    //获取单例用户数据
    self.user= [UserInfo  sharedSingleUserInfo];
}

- (void) viewWillAppear:(BOOL)animated
{


    
    
}

- (void) viewDidAppear:(BOOL)animated
{
    //滚动到选择行
    NSInteger s = [self.sunSentenceTable numberOfSections];
    if (s<1) return;
    NSInteger r = [self.sunSentenceTable numberOfRowsInSection:s-1];
    if (r<1) return;
    
    if (user.sunSentenceSelect>r) {
        return;
    }
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:user.sunSentenceSelect inSection:s-1];
    [sunSentenceTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [sunSentenceTable setEditing:NO animated:YES];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [user.sunDataSourceArray count];

    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"SunCell"];
        cell.textLabel.text =[user.sunDataSourceArray objectAtIndex:indexPath.row];
        if(indexPath.row == user.sunSentenceSelect)
        {

            cell.imageView.image = [UIImage imageNamed:@"sun.png"];
        }
        
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
            
        }
    
        cell.backgroundColor = [UIColor clearColor];
        return cell;
  
    
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//继承该方法时,左右滑动会出现删除按钮(自定义按钮),点击按钮时的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if ([user.sunDataSourceArray count] == 1) {
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:@"请留一条阳光语录哦~"
                              delegate:nil
                              cancelButtonTitle:@"Yes"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    
    NSMutableArray *mutaArray = [[NSMutableArray alloc] init];
    [mutaArray addObjectsFromArray:user.sunDataSourceArray];
    
    [mutaArray removeObjectAtIndex:indexPath.row];
    user.sunDataSourceArray = mutaArray;
    //[self.dataSourceArray removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    //更新语录
    [user updateSunSentence:user.sunDataSourceArray];
    
    //重新选择第0条
    [user updateSunSentenceSelected:0];
    
    //重置选择光标
    NSInteger s = [self.sunSentenceTable numberOfSections];
    if (s<1) return;
    NSInteger r = [self.sunSentenceTable numberOfRowsInSection:s-1];
    if (r<1) return;
    
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:s-1];
    [sunSentenceTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [sunSentenceTable reloadData];
    

    
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
      
    cell.imageView.image = [UIImage imageNamed:@"选择.png"];
    
    [sunSentenceTable reloadData];

    
    [user updateSunSentenceSelected:indexPath.row];
    
    
    
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.imageView.image = nil;
    
}


- (void)canEditSentence:(id)sender {
    
    [sunSentenceTable setEditing:!sunSentenceTable.editing animated:YES];
    
    if (sunSentenceTable.editing == YES) {
    }else
    {
        
    }
    
}

- (IBAction)sentenceTextChanged:(id)sender
{
    
    if ([self.addNewSentence.text isEqualToString:@""]) {
        
        [addNewSentenceBtn setImage:[UIImage imageNamed:@"加语录-关闭.png"] forState:UIControlStateNormal ];

    }else
    {
        [addNewSentenceBtn setImage:[UIImage imageNamed:@"加语录-打开.png"] forState:UIControlStateNormal ];
        
    }
    
    
    
    
    
}

- (IBAction)doAddSunSentence:(id)sender {
    
    
    if ([self.addNewSentence.text isEqualToString:@""]) {
        return;
    }
    
    for (int i=0; i<user.sunDataSourceArray.count; i++)
    {
        NSString *now = [user.sunDataSourceArray objectAtIndex:i];
        
        if ([self.addNewSentence.text isEqualToString:now])
        {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:@"此语录已在列表中！"
                                  delegate:self
                                  cancelButtonTitle:@"确定"
                                  otherButtonTitles: nil];
            [alert show];
            
            return;
        }
        
    }
    
    if ([self.addNewSentence.text isEqualToString:@""]) {
        return;
    }
    
    NSMutableArray *mutaArray = [[NSMutableArray alloc] init];
    [mutaArray addObjectsFromArray:user.sunDataSourceArray ];
    
    [mutaArray addObject:addNewSentence.text];
    user.sunDataSourceArray =mutaArray;
    
    //更新到库
    [user updateSunSentence:user.sunDataSourceArray];
    [user updateSunSentenceSelected:user.sunDataSourceArray.count-1];

    
    [sunSentenceTable reloadData];
    
    //刷新界面,移动光标到最下方
    NSInteger s = [self.sunSentenceTable numberOfSections];
    if (s<1) return;
    NSInteger r = [self.sunSentenceTable numberOfRowsInSection:s-1];
    if (r<1) return;
    
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [sunSentenceTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
  

    
    addNewSentence.text = @"";
    [self sentenceTextChanged:nil];
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 250.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = rect;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    //return YES;
}

@end
