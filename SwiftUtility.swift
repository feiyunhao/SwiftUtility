//
//  SwiftUtility.swift
//  SwiftUtility
//
//  Created by admin on 2017/2/28.
//  Copyright © 2017年 shenyang. All rights reserved.
//

import UIKit


//Core Graphics Initializers

extension CGRect {
    init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        self.init(x: x, y: y, width: w, height: h)
    }
}

extension CGSize {
    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }
}

extension CGPoint {
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
}

extension CGVector {
    init (_ dx: CGFloat, _ dy: CGFloat) {
        self.init(dx: dx, dy: dy)
    }
}


//Center of a CGRect

extension CGRect {
    var center : CGPoint {
        return CGPoint(self.midX, self.midY)
    }
}


//Adjust a CGSize

extension CGSize {
    func sizeByDelta(dw: CGFloat, dh: CGFloat) -> CGSize {
        return CGSize(self.width + dw, self.height + dh)
    }
}


//Delayed Performance

func delay(_ delay:Double, closure: @escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}


//Dictionary of Views
//Equivalent of Objective-C’s NSDictionaryOfVariableBindings

func dictionaryOfNames(_ arr: UIView...) -> [String: UIView] {
    var d = [String: UIView]()
    for (ix,v) in arr.enumerated() {
        d["v\(ix+1)"] = v
    }
    return d
}


//Constraint Issues

extension NSLayoutConstraint {
    class func reportAmbiguity (_ v:UIView?) {
        var v = v
        if v == nil {
            v = UIApplication.shared.keyWindow
        }
        for vv in v!.subviews {
            print("\(vv) \(vv.hasAmbiguousLayout)")
            if vv.subviews.count > 0 {
                self.reportAmbiguity(vv)
            }
        }
    }
    
    class func listConstraints (_ v:UIView?) {
        var v = v
        if v == nil {
            v = UIApplication.shared.keyWindow
        }
        for vv in v!.subviews {
            let arr1 = vv.constraintsAffectingLayout(for:.horizontal)
            let arr2 = vv.constraintsAffectingLayout(for:.vertical)
            NSLog("\n\n%@\nH: %@\nV:%@", vv, arr1, arr2);
            if vv.subviews.count > 0 {
                self.listConstraints(vv)
            }
        }
    }
}


//Drawing Into an Image Context

func imageOfSize(_ size:CGSize, opaque:Bool = false, closure: () -> ()) -> UIImage {
    if #available(iOS 10.0, *) {
        let f = UIGraphicsImageRendererFormat.default()
        f.opaque = opaque
        let r = UIGraphicsImageRenderer(size: size, format: f)
        return r.image {_ in
            closure()
        }
    } else {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        closure()
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
}


//Finite Repetition of an Animation

extension UIView {
    class func animate(times:Int,
                       duration dur: TimeInterval,
                       delay del: TimeInterval,
                       options opts: UIViewAnimationOptions,
                       animations anim: @escaping () -> Void,
                       completion comp: ((Bool) -> Void)?) {
        func helper(_ t:Int,
                    _ dur: TimeInterval,
                    _ del: TimeInterval,
                    _ opt: UIViewAnimationOptions,
                    _ anim: @escaping () -> Void,
                    _ com: ((Bool) -> Void)?) {
            UIView.animate(withDuration: dur,
                           delay: del,
                           options: opt,
                           animations: anim,
                           completion: { done in
                            if com != nil {
                                com!(done)
                            }
                            if t > 0 {
                                delay(0) {
                                    helper(t-1, dur, del, opt, anim, com)
                                }
                            }
            })
        }
        helper(times-1, dur, del, opts, anim, comp)
    }
}

//Remove Multiple Indexes From Array

extension Array {
    mutating func remove(at ixs:Set<Int>) -> () {
        for i in Array<Int>(ixs).sorted(by:>) {
            self.remove(at:i)
        }
    }
}

//Configure a Value Class at Point of Use

func lend<T> (_ closure: (T)->()) -> T where T: NSObject {
    let orig = T()
    closure(orig)
    return orig
}


