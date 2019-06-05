//
//  PaymentViewController.swift
//  Alice
//
//  Created by lmcmz on 5/6/19.
//

import UIKit

class PaymentViewController: UIViewController {
    
    
    @IBOutlet weak var payButton: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(hex: "#659BEF"), UIColor(hex: "#2060CB")]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        payButton.layer.addSublayer(gradient)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        payButton.roundCorners(corners: .allCorners, radius: 8)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
