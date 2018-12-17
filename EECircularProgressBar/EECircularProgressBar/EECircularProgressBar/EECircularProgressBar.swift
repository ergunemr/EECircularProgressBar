//
//  EECircularProgressBar.swift
//  EECircularProgressBar
//
//  Created by Emre on 1.10.2018.
//  Copyright © 2018 Emre. All rights reserved.
//

import UIKit

public protocol EECircularProgressBarDelegate: NSObjectProtocol {
    func trackAnimationDidStart(_ dynamicColorBar: EECircularProgressBar)
    func trackAnimating(_ dynamicColorBar: EECircularProgressBar, currentProgress: Double)
    func trackAnimationDidEnd(_ dynamicColorBar: EECircularProgressBar)
}

@IBDesignable
public class EECircularProgressBar: UIView {
    
    //MARK: Private Definitions
    private let trackLayer = CAShapeLayer()
    private let levelLayer = CAShapeLayer()
    
    private let kStrokeColorAnimationKeyPath = "strokeColor"
    private let kStrokeEndAnimationKeyPath = "strokeEnd"
    private let kColorAnimationKey = "colorAnim"
    private var keyTimes = [Double]()
    private let defaultLevelColor = UIColor.green
    
    private var colorAnimation: CAAnimation!
    private var strokeAnimation: CABasicAnimation!
    private var groupAnim: CAAnimationGroup!
    
    private var displayLink: CADisplayLink?
    private var targetPercent: Double = 0
    private(set) var isAnimating = false
    private var progressTextLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: .zero))
        label.textAlignment = .center
        return label
    }()
    
    public var delegate: EECircularProgressBarDelegate?
    
    //MARK: Public Methods
    
    // Animates level depend on given percent
    // Percent parameter should be between 0 and 1. It is set to nearest edge otherwise.
    public func animate(toPercent percent: Double) {
        guard !isAnimating else { return }
        targetPercent = limitPercent(withValue: percent)
        buildStrokeAnimation(withPercent: targetPercent)
        buildColorAnimations()

        animateLevel(toPercent: targetPercent)
    }
    
    //MARK: Public Properties
    
    // Colors used in levels. Default color is used if no color set
    public var levelColors: [UIColor]? {
        didSet {
            keyTimes.removeAll()
            if levelColors?.count ?? 0 > 1 {
                setKeyTimes()
            }
        }
    }
    
    
    // Determines progress text in the middle of the circle is whether visible or not
    @IBInspectable
    public var isProgressLabelVisible: Bool = false
    
    // Font of the progress label
    public var progressLabelFont: UIFont = UIFont.systemFont(ofSize: 24)
    
    // Color of the progress label
    @IBInspectable
    public var progressLabelColor: UIColor = UIColor.darkGray
    
    // Total animation Duration
    @IBInspectable
    public var animationDuration: Double = 1.0
    
    // Background color of the track
    @IBInspectable
    public var trackColor: UIColor = .white
    
    // Line width of the track
    @IBInspectable
    public var trackLineWidth: CGFloat = 0
    
    // Line cap of the level
    public var levelLineCap: CAShapeLayerLineCap = .square
    
    
    //MARK: Initialization
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override public func prepareForInterfaceBuilder() {
        setupUI()
    }
    
    private func setupUI() {
        layer.masksToBounds = true
        setupLayers()
        buildColorAnimations()
        setupProgressTextLabel()
    }
    
    //MARK: Private Methods
    
    private func limitPercent(withValue value: Double) -> Double {
        return max(min(value, 1), 0)
    }
    
    private func setKeyTimes() {
        guard let levelColors = levelColors else { return }
        let levelColorsCount = levelColors.count
        
        let timeOffset = 1.0/Double(levelColorsCount-1)
        for i in 0...(levelColorsCount-1) {
            keyTimes.append(Double(i)*timeOffset)
        }
    }
    
    private func buildColorAnimations() {
        if levelColors?.isEmpty ?? true {
            buildBasicColorAnimation(toColor: defaultLevelColor)
        } else if let colors = levelColors, colors.count == 1, let firstColor = colors.first {
            buildBasicColorAnimation(toColor: firstColor)
        } else {
            buildKeyFrameColorAnimation()
        }
    }
    
    private func buildKeyFrameColorAnimation() {
        guard let levelColors = levelColors else { return }
        let colorKeyFrameAnim = CAKeyframeAnimation(keyPath: kStrokeColorAnimationKeyPath)
        colorKeyFrameAnim.keyTimes = keyTimes.map({ return NSNumber(value: $0) })
        colorKeyFrameAnim.values = levelColors.map({ return $0.cgColor })
        colorKeyFrameAnim.duration = animationDuration
        colorAnimation = colorKeyFrameAnim
    }
    
    private func buildBasicColorAnimation(toColor color: UIColor) {
        let basicColorAnim = CABasicAnimation(keyPath: kStrokeColorAnimationKeyPath)
        basicColorAnim.duration = animationDuration
        basicColorAnim.toValue = color.cgColor
        basicColorAnim.fromValue = color.cgColor
        colorAnimation = basicColorAnim
    }
    
    private func setupProgressTextLabel() {
        progressTextLabel.text = "%0"
        progressTextLabel.font = progressLabelFont
        progressTextLabel.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        progressTextLabel.textColor = progressLabelColor
        progressTextLabel.isHidden = !isProgressLabelVisible
        addSubview(progressTextLabel)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: bounds.size.height/2 - levelLayer.lineWidth/2, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(-Double.pi/2 - 2*Double.pi), clockwise: false)
        levelLayer.path = circularPath.cgPath
        trackLayer.path = circularPath.cgPath
        progressTextLabel.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    private func buildStrokeAnimation(withPercent percent: Double) {
        strokeAnimation = CABasicAnimation(keyPath: kStrokeEndAnimationKeyPath)
        strokeAnimation.toValue = CGFloat(percent)
        strokeAnimation.fromValue = 0.0
        strokeAnimation.duration = animationDuration*percent
    }
    
    private func setupLayers() {
        layer.sublayers?.removeAll()
        layer.addSublayer(trackLayer)
        layer.addSublayer(levelLayer)
        
        trackLayer.lineWidth = trackLineWidth
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        
        levelLayer.lineWidth = trackLineWidth
        levelLayer.fillColor = UIColor.clear.cgColor
        levelLayer.strokeColor = levelColors?.first?.cgColor ?? UIColor.clear.cgColor
        levelLayer.strokeEnd = CGFloat(0)
        levelLayer.lineCap = levelLineCap
    }
    
    private func animateLevel(toPercent percent: Double) {
        groupAnim = CAAnimationGroup()
        groupAnim.duration = animationDuration*percent
        groupAnim.isRemovedOnCompletion = false
        groupAnim.fillMode = CAMediaTimingFillMode.forwards
        groupAnim.animations = [strokeAnimation, colorAnimation]
        groupAnim.beginTime = CACurrentMediaTime()
        groupAnim.delegate = self
        
        levelLayer.add(groupAnim, forKey: "groupAnimation")
    }
    
    private func animationWillStart() {
        isAnimating = true
        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(tick(displayLink:)))
            displayLink!.add(to: .main, forMode: .default)
        }
    }
    
    private func animationDidComplete() {
        isAnimating = false
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func tick(displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - groupAnim.beginTime
        let percent = elapsed/groupAnim.duration
        let result = ((percent*targetPercent)*100).rounded()-1
        
        if isProgressLabelVisible {
            animateProgressTextLayerText(withPercent: result)
        }
        
        delegate?.trackAnimating(self, currentProgress: result)
    }
    
    private func animateProgressTextLayerText(withPercent percent: Double) {
        let text = "%\(Int(percent))"
        progressTextLabel.text = text
    }
}

extension EECircularProgressBar: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        if anim is CAAnimationGroup {
            animationWillStart()
            delegate?.trackAnimationDidStart(self)
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is CAAnimationGroup {
            animationDidComplete()
            animateProgressTextLayerText(withPercent: targetPercent*100)
            delegate?.trackAnimationDidEnd(self)
        }
    }
}
