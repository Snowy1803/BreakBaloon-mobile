//
//  ECLoginManager.swift
//  BreakBaloon
//
//  Created by Emil Pedersen on 06/07/2021.
//  Copyright © 2021 Snowy_1803. All rights reserved.
//

import Foundation
import UIKit

class ECLoginManager {
    static let shared = ECLoginManager()
    var loggedIn: Bool = false
    
    func logInDialog(username: String? = nil, password: String? = nil, delegate: Delegate) {
        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.text", comment: ""), preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("login.username.placeholder", comment: "")
            textField.text = username
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("login.password.placeholder", comment: "")
            textField.text = password
            textField.isSecureTextEntry = true
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default) { _ in
            self.logIn(username: alert.textFields![0].text!, password: alert.textFields![1].text!, delegate: delegate)
        })
        delegate.present(alert: alert)
    }
    
    func logIn(username: String, password: String, delegate: Delegate?) {
        logIn(query: "user=\(username)&passwd=\(password)&v2&appid=ibb", username: username, password: password, delegate: delegate)
    }
    
    func logIn(sessid: String, delegate: Delegate?) {
        logIn(query: "sessid=\(sessid)", delegate: delegate)
    }
    
    func logIn(query: String, username: String? = nil, password: String? = nil, delegate: Delegate?) {
        let request = NSMutableURLRequest(url: URL(string: "http://elementalcube.infos.st/api/auth.php")!)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil, data != nil else {
                print("[LOGIN] error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("[LOGIN] status code: \(httpStatus.statusCode)")
                print("[LOGIN] response: \(String(describing: response))")
            }
            DispatchQueue.main.async {
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                let authStatus = responseString?.components(separatedBy: "\r\n")[0]
                if let authStatus = authStatus,
                   let authStatusInt = Int(authStatus) {
                    let status = LoginStatus(rawValue: authStatusInt)
                    switch status {
                    case .authenticated:
                        let sessid = responseString!.components(separatedBy: "\r\n")[1]
                        UserDefaults.standard.set(sessid, forKey: "elementalcube.sessid")
                        self.loggedIn = true
                        delegate?.loginDidComplete()
                    case .tfaRequired:
                        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.error.\(String(describing: status!))", comment: ""), preferredStyle: .alert)
                        alert.addTextField(configurationHandler: { textField in
                            textField.placeholder = NSLocalizedString("login.2fa.placeholder", comment: "")
                        })
                        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("login.title", comment: ""), style: .default) { _ in
                            self.logIn(query: "\(query)&code=\(alert.textFields![0].text!)", delegate: delegate)
                        })
                        delegate?.present(alert: alert)
                    case let .some(status):
                        let alert = UIAlertController(title: NSLocalizedString("login.title", comment: ""), message: NSLocalizedString("login.error.\(status)", comment: ""), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
                        alert.addAction(UIAlertAction(title: NSLocalizedString("login.tryagain", comment: ""), style: .default) { _ in
                            if status == .invalidUsername || status == .incorrectPassword {
                                self.logInDialog(username: username, password: password, delegate: delegate!)
                            } else {
                                self.logIn(query: query, delegate: delegate)
                            }
                        })
                        delegate?.present(alert: alert)
                    case .none:
                        break
                    }
                }
            }
        })
        task.resume()
    }
    
    func logOut() {
        UserDefaults.standard.set(nil, forKey: "elementalcube.sessid")
        loggedIn = false
    }
    
    typealias Delegate = ECLoginDelegate
}

protocol ECLoginDelegate: AnyObject {
    func present(alert: UIAlertController)
    func loginDidComplete()
}

enum LoginStatus: Int {
    case authenticated = 1
    case invalidUsername = -1
    case dbError = -2
    case invalidSessID = -3
    case incorrectPassword = -4
    case profileDeactivated = -5
    case tfaRequired = -6
}
