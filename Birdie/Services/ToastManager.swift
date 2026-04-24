//
//  AlertViewModel.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import AlertToast
import SwiftUI

class ToastManager: ObservableObject {
    @Published var show = false
    var alertToast: AlertToast = AlertToast(type: .regular)

    func showToast(_ toast: AlertToast, duration: Double = 2.0) {
        alertToast = toast
        show = true

        if duration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.show = false
            }
        }
    }

    func dismiss() {
        show = false
    }
}
