// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashView: UIView {
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        let logoImageView = UIImageView(image: R.image.launchIcon())
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
