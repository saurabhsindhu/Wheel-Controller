

import UIKit

public protocol WheelMenuViewDelegate: NSObjectProtocol {
    
    func wheelMenuView(_ view: WheelMenuView, didSelectItem: UITabBarItem)
    
}


@IBDesignable public final class WheelMenuView: UIView {
    
    /* ====================================================================== */
    // MARK: Properties
    /* ====================================================================== */
    
    @IBInspectable public var centerButtonRadius: CGFloat = 32 {
        didSet {
            updateCenterButton()
        }
    }
    
    @IBInspectable public var menuBackGroundColor: UIColor = UIColor(white: 250/255, alpha: 1) {
        didSet {
            menuLayers.forEach {
                $0.fillColor = menuBackGroundColor.cgColor
            }
        }
    }
    
    @IBInspectable public var boarderColor: UIColor = UIColor(white: 1.0, alpha: 1) {
        didSet {
            menuLayers.forEach {
                $0.strokeColor = boarderColor.cgColor
            }
        }
    }
    
    @IBInspectable public var animationDuration: CGFloat = 0.2
    
    
    public weak var delegate: WheelMenuViewDelegate?
    
    public var tabBarItems: [UITabBarItem] {
        get {
            return menuLayers.map { $0.tabBarItem }
        } set {
            menuLayers.forEach{ $0.removeFromSuperlayer() }
            
            let angle = 2 * CGFloat(Double.pi) / CGFloat(newValue.count)
            
            menuLayers = newValue.enumerated().map {
                let startAngle = CGFloat($0.offset) * angle - angle / 2 - CGFloat(Double.pi / 2)
                let endAngle   = CGFloat($0.offset + 1)  * angle - angle / 2 - CGFloat(Double.pi / 2) + 0.005
                let center     = CGPoint(
                    x: bounds.width/2,
                    y: bounds.height/2)
                
                var transform = CATransform3DMakeRotation(angle * CGFloat($0.offset), 0, 0, 1)
                transform     = CATransform3DTranslate(
                    transform,
                    0,
                    -bounds.width/3,
                    0)
                
                let layer = MenuLayer(
                    center: center,
                    radius: bounds.width/2,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    tabBarItem: $0.element,
                    bounds: bounds,
                    contentsTransform: transform)
                
                layer.strokeColor = boarderColor.cgColor
                layer.fillColor   = menuBackGroundColor.cgColor
                layer.selected    = $0.offset == selectedIndex
                menuBaseView.layer.addSublayer(layer)
                
                createHoleIn(view : menuBaseView!, radius: 45.0)
                menuBaseView.frame = CGRect(x:  menuBaseView.frame.origin.x+100, y: menuBaseView.frame.origin.y, width: menuBaseView.frame.width, height: menuBaseView.frame.height)
                return layer
            }
        }
    }
    func createHoleIn(view : UIView ,
                       xOffset: CGFloat = 100,
                       yOffset: CGFloat = 100,
                       radius: CGFloat)   {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: 100, y: 100),
                    radius: radius,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: view.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
//        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        // For Swift 4.0
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        // For Swift 4.2
        maskLayer.fillRule = .evenOdd
        // Step 4
        view.layer.mask = maskLayer
        view.clipsToBounds = true
    }
    
    fileprivate(set) var openMenu: Bool = true
    
    fileprivate(set) var selectedIndex = 0
    
    fileprivate var startPoint = CGPoint.zero
    
    fileprivate var currentAngle: CGFloat {
        let angle = 2 * CGFloat(Double.pi) / CGFloat(menuLayers.count)
        return CGFloat(menuLayers.count - selectedIndex) * angle
    }
    
    fileprivate var menuLayers = [MenuLayer]()
    
    
    /* ====================================================================== */
    // MARK: IBOutlet
    /* ====================================================================== */
    
    public var centerButtonCustomImage: UIImage? {
        didSet {
            updateCenterButton()
        }
    }
    
    @IBOutlet public weak var centerButton: UIButton! {
        didSet {
            let bundle = Bundle(for: type(of: self))
            let image  = centerButtonCustomImage ?? UIImage(named: "Vector", in: bundle, compatibleWith: nil)!
                .withRenderingMode(.alwaysTemplate)
            centerButton.setImage(image, for: UIControl.State())
            centerButton.layer.shadowOpacity = 0.0
            centerButton.layer.shadowRadius  = 5
            centerButton.layer.shadowOffset  = CGSize.zero
        }
    }
    
    @IBOutlet fileprivate weak var centerButtonWidth: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var menuBaseView: UIView!
    

    
    /* ====================================================================== */
    // MARK: initializer
    /* ====================================================================== */
    
    convenience public init(frame: CGRect, tabBarItems: [UITabBarItem]) {
        self.init(frame: frame)
        self.tabBarItems = tabBarItems
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        let bundle         = Bundle(for: type(of: self))
        let nib            = UINib(nibName: "WheelMenuView", bundle: bundle)
        let view           = nib.instantiate(withOwner: self, options: nil).first as! UIView
        let viewDictionary = ["view": view]
        
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
            options:NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics:nil,
            views: viewDictionary))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|",
            options:NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics:nil,
            views: viewDictionary))
        
        updateCenterButton()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        tabBarItems = [
            UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1),
            UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2),
            UITabBarItem(tabBarSystemItem: .bookmarks, tag: 3),
            UITabBarItem(tabBarSystemItem: .bookmarks, tag: 4)
        ]
    }
    
    
    /* ====================================================================== */
    // MARK: Actions
    /* ====================================================================== */
    
    @IBAction fileprivate func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let location = sender.location(in: self)
        
        switch sender.state {
        case .began:
            startPoint = location
            
        case .changed:
            let radian1 = -atan2(
                startPoint.x - menuBaseView.center.x,
                startPoint.y - menuBaseView.center.y)
            let radian2 = -atan2(
                location.x - menuBaseView.center.x,
                location.y - menuBaseView.center.y)
            
            menuBaseView.transform = menuBaseView.transform.rotated(by: radian2 - radian1)
            
            startPoint = location
            
        default:
            let angle         = 2 * CGFloat(Double.pi) / CGFloat(menuLayers.count)
            var menuViewAngle = atan2(menuBaseView.transform.b, menuBaseView.transform.a)
            
            if menuViewAngle < 0 {
                menuViewAngle += CGFloat(2 * Double.pi)
            }
            
            var index = menuLayers.count - Int((menuViewAngle + CGFloat(Double.pi / 4)) / angle)
            if index == menuLayers.count {
                index = 0
            }
            
            setSelectedIndex(index, animated: true)
            delegate?.wheelMenuView(self, didSelectItem: tabBarItems[index])
        }
    }
    
    @IBAction fileprivate func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: menuBaseView)
        
        for (idx, menuLayer) in menuLayers.enumerated() {
            let touchInLayer = menuLayer.path?.contains(location) ?? false
            if touchInLayer {
                setSelectedIndex(idx, animated: true)
                delegate?.wheelMenuView(self, didSelectItem: tabBarItems[idx])
                return
            }
        }
    }
    
    public var customActionCallback: (() -> Void)? = nil
    
    @IBAction func didTapCenterButton(_: UIButton) {
        if let customActionCallback = customActionCallback {
            customActionCallback()
        } else {
            if openMenu {
                closeMenuView()
                self.menuBaseView.isHidden=true;
                self.centerButton.isHidden=true;
            } else {
                openMenuView()
            }
        }
    }
    
    /* ====================================================================== */
    // MARK: Public Method
    /* ====================================================================== */
    
    public func setSelectedIndex(_ index: Int, animated: Bool) {
        selectedIndex = index
        
        let duration  = animated ? TimeInterval(animationDuration) : 0
        
        UIView.animate(withDuration: TimeInterval(duration),
            animations: {
                self.menuBaseView.transform =
                    CGAffineTransform(rotationAngle: self.currentAngle)
            },
            completion: { _ in
                self.menuLayers.enumerated().forEach {
                    $0.element.selected = $0.offset == index
                }
            }
        )
    }
    
    
    /* ====================================================================== */
    // MARK: Private Method
    /* ====================================================================== */
    
    public func updateCenterButton() {
        centerButtonWidth.constant      = centerButtonRadius * 2
        centerButton.layer.cornerRadius = centerButtonRadius
        let bundle = Bundle(for: type(of: self))
        let image  = centerButtonCustomImage ?? UIImage(named: "Vector", in: bundle, compatibleWith: nil)!
            .withRenderingMode(.alwaysTemplate)
        centerButton.setImage(image, for: UIControl.State())
    }
    
    public func openMenuView() {
        openMenu = true
        UIView.animate(withDuration: TimeInterval(animationDuration),
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 5.0,
            options: [],
            animations: {
                self.menuBaseView.transform = CGAffineTransform(scaleX: 1, y: 1).rotated(by: self.currentAngle)
            },
            completion: nil
        )
    }
    
    public func closeMenuView() {
        openMenu = false
        UIView.animate(withDuration: TimeInterval(animationDuration),
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 5.0,
            options: [],
            animations: {
                self.menuBaseView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: self.currentAngle)
            },
            completion: nil
        )
    }

}
