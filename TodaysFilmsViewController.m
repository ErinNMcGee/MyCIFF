//
//  TodaysFilmsViewController.m
//  MyCIFF
//
//  Created by Erin McGee on 2/21/15.
//  Copyright (c) 2015 Erin McGee. All rights reserved.
//

#import "TodaysFilmsViewController.h"
#import "AllFilmsViewController.h"

@interface TodaysFilmsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *totalFilmCount;
@property (weak, nonatomic) IBOutlet UITextView *introCountText;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSDictionary *filmDictionary;
@property (strong, nonatomic) NSString *objectId;

@end

@implementation TodaysFilmsViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.todaysFilmsList.delegate = self;
    self.todaysFilmsList.dataSource = self;
    [self.todaysFilmsList reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.todaysFilmsList.delegate = self;
    self.todaysFilmsList.dataSource = self;
    [self loadData];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    
    
    [refresh addTarget:self action:@selector(myRefresh)
     
      forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    [self.todaysFilmsList addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)myRefresh {
    [self loadData];
    [self.todaysFilmsList reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

-(void) loadData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Film"];
    [query orderByAscending:@"filmDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            int movieCount=0;
            NSDate *currDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:currDate];
            NSDate *currentTime=[dateFormatter dateFromString:dateString];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            NSString *currentDate=[dateFormatter stringFromDate:currentTime];
            
            NSMutableArray *todaysFilms=[NSMutableArray new];
            for(PFObject * film in objects){
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString *filmDateString = [dateFormatter stringFromDate:[film objectForKey: @"filmDate"]];
                
                NSDate *filmTime=[dateFormatter dateFromString:filmDateString];
                
                
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                
                NSString *filmDate=[dateFormatter stringFromDate:filmTime];
                
                if([filmDate isEqualToString:currentDate] && filmTime >=currentTime){
                    [todaysFilms addObject:film];
                    UILocalNotification *notification = [[UILocalNotification alloc]init];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *components = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:[film objectForKey: @"filmDate"]];
                    
                    [components setMinute:-30];
                    
                    NSDate *fireDate = [gregorian dateFromComponents:components];
                    NSLog(@"Fire date : %@",fireDate);
                    NSLog(@"Fire date : %@",fireDate);
                    //Build the notification
                    [notification setFireDate:fireDate];
                    [notification setAlertAction:@"Your Next Film Is Coming Up!"];
                    [notification setApplicationIconBadgeNumber:1];
                    [notification setAlertBody:[NSString stringWithFormat:@"Your next film %@, is coming up in 30 minutes in %@ theater.",[film objectForKey: @"title"], [film objectForKey: @"theater"]]];
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }else if(filmTime <=currentTime)
                {
                    movieCount++;
                }
            }
            self.totalFilmCount.text=[NSString stringWithFormat:@"%i",movieCount];
            todaysFilmData=todaysFilms;
            self.filmDictionary = [[NSMutableDictionary alloc] initWithCapacity: todaysFilmData.count];
            for (PFObject *obj in todaysFilmData){
                if (obj){
                    [self.filmDictionary setValue: obj forKey: obj.objectId ];
                }
            }
            [self.todaysFilmsList reloadData];
        }
        
    }];
    
    query = [PFQuery queryWithClassName:@"Intro"];
    [query orderByDescending:@"count"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSString *introers=@"";
        if (!error) {
            for(PFObject * intro in objects){
                
                if([introers isEqualToString:@""]){
                    introers=[NSString stringWithFormat:@"%@ %@ Times\n",[intro objectForKey: @"name"], [intro objectForKey: @"count"]];
                }else{
                    introers =[introers stringByAppendingString:[NSString stringWithFormat:@"%@ %@ Times\n",[intro objectForKey: @"name"], [intro objectForKey: @"count"]]];
                }
                
            }
            
        }
        
        self.introCountText.text=introers;
        
    }];
    
}

- (IBAction)allFilms:(id)sender {
        AllFilmsViewController *allView = [[AllFilmsViewController alloc] initWithNibName:@"AllFilmsViewController" bundle:nil];
    [self presentViewController:allView animated:NO completion:nil];
}

- (IBAction)openCalendar:(id)sender {
    TodaysCalendarViewController *calendarView = [[TodaysCalendarViewController alloc] initWithNibName:@"TodaysCalendarViewController" bundle:nil];
    [self presentViewController:calendarView animated:NO completion:nil];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [todaysFilmData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    if (todaysFilmData == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              @"Data not found" message:nil delegate:nil cancelButtonTitle:
                              @"OK" otherButtonTitles:nil];
        [alert show];
        cell.textLabel.text = @"";
        
    }
    else{
        PFObject *film = [todaysFilmData objectAtIndex: indexPath.row];
        cell.textLabel.text = [film objectForKey: @"title"];
        cell.textLabel.accessibilityHint= [film objectForKey: @"link"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM/dd/YY hh:mm a"];
        NSString *dateString = [dateFormatter stringFromDate:[film objectForKey: @"filmDate"]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@ %s",dateString,[film objectForKey: @"theater"],"Theater"];
        cell.textLabel.userInteractionEnabled = YES;
        cell.detailTextLabel.accessibilityHint= film.objectId;
        
        UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl:)];
        gestureRec.numberOfTouchesRequired = 1;
        gestureRec.numberOfTapsRequired = 1;
        [cell.textLabel addGestureRecognizer:gestureRec];
        
        UISwipeGestureRecognizer *gestureSwipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(editFilm:)];
        gestureSwipeRec.direction = UISwipeGestureRecognizerDirectionLeft;
        [cell addGestureRecognizer:gestureSwipeRec];
        
        gestureSwipeRec = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteFilm:)];
        gestureSwipeRec.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:gestureSwipeRec];
    }
    
    return cell;
}

- (void)openUrl:(id)sender
{
    UIGestureRecognizer *rec = (UIGestureRecognizer *)sender;
    
    id hitLabel = [self.view hitTest:[rec locationInView:self.view] withEvent:UIEventTypeTouches];
    
    if ([hitLabel isKindOfClass:[UILabel class]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:((UILabel *)hitLabel).accessibilityHint]];
        
    }
}

- (void)editFilm:(id)sender
{
    UIGestureRecognizer *rec = (UIGestureRecognizer *)sender;
    
    UITableViewCell *cell = (UITableViewCell*)rec.view;
    self.objectId=cell.detailTextLabel.accessibilityHint;
    EditFilmsViewController *filmEditView = [[EditFilmsViewController alloc] initWithNibName:@"EditFilmsViewController" bundle:nil];
    PFObject *film = [self.filmDictionary objectForKey: self.objectId];
    
    if (film){
        filmEditView.film = film;
        filmEditView.controller=@"All";
    }
    
    [self presentViewController:filmEditView animated:NO completion:nil];
}
- (void)deleteFilm:(id)sender
{
    UIGestureRecognizer *rec = (UIGestureRecognizer *)sender;
    
    UITableViewCell *cell = (UITableViewCell*)rec.view;
    self.objectId=cell.detailTextLabel.accessibilityHint;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Are you sure you want to delete this film?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            break;
        case 1: //"Yes" pressed
        {
            PFObject *film = [self.filmDictionary objectForKey: self.objectId];
            [film deleteInBackground];
            [self loadData];
            break;
        }
    }
}

@end
