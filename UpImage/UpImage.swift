//
//  UpImage.swift
//  IndustryPark
//
//  Created by Henry Gao on 2018/10/12.
//  Copyright © 2018 RedSoft. All rights reserved.
//  图片上传

import Foundation
import Alamofire
import SVProgressHUD
//import SwiftyJSON
struct UpImage {
    let upPathUrl : String
    /// 上传图片
    ///
    /// - Parameters:
    ///   - imgs: <#imgs description#>
    ///   - imgUrls: <#imgUrls description#>
    func upImages(_ imgs : [Data] , imgUrls : @escaping([String]) -> Void) {
        SVProgressHUD.show()
        DispatchQueue.global().async {
            Alamofire.upload(multipartFormData: { (items) in
                for i in 0 ..< imgs.count {
                    //                items.append(imgs[i] , withName: "", mimeType: "image/png")
                    items.append(imgs[i], withName: "files", fileName: "wangEditorH5File\(i).jpg", mimeType: "image/jpeg")
                }
            }, to: self.upPathUrl , headers: ["Authorization" : "Bearer \(LocalUser.deafult.currUserToken)"]) { (res) in
                SVProgressHUD.dismiss()
                switch res {
                case .success(request: let upload , _ , _):
                    upload.responseJSON(completionHandler: { (res1) in
                        if let jsonData = res1.data {
                            if let anys = jsonData.dic , let urls = anys["data"] as? [String] {
                                DispatchQueue.main.async {
                                    imgUrls(urls)
                                }
                            }
                        }else {
                            topMsg(msg: "未返回url地址")
                            
                        }
                    })
                case .failure(let err):
                    topMsg(msg: err.localizedDescription)
                }
            }
        }
        
    }
    /// 参数+图片 上传
    ///
    /// - Parameters:
    ///   - imgs: <#imgs description#>
    ///   - parmers: <#parmers description#>
    ///   - finished: <#finished description#>
    func upImagesWithParmers(imgs : [(Data,String)] , parmers : [String : String] , finished : @escaping () -> Void) {
        SVProgressHUD.show()
        Alamofire.upload(multipartFormData: { (items) in
            for i in 0 ..< imgs.count { // 图片
                items.append(imgs[i].0, withName: imgs[i].1, fileName: "wangEditorH5File\(i).jpg", mimeType: "image/jpeg")
            }
            for parmer in parmers { // 参数
                items.append(parmer.value.data(using: String.Encoding.utf8)! , withName: parmer.key)
            }
        }, to: upPathUrl) { (res) in
            SVProgressHUD.dismiss()
            switch res {
            case .success(request: let upload , _ , _):
                upload.responseJSON(completionHandler: { (res1) in
                    if res1.result.isSuccess {
                        if let value =  res1.result.value as? Data {
                            if let json = value.dic {
                                print(json)
                                finished()
                            }
                        }else {
                            topMsg(msg: "未返回url地址")
                        }
                    }
                })
            case .failure(let err):
                print(err.localizedDescription)
                topMsg(msg: "未返回url地址")
            }
        }
    }
    
    
    
    /// 上传单个二进制 数据
    ///
    /// - Parameters:
    ///   - data: <#data description#>
    ///   - finishe: <#finishe description#>
    ///   - err: <#err description#>
    func update(data : Data , finishe : @escaping BaseBlock<String> , err : @escaping BaseBlock<String>) {
        SVProgressHUD.show()
        var headers : [String:String] = [:]
        if LocalUser.deafult.currUserToken.count > 0 {
           headers = [ "Authorization" : "Bearer \(LocalUser.deafult.currUserToken)" ]
        }
        Alamofire.upload(multipartFormData: { (item) in
            item.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
        } , to: UrlPath.singleUpdateUrl , method: .post, headers:headers) { (res : SessionManager.MultipartFormDataEncodingResult) in
            SVProgressHUD.dismiss()
            switch res {
            case .success(request: let upload , _ , _):
                upload.responseJSON(completionHandler: { (_res) in
                    if let jsonData = _res.data , let anys = jsonData.dic , let url = anys["data"] as? String {
                        DispatchQueue.main.async { finishe(url) }
                    }else {
                        topMsg(msg: "未返回url地址")
                    }
                })
            default:
                topMsg(msg: "未返回url地址")
            }
        }
        
    }
}
