# background-task
后台下载任务示例代码（苹果帮助文档示例程序）

 使用说明：
 点击button后，开始下载。
 下载完成后，imageView背景变绿。
 
 1、
 如果在下载完成之前，关闭程序。此时任务会在后台进程继续进行下载。
 此时不进行任何操作，等待下载任务完成之后，系统会自动唤醒该程序（把程序设置为后台运行状态），并且调用appDelegate的
 - (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
方法（可通过后台日志观察是否调用了这个方法）。
然后当用户再次进入程序时，发现背景已经变为绿色，代表下载完成了，说明后台任务执行正确。

2、
如果在下载完成之前，关闭程序。此时任务会在后台进程继续进行下载。
如果在任务下载完成之前，用户又打开程序，会发现控制台日志继续打印下载进度（而且根据进度判断，不是从新下载），代表下载任务一直在进行中，说明后台任务执行正确。
等下载完成之后，背景变绿色。

3、
可根据控制台日志和文件日志观察程序运行过程。

L8Log类用来写文件日志。
