//
//  SnackbarView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import SwiftUI

struct SnackbarView: View {
    
    let type: SnackbarType
    let message: String
    let dismissAutomatically: Bool
    let allowManualDismiss: Bool
    let onDismiss: () -> Void
    @Binding var show: Bool
    
    @State private var dismissTask: DispatchWorkItem?
            
    var body: some View {
        ZStack {
            if show {
                VStack {
                    Spacer()
                    CustomCardView(shadowColor: .clear, backgroundColor: type.info.backgroundColor) {
                        HStack(alignment: .center, spacing: 16) {
                            type.info.icon
                                .resizable()
                                .foregroundColor(type.info.foregroundColor)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            Text(message)
                                .foregroundColor(type.info.foregroundColor)
                                .font(.callout)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(alignment: .leading)
                                .layoutPriority(1)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            scheduleDismissal()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    .onTapGesture {
                        if allowManualDismiss {
                            cancelAutomaticDismissal()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // function to schedule when the snackbar should be dismissed
    private func scheduleDismissal() {
        // cancel any existing dismissal task
        dismissTask?.cancel()
        // schedule if automatic dismissal is enabled
        if dismissAutomatically {
            dismissTask = DispatchWorkItem {
                dismiss()
            }
            if let dismissTask = dismissTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: dismissTask)
            }
        }
    }
    
    // function to cancel an automatic dismissal
    private func cancelAutomaticDismissal() {
        dismissTask?.cancel()
    }
    
    // function to dismiss the snackbar
    private func dismiss() {
        withAnimation(.easeInOut) {
            show = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

extension View {
    func snackbar(
        show: Binding<Bool>,
        type: SnackbarType,
        message: String,
        dismissAutomatically: Bool,
        allowManualDismiss: Bool,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(
            SnackbarModifier(
                show: show,
                type: type,
                message: message,
                dismissAutomatically: dismissAutomatically,
                allowManualDismiss: allowManualDismiss,
                onDismiss: onDismiss
            )
        )
    }
}

struct SnackbarModifier: ViewModifier {
    @Binding var show: Bool
    let type: SnackbarType
    let message: String
    let dismissAutomatically: Bool
    let allowManualDismiss: Bool
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            SnackbarView(
                type: type,
                message: message,
                dismissAutomatically: dismissAutomatically,
                allowManualDismiss: allowManualDismiss,
                onDismiss: onDismiss,
                show: $show
            )
        }
    }
    
}

struct SnackbarInfo {
    var backgroundColor: Color
    var icon: Image
    var foregroundColor: Color
}

extension SnackbarType {
    var info: SnackbarInfo {
        switch self {
        case .error:
            return SnackbarInfo(backgroundColor: .SEESTURM_RED, icon: Image(systemName: "xmark.circle"), foregroundColor: .white)
        case .info:
            return SnackbarInfo(backgroundColor: .SEESTURM_BLUE, icon: Image(systemName: "info.circle"), foregroundColor: .white)
        case .success:
            return SnackbarInfo(backgroundColor: .SEESTURM_GREEN, icon: Image(systemName: "checkmark.circle"), foregroundColor: .white)
        }
    }
}

struct SnackbarPreview: View {
    @State var showError = false
    @State var showInfo = false
    @State var showSuccess = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Show Error Snackbar") {
                showError = true
            }
            Button("Show Info Snackbar") {
                showInfo = true
            }
            Button("Show Success Snackbar") {
                showSuccess = true
            }
        }
        .snackbar(show: $showError, type: .error, message: "Ein Fehler ist aufgetreten", dismissAutomatically: false, allowManualDismiss: true, onDismiss: {})
        .snackbar(show: $showInfo, type: .info, message: "Irgend eine random Info.", dismissAutomatically: true, allowManualDismiss: true, onDismiss: {})
        .snackbar(show: $showSuccess, type: .success, message: "Irgend eine Erfolgsmeldung", dismissAutomatically: false, allowManualDismiss: false, onDismiss: {})
    }
    
}

#Preview {
    SnackbarPreview()
}
