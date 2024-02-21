//
//  Canvas.swift
//  DrawingView
//
//  Created by debugholic on 2022/03/15.
//

import UIKit

public protocol CanvasDelegate: NSObjectProtocol {
    func canvas(_ canvas: Canvas, didDrawWithPoints drawingPoints: [CGPoint]?)
    func canvas(_ canvas: Canvas, willDrawWithPoint drawingPoint: CGPoint?)
}

public class Canvas: UIView {
    private var paths = [[CGPoint]]()
    private lazy var renderer: UIGraphicsImageRenderer? = {
        return UIGraphicsImageRenderer(bounds: bounds)
    }()
    
    var strokeColor: UIColor = UIColor.black.withAlphaComponent(1)
    var lineWidth: CGFloat = 10
    
    private var last: CGPoint?
    public weak var delegate: CanvasDelegate?
        
    open override func layoutSubviews() {
        super.layoutSubviews()
        renderer = UIGraphicsImageRenderer(bounds: bounds)
    }
    
    public func reset() {
        paths.removeAll()
        layer.contents = nil
    }
    
    public func undo() {
        layer.contents = nil
        if !paths.isEmpty {
            paths.removeLast()
        }
        
        let image = self.renderer?.image {
            $0.cgContext.setStrokeColor(strokeColor.cgColor)
            $0.cgContext.setLineWidth(lineWidth)
            $0.cgContext.setLineCap(.round)
            $0.cgContext.setLineJoin(.round)
            for path in paths {
                $0.cgContext.addLines(between: path)
            }
            $0.cgContext.strokePath()
        }
        layer.contents = image?.cgImage
    }
                
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let firstPoint = touches.first!.location(in: self)
        delegate?.canvas(self, willDrawWithPoint: firstPoint)
        let image = self.renderer?.image {
            $0.cgContext.setStrokeColor(strokeColor.cgColor)
            $0.cgContext.setLineCap(.round)
            $0.cgContext.setLineJoin(.round)
            $0.cgContext.setLineWidth(lineWidth)
            $0.cgContext.beginPath()
            paths.append([CGPoint]())
            for path in paths {
                $0.cgContext.addLines(between: path)
            }
            $0.cgContext.strokePath()
            paths[paths.count-1].append(firstPoint)
            $0.cgContext.move(to: firstPoint)
            self.last = firstPoint
        }
        layer.contents = image?.cgImage
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let image: UIImage?
        if let last = last, let point = touches.first?.location(in: self) {
            image = self.renderer?.image {
                $0.cgContext.setStrokeColor(strokeColor.cgColor)
                $0.cgContext.setLineCap(.round)
                $0.cgContext.setLineJoin(.round)
                $0.cgContext.setLineWidth(lineWidth)
                for path in paths {
                    $0.cgContext.addLines(between: path)
                    $0.cgContext.strokePath()
                }
                $0.cgContext.move(to: last)
                paths[paths.count-1].append(point)
                $0.cgContext.addLine(to: point)
                $0.cgContext.strokePath()
                self.last = point
            }
            
        } else {
            image = nil
        }
        layer.contents = image?.cgImage
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let image = self.renderer?.image {
            $0.cgContext.setStrokeColor(strokeColor.cgColor)
            $0.cgContext.setLineCap(.round)
            $0.cgContext.setLineJoin(.round)
            $0.cgContext.setLineWidth(lineWidth)
            for path in paths {
                $0.cgContext.addLines(between: path)
                $0.cgContext.strokePath()
            }
        }
        layer.contents = image?.cgImage
        delegate?.canvas(self, didDrawWithPoints: paths.last)
    }
}

