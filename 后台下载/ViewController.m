//
//  ViewController.m
//  后台下载
//
//  Created by 李亮 on 15/6/25.
//  Copyright (c) 2015年 李亮. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "L8Log.h"

/*
 开启后台下载线程（下载一个qq程序包...因为没找到很大的图片），当下载完成之后，把imageView的背景颜色设置为绿色。
 */

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

@end

static NSString *DownloadURLString = @"http://sqdd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk";

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //创建session
    self.session = [self backgroundSession];
    
    self.progressView.progress = 0;
    self.imageView.hidden = NO;
    self.progressView.hidden = YES;
    
}

//关联一个按钮事件，点击按钮开始下载
- (IBAction)start:(id)sender
{
    if (self.downloadTask)
    {
        return;
    }
    
    /*
     开始下载
     */
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.downloadTask = [self.session downloadTaskWithRequest:request];
    [self.downloadTask resume];
    
    self.imageView.hidden = YES;
    self.progressView.hidden = NO;
}


- (NSURLSession *)backgroundSession
{
    /*
     Using disptach_once here ensures that multiple background sessions with the same identifier are not created in this instance of the application. If you want to support multiple background sessions within a single process, you should create each session with its own identifier.
     */
    NSLog(@"%s", __FUNCTION__);;
    [L8Log log:@"%@", @(__FUNCTION__),nil];
    
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.example.apple-samplecode.SimpleBackgroundTransfer.BackgroundSession"];
        
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"%s", __FUNCTION__);;
    [L8Log log:@"%@", @(__FUNCTION__),nil];
    /*
     Report progress on the task.
     If you created more than one task, you might keep references to them and report on them individually.
     */
    
    if (downloadTask == self.downloadTask)
    {
        double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
        [L8Log log:@"DownloadTask: %@ progress: %@", downloadTask, @(progress),nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = progress;
        });
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL
{
    NSLog(@"%s", __FUNCTION__);;
    [L8Log log:@"%@", @(__FUNCTION__),nil];
    /*
     The download completed, you need to copy the file at targetPath before the end of this block.
     As an example, copy the file to the Documents directory of your app.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
    NSURL *originalURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[originalURL lastPathComponent]];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
    
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置imageView背景颜色，代表下载完成。
            self.imageView.backgroundColor = [UIColor greenColor];
            self.imageView.hidden = NO;
            self.progressView.hidden = YES;
        });
    }
    else
    {
        /*
         In the general case, what you might do in the event of failure depends on the error and the specifics of your application.
         */
        NSLog(@"Error during the copy: %@", [errorCopy localizedDescription]);
        [L8Log log:@"%@", @"Error during the copy",nil];
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);;
    [L8Log log:@"%@", @(__FUNCTION__),nil];
    
    if (error == nil)
    {
        NSLog(@"Task: %@ completed successfully", task);
        [L8Log log:@"Task: %@ completed successfully",task,nil];
    }
    else
    {
        NSLog(@"Task: %@ completed with error: %@", task, [error localizedDescription]);
        [L8Log log:@"Task: %@ completed with error: %@", task, [error localizedDescription],nil];
    }
    
    double progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
    
    self.downloadTask = nil;
}


/*
 If an application has received an -application:handleEventsForBackgroundURLSession:completionHandler: message, the session delegate will receive this message to indicate that all messages previously enqueued for this session have been delivered. At this time it is safe to invoke the previously stored completion handler, or to begin any internal updates that will result in invoking the completion handler.
 */
//这个方法我没弄明白，一直也没见系统调用这个方法？？？
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            completionHandler();
        }];
    }
    
    NSLog(@"All tasks are finished");
    [L8Log log:@"All tasks are finished",nil];
}


-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    [L8Log log:@"%@", @(__FUNCTION__),nil];
    NSLog(@"All tasks are finished");
}

@end
