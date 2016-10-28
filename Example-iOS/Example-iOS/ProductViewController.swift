//
//  ProductViewController.swift
//  Example-iOS
//
//  Created by SherlockYao on 10/27/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import Foundation

import UIKit

class ProductViewController: UIViewController {
    
    var productName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewComponents()
    }
    
    // MARK: - Actions
    
    func dismissButtonTouchUpInside(_ sender: AnyObject) {
        Wireframe.sharedWireframe.navigateTo(port: .back, from: self)
    }
    
    // MARK: - Private Section
    
    private func setupViewComponents() {
        if let productName = productName {
            title = "Product Detail for \(productName)"
        }
        
        view.backgroundColor = UIColor.white
        
        let backButton = UIButton(frame: CGRect(x: 16, y: 68, width: 80, height: 44))
        backButton.setTitle("Dismiss", for: .normal)
        backButton.setTitleColor(UIColor.blue, for: .normal)
        backButton.addTarget(self, action: #selector(dismissButtonTouchUpInside(_:)), for: .touchUpInside)
        view.addSubview(backButton)
    }
}
