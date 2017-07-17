#import "NativeAppInfoViewController.h"
#import "SWRevealViewController.h"
#import "FH.h"

@interface NativeAppInfoViewController ()

@end

@implementation NativeAppInfoViewController

- (void)viewDidLoad {
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    _loading.hidden = YES;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Block user interaction
    UIView *overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [[UIApplication sharedApplication].keyWindow addSubview:overlayView];
    
    // Start UIActivityIndicatorView
    _loading.hidden = NO;
    [_loading startAnimating];
    
    // Fire cloud request
    FHCloudRequest *req = (FHCloudRequest *) [FH buildCloudRequest:@"/getFhVars" WithMethod:@"POST" AndHeaders:nil AndArgs:nil];
    
    [req execAsyncWithSuccess:^(FHResponse * res) {
        // Response
        NSLog(@"Response: %@", res.rawResponseAsString);
        
        // Show result
        _couldAppName.text = [res.parsedResponse objectForKey:@"appName"];
        _couldDomain.text = [res.parsedResponse objectForKey:@"domain"];
        _couldEnv.text = [res.parsedResponse objectForKey:@"env"];
        _couldPort.text = [res.parsedResponse objectForKey:@"port"];
        
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
