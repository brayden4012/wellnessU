//
//  Quote.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/7/21.
//

import Foundation
import SwiftUI

class ContentManager: ObservableObject {
    @Published var contentList: ContentList?
    @Published var selectedContent: Content?

    @MainActor
    init() {
        Task {
            self.contentList = try? await Networking().fetchQuotes()
        }
    }

    @MainActor
    static func previewManager(selectedContentType: ContentType?) -> ContentManager {
        let manager = ContentManager()
        switch selectedContentType {
        case .quote:
            manager.selectedContent = Content.previewQuoteModel
        case .joke:
            manager.selectedContent = Content.previewJokeModel
        case .trivia:
            manager.selectedContent = Content.previewTriviaModel
        default:
            break
        }
        return manager
    }
}

class ContentList: Codable {
    var quoteList = [Content]()
}

struct Content: Codable {
    static var defaultProfilePic = Image(systemName: "person.crop.circle.fill")

    let id: Int
    let author: String?
    let submitter: String
    let details: String
    let answer: String?
    let punchline: String?
    let profileImageUrl: String?
    let confluenceProfileUrl: String?

    var contentType: ContentType {
        if let author = author,
           !author.isEmpty {
            return .quote
        } else if let answer = answer,
                  !answer.isEmpty {
            return .trivia
        } else {
            return .joke
        }
    }

    func getProfileImage() async throws -> Image {
        guard let profileImageUrl = profileImageUrl else { return Content.defaultProfilePic }
        guard let uiImage = try? await Networking().fetchProfileImage(urlString: profileImageUrl) else { return Content.defaultProfilePic }
        return Image(uiImage: uiImage)
    }

    static var previewQuoteModel: Content {
        Content(id: 1, author: "Terminator", submitter: "John Doe", details: "\"Hasta la vista, baby\"", answer: nil, punchline: nil, profileImageUrl: nil, confluenceProfileUrl: nil)
    }

    static var previewJokeModel: Content {
        Content(id: 1, author: nil, submitter: "John Doe", details: "How do you know a pepper is mad at you?", answer: nil, punchline: "It gets Jalapeño face", profileImageUrl: nil, confluenceProfileUrl: nil)
    }

    static var previewTriviaModel: Content {
        Content(id: 1, author: nil, submitter: "John Doe", details: "What is 2 + 2", answer: "4", punchline: nil, profileImageUrl: nil, confluenceProfileUrl: nil)
    }
}

enum ContentType {
    case quote, joke, trivia

    var title: String {
        switch self {
        case .quote:
            return "Quote"
        case .joke:
            return "Joke"
        case .trivia:
            return "Question"
        }
    }
    var missingVariableMessage: String {
        switch self {
        case .quote:
            return "Uh oh! We forgot who this quote belongs to..."
        case .joke:
            return "Uh oh! We seem to have forgotten the punchline..."
        case .trivia:
            return "Uh oh! We seem to have lost the answer..."
        }
    }
}
