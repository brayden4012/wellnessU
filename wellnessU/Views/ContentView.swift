//
//  QuoteView.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/7/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var contentManager: ContentManager

    var body: some View {
        ZStack {
            switch contentManager.selectedContent?.contentType {
            case .quote:
                QuoteView(quote: contentManager.selectedContent!)
            case .joke, .trivia:
                QuestionAnswerView(content: contentManager.selectedContent!)
            default:
                ErrorView()
            }

            NavBar(contentType: contentManager.selectedContent?.contentType)

            VStack {
                Spacer()
                Color("calmGreen")
                    .frame(height: 60)
            }
            .ignoresSafeArea()

            if let selectedContent = contentManager.selectedContent {
                VStack {
                    Spacer()
                    SubmitterView(viewModel: SubmitterViewModel(content: selectedContent))
                    Spacer()
                        .frame(height: 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ErrorView: View {
    var body: some View {
        Text("This is awkward...\nWe're having trouble loading your content. Please try again later")
            .multilineTextAlignment(.center)
            .font(Font.custom("OpenSans-Regular", size: 30.0))
    }
}

struct QuoteView: View {
    let quote: Content
    var authorText: String {
        "- \(quote.author!)"
    }

    var body: some View {
        ZStack {
            EmojiShowerView(emojis: "💭🤔")
            VStack(spacing: 20) {
                Text(quote.details)
                    .multilineTextAlignment(.center)
                    .font(Font.custom("OpenSans-Regular", size: 30.0))
                Text(authorText)
                    .multilineTextAlignment(.center)
                    .font(Font.custom("OpenSans-Regular", size: 30.0))
            }
        }
    }
}

struct QuestionAnswerView: View {
    let content: Content

    @State var showAnswer = false

    var emojis: String {
        switch content.contentType {
        case .joke:
            return "😂🤣😹"
        case .trivia:
            return "🧠💡"
        default:
            return ""
        }
    }

    var body: some View {
        ZStack(alignment: .center) {
            if showAnswer {
                EmojiShowerView(emojis: emojis)
            }

            VStack(spacing: 20) {
                if showAnswer {
                    Text(content.punchline ?? content.answer ?? content.contentType.missingVariableMessage)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("OpenSans-Regular", size: 30.0))
                } else {
                    Text(content.details)
                        .multilineTextAlignment(.center)
                        .font(Font.custom("OpenSans-Regular", size: 30.0))
                }

                Button {
                    showAnswer.toggle()
                } label: {
                    Text(showAnswer ? "Hide Answer" : "Answer")
                        .foregroundColor(.black)
                }
                .frame(width: 200, height: 50)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2))

            }
        }
    }
}

class SubmitterViewModel: ObservableObject {
    let content: Content
    @Published var profileImage = Image(systemName: "person.crop.circle.fill")

    @MainActor
    init(content: Content) {
        self.content = content
        Task {
            if let profileImage = try? await Networking().fetchProfileImage(urlString: content.profileImageUrl) {
                self.profileImage = Image(uiImage: profileImage)
            }
        }
    }
}

struct SubmitterView: View {
    @ObservedObject var viewModel: SubmitterViewModel
    @State var showConfluenceProfile = false

    var body: some View {
        VStack {
            viewModel.profileImage
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)

            Text(viewModel.content.submitter)
                .multilineTextAlignment(.center)
                .font(Font.custom("OpenSans-Bold", size: 20.0))
                .foregroundColor(.blue)
                .onTapGesture {
                    showConfluenceProfile.toggle()
                }
        }
        .sheet(isPresented: $showConfluenceProfile) {
            print("Dismissed!")
        } content: {
            if let urlString = viewModel.content.confluenceProfileUrl,
            let url = URL(string: urlString) {
                SafariView(url: url)
            } else {
                Text("We're missing \(viewModel.content.submitter)'s profile")
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(ContentManager.previewManager(selectedContentType: nil))
            ContentView()
                .environmentObject(ContentManager.previewManager(selectedContentType: .quote))
            ContentView()
                .environmentObject(ContentManager.previewManager(selectedContentType: .joke))
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
