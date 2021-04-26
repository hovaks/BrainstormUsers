//
//  UITableView+Extensions.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T>(type: T.Type) -> T? where T: UITableViewCell {
        dequeueReusableCell(withIdentifier: String(describing: T.self)) as? T
    }
}
