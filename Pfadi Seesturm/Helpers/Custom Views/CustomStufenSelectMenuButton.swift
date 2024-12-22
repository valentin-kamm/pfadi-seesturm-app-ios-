//
//  CustomMenuButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct CustomStufenSelectMenuButton: View {
    
    @Binding var selectedStufen: Set<SeesturmStufe>
    
    var options: [SeesturmStufe] = [.biber, .wolf, .pfadi, .pio]
    
    var body: some View {
        Menu {
            ForEach(options, id: \.id) { option in
                Button(action: {
                    toggleSelection(option: option)
                }) {
                    HStack {
                        Text(option.description)
                        if selectedStufen.contains(option) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(getButtonDisplayText())
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.subheadline)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.gray.opacity(0.2))
            .foregroundStyle(Color.SEESTURM_GREEN)
            .cornerRadius(16)
        }
    }
    
    private func toggleSelection(option: SeesturmStufe) {
        withAnimation {
            if !selectedStufen.contains(option) {
                selectedStufen.insert(option)
            }
            else {
                selectedStufen.remove(option)
            }
        }
    }
    
    private func getButtonDisplayText() -> String {
        if selectedStufen.count == 0 {
            return "Wählen"
        }
        else if selectedStufen.count == 4 {
            return "Alle"
        }
        else if selectedStufen.count == 1 {
            if let singleStufe = selectedStufen.first?.description {
                return singleStufe
            }
            else {
                return "Wählen"
            }
        }
        else {
            return "Mehrere"
        }
    }
}

#Preview {
    CustomStufenSelectMenuButton(
        selectedStufen: .constant([.biber, .pio])
    )
}
