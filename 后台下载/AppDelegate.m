//
//  AppDelegate.m
//  后台下载
//
//  Created by 李亮 on 15/6/25.
//  Copyright (c) 2015年 李亮. All rights reserved.
//

#import "AppDelegate.h"
#import "L8Log.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
   如果程序开启了一个后台网络任务（通过backgroundSessionConfiguration），在任务完成之前，程序被关闭了，那么后台任务会在另外的进程继续执行。当后台任务执行完毕，或者收到验证消息之后，系统会重启我们的应用程序，把应用程序置为background状态，并且调用下面这个方法，告诉我们根据指定的identifier创建一个backgroundSession，然后系统会自动把后台任务关联到这个session，并且通过session的代理方法处理后台任务的相关事件。
 
    如果当任务完成，或者收到验证消息时，程序正处于suspended状态，系统不会调用这个方法。因为此时，创建任务的session并没有被释放（因为任务没完成），会继续使用原来的session的代理方法处理后台任务的相关事件。
 
    如果任务下载完成之前，程序被关闭了。但是在在下载完成前，用户又打开了这个程序，此时程序也要记录未完成到session任务，并且在启动之后重新创建identifier相同的session并且设置代理，此时，系统会自动把后台session关联到我们重新创建的这个identifier相同的session，并且使用这个session的代理处理后台任务的相关事件。
 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    NSLog(@"%s", __FUNCTION__);
    [L8Log log:@"%@", @(__FUNCTION__),nil];
    /*
     这个方法中，我们并没有根据identifier创建session，因为当系统重新启动应用程序时，viewController的viewDidLoad方法会被调用，而viewDidLoad方法中会创建session。而且handleEventsForBackgroundURLSession方法传过来的identifier实际上就是viewDidLoad方法中创建session时使用的identifier。
     
     这里只需要保存completionHandler，在适当的时机执行一下改block，告诉系统，可以更新应用程序的快照了。
     */
    self.backgroundSessionCompletionHandler = completionHandler;
}

//下面的方法不需关注
-(void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    [L8Log log:@"%@", @(__FUNCTION__),nil];
}


-(void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"%s", __FUNCTION__);
    [L8Log log:@"%@", @(__FUNCTION__),nil];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSLog(@"%s", __FUNCTION__);
    [L8Log log:@"%@", @(__FUNCTION__),nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSLog(@"%s", __FUNCTION__);
    [L8Log log:@"%@", @(__FUNCTION__),nil];
}



- (void)applicationWillTerminate:(UIApplication *)application {

    NSLog(@"%s", __FUNCTION__);
    [L8Log log:@"%@", @(__FUNCTION__),nil];
}

@end
