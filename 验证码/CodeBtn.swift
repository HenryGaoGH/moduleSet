//
//  CodeBtn.swift
//  newHouse
//
//  Created by Henry Gao on 2018/12/8.
//  Copyright © 2018 Henry Gao. All rights reserved.
//  验证码

import UIKit
class CodeButton: UIButton {
    var phone : String = ""
    var callBack : BaseBlock<(CodeButton,Int)>?
    var sendCode : BaseBlock<String>?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        UI()
    }
    private func UI() {
        self.addTarget(self , action: #selector(countdown), for: .touchUpInside)
        self.setTitle("获取验证码", for: .normal)
        self.setTitle("60 s", for: .selected)
        self.backgroundColor = rgba(47, 137, 252, 1)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.addCornerRadius = 4
    }
    
    @objc private func countdown() {
        if isSelected { return }
        if !getCode() { return }
        isSelected = true
        DispatchTimer(timeInterval: 1 , repeatCount: 60) { (timer, count) in
            self.callBack?((self,count))
            self.setTitle("\(count) s", for: .selected)
            if count == 0 {
                self.isSelected = false
            }
        }
    }
    private func getCode() -> Bool{
        guard phone != "" , phone.isPhone else {
            alert("手机号不能为空")
            return false
        }
        sendCode?(phone) // 发送验证码
        return true
    }
}

