//
//  ViewController.m
//  savePhoto2CameraRoll
//
//  Created by zhanghe on 2016/10/31.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *Photo;
- (PHAssetCollection *)createdCollection;
- (PHFetchResult<PHAsset *> *)createdAsset;
@end
@implementation ViewController
//保存照片到相册
- (IBAction)savePhoto {

    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    //请求/检查访问权限
    //如果用户还没有做出选择，会自动弹框，用户对弹框做出选择后才会调用block
    //如果之前做过选择，会直接执行调用block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) {//用户拒绝当前APP访问相册
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    //提醒用户打开开关
                }
            }else if (status == PHAuthorizationStatusAuthorized) {//用户允许当前APP访问相册
                [self saveImageIntoAlbum];
            }else if (status == PHAuthorizationStatusRestricted) {//无法访问相册
                //因系统原因无法访问相册
            }
        });
    }];

}
//保存照片到自定义相册
- (void)saveImageIntoAlbum{
    //保存图片到相机胶卷
    PHFetchResult<PHAsset *> *createdAsset = self.createdAsset;
    if (createdAsset == nil) {
        //保存照片失败
        return;
    }
    //获得相册
    PHAssetCollection *collection = self.createdCollection;
    if (collection == nil) {
        //创建相册失败
        return;
    }
    //把刚才添加到相机胶卷的照片放到自定义相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        [request insertAssets:createdAsset atIndexes:[NSIndexSet indexSetWithIndex:0]];
        
    } error:&error];
    if (error) {
        //保存图片失败
        return;
    }
}
//返回刚才保存到相机胶卷的照片
- (PHFetchResult<PHAsset *> *)createdAsset{
    
    NSError *error = nil;
    //保存照片到相机胶卷
    __block NSString * createdID = nil;
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdID = [PHAssetChangeRequest creationRequestForAssetFromImage:self.Photo.image].placeholderForCreatedAsset.localIdentifier;
        
    } error:&error];
    if (error) return nil;
    
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdID] options:nil];

}
//当前APP对应的相册
- (PHAssetCollection *)createdCollection{
    
    //获取应用的名字
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    //抓取所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //查找当前APP对应的自定义相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    /** 当前APP对应的自定义相册没有被创建过 **/
    NSError *error = nil;
    __block NSString *createdCollectionID;
    //创建一个相册,拿到相册的唯一标识符
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdCollectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) return nil;

    //根据相册的唯一标识符拿到相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionID] options:nil].firstObject;

}
@end
