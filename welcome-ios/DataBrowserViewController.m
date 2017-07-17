#import "DataBrowserViewController.h"
#import "SWRevealViewController.h"
#import "FH.h"

@interface DataBrowserViewController ()

@end

@implementation DataBrowserViewController

- (void)viewDidLoad {
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _loading.hidden = YES;
    
}

- (IBAction)saveData:(id)sender {
    NSLog(@"Save button was was clicked");
    
    // Block user interaction
    UIView *overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
    
    // Start UIActivityIndicatorView
    _loading.hidden = NO;
    [_loading startAnimating];
    
    // Fire cloud request
    
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Users", @"collection",
                          [NSDictionary dictionaryWithObject:_data.text forKey:@"data"], @"document",
                          nil];
    
    FHCloudRequest *req = (FHCloudRequest *) [FH buildCloudRequest:@"/saveData" WithMethod:@"POST" AndHeaders:nil AndArgs:args];
    
    [req execAsyncWithSuccess:^(FHResponse * res) {
        
        NSLog(@"Response: %@", res.rawResponseAsString);
        
        // Clean up data
        _data.text = @"";
        [_data becomeFirstResponder];
        
        // Remove block interaction layer
        [overlayView removeFromSuperview];
        
        // Stop UIActivityIndicatorView
        [_loading stopAnimating];
        _loading.hidden = YES;
        
        // Show user alert
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"Success"
                                      message:@"Yay, your data was saved in the cloud"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction* okAction = [UIAlertAction
                                    actionWithTitle:@"Ok, cool!"
                                    style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
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
