import UIKit
import Foundation

protocol APImageMarkerViewDelegate {
    func MarkerPlotted(markerView: APImageMarkerView, xRatio: Float, yRatio: Float)
}

class APImageMarkerView: NSObject, UIScrollViewDelegate {
    
    var delegate: APImageMarkerViewDelegate?
    private var imageView: UIImageView!
    private var markerImgView: UIImageView!
    private var scrollView: UIScrollView!
    
    private var tapGesture: UITapGestureRecognizer!
    
    private var xRatio: Float = 0.0
    private var yRatio: Float = 0.0
    
    private var rippleColor: UIColor = .red
    
    init(frame: CGRect, image: UIImage, inView: UIView, mageAPImageMarkerView: UIImageView, maximumScrollScale: CGFloat, startMarking: Bool = false, rippleColor: UIColor = .red) {
        super.init()
        
        self.imageView = UIImageView(frame: frame)
        self.imageView.image = image
        self.imageView.contentMode = .scaleAspectFill
        self.markerImgView = mageAPImageMarkerView
        self.markerImgView.isHidden = true
        self.imageView.addSubview(self.markerImgView)
        
        scrollView = UIScrollView(frame: imageView.frame)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = maximumScrollScale
        scrollView.addSubview(self.imageView)
        scrollView.center = inView.center
        inView.addSubview(scrollView)
        
        self.rippleColor = rippleColor
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        
        if startMarking {
            self.startMarking()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.imageView)
        self.markerImgView.center = point
        self.markerImgView.isHidden = false
        
        self.xRatio = Float(100 * point.x/self.imageView.bounds.maxX)
        self.yRatio = Float(100 * point.y/self.imageView.bounds.maxY)
        
        delegate?.MarkerPlotted(markerView: self, xRatio: self.xRatio, yRatio: self.yRatio)
        self.markerImgView.makeRipple(color: self.rippleColor)
    }
    
    func getXYRatio() -> (Float, Float) {
        return(self.xRatio, self.yRatio)
    }
    
    func reset() {
        self.markerImgView.isHidden = true
        self.xRatio = 0.0
        self.yRatio = 0.0
    }
    
    func startMarking() {
        self.scrollView.addGestureRecognizer(self.tapGesture)
    }
    
    func stopMarking() {
        self.scrollView.removeGestureRecognizer(self.tapGesture)
    }
}

extension UIView {
    func makeRipple(number: Float = 1, color: UIColor = .red) {
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let shapePosition = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = color.cgColor
        rippleShape.lineWidth = 10
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        
        self.layer.addSublayer(rippleShape)
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = CFTimeInterval(1)
        animation.repeatCount = number
        animation.isRemovedOnCompletion = true
        
        rippleShape.add(animation, forKey: "ripple")
    }
}
