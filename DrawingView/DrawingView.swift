//
//  DrawingView.swift
//  DrawingView
//
//  Created by debugholic on 2022/03/15.
//

import UIKit
import PocketSVG

protocol DrawingViewDelegate: NSObjectProtocol {
    func drawingViewDidDrawingFinished(_ drawingView: DrawingView, sequence: Int?, similarity: CGFloat)
    func drawingViewDidDrawingComplete(_ drawingView: DrawingView)
}

extension DrawingViewDelegate {
    func drawingViewDidDrawingComplete(_ drawingView: DrawingView) {
        return
    }
}

class DrawingPath {
    let svgPath: SVGBezierPath
    var isDrawn: Bool = false
    
    init(svgPath: SVGBezierPath) {
        self.svgPath = svgPath
    }
}

public class DrawingView: UIView {    
    let canvas: Canvas
    private let imageView: UIImageView
    weak var delegate: DrawingViewDelegate?
    
    var timer: Timer?

    var answers: [SVGBezierPath]?
    var paths = [DrawingPath]()
    
    var strokeColor: UIColor = UIColor.blue.withAlphaComponent(1) {
        didSet {
            canvas.strokeColor = strokeColor
        }
    }
    
    var lineWidth: CGFloat = 10 {
        didSet {
            canvas.lineWidth = lineWidth
        }
    }

    lazy var autoDrawView: UIImageView = {
        let imageView = UIImageView()
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        return imageView
    }()
    
    private var isDrawInSequence: Bool = false
    private(set) var sequence: Int?
    
    public override init(frame: CGRect) {
        canvas = Canvas(frame: frame)
        let size = frame.width > frame.height ? CGSize(width: frame.height, height: frame.height) : CGSize(width: frame.width, height: frame.width)
        imageView = UIImageView(frame: CGRect(origin: frame.origin, size: size))
        super.init(frame: frame)
        addSubview(canvas)
        addSubview(imageView)
        bringSubviewToFront(canvas)
        canvas.delegate = self
        autoDrawView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        canvas = Canvas(frame: .zero)
        imageView = UIImageView(frame: .zero)
        super.init(coder: coder)
        addSubview(canvas)
        addSubview(imageView)
        bringSubviewToFront(canvas)
        canvas.delegate = self
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        canvas.frame = bounds
        let size = bounds.width > bounds.height ? CGSize(width: bounds.height, height: bounds.height) : CGSize(width: bounds.width, height: bounds.width)
        imageView.frame = CGRect(origin: bounds.origin, size: size)
        imageView.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    public func drawPaths(url: URL, answers: URL? = nil, isDrawInSequence: Bool = false) {
        applyScale(paths: SVGBezierPath.pathsFromSVG(at: url)) { paths in
            self.paths = self.drawPaths(paths.map({ DrawingPath(svgPath: $0) }))
        }

        if let answers = answers {
            applyScale(paths: SVGBezierPath.pathsFromSVG(at: answers)) { paths in
                self.answers = paths
            }
        }
        self.isDrawInSequence = isDrawInSequence
        sequence = isDrawInSequence ? 0 : nil
    }
    
    public func drawPaths(string: String, answers: String? = nil, isDrawInSequence: Bool = false) {
        applyScale(paths: SVGBezierPath.paths(fromSVGString: string)) { paths in
            self.paths = self.drawPaths(paths.map({ DrawingPath(svgPath: $0) }))
        }

        if let answers = answers {
            applyScale(paths: SVGBezierPath.paths(fromSVGString: answers)) { paths in
                self.answers = paths
            }
        }
        self.isDrawInSequence = isDrawInSequence
        sequence = isDrawInSequence ? 0 : nil
    }
    
    public func drawPaths(svgPaths: [SVGBezierPath], answers: [SVGBezierPath]? = nil, isDrawInSequence: Bool = false) {
        if let answers = answers {
            applyScale(paths: answers) { paths in
                self.answers = paths
            }
        }
        applyScale(paths: svgPaths) { paths in
            self.paths = self.drawPaths(paths.map({ DrawingPath(svgPath: $0) }))
        }
        self.isDrawInSequence = isDrawInSequence
        sequence = isDrawInSequence ? 0 : nil
    }
    
    func applyScale(paths: [SVGBezierPath], completion: @escaping ([SVGBezierPath])->()) {
        DispatchQueue.main.async {
            self.imageView.layoutIfNeeded()
            for path in paths {
                if path.viewBox.width > 0 && path.viewBox.height > 0 {
                    let scaleX = self.imageView.bounds.width / path.viewBox.width
                    let scaleY = self.imageView.bounds.height / path.viewBox.height
                    path.apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
                }
            }
            completion(paths)
        }
    }
    
    func reloadScale(from size: CGSize) {
        for path in paths {
            if path.svgPath.viewBox.width > 0 && path.svgPath.viewBox.height > 0 {
                let scaleX = self.imageView.bounds.width / size.width
                let scaleY = self.imageView.bounds.height / size.height
                
                path.svgPath.apply(CGAffineTransform(scaleX: scaleX, y: scaleY))
            }
        }
        
        let drawingPaths = paths.map({ DrawingPath(svgPath: $0.svgPath) })
        for i in 0..<paths.count {
            if i < drawingPaths.count {
                drawingPaths[i].isDrawn = paths[i].isDrawn
            }
        }
        self.paths = self.drawPaths(drawingPaths)
    }
    
    @discardableResult func drawPaths(_ paths: [DrawingPath]) -> [DrawingPath] {
        let renderer = UIGraphicsImageRenderer(bounds: imageView.bounds)
        imageView.image = renderer.image {
            for path in paths.sorted(by: { !$0.isDrawn && $1.isDrawn }) {
                $0.cgContext.setFillColor(gray: path.isDrawn ? 0.0 : 0.8, alpha: 1.0)
                $0.cgContext.setLineWidth(path.svgPath.lineWidth)
                $0.cgContext.addPath(path.svgPath.cgPath)
                path.svgPath.fill()
            }
        }
        return paths
    }
    
    public func undo() {
        canvas.undo()
        if !paths.isEmpty {
            if let sequence = sequence, sequence >= 0, sequence <= paths.count {
                if sequence > 0 {
                    self.sequence = sequence - 1
                }
                paths[(self.sequence ?? 0)].isDrawn = false
            }
        }
        canvas.isUserInteractionEnabled = true
        drawPaths(paths)
    }
    
    public func reset() {
        canvas.reset()
        timer?.invalidate()
        autoDrawView.image = nil
        for path in paths {
            path.isDrawn = false
        }
        sequence = isDrawInSequence ? 0 : nil
        canvas.isUserInteractionEnabled = true
        drawPaths(paths)
    }
    
    public func clear() {
        autoDrawView.isHidden = true
        autoDrawView.image = nil
        reset()
    }
}

extension DrawingView: CanvasDelegate {
    public func canvas(_ canvas: Canvas, didDrawWithPoints drawingPoints: [CGPoint]?) {
        if let answers = answers,
           let drawingPoints = drawingPoints {
            canvas.undo()
            var index: Int?
            var maxSim: CGFloat = 0
                     
            var points = [CGPoint]()
            points.append(drawingPoints[0])
            if drawingPoints.count > 1 {
                for i in 1..<drawingPoints.count {
                    if drawingPoints[i-1].distance(to: drawingPoints[i]) > 5{
                        points.append(drawingPoints[i])
                    }
                }
            }
            
            if let sequence = sequence, sequence < answers.count {
                let bezierPath = BezierPath(cgPath: answers[sequence].cgPath)
                bezierPath.generateLookupTable()
                let answerPoints = bezierPath.lookupTable

                maxSim = getSimilarity(points, with: answerPoints)
                if maxSim >= Similarity.cutOffScore {
                    index = sequence
                    self.sequence = sequence + 1
                }
                
            } else {
                for i in 0..<answers.count {
                    let bezierPath = BezierPath(cgPath: answers[i].cgPath)
                    bezierPath.generateLookupTable()
                    let answerPoints = bezierPath.lookupTable
                    
                    let sim = getSimilarity(points, with: answerPoints)
                    maxSim = max(sim, maxSim)
                    if sim >= Similarity.cutOffScore && sim == maxSim {
                        index = i
                    }
                }
            }
            
            if let index = index {
                paths[index].isDrawn = true
                delegate?.drawingViewDidDrawingFinished(self, sequence: index, similarity: maxSim)

            } else {
                delegate?.drawingViewDidDrawingFinished(self, sequence: nil, similarity: maxSim)
            }
            
            drawPaths(paths)
            
            if paths.filter({ !$0.isDrawn }).isEmpty {
                canvas.isUserInteractionEnabled = false
                delegate?.drawingViewDidDrawingComplete(self)
            }
        }
    }
    
    func getSimilarity(_ pts1: [CGPoint], with pts2: [CGPoint]) -> CGFloat {
        var points = [CGPoint]()

        let larger: [CGPoint] = pts1.count > pts2.count ? pts1 : pts2
        let smaller: [CGPoint] = pts1.count > pts2.count ? pts2 : pts1

        for i in 0..<smaller.count {
            var position = Int(Float(i * larger.count) / (Float(smaller.count) - 1.0 + 1e-8))
            if position >= larger.count {
                position = larger.count - 1
            }
            points.append(larger[position])
        }
        return Similarity.compute(p1: smaller, p2:points, frameSize: frame.size)
    }
    
    func autoDraw() {
        timer?.invalidate()
        autoDrawView.isHidden = false
        autoDrawView.layoutIfNeeded()
        autoDraw(i: 0, paths: [[CGPoint]]())
    }
    
    func autoDraw(i: Int, paths: [[CGPoint]]) {
        var paths = paths
        if let drawingPaths = answers {
            if i < drawingPaths.count {
                paths.append([CGPoint]())
                
                let drawingPath = BezierPath(cgPath: drawingPaths[i].cgPath)
                drawingPath.generateLookupTable()
                var answers = drawingPath.lookupTable
                
                let renderer = UIGraphicsImageRenderer(bounds: autoDrawView.bounds)
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                    if answers.isEmpty {
                        timer.invalidate()
                        self.autoDraw(i: i + 1, paths: paths)
                        return
                    }
                    
                    let last: CGPoint = answers.removeFirst()
                    let image = renderer.image {
                        $0.cgContext.setStrokeColor(UIColor.red.cgColor)
                        $0.cgContext.setLineCap(.round)
                        $0.cgContext.setLineJoin(.round)
                        $0.cgContext.setLineWidth(30)
                        $0.cgContext.beginPath()
                        paths[i].append(last)
                        for path in paths {
                            $0.cgContext.addLines(between: path)
                        }
                        $0.cgContext.strokePath()
                        $0.cgContext.move(to: last)
                    }
                    self.autoDrawView.image = image
                }
            }
        }
    }
}
