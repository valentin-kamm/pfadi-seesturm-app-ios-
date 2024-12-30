//
//  AktivitätBearbeitenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI
import InfomaniakRichHTMLEditor

struct AktivitaetBearbeitenView: View {
    
    let stufe: SeesturmStufe
    let contentMode: AktivitaetBearbeitenViewContentMode
    @StateObject private var viewModel: AktivitaetBearbeitenViewModel
    @StateObject private var textAttributes: TextAttributes
    
    init(
        stufe: SeesturmStufe,
        contentMode: AktivitaetBearbeitenViewContentMode
    ) {
        self.stufe = stufe
        self.contentMode = contentMode
        _viewModel = StateObject(wrappedValue: AktivitaetBearbeitenViewModel(stufe: stufe))
        _textAttributes = StateObject(wrappedValue: TextAttributes())
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Stufe", selection: $viewModel.stufe) {
                    Text(SeesturmStufe.biber.description)
                        .tag(SeesturmStufe.biber)
                    Text(SeesturmStufe.wolf.description)
                        .tag(SeesturmStufe.wolf)
                    Text(SeesturmStufe.pfadi.description)
                        .tag(SeesturmStufe.pfadi)
                    Text(SeesturmStufe.pio.description)
                        .tag(SeesturmStufe.pio)
                }
                .pickerStyle(.menu)
                .tint(Color.SEESTURM_GREEN)
                .disabled(true)
            }
            Section {
                DatePicker("Start", selection: $viewModel.startDateTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .disabled(viewModel.publishEventLoadingState.userInteractionDisabled)
                    .tint(Color.SEESTURM_GREEN)
                DatePicker("Ende", selection: $viewModel.endDateTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .disabled(viewModel.publishEventLoadingState.userInteractionDisabled)
                    .tint(Color.SEESTURM_GREEN)
                HStack(spacing: 16) {
                    Text("Treffpunkt")
                    TextField("Treffpunkt", text: $viewModel.treffpunkt)
                        .multilineTextAlignment(.trailing)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemGray6))
                        )
                        .disabled(viewModel.publishEventLoadingState.userInteractionDisabled)
                }
                .padding(.vertical, -2)
            } header: {
                Text("Zeit und Treffpunkt")
            }
            Section {
                RichHTMLEditor(html: $viewModel.html, textAttributes: textAttributes)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .disabled(viewModel.publishEventLoadingState.userInteractionDisabled)
            } header: {
                Text("Beschreibung")
            }
            Section {
                Toggle("Push-Nachricht senden", isOn: $viewModel.sendPushNotification)
                    .tint(Color.SEESTURM_GREEN)
                    .disabled(viewModel.publishEventLoadingState.userInteractionDisabled)
            } header: {
                Text("Veröffentlichen")
            }
            Section {
                CustomButton(
                    buttonStyle: .primary,
                    buttonTitle: (viewModel.sendPushNotification ? "Mit" : "Ohne") + " Push-Nachricht veröffentlichen",
                    isLoading: viewModel.publishEventLoadingState.loadingBinding(from: viewModel.$publishEventLoadingState),
                    asyncButtonAction: {
                        await viewModel.publishEvent()                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(contentMode == .new ? "Neue Aktivität" : "Aktivität bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
    }
}

enum AktivitaetBearbeitenViewContentMode: Equatable {
    case new
    case edit(eventId: String)
}

#Preview {
    AktivitaetBearbeitenView(
        stufe: .biber,
        contentMode: .new
    )
}
