//
//  API.swift
//  webViewDemo
//
//  Created by HenryGao on 2018/6/3.
//  Copyright © 2018年 HenryGao. All rights reserved.
//  网络请求基础类

import Foundation
import Alamofire
import HandyJSON
import SVProgressHUD

// MARK: - Henry 二期 Add Base NetWorking
class API {
    static let shared = API()
    // private
    private var host : String = ""
    fileprivate var hr_session = URLSession.shared          // 请求Session
    /// codable 协议 mdoel get请求
    ///
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - parmars: <#parmars description#>
    ///   - headers: <#headers description#> // application/json ,"Authorization":"Bearer \(LocalUser.deafult.currUserId)
    ///   - dynamicKey: <#dynamicKey description#>
    ///   - finishe: <#finishe description#>
    ///   - error: <#error description#>
    func req<T: HandyJSON>(info method : HTTPMethod , url : String , parmars : [String : Any] = [:] , headers : [String:String] = ["Content-Type":"application/x-www-form-urlencoded"] , arrCode : Bool = false , finishe : @escaping BaseBlock<T>)   {
        SVProgressHUD.show()
        var newH = headers
        if LocalUser.deafult.currUserToken.count > 0 { newH["Authorization"] = "Bearer \(LocalUser.deafult.currUserToken)" }
        Alamofire.request(
            URL(string: url.trimmingCharacters(in: .whitespaces).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!,
            method: method,
            parameters: parmars,
            headers: newH).responseJSON(
            options: JSONSerialization.ReadingOptions.mutableContainers) { (res) in
                do {
                    let json = try JSONSerialization.jsonObject(with: res.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                    print(json)
                    let model = Model<T>(dic: json)
                    if model.status == 0 {
                        finishe((model.data ?? T())!)
                    }else if model.status == 500 && model.msg == "token已过期 或 账号在别处登录" {
                        let _vc : LoginMainVC = vc(sb: SB.login_rigster, vc: VC.LoginMainVC)
                        _vc.isModel = true
                        _vc.isAgain = true
                        let login : Nav = Nav(rootViewController: _vc)
                        CurrController?.present(login, animated: true, completion: nil)
                    }else { topMsg(msg: model.msg) }
                } catch _ { }
                SVProgressHUD.dismiss()
        }
    }
}
