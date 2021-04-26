//
//  UIViewController+Extensions.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 24.04.21.
//

import UIKit

extension UIViewController {
    func performSegue<T>(to: T.Type, sender: Any? = nil) where T: UIViewController {
        performSegue(withIdentifier: String(describing: T.self) + "Segue", sender: sender)
    }

    func showErrorAlert(error: AlertableError) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
