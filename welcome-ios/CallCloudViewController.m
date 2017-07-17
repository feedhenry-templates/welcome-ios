#import "CallCloudViewController.h"
#import "SWRevealViewController.h"
#import "FH.h"

@interface CallCloudViewController ()

@end

@implementation CallCloudViewController

- (void)viewDidLoad {
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _loading.hidden = YES;
    
}

- (IBAction)callCloud:(id)sender {
    
    NSLog(@"Call cloud was clicked");
    
    // Block user interaction
    UIView *overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
    
    // Start UIActivityIndicatorView
    _loading.hidden = NO;
    [_loading startAnimating];
    
    // Fire cloud request
    FHCloudRequest *req = (FHCloudRequest *) [FH buildCloudRequest:@"/hello" WithMethod:@"POST" AndHeaders:nil AndArgs:nil];
    
    [req execAsyncWithSuccess:^(FHResponse * res) {
        // Response
        NSLog(@"Response: %@", res.rawResponseAsString);
        NSLog(@"Text: %@", [res.parsedResponse objectForKey:@"text"]);
        
        // Show result
        _result.text = [res.parsedResponse objectForKey:@"text"];
        
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
