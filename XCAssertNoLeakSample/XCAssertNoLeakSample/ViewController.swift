//
//  ViewController.swift
//  XCAssertNoLeakSample
//
//  Created by tarunon on 2019/03/13.
//  Copyright © 2019 tarunon. All rights reserved.
//

import UIKit

class ViewControllerNoLeak: UIViewController {
    
    let button = UIButton()
    let slider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(changed(_:)), for: .valueChanged)
    }

    @objc func tapped(_ sender: UIButton) {
        
    }

    @objc func changed(_ sender: UISlider) {
        
    }
}

class ViewControllerLeaked: UIViewController {
    lazy var observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: leakedMethod(_:))
    
    init() {
        super.init(nibName: nil, bundle: nil)
        _ = observer
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func leakedMethod(_ notification: Notification) {
        
    }
}

class ViewControllerLeakedViewDidAppear: UIViewController {
    lazy var observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: leakedMethod(_:))
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = observer
    }
    
    func leakedMethod(_ notification: Notification) {
        
    }
}

