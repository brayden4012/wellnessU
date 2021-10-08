//
//  SafariView.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/8/21.
//

import SafariServices
import SwiftUI

final class SafariView: UIViewControllerRepresentable {

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}
