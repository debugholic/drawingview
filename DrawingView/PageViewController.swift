//
//  PageViewController.swift
//  DrawingViewSample
//
//  Created by debugholic on 2022/01/07.
//

import UIKit

class PageViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!

    var index = 0 {
        didSet {
            self.nextButton.isHidden = index == self.data.count - 1
            self.prevButton.isHidden = index == 0
        }
    }
    
    let data = [
        ("A", "PATH_A"),
        ("B", "PATH_B"),
    ]
    
    weak var pageViewController: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "Draw") as? ViewController {
            viewController.imageName = self.data[index].0
            viewController.answerName = self.data[index].1
            pageViewController?.setViewControllers([viewController], direction: .forward, animated: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        pageViewController = segue.destination as? UIPageViewController
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        switch sender as? UIButton {
        case nextButton:
            self.index += 1
            if let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "Draw") as? ViewController {
                viewController.imageName = self.data[index].0
                viewController.answerName = self.data[index].1
                pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
            }
            break

        case prevButton:
            self.index -= 1
            if let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "Draw") as? ViewController {
                viewController.imageName = self.data[index].0
                viewController.answerName = self.data[index].1
                pageViewController?.setViewControllers([viewController], direction: .reverse, animated: true)
            }
            break

        default:
            break
        }
    }
}
