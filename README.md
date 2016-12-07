# MTCheckNewVersion
一句代码检测新版本


效果图：
![image](https://github.com/MrTung/MTCheckNewVersion/blob/master/MTCheckVersionDemo/74F7A3E8-F720-4824-93B6-523DCCE85106.png?raw=true)

    
如何使用?


导入头文件 #import "MTVersionHelper.h" ,在检测新版本的地方调用下面代码,一般在AppDelegate.h中:

     //1.使用默认提示框
     [MTVersionHelper checkNewVersion];

     //2.自定义提示框
      [MTVersionHelper checkNewVersionAndCustomAlert:^(MTVersionModel *appInfo) {
        //CustomView
     }];
 
