//
//  AddFilmsViewController.m
//  MyCIFF
//
//  Created by Erin McGee on 4/8/14.
//  Copyright (c) 2014 Erin McGee. All rights reserved.
//

#import "AddFilmsViewController.h"
#import "AllFilmsViewController.h"
#import <EventKit/EventKit.h>

@interface AddFilmsViewController ()

@end

@implementation AddFilmsViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datePicker.hidden=true;
    self.colorPicker.delegate = self;
    self.colorPicker.dataSource = self;
    self.colorPicker.hidden=true;
    self.colorArray= @[@"Blue", @"Brown", @"Green",
                        @"Grey", @"Orange", @"Purple", @"Red", @"Yellow"];
    [self.datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/YY hh:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    self.dateTimeLabel.text=dateString;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches)
    {
        if(touch.view.tag == 1)
        {
            if(self.colorPicker.hidden)
            {
                self.colorPicker.hidden = false;
                self.datePicker.hidden = true;
            }
        }else if(touch.view.tag == 2)
        {
            if(self.datePicker.hidden)
            {
                self.datePicker.hidden = false;
                self.colorPicker.hidden = true;
            }
        }
        else
        {
            self.datePicker.hidden = true;
            self.colorPicker.hidden = true;
        }
        
        [self.filmTitle resignFirstResponder];
        [self.filmLength resignFirstResponder];
    }
}
- (IBAction)cancelAddFilm:(id)sender {
    
    AllFilmsViewController *allView = [[AllFilmsViewController alloc] initWithNibName:@"AllFilmsViewController" bundle:nil];
    [self presentViewController:allView animated:NO completion:nil];
}

- (IBAction)addFilm:(id)sender {
    NSString *alertString = @"Data Insertion failed";
    if (self.filmTitle.text.length>0)
    {
        EKEventStore *store = [[EKEventStore alloc] init];
        
        NSString *link =[@"http://www.clevelandfilm.org/films/2016/" stringByAppendingString:self.filmTitle.text];
        
        link = [link stringByReplacingOccurrencesOfString:@" "
                                               withString:@"-"];
        
        link = [link stringByReplacingOccurrencesOfString:@"'"
                                               withString:@""];
        
        link = [link stringByReplacingOccurrencesOfString:@":"
                                               withString:@"-"];
        
        link = [link stringByReplacingOccurrencesOfString:@"-//"
                                               withString:@"://"];
        
        link = [link stringByReplacingOccurrencesOfString:@"?"
                                               withString:@""];
        
        link = [link stringByReplacingOccurrencesOfString:@"!"
                                               withString:@""];
        
        link = [link stringByReplacingOccurrencesOfString:@"+"
                                               withString:@"-"];
        
        link = [link stringByReplacingOccurrencesOfString:@"--"
                                               withString:@"-"];
        
        
        NSMutableString *filmTitle = [NSMutableString string];
        NSString * secondChar=[self.filmTitle.text substringWithRange:NSMakeRange(1, 2)];
        if([secondChar rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound){
            NSString *previousChar=@" ";
            for (NSInteger i=0; i<self.filmTitle.text.length; i++){
                NSString *ch = [self.filmTitle.text substringWithRange:NSMakeRange(i, 1)];
                if([ch isEqualToString:@" "] || [ch isEqualToString:@"-"] || [ch isEqualToString:@":"] || [ch isEqualToString:@"'"]){
                    [filmTitle appendString:ch];
                }else{
                    if ([ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound && !   [previousChar isEqualToString:@" "]) {
                        [filmTitle appendString:[ch lowercaseString]];
                    }else{
                        [filmTitle appendString:ch];
                    }
                }
                previousChar=ch;
            }
        }else{
            [filmTitle setString:self.filmTitle.text];
        }
        
        PFObject *film = [PFObject objectWithClassName:@"Film"];
        film[@"title"] = [filmTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        film[@"link"] = link;
        film[@"filmDate"] = self.datePicker.date;
        film[@"theater"] = self.theaterColor.text;
        film[@"filmLength"] = self.filmLength.text;
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [NSString stringWithFormat:@"CIFF: %@",[filmTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        event.startDate = self.datePicker.date;
        event.endDate = [self.datePicker.date dateByAddingTimeInterval: (self.filmLength.text.intValue *60)];
        event.location = [NSString stringWithFormat:@"%@ Theater",self.theaterColor.text];
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        NSString* str = [[NSString alloc] initWithFormat:@"%@", event.eventIdentifier];
        film[@"eventID"] = str;
        [film saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (!granted) { return; }
                }];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:
                                      alertString message:error.description
                                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
        AllFilmsViewController *allView = [[AllFilmsViewController alloc] initWithNibName:@"AllFilmsViewController" bundle:nil];
        [self presentViewController:allView animated:NO completion:nil];
    }
    else{
        alertString = @"Enter a title and time";
    }
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 8;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component{
    
    self.theaterColor.text=[self.colorArray objectAtIndex:row];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [self.colorArray objectAtIndex:row];
}

- (IBAction)datePickerDateChanged:(id)sender {
    
    NSDate *today1 = self.datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/YYYY' 'hh:mm a"];
    NSString *dateString11 = [dateFormat stringFromDate:today1];
    self.dateTimeLabel.text=dateString11;
}

@end
