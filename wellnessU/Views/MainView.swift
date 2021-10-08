//
//  MainView.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/7/21.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var contentManager: ContentManager

    @ObservedObject var mainViewModel = MainViewModel()

    @State var showContent = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 15)
                    
                    VStack(spacing: 40) {
                        Text("Welcome to wellnessU, \nwe're happy you came.")
                            .font(Font.custom("OpenSans-Regular", size: 30.0))
                            .multilineTextAlignment(.center)
                        Text("Take a moment for U.")
                            .font(Font.custom("OpenSans-Regular", size: 30.0))
                        Text("Powered by Rocketeers")
                            .font(Font.custom("OpenSans-Regular", size: 30.0))
                    }

                    Spacer()
                        .frame(height: 100)

                    HStack(alignment: .top, spacing: 20) {
                        VStack {
                            TextField("", text: $mainViewModel.selectedNumber)
                                .multilineTextAlignment(.center)
                                .keyboardType(.numberPad)
                                .frame(height: 50)
                                .frame(maxWidth: 100)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 4)
                                )
                            Text("Pick a number 1 to 300")
                                .font(Font.custom("OpenSans-Regular", size: 15.0))
                        }


                        Button {
                            selectContent()
                            showContent = true
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 45, height: 45)
                                Text("🚀")
                                    .font(.system(size: 30))
                            }
                        }
                        .disabled(mainViewModel.selectedNumber.isEmpty)

                    }
                }

                NavBar()

                NavigationLink(isActive: $showContent) {
                    ContentView()
                } label: {
                    EmptyView()
                }
            }
            .onDisappear {
                mainViewModel.selectedNumber.removeAll()
            }
            .navigationBarHidden(true)
        }
    }

    private func selectContent() {
        guard let contentList = contentManager.contentList?.quoteList,
              var selectedNumber = Int(mainViewModel.selectedNumber) else { return }

        while selectedNumber > contentList.count {
            selectedNumber -= contentList.count
        }
        contentManager.selectedContent = contentList[selectedNumber - 1]
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView()
            MainView()
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}

struct NavBar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var contentType: ContentType?

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Color("calmGreen")
                    .ignoresSafeArea()
                Image("appLogo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .frame(height: 125)

            if let contentType = contentType {
                Text(contentType.title)
                    .underline()
                    .font(Font.custom("OpenSans-Bold", size: 20.0))
            }
            
            Spacer()
        }
    }
}
