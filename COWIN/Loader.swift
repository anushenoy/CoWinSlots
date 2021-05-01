//
//  Loader.swift
//  COWIN
//
//  Created by Anush on 01/05/21.
//

import Foundation
import UIKit 
class LoaderView: UIView {
    
    var blurEffectView: UIVisualEffectView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView = blurEffectView
        addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurEffectView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blurEffectView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        addLoader()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addLoader() {
        guard let blurEffectView = blurEffectView else { return }
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
        self.layoutIfNeeded()
    }
}
extension UIView {
    func showLoader() {
        let blurLoader = LoaderView(frame: self.frame)
        
        self.addSubview(blurLoader)
        blurLoader.translatesAutoresizingMaskIntoConstraints = false
        blurLoader.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurLoader.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurLoader.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        blurLoader.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.layoutIfNeeded()
    }
    func isLoading()->Bool {
        if subviews.first(where: { $0 is LoaderView }) != nil {
            return true
        }
        return false
    }
    func hideLoader() {
        if let blurLoader = subviews.first(where: { $0 is LoaderView }) {
            blurLoader.removeFromSuperview()
        }
    }
}
