//
//  AllFilmsViewController.m
//  MyCIFF
//
//  Created by Erin McGee on 2/21/15.
//  Copyright (c) 2015 Erin McGee. All rights reserved.
//

#import "AllFilmsViewController.h"
#import "EditFilmsViewController.h"
#import "AddFilmsViewController.h"

@interface AllFilmsViewController  ()

@property (strong, nonatomic) NSDictionary *filmDictionary;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *previousDate;

@end

@implementation AllFilmsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.filmList reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.filmList.delegate = self;
    self.filmList.dataSource = self;
    [self loadData ];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    
    
    [refresh addTarget:self action:@selector(myRefresh)
     
      forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    [self.filmList addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)myRefresh {
    [self loadData];
    [self.filmList reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

-(void) loadData
{
    
    for (UILocalNotification *lNotification in [[UIApplication sharedApplication] scheduledLocalNotifications]){
        [[UIApplication sharedApplication]cancelLocalNotification:lNotification];
        break;
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Film"];
    [query orderByAscending:@"filmDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            filmData=objects;
            self.filmDictionary = [[NSMutableDictionary alloc] initWithCapacity: filmData.count];
            UIApplication *app=[UIApplication sharedApplication];
            for (PFObject *film in filmData){
                if (film){
                    UILocalNotification *notification = [[UILocalNotification alloc]init];
                    NSDate *filmDate=[film objectForKey: @"filmDate"];
                    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                    [offsetComponents setMinute:-30]; // note that I'm setting it to -1
                    NSDate *fireDate = [gregorian dateByAddingComponents:offsetComponents toDate:filmDate options:0];
                    
                    NSLog(@"Fire date : %@",fireDate);
                    NSLog(@"Fire date : %@",fireDate);
                    //Build the notification
                    [notification setFireDate:fireDate];
                    [notification setTimeZone:[NSTimeZone defaultTimeZone]];
                    [notification setAlertAction:@"Your Next Film Is Coming Up!"];
                    [notification setApplicationIconBadgeNumber:1];
                    [notification setAlertBody:[NSString stringWithFormat:@"Your next film %@, is coming up in 30 minutes in %@ theater.",[film objectForKey: @"title"], [film objectForKey: @"theater"]]];
                    [app scheduleLocalNotification:notification];
                    [self.filmDictionary setValue: film forKey: film.objectId ];
                }
            }
            [self.filmList reloadData];
        }
        
    }];
}
- (IBAction)todaysFilms:(id)sender {
    TodaysFilmsViewController *todayView = [[TodaysFilmsViewController alloc] initWithNibName:@"TodaysFilmsViewController" bundle:nil];
    [self presentViewController:todayView animated:NO completion:nil];
}

- (IBAction)addAFilm:(id)sender {
    AddFilmsViewController *addView = [[AddFilmsViewController alloc] initWithNibName:@"AddFilmsViewController" bundle:nil];
    [self presentViewController:addView animated:NO completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [filmData count];
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
    if (filmData == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                              @"Data not found" message:nil delegate:nil cancelButtonTitle:
                              @"OK" otherButtonTitles:nil];
        [alert show];
        cell.textLabel.text = @"";
        
    }
    else{
        
        PFObject *film = [filmData objectAtIndex: indexPath.row];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM/dd/YY"];
        NSString *filmDateString = [dateFormatter stringFromDate:[film objectForKey: @"filmDate"]];
        if(![filmDateString isEqualToString:self.previousDate]){
            [dateFormatter setDateFormat:@"EEEE MM/dd/YY"];
            cell.textLabel.text =[dateFormatter stringFromDate:[film objectForKey: @"filmDate"]];
            //return cell;
        }
        cell.textLabel.text = [film objectForKey: @"title"];
        [dateFormatter setDateFormat:@"MM/dd/YY hh:mm a"];
        NSString *dateString = [dateFormatter stringFromDate:[film objectForKey: @"filmDate"]];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@ %s",dateString,[film objectForKey: @"theater"],"Theater"];
        cell.detailTextLabel.accessibilityHint= film.objectId;
        cell.textLabel.userInteractionEnabled = YES;
        [dateFormatter setDateFormat:@"MM/dd/YY"];
        self.previousDate=[dateFormatter stringFromDate:[film objectForKey: @"filmDate"]];
        
        UITapGestureRecognizer *gestureRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUrl:)];
        gestureRec.numberOfTouchesRequired = 1;
        gestureRec.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:gestureRec];
        
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
    UISwipeGestureRecognizer *rec = (UISwipeGestureRecognizer *)sender;
    
    UITableViewCell *cell = (UITableViewCell*)rec.view;
    self.objectId=cell.detailTextLabel.accessibilityHint;
    PFObject *film = [self.filmDictionary objectForKey: self.objectId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[film objectForKey:@"link"]]];
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
            EKEventStore *store = [[EKEventStore alloc] init];
            EKEvent* eventToRemove = [store eventWithIdentifier:film[@"eventID"]];
            if (eventToRemove != nil) {
                NSError* error = nil;
                [store removeEvent:eventToRemove span:EKSpanThisEvent error:&error];
            }
            [film deleteInBackground];
            [self loadData];
            break;
        }
    }
}

@end
