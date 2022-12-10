//
//  ViewController.swift
//  GdyJsBridge2-iOS
//
//  Created by Apple on 2022/11/22.
//

import UIKit
import GdyJsBridge2
class ViewController: UIViewController {

    var lblJsMessage: UILabel!
    var btnCallJsMethod1: UIButton!
    var btnCallJsMethod2: UIButton!
    var wkwebView: GDYWKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
        registApiForJs()
        
//        let urlRequest = URLRequest(url: Bundle.main.url(forResource: "test", withExtension: "html")!)
        let urlRequest = URLRequest(url: URL(string: "https://web.guangdianyun.tv/live/1000376?uin=1000")!)
        self.wkwebView.load(urlRequest)
        // 在wkwebView之后就可以直接调用callJsFunction了， 可以不用监听navigationDelegate的
        wkwebView.callJsFunction(method: "onLimitedMode") { [weak self] success, data in
            if success {
                self?.showMessage(message: "onLimitedMode called")
            } else {
                self?.showMessage(message: "onLimitedMode called failed, \(data as? String ?? "nil")")
            }
            
        }
    }

    func setup() {
        self.title = "Native code <-> JS"
        
        let screenSize = UIScreen.main.bounds
        
        self.wkwebView = GDYWKWebView(frame: CGRect.init(x: 0, y: 0, width: screenSize.width, height: screenSize.height/2))
        self.view.addSubview(self.wkwebView)
        // message label
        self.lblJsMessage = UILabel()
        lblJsMessage.frame = CGRect.init(x: 0, y: screenSize.height - 270, width: screenSize.width, height: 100)
        lblJsMessage.textAlignment = .center
        lblJsMessage.numberOfLines = 0
        lblJsMessage.backgroundColor = .orange
        lblJsMessage.isHidden = true
        self.view.addSubview(self.lblJsMessage)
        
        self.btnCallJsMethod1 = UIButton.init(type: .custom)
        btnCallJsMethod1.frame = CGRect.init(x: 8, y: screenSize.height - 182, width: screenSize.width - 16 , height: 50)
        btnCallJsMethod1.setTitle("Swift 调用 JS 方法获取信息", for: .normal)
        btnCallJsMethod1.setTitleColor(.black, for: .normal)
        btnCallJsMethod1.backgroundColor = .white
        btnCallJsMethod1.layer.borderColor = UIColor.gray.cgColor
        btnCallJsMethod1.layer.borderWidth = 1
        btnCallJsMethod1.addTarget(self, action: #selector(onCallJsMethod1), for: .touchUpInside)
        self.view.addSubview(self.btnCallJsMethod1)
        
        // button
        self.btnCallJsMethod2 = UIButton.init(type: .custom)
        btnCallJsMethod2.frame = CGRect.init(x: 8, y: screenSize.height - 118, width: screenSize.width - 16 , height: 50)
        btnCallJsMethod2.setTitle("Swift 调用 JS 方法获取对象", for: .normal)
        btnCallJsMethod2.setTitleColor(.black, for: .normal)
        btnCallJsMethod2.backgroundColor = .white
        btnCallJsMethod2.layer.borderColor = UIColor.gray.cgColor
        btnCallJsMethod2.layer.borderWidth = 1
        btnCallJsMethod2.addTarget(self, action: #selector(onCallJsMethod2), for: .touchUpInside)
        self.view.addSubview(self.btnCallJsMethod2)
    }
    
    @objc func onCallJsMethod1() {
        let js = [1,"a",false] as [Any]
        wkwebView.callJsFunction(method: "getStringFromJs", args:js) { [weak self] (success, value) in
            if success {
                self?.showMessage(message: "message From js: \(value as? String ?? "无返回值")")
            } else {
                self?.showMessage(message: "方法调用失败, 原因：\(value as! String)")
            }
        }
    }
    
    @objc func onCallJsMethod2() {
        self.wkwebView.callJsFunction(method: "getObjectFromJs") { [weak self] (success, value) in
            if success {
                self?.showMessage(message: "objectFromJs: \(value as? Dictionary ?? [String : AnyObject]())")
            } else {
                self?.showMessage(message: "方法返回失败，原因：\(value as? String ?? "")")
            }
        }
    }

    func registApiForJs() {
        self.wkwebView.registApi(method: "loginRequest") { [weak self] args in
            self?.showMessage(message: "called loginRequest")
        }
        // 简单测试方法
        self.wkwebView.registApi(method: "getStringFromNative") { args in
            print("-----> recived js message: \(args.description)\n\n")
            var str = ""
            for arg in args {
                if arg is String {
                    str += arg as! String
                }
                if arg is Bool {
                    str += (arg as! Bool ? "true" : "false")
                }
            }
            return str
        }
        
        // 简单测试方法
        self.wkwebView.registApi(method: "getObjectFromNative") { _ in
            return ["key1":"value1", "key2":"value2"]
        }
        
    }
    
    // 显示信息
    fileprivate func showMessage(message: String) {
        self.lblJsMessage.text = message
        
        DispatchQueue.main.async {
            self.lblJsMessage.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self.lblJsMessage.isHidden = true
            })
        }
    }

    
}

