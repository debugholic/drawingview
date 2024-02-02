//
//  PathCommand.swift
//  DrawingView
//
//  Created by debugholic on 2022/03/15.
//

import UIKit

struct PathCommand {
    let type: CGPathElementType
    let point: CGPoint
    let controlPoints: [CGPoint]
}

extension CGPath {
    func points() -> [PathCommand] {
        var bezierPoints = [PathCommand]()
        forEach(body: { (element: CGPathElement) in
            guard element.type != .closeSubpath else {
                return
            }
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint, .addLineToPoint: // contains 1 point
                    return 1
                case .addQuadCurveToPoint: // contains 2 points
                    return 2
                case .addCurveToPoint: // contains 3 points
                    return 3
                case .closeSubpath:
                    return 0
                @unknown default:
                    fatalError()
                }
            }()
            var points = [CGPoint]()
            for index in 0..<(numberOfPoints - 1) {
                let point = element.points[index]
                points.append(point)
            }
            let command = PathCommand(type: element.type, point: element.points[numberOfPoints - 1], controlPoints: points)
            bezierPoints.append(command)
        })
        return bezierPoints
    }

    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
}
