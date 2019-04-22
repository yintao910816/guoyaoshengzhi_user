//
//  PrepareRechargeViewController.swift
//  aileyun
//
//  Created by 尹涛 on 2018/9/14.
//  Copyright © 2018年 huchuang. All rights reserved.
//

import UIKit
import SVProgressHUD

class PrepareRechargeViewController: BaseViewController {

    @IBOutlet weak var visitCardOutlet: UILabel!
    @IBOutlet weak var moneyOutlet: UITextField!
    @IBOutlet weak var topCnsOutlet: NSLayoutConstraint!
    @IBOutlet weak var balanceOutlet: UILabel!
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.barTintColor = kDefaultThemeColor
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : kLightTextColor]
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
        navigationItem.title = "在线充值"
        
        topCnsOutlet.constant += HC_getTopAndBottomSpace().0
        
        visitCardOutlet.text = UserManager.shareIntance.HCUserInfo?.visitCard
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getBalance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func prepareRecharege(_ sender: Any) {
        view.endEditing(true)
        if moneyOutlet.text?.count ?? 0 > 0 {
            SVProgressHUD.show()
            HttpRequestManager.shareIntance.HC_getOrderID(visitCard: visitCardOutlet.text!, price: moneyOutlet.text!) { (ret, content) in
                if ret == true {
                    HttpRequestManager.shareIntance.HC_getPayHrefH5(callback: { [weak self] (flag, param) in
                        if flag == true {
                            SVProgressHUD.dismiss()
                            let url = param + "?orderSn=\(content)&appType=ios&appName=appName&appPackageName=com.sinopharm.shgy"
                            let webVC = WebViewController()
                            webVC.canGoBack = false
                            webVC.url = url
                            self?.navigationController?.pushViewController(webVC, animated: true)
                        }else {
                            SVProgressHUD.showError(withStatus: param)
                        }
                    })
                }else {
                    SVProgressHUD.showError(withStatus: content)
                }
            }
        }else {
            HCShowError(info: "请输入充值金额")
        }
    }
    
    private func getBalance() {
        if let cardSn = UserManager.shareIntance.HCUserInfo?.visitCard {
            HttpRequestManager.shareIntance.getBalance(cardSn: cardSn) { [weak self] (flag, model) in
                if flag == true, let m = model {
                    self?.balanceOutlet.text = String.init(format: "(余额：%.2f元)", m.balance)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
