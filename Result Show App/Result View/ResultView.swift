
import UIKit

class ResultView: UIView {
    
    private enum Constants {
        static let innerCircleRadiusRatio: CGFloat = 350 / 490
        static let bigBlockCircleRadiusRatio: CGFloat = 400 / 490
        static let bigBlockCircleWidthRatio: CGFloat =  30 / 490
        
        static let smallBlockCircleRadiusRatio: CGFloat = 452 / 490
        static let smallBlockCircleWidthRatio: CGFloat =  8 / 490
        
        static let glowEffectLayerExpandRatio: CGFloat = 150 / 490
        static let glowEffectDuration: Double = 1
        
        static let yriResultPercentViewFadeInDuration: Double = 0.5
        static let outerCircleDrawDuration: Double = 0.5
        static let pinkCircleFadeInDuration: Double = 0.5
        static let pinkCircleRotateDuration: Double = 1.5
        static let innerCircleDrawDuration: Double = 1.5
        static let quarterCircleFadeInDuration: Double = 0.5
        static let quarterCircleRotateDuration: Double = 1.5
        static let scoreCountingDuration: Double = 2
    }
    
    private let maxScoreValue = 100
    static private let nibIdentifier = "ResultView"
    var scoreValue: Int = 0
    private var viewFrameCenter: CGPoint { return CGPoint(x: bounds.width / 2, y: bounds.height / 2) }
    private var customLayers = [CALayer]()
    
    private var completionHandler: (() -> ())?
    
    @IBOutlet private var resultCountLabel: UILabel!
    @IBOutlet private var resultCountView: UIView! {
        didSet { resultCountView.alpha = 0 }
    }
    @IBOutlet private var pinkCircleView: UIView! {
        didSet { pinkCircleView.alpha = 0 }
    }
    
    static func createNdAdd(in view: UIView) -> ResultView {
        guard let resultView = Bundle.main.loadNibNamed(ResultView.nibIdentifier, owner: self, options: nil)?.first as? ResultView
        else { fatalError("No such Result view found") }
        resultView.frame = view.bounds
        resultView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        view.addSubview(resultView)
        return resultView
    }
    
    func startDrawing(completionHandler: (() -> ())? = nil) {
        self.completionHandler = completionHandler
        drawOuterCircle()
        resultCountView.fadeIn(duration: Constants.yriResultPercentViewFadeInDuration)
    }
    
    func clearView() {
        subviews.forEach { $0.alpha = 0 }
        customLayers.forEach({ $0.removeAllAnimations(); $0.removeFromSuperlayer(); })
        customLayers.removeAll()
        resultCountLabel.text = "0"
        setNeedsDisplay()
    }
    
}

extension ResultView {
    
    private func drawOuterCircle() {
        let circleArc = Arc(center: viewFrameCenter, radius: bounds.width / 2, startAngle: (-CGFloat.pi / 2), endAngle: (2 * CGFloat.pi) * (3 / 4), lineColor: .white)
        let circleLayer = CAShapeLayer(circle: circleArc, frame: bounds)
        add(subLayer: circleLayer)
        
        circleLayer.animateStrokeEnd(duration: Constants.outerCircleDrawDuration) { [weak self] in
            self?.drawQuarterArc()
            self?.drawInnerCircle()
            self?.animatePinkCircle()
        }
        
    }
    
    private func animatePinkCircle() {
        pinkCircleView.fadeIn(duration: Constants.pinkCircleFadeInDuration)
        pinkCircleView.rotateView(fromAngle: 2.0 * Double.pi, toAngle: 0, duration: Constants.pinkCircleRotateDuration)
    }
    
    private func drawInnerCircle() {
        var circleArc = Arc(center: viewFrameCenter, radius: (bounds.width * Constants.innerCircleRadiusRatio) / 2, startAngle: (2 * CGFloat.pi) * (3 / 4), endAngle: (-CGFloat.pi / 2), clockWise: false, lineColor: .white)
        circleArc.lineDash = LineDash(length: 3, gap: 2)
        let circleLayer = CAShapeLayer(circle: circleArc, frame: bounds)
        add(subLayer: circleLayer)
        
        circleLayer.animateStrokeEnd(duration: Constants.innerCircleDrawDuration)
    }
    
    private func drawQuarterArc() {
        let circleArc = Arc(center: viewFrameCenter, radius: bounds.width / 2, endAngle: (CGFloat.pi / 2), lineWidth: 4, lineColor: UIColor(hexValue: 0xfe4ee4))
        let circleLayer = CAShapeLayer(circle: circleArc, frame: bounds)
        add(subLayer: circleLayer)
        
        circleLayer.fade(duration: Constants.quarterCircleFadeInDuration, startAlpha: 0, endAlpha: 1)
        circleLayer.rotateOnZAxis(duration: Constants.quarterCircleRotateDuration) { [weak self] in
            self?.startCounting(duration: Constants.scoreCountingDuration)
            self?.startGlowEffect(duration: Constants.glowEffectDuration, delay: Constants.scoreCountingDuration)
        }
    }
    
    private func startCounting(duration: Double = 1) {
        resultCountLabel.animateIncrement(toValue: scoreValue, duration: duration)
        drawBlockCirle(animationDuration: duration)
    }
    
    private func drawSmallBlockLayer() -> CAShapeLayer {
        let smallCircleRadius = (bounds.width * Constants.smallBlockCircleRadiusRatio) / 2
        let smallCircleWidth = bounds.width * Constants.smallBlockCircleWidthRatio
        let blockLength2 = (2 * CGFloat.pi * smallCircleRadius) / 22
        
        var smallCircle = Arc(center: viewFrameCenter, radius: smallCircleRadius, startAngle: (CGFloat.pi / 2), endAngle: (CGFloat.pi * 2) + (CGFloat.pi / 2), clockWise: true, lineWidth: smallCircleWidth, lineColor: UIColor(hexValue: 0xEBCFEC))
        smallCircle.lineDash = LineDash(length: blockLength2, gap: 4)
        let smallCircleLayer = CAShapeLayer(circle: smallCircle, frame: bounds)
        smallCircleLayer.strokeEnd = CGFloat(scoreValue) / CGFloat(maxScoreValue)
        add(subLayer: smallCircleLayer)
        
        return smallCircleLayer
    }
    
    private func drawBigBlockLayer() -> CAShapeLayer {
        let bigCircleRadius = (bounds.width * Constants.bigBlockCircleRadiusRatio) / 2
        let bigCircleWidth = bounds.width * Constants.bigBlockCircleWidthRatio
        let blockLength1 = (2 * CGFloat.pi * bigCircleRadius) / 22
        var bigCircle = Arc(center: viewFrameCenter, radius: bigCircleRadius, startAngle: (CGFloat.pi / 2), endAngle: (CGFloat.pi * 2) + (CGFloat.pi / 2), clockWise: true, lineWidth: bigCircleWidth, lineColor: UIColor(hexValue: 0xEBCFEC))
        bigCircle.lineDash = LineDash(length: blockLength1, gap: 3.5)
        let bigCircleLayer = CAShapeLayer(circle: bigCircle, frame: bounds)
        add(subLayer: bigCircleLayer)
        
        return bigCircleLayer
    }
    
    private func drawBlockCirle(animationDuration: Double) {
        let bigCircleLayer = drawBigBlockLayer()
        let smallCircleLayer = drawSmallBlockLayer()
        
        let strokeEndValue = CGFloat(scoreValue) / CGFloat(maxScoreValue)
        bigCircleLayer.animateStrokeEnd(duration: animationDuration, endValue: strokeEndValue)
        smallCircleLayer.animateStrokeEnd(duration: animationDuration, endValue: strokeEndValue)
    }
    
    private func startGlowEffect(duration: TimeInterval, delay: TimeInterval) {
        layer.presentGlowAnimation(withColor: .white, maxSpreadDistance: (Constants.glowEffectLayerExpandRatio * bounds.width), duration: duration, delay: delay + 0.2)
        layer.animateShadowOpacity(to: 0, duration: duration / 3, delay: delay + duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + duration + 1) { [weak self] in
            self?.resultViewAnimationsCompleted()
        }
    }
    
    private func add(subLayer: CALayer) {
        layer.addSublayer(subLayer)
        customLayers.append(subLayer)
    }
    
    private func resultViewAnimationsCompleted() {
        completionHandler?()
    }
    
}

