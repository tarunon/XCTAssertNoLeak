//
//  XCAssertNoLeakExample.swift
//  XCAssertNoLeakExample
//
//  Created by tarunon on 2019/03/13.
//  Copyright © 2019 tarunon. All rights reserved.
//

import XCTest
import XCTAssertNoLeak
@testable import XCAssertNoLeakExample

class XCAssertNoLeakExample: XCTestCase {

    func testAssertNoLeak() {
        XCTAssertNoLeak(ViewControllerLeaked())
        
        XCTAssertNoLeak { context in
            let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
            let viewController = ViewControllerLeakedViewDidAppear()
            
            rootViewController.present(viewController, animated: true, completion: {
                context.traverse(viewController)
                rootViewController.dismiss(animated: true, completion: {
                    context.completion()
                })
            })
        }
    }

}
