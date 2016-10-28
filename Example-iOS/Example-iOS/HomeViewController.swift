//
//  ViewController.swift
//  Example-iOS
//
//  Created by SherlockYao on 10/26/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    //MARK: - Actions
    
    @IBAction func sellerButtonTouchUpInside(_ sender: AnyObject) {
        Wireframe.sharedWireframe.navigateTo(port: .detail, gate: .seller, from: self)
    }

    @IBAction func productButtonTouchUpInside(_ sender: AnyObject) {
        let params = [ WireframeParam.name.rawValue: "iPhone7" ]
        Wireframe.sharedWireframe.navigateTo(port: .detail, gate: .product, params: params, from: self)
    }

}

