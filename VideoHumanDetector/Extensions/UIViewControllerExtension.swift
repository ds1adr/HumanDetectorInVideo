//
//  UIViewControllerExtension.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/24/23.
//

import UIKit

extension UIViewController {
    @MainActor
    func displayError(error: Error) {
        displayAlert(title: "Error", message: error.localizedDescription)
    }

    @MainActor
    func displayAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        self.present(alertController, animated: true)
    }
}
