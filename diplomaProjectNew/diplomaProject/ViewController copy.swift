//
//  ViewController.swift
//  diplomaProject
//
//  Created by Имангали on 3/9/23.
//

import UIKit


class ViewController: UIViewController {
    
    let contentView: UIView = {
        let contentView = UIView(frame: UIScreen.main.bounds)
        //contentView.backgroundColor = UIColor.red
        return contentView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "1floor")
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        //imageView.backgroundColor = UIColor.systemPink
        return imageView
    }()
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "1", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "2", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "3", at: 3, animated: true)
        segmentedControl.insertSegment(withTitle: "4", at: 4, animated: true)
        segmentedControl.insertSegment(withTitle: "0", at: 0, animated: true)
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        for sview in segmentedControl.subviews {
            for subview in sview.subviews {
                if subview is UILabel {
                    (subview as! UILabel).transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
                    //subview.transform = CGAffineTransformMakeRotation(CGFloat(-CGFloat.pi / 2))
                }
            }
        }
        return segmentedControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.isUserInteractionEnabled = true
        contentView.isMultipleTouchEnabled = true

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureRecognized(_:)))
        contentView.addGestureRecognizer(pinchGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized(_:)))
        contentView.addGestureRecognizer(panGestureRecognizer)

        pinchGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        
        setupSubviews()
        
        print("origin", imageView.frame.origin)
        print("origin", contentView.frame.origin)
        drawRooms()
        
    }
    private func drawRooms() {
        
        var startPoint: CGPoint = CGPoint(x: 0, y: 0)
        var endPoint = CGPoint(x: 100, y: 100)
        
        for room in rooms {
            room.x *= contentView.frame.width / 271.29
            room.y *= contentView.frame.width * 1.10582771204 / 300.0
            room.x += imageView.frame.origin.x
            room.y += imageView.frame.origin.y
            
            if (room.id == "room1") {
                startPoint = CGPoint(x: room.x, y: room.y)
            }
            if (room.id == "room2") {
                endPoint = CGPoint(x: room.x, y: room.y)
            }
        }
    
        drawPath(startPoint, endPoint)
        
        for room in rooms {
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: room.x, y: room.y),
                                                      radius: 1,
                                                      startAngle: 0,
                                                      endAngle: CGFloat(Double.pi * 2),
                                                      clockwise: true)
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.orange.cgColor
            contentView.layer.addSublayer(circleLayer)
        }
    }
    
    private func drawPath(_ startPoint: CGPoint, _ endPoint: CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = UIColor.green.cgColor
        lineLayer.lineWidth = 2.0

        contentView.layer.addSublayer(lineLayer)
    }
    
    private func setupSubviews() {
        contentView.center = view.center
        imageView.center = contentView.center
        
        view.backgroundColor = UIColor.white
        view.addSubview(contentView)
        view.addSubview(segmentedControl)
        
        contentView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: contentView.frame.width * 1.10582771204),
            
            segmentedControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            segmentedControl.widthAnchor.constraint(equalToConstant: 100),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
        imageView.bounds.size = CGSize(width: contentView.frame.width, height: contentView.frame.width * 1.10582771204)
        
        let desiredX = contentView.center.x
        let desiredY = contentView.center.y
        imageView.center = CGPoint(x: desiredX, y: desiredY)
        let newOriginX = desiredX - imageView.frame.size.width / 2.0
        let newOriginY = desiredY - imageView.frame.size.height / 2.0
        imageView.frame.origin = CGPoint(x: newOriginX, y: newOriginY)
        print(desiredX, desiredY)
        print(newOriginX, newOriginY)
        
    }
    @objc func pinchGestureRecognized(_ gestureRecognizer: UIPinchGestureRecognizer) {

        switch gestureRecognizer.state {
           case .began, .changed:
               let scale = gestureRecognizer.scale
               let currentTransform = contentView.transform
               let newTransform = currentTransform.scaledBy(x: scale, y: scale)
               let newScale = newTransform.a

               if newScale < 0.8 || newScale > 5.0 {
                   return
               }

               contentView.transform = newTransform
               gestureRecognizer.scale = 1.0
           default:
               break
           }
    }

    @objc func panGestureRecognized(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
            case .began, .changed:
                let translation = gestureRecognizer.translation(in: view)

                var centerX = contentView.center.x + translation.x
                var centerY = contentView.center.y + translation.y

                let mxX = contentView.frame.width * 1
                let mnX = view.bounds.width * 1 - contentView.frame.width * 1
                centerX = max(min(centerX, mxX), mnX)

                let mxY = contentView.frame.height * 1
                let mnY = view.bounds.height * 1 - contentView.frame.height * 1
                centerY = max(min(centerY, mxY), mnY)

                contentView.center = CGPoint(x: centerX, y: centerY)
                gestureRecognizer.setTranslation(CGPoint.zero, in: view)
            default:
                break
            }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            print(position)
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
