//
//  ViewController.swift
//  DrawingViewSample
//
//  Created by debugholic on 2022/03/19.
//

import UIKit
import DrawingViewSwift

class ViewController: UIViewController {
    @IBOutlet weak var drawingPlace: DrawingView! {
        didSet {
            drawingPlace.layer.borderWidth = 1
            drawingPlace.delegate = self
        }
    }
    
    @IBOutlet weak var simLabel: UILabel!
    
    var answerName: String?
    var imageName: String?
    var isDrawInSequence: Bool = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let imageName = imageName, let url = Bundle.main.url(forResource: imageName, withExtension: "svg") {
            let answer = Bundle.main.url(forResource: answerName, withExtension: "svg")
            drawingPlace.drawPaths(url: url, answers: answer, isDrawInSequence: isDrawInSequence)
            drawingPlace.delegate = self
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let size = drawingPlace.frame.size
        coordinator.animate { _ in
            self.drawingPlace.reloadScale(from: size)
        }
    }
    
    @IBAction func undo() {
        drawingPlace.undo()
    }
    
    @IBAction func autoDraw() {
        drawingPlace.autoDraw()
    }
    
    @IBAction func clear() {
        drawingPlace.clear()
    }
}

extension ViewController: DrawingViewDelegate {
    func drawingViewDidDrawingFinished(_ drawingView: DrawingView, sequence: Int?, similarity: CGFloat) {
        simLabel.text = "\(Int(floor(similarity * 100)))%"
    }
}
