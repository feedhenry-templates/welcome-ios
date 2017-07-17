#import "LocationViewController.h"
#import "SWRevealViewController.h"
#import "FH.h"

@interface LocationViewController ()

@end

@implementation LocationViewController

- (void)viewDidLoad {
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _loading.hidden = YES;
    
}

- (IBAction)retrieveWeatherInfo:(id)sender {

    NSLog(@"Get My Location was clicked");
    
    // Block user interaction
    UIView *overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
    
    // Start UIActivityIndicatorView
    _loading.hidden = NO;
    [_loading startAnimating];
    
    // Fire cloud request
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:_latitude.text, @"lat", _longitude.text, @"lon", nil];
    
    FHCloudRequest *req = (FHCloudRequest *) [FH buildCloudRequest:@"/getWeather" WithMethod:@"POST" AndHeaders:nil AndArgs:args];
    
    [req execAsyncWithSuccess:^(FHResponse * res) {

        NSLog(@"Response: %@", res.rawResponseAsString);
        
        NSDictionary *responseDictionary = res.parsedResponse;
        NSArray *responseData = [responseDictionary objectForKey:@ "data"];
        NSDictionary *data = responseData[0];

        NSLog(@"Data: %@", data);
        
        // Show result
        _weatherDescription.text = [data objectForKey:@"desc"];
        _weatherDate.text = [data objectForKey:@"date"];
        _weatherLow.text = [data objectForKey:@"low"];
        _weatherHigh.text = [data objectForKey:@"high"];
        
        NSLog(@"Description: %@", [data objectForKey:@"desc"]);
        
        // Remove block interaction layer
        [overlayView removeFromSuperview];
        
        // Stop UIActivityIndicatorView
        [_loading stopAnimating];
        _loading.hidden = YES;
        
    } AndFailure:^(FHResponse * res){
        
        NSLog(@"Failed to call. Response = %@", res.rawResponseAsString);
        
        // Remove block interaction layer
        [overlayView removeFromSuperview];
        
        // Stop UIActivityIndicatorView
        [_loading stopAnimating];
        _loading.hidden = YES;
        
        // Show user alert
        NSString * message = @"Oops, something went wrong";
        if (res.parsedResponse) {
            message = [res.parsedResponse objectForKey:@"msg"];
        }
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Failure"
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction
                                   actionWithTitle:@"Ok, roger that!"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];

}

@end

