//
//  CustomPrimaryButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

// custom primary button that is used throughout the app
struct CustomButton: View {
    
    var buttonStyle: CustomButtonStyle
    var buttonTitle: String?
    var buttonSystemIconName: String?
    var buttonCustomIconName: String?
    @Binding var isLoading: Bool
    var isDisabled: Bool
    var buttonAction: (() -> Void)?
    var asyncButtonAction: (() async throws -> Void)?
    
    init(
        buttonStyle: CustomButtonStyle,
        buttonTitle: String?,
        buttonSystemIconName: String? = nil,
        buttonCustomIconName: String? = nil,
        isLoading: Binding<Bool> = .constant(false),
        isDisabled: Bool = false,
        buttonAction: (() -> Void)? = nil,
        asyncButtonAction: (() async throws -> Void)? = nil
    ) {
        self.buttonStyle = buttonStyle
        self.buttonTitle = buttonTitle
        self.buttonSystemIconName = buttonSystemIconName
        self.buttonCustomIconName = buttonCustomIconName
        self._isLoading = isLoading
        self.isDisabled = isDisabled
        self.buttonAction = buttonAction
        self.asyncButtonAction = asyncButtonAction
    }
    
    var body: some View {
        
        VStack {
            switch buttonStyle {
            case .primary:
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        HStack {
                            if let title = buttonTitle {
                                Text(title)
                                    .lineLimit(1)
                            }
                            if let systemIconName = buttonSystemIconName {
                                Image(systemName: systemIconName)
                            }
                            else if let customIconName = buttonCustomIconName {
                                Image(customIconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        if isLoading {
                            ProgressView()
                                .tint(Color.white)
                        }
                    }
                }
                .buttonStyle(PrimaryButtonConfig(isLoading: $isLoading))
                .cornerRadius(16)
                .buttonStyle(.plain)
                .disabled(isLoading || isDisabled)
            case .secondary:
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        HStack {
                            if let title = buttonTitle {
                                Text(title)
                                    .lineLimit(1)
                            }
                            if let systemIconName = buttonSystemIconName {
                                Image(systemName: systemIconName)
                            }
                            else if let customIconName = buttonCustomIconName {
                                Image(customIconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        if isLoading {
                            ProgressView()
                        }
                    }
                }
                .buttonStyle(SecondaryButtonConfig(isLoading: $isLoading))
                .cornerRadius(16)
                .buttonStyle(.plain)
                .disabled(isLoading)
            case .tertiary(let color):
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        HStack {
                            if let title = buttonTitle {
                                Text(title)
                                    .lineLimit(1)
                            }
                            if let systemIconName = buttonSystemIconName {
                                Image(systemName: systemIconName)
                            }
                            else if let customIconName = buttonCustomIconName {
                                Image(customIconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        if isLoading {
                            ProgressView()
                                .tint(Color.white)
                        }
                    }
                }
                .buttonStyle(TertiaryButtonConfig(isLoading: $isLoading, buttonColor: color))
                .cornerRadius(16)
                .buttonStyle(.plain)
                .disabled(isLoading)
            }
        }
    }
}

// button configurations
struct PrimaryButtonConfig: ButtonStyle {
    @Binding var isLoading: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.SEESTURM_RED)
            .foregroundStyle(isLoading ? Color.clear : Color.white)
    }
}
struct SecondaryButtonConfig: ButtonStyle {
    @Binding var isLoading: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
            .foregroundStyle(isLoading ? Color.clear : Color.primary)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.SEESTURM_GREEN, lineWidth: 5)
            }
    }
}
struct TertiaryButtonConfig: ButtonStyle {
    @Binding var isLoading: Bool
    var buttonColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .clipShape(Capsule())
            .background(buttonColor)
            .foregroundStyle(isLoading ? Color.clear : Color.white)
            .font(.subheadline)
    }
}

#Preview("Primary Button") {
    CustomButton(
        buttonStyle: .primary,
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: .constant(false)
    )
}
#Preview("Primary Button Loading") {
    CustomButton(
        buttonStyle: .primary,
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: .constant(true)
    )
}

#Preview("Secondary Button") {
    CustomButton(
        buttonStyle: .secondary,
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: .constant(false)
    )
}
#Preview("Secondary Button Loading") {
    CustomButton(
        buttonStyle: .secondary,
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: .constant(true)
    )
}

#Preview("Tertiary Button") {
    CustomButton(
        buttonStyle: .tertiary(),
        buttonTitle: "Test-Button",
        buttonCustomIconName: "midataLogo",
        isLoading: .constant(false)
    )
}
#Preview("Tertiary Button Loading") {
    CustomButton(
        buttonStyle: .tertiary(),
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: .constant(true)
    )
}
