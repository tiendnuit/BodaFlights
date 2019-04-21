//
//  UIViewController+Utility.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/20/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    @IBAction func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leftButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func addCloseButton(with image: UIImage? = #imageLiteral(resourceName: "ArrowBack")) {
        let closeButtonItem = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal),
                                              style: .plain,
                                              target: self,
                                              action: #selector(UIViewController.closeTapped))
        navigationItem.leftBarButtonItem = closeButtonItem
    }
    
    func addCloseButton(with title:String) {
        let closeButtonItem = UIBarButtonItem(title: title,
                                              style: .plain,
                                              target: self,
                                              action: #selector(UIViewController.closeTapped))
        navigationItem.leftBarButtonItem = closeButtonItem
    }
    
    func addLeftButton(image: UIImage?, title: String?) {
        if let image = image {
            let closeButtonItem = UIBarButtonItem(image: image.withRenderingMode(.alwaysOriginal),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(UIViewController.leftButtonTapped))
            navigationItem.leftBarButtonItem = closeButtonItem
        } else if let title = title {
            let closeButtonItem = UIBarButtonItem(title: title,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(UIViewController.leftButtonTapped))
            navigationItem.leftBarButtonItem = closeButtonItem
        } else {
            addCloseButton()
        }
    }
    
    func dismiss() {
        if let nc = navigationController, nc.viewControllers.count > 1 {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func show(viewController: UIViewController) {
        if let nc = navigationController {
            nc.pushViewController(viewController, animated: true)
        } else {
            presentModally(viewController: viewController)
        }
    }
    
    func presentModally(viewController: UIViewController, closeEnable: Bool = false) {
        if closeEnable {
           viewController.addCloseButton(with: "Close")
        }
        
        let nc = UINavigationController(rootViewController: viewController)
        present(nc, animated: true, completion: nil)
    }
    
    static func topMostController() -> UIViewController {
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        var topController: UIViewController = delegate!.window!.rootViewController!
        for _ in 0..<2 {
            while topController.presentedViewController != nil && topController.presentedViewController?.isKind(of: UIAlertController.self) == false {
                topController = topController.presentedViewController!
            }
            if (topController.isKind(of: UITabBarController.self)) {
                topController = ((topController as! UITabBarController)).selectedViewController!
            }
            if (topController.isKind(of: UINavigationController.self)) {
                topController = ((topController as! UINavigationController)).topViewController!
            }
        }
        return topController
    }
}


//MARK: - UIAlertViewController
extension UIAlertController {
    
    static func okAlertWithTitle(_ title: String, message: String?, okTapped: (()->Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            okTapped?()
        }))
        return alertController
    }
    
    static func destructiveQuestionAlertWithTitle(_ title: String, message: String?, destructiveButtonTitle: String, destructiveTapped: @escaping ()->Void) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: destructiveButtonTitle, style: .destructive, handler: { action in
            destructiveTapped()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alertController
    }
    
    static func presentOKAlertWithTitle(_ title: String, message: String?, okTapped: (()->Void)? = nil) {
        let alertController = UIAlertController.okAlertWithTitle(title, message: message, okTapped: okTapped)
        UIViewController.topMostController().present(alertController, animated: true, completion: nil)
    }
    
    static func presentOKAlertWithError(_ error: NSError, title: String? = nil, okTapped: (()->Void)? = nil) {
        presentOKAlertWithTitle(title ?? error.domain, message: error.localizedDescription)
    }
}
