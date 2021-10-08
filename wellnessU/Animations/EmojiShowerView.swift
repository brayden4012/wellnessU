//
//  Confetti.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/7/21.
//

import UIKit
import SwiftUI

final class EmojiShowerView: UIViewControllerRepresentable {

    let emojis: String

    init(emojis: String) {
        self.emojis = emojis
    }

    func makeUIViewController(context: Context) -> EmojiShowerViewController {
        EmojiShowerViewController(emojis: emojis)
    }

    func updateUIViewController(_ uiViewController: EmojiShowerViewController, context: Context) { }
}

class EmojiShowerViewController: UIViewController {

    let emojis: String

    init(emojis: String) {
        self.emojis = emojis
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var confettiLayer: CAEmitterLayer = {
        let emitterLayer = CAEmitterLayer()

        emitterLayer.emitterCells = confettiCells
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 500)
        emitterLayer.emitterSize = CGSize(width: view.bounds.size.width, height: 500)
        emitterLayer.emitterShape = .rectangle
        emitterLayer.frame = view.bounds

        emitterLayer.beginTime = CACurrentMediaTime()
        return emitterLayer
    }()

    lazy var confettiCells: [CAEmitterCell] = {
        return Array(emojis).map { emoji in
            let cell = CAEmitterCell()

            cell.beginTime = 0.1
            cell.birthRate = 5
            let image = String(emoji).textToImage()?.resized(newWidth: 50)
            cell.contents = image?.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 2
            cell.spinRange = 8
            cell.velocityRange = 50
            cell.yAcceleration = 50

            return cell
        }
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layer.addSublayer(confettiLayer)
    }
}

extension UIImage {
    func resized(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension String {
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 1024) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}
