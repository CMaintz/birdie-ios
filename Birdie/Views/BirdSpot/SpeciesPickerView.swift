import SwiftUI
import AlertToast
struct SpeciesPickerView: View {
    @Binding var selectedSpecies: Set<String>
    @State private var searchText: String = ""
    @EnvironmentObject var toastManager: ToastManager

    private var allSpecies: [BirdSpecies] {
        BirdSpecies.allCases
    }

    private var filteredSpecies: [BirdSpecies] {
        if searchText.isEmpty {
            return allSpecies
        } else {
            return allSpecies.filter {
                $0.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            TextField("Search species", text: $searchText)
                .keyboardType(.namePhonePad)
                .autocorrectionDisabled(true)
                   .padding(8)
                   .background(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor))
                   .padding(.bottom, 4)
                   .padding(.horizontal)

            ScrollView {
                   LazyVStack(spacing: 0) {
                       ForEach(filteredSpecies, id: \.rawValue) { species in
                           MultipleSelectionRow(
                               title: species.rawValue,
                               isSelected: selectedSpecies.contains(species.rawValue)
                           ) {
                               toggleSelection(for: species.rawValue)
                           }
                           Divider()
                       }
                   }
               }
               .frame(maxHeight: 350)
           }
       }
    private func toggleSelection(for species: String) {
        if selectedSpecies.contains(species) {
            selectedSpecies.remove(species)
        } else {
            if selectedSpecies.count >= 10 {
                toastManager.showToast(AlertToast(displayMode: .banner(.slide), type: .error(.red), title: "Limit Reached", subTitle: "You can only select up to 10 species."))
                return
            }
            selectedSpecies.insert(species)
        }
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false
    @State private var animateCheckmark = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                    isPressed = false
                }
                animateCheckmark = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateCheckmark = false
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Color.clear.frame(width: 30, height: 24)
                    if isSelected || animateCheckmark {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .scaleEffect(animateCheckmark ? 1.5 : 1)
                            .rotationEffect(.degrees(animateCheckmark ? 20 : 0))
                            .opacity(animateCheckmark ? 1 : (isSelected ? 1 : 0))
                            .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: animateCheckmark)
                    } else {
                        Image(systemName: "checkmark")
                            .opacity(0)
                    }
                }

                Text(title)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

