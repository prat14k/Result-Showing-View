//
//  ViewController.swift
//  Result Show App
//
//  Created by Prateek Sharma on 9/24/18.
//  Copyright © 2018 Prateek Sharma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let resultView = ResultView.createNdAdd(in: view)
        resultView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        resultView.center = view.center
        
        resultView.scoreValue = 96
    
        DispatchQueue.main.async { [weak self] in
            resultView.startDrawing()
        }
    }

}

