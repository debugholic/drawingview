//
//  TableViewController.swift
//  DrawingViewSample
//
//  Created by debugholic on 2024/02/15.
//

import UIKit

class TableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
