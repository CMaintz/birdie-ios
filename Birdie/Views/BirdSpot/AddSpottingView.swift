//
//  AddSpottingView.swift
//  Birdie
//
//  Created by dmu mac 33 on 12/05/2025.
//

import SwiftUI
import AlertToast

struct AddSpottingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(BirdSpotController.self) var spotController
    @Environment(LocationController.self) var locationController
    @Environment(UserController.self) var userController
    @EnvironmentObject var toastManager: ToastManager

    @State var selectedSpecies: BirdSpecies?
    @State var note: String = ""
    @State var isSaving = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Species")) {
                        Picker("Observed Species:", selection: $selectedSpecies) {
                            Text("All Species").tag(BirdSpecies?.none)
                            ForEach(BirdSpecies.allCases, id: \.self) { species in
                                Text(species.rawValue.capitalized).tag(species)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Section(header: Text("Sighting Notes")) {
                        TextField("", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Section {
                        Button(action: {
                            Task {
                                await saveSpotting()
                            }
                        }) {
                            Text("Confirm Sighting")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button("Cancel") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    }
                }
            }
            .navigationTitle("New Sighting")
            .toast(isPresenting: $toastManager.show) {
                toastManager.alertToast
            }
        }
        .onAppear {
            locationController.startUpdatingLocation()
        }
        .onDisappear {
            locationController.stopUpdatingLocation()
        }
        .disabled(isSaving)
    }

    private func saveSpotting() async {
        isSaving = true

        guard
            let location = locationController.currentLocation,
            let userID = userController.getUserID(),
            let selectedSpecies
        else {
            toastManager.showToast(
                AlertToast(type: .error(.red), title: "Error", subTitle: "Missing required data.")
            )
            isSaving = false
            return
        }

        await spotController.add(selectedSpecies, location, note, userID)
        await spotController.updateSpots(currentLocation: locationController.currentLocation)

        toastManager.showToast(
            AlertToast(type: .complete(.green), title: "Sighting Added")
        )

        isSaving = false
        dismiss()
    }
}

#Preview {
    AddSpottingView().environment(BirdSpotController()).environment(
        UserController()
    ).environment(LocationController()).environmentObject(ToastManager()).environment(UserController())
}
