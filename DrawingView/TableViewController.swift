//
//  TableViewController.swift
//  DrawingViewSample
//
//  Created by debugholic on 2024/02/15.
//

import UIKit

class TableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? PageViewController {
            viewController.isDrawInSequence = indexPath.row == 0
            viewController.data = indexPath.row == 2 ? nil : [("A", "PATH_A"), ("B", "PATH_B")]
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
