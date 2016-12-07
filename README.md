# MTCheckNewVersion
一句代码检测新版本


图例：


    ![image](http://img.blog.csdn.net/20161207102251276?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvZHh3Mjg3MTc4Nzkw/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)
    
    
如何使用?


导入头文件 #import "MTVersionHelper.h" ,在检测新版本的地方调用下面代码,一般在AppDelegate.h中:

     //1.使用默认提示框
     [MTVersionHelper checkNewVersion];

     //2.自定义提示框
      [MTVersionHelper checkNewVersionAndCustomAlert:^(MTVersionModel *appInfo) {
        //CustomView
     }];
 
