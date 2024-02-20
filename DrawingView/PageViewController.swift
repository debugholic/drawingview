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
            nextButton.isHidden = !(index < (data?.count ?? 0) - 1)
            prevButton.isHidden = !(index > 0)
        }
    }
    
    var data: [(String, String)]?
    var isDrawInSequence: Bool = true
    weak var pageViewController: UIPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "Draw") as? ViewController {
            if index < (data?.count ?? 0) {
                viewController.imageName = data?[index].0
                viewController.answerName = data?[index].1
            }
            viewController.isDrawInSequence = isDrawInSequence
            pageViewController?.setViewControllers([viewController], direction: .forward, animated: false)
        }
        nextButton.isHidden = !(index < (data?.count ?? 0) - 1)
        prevButton.isHidden = !(index > 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        pageViewController = segue.destination as? UIPageViewController
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        switch sender as? UIButton {
        case nextButton:
            index += 1
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "Draw") as? ViewController {
                if index < (data?.count ?? 0) {
                    viewController.imageName = data?[index].0
                    viewController.answerName = data?[index].1
                }
                viewController.isDrawInSequence = isDrawInSequence
                pageViewController?.setViewControllers([viewController], direction: .forward, animated: true)
            }
            break

        case prevButton:
            index -= 1
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "Draw") as? ViewController {
                if index < (data?.count ?? 0) {
                    viewController.imageName = data?[index].0
                    viewController.answerName = data?[index].1
                }
                viewController.isDrawInSequence = isDrawInSequence
                pageViewController?.setViewControllers([viewController], direction: .reverse, animated: true)
            }
            break

        default:
            break
        }
    }
}
