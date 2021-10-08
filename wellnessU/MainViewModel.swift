//
//  MainViewModel.swift
//  wellnessU
//
//  Created by Brayden Harris on 10/7/21.
//

import Combine
import Foundation

class MainViewModel: ObservableObject {
    @Published var selectedNumber = ""
    var cancellables = [AnyCancellable]()

    init() {
        $selectedNumber.sink { newNumber in
            if let number = Int(newNumber) {
                if number < 1 {
                    DispatchQueue.main.async {
                        self.selectedNumber = "1"
                    }
                } else if number > 300 {
                    DispatchQueue.main.async {
                        self.selectedNumber = "300"
                    }
                }
            } else {
                guard !newNumber.isEmpty else { return }
                let trimmedNumber = newNumber.trimmingCharacters(in: .decimalDigits.inverted)
                DispatchQueue.main.async {
                    self.selectedNumber = trimmedNumber
                }
            }
        }
        .store(in: &cancellables)
    }
}
