//
//  UIView+SmapleHUD.swift
//  MVC_to_MVVM
//
//  Created by GreenChiu on 2018/12/22.
//  Copyright © 2018 Green. All rights reserved.
//

import UIKit

private struct AsscoiatedKeys {
    static var HUD: UInt8 = 0
}

extension UIView {
    static func HUDView( for view: UIView ) -> UIView? {
        return view.HUD
    }
    
    static func hideHUD( for view: UIView ) -> Void {
        guard let HUD = view.HUD else {
            return
        }
        HUD.removeFromSuperview()
        view.HUD = nil
    }
    
    static func showHUD( for view: UIView ) -> Void {
        if let _ = HUDView(for: view) {
            return
        }
        
        let HUD = UIView()
        HUD.backgroundColor = UIColor(white: 0, alpha: 0.5)
        HUD.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(HUD)
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[aHud]|", options: [], metrics: nil, views: ["aHud":HUD]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[aHud]|", options: [], metrics: nil, views: ["aHud":HUD]))
        
        let loadingActivity = UIActivityIndicatorView(style: .whiteLarge)
        loadingActivity.startAnimating()
        loadingActivity.translatesAutoresizingMaskIntoConstraints = false
        HUD.addSubview(loadingActivity)
        NSLayoutConstraint(item: loadingActivity, attribute: .centerX, relatedBy: .equal, toItem: HUD, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingActivity, attribute: .centerY, relatedBy: .equal, toItem: HUD, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        view.HUD = HUD
    }
}

fileprivate extension UIView {
    var HUD: UIView? {
        set {
            objc_setAssociatedObject(self, &AsscoiatedKeys.HUD, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &AsscoiatedKeys.HUD) as? UIView
        }
    }
    
}
