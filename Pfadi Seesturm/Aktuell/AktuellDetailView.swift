//
//  AktuellDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI
import Kingfisher
import RichText

struct AktuellDetailView: View {
    
    @StateObject private var viewModel = AktuellDetailViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var appState: AppState
    var input: AktuellDetailViewInputType
    
    var body: some View {
        
        Group {
            switch(input) {
            case .id(let postId):
                // artikel id würde übergeben -> laden und anzeigen
                switch viewModel.loadingState {
                case .none, .loading, .errorWithReload(_):
                    VStack(spacing: 16) {
                        Rectangle()
                            .fill(Color.skeletonPlaceholderColor)
                            .aspectRatio(4/3, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .customLoadingBlinking()
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(2)
                            .padding(.horizontal)
                            .font(.title)
                            .fontWeight(.bold)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                        Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                            .padding(.bottom, -100)
                            .padding(.horizontal)
                            .font(.body)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                    }
                case .result(.failure(let error)):
                    ScrollView {
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: error.localizedDescription,
                            asyncRetryAction: {
                                await viewModel.fetchPost(by: postId, isPullToRefresh: false)
                            }
                        )
                        .padding(.vertical)
                    }
                case .result(.success(let post)):
                    AktuellDetailContentView(post: post)
                }
            case .object(let post):
                AktuellDetailContentView(post: post)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // push notifications
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AktuellDetailNavigationDestination.pushNotifications) {
                    Image(systemName: "bell.badge")
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if case .id(let postId) = input, viewModel.loadingState.taskShouldRun || postId != viewModel.currentPostId {
                    Task {
                        await viewModel.fetchPost(by: postId, isPullToRefresh: false)
                    }
                }
            }
        }
        .onAppear {
            if case .id(let postId) = input, viewModel.loadingState.taskShouldRun || postId != viewModel.currentPostId {
                Task {
                    await viewModel.fetchPost(by: postId, isPullToRefresh: false)
                }
            }
        }
        .navigationDestination(for: AktuellDetailNavigationDestination.self) { destination in
            switch destination {
            case .pushNotifications:
                PushNotificationVerwaltenView()
            }
        }
    }
}

// view to actually display the content of a post
struct AktuellDetailContentView: View {
    
    var post: TransformedAktuellPostResponse
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let imageUrl = URL(string: post.imageUrl) {
                        KFImage(imageUrl)
                            .placeholder { progress in
                                ZStack(alignment: .top) {
                                    Rectangle()
                                        .fill(Color.skeletonPlaceholderColor)
                                        .aspectRatio(post.aspectRatio, contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .customLoadingBlinking()
                                    ProgressView(value: progress.fractionCompleted, total: Double(1.0))
                                        .progressViewStyle(.linear)
                                        .tint(Color.SEESTURM_GREEN)
                                }
                            }
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(post.aspectRatio, contentMode: .fit)
                            .frame(width: geometry.size.width, height: geometry.size.width / post.aspectRatio)
                            .clipped()
                    }
                    Text(post.titleDecoded)
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, URL(string: post.imageUrl) == nil ? 16 : 0)
                    Label(post.published, systemImage: "calendar")
                        .padding(.horizontal)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .labelStyle(.titleAndIcon)
                    RichText(html: post.content)
                        .transition(.none)
                        .linkOpenType(.SFSafariView())
                        .placeholder(content: {
                            Text(Constants.PLACEHOLDER_TEXT)
                                .padding(.bottom, -100)
                                .padding(.horizontal)
                                .font(.body)
                                .redacted(reason: .placeholder)
                                .customLoadingBlinking()
                        })
                        .padding([.horizontal, .bottom])
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

enum AktuellDetailViewInputType: Hashable {
    case id(Int)
    case object(TransformedAktuellPostResponse)
}

enum AktuellDetailNavigationDestination: Hashable {
    case pushNotifications
}

#Preview("Artikel aus Internet laden") {
    AktuellDetailView(
        input: .id(11073)
    )
}

#Preview("Artikel übergeben") {
    AktuellDetailView(
        input: .object(
            TransformedAktuellPostResponse(
                id: 22566,
                publishedYear: "2023",
                published: "2023-06-28T16:29:56+00:00",
                modified: "2023-06-28T16:35:44+00:00",
                imageUrl: "https://seesturm.ch/wp-content/gallery/sola-2021-pfadi-piostufe/DSC1080.jpg",
                title: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
                titleDecoded: "Erinnerung: Anmeldung KaTre noch bis am 1. Juli",
                content: "\n<p>Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende <strong>vom 23. und 24. September</strong> unter dem Motto <strong>«Die Piraten vom Bodamicus»</strong>.</p>\n\n\n\n<p>Das KaTre 2023 findet ganz in der Nähe statt, nämlich in <strong>Romanshorn direkt am schönen Bodensee</strong>. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter <a rel=\"noreferrer noopener\" href=\"http: //www.katre.ch\" target=\"_blank\">www.katre.ch</a> oder in unserem Mail vom 2. Juni.</p>\n\n\n\n<p>Leider haben wir bisher erst sehr <strong>wenige Anmeldungen</strong> erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2023/06/KaTre-23__Anmeldetalon.pdf\" target=\"_blank\" rel=\"noreferrer noopener\">Anmeldeformular</a> aus und sendet es <strong>bis am 01. Juli</strong> an <a href=\"mailto: al@seesturm.ch\" target=\"_blank\" rel=\"noreferrer noopener\">al@seesturm.ch</a>.</p>\n\n\n\n<p>Danke!</p>\n",
                contentPlain: "Über 1000 Pfadis aus dem ganzen Thurgau treffen sich jährlich zum Kantonalen Pfaditreffen (KaTre) \u{2013} ein Höhepunkt im Kalender der Pfadi Thurgau. Dieses Jahr findet der Anlass erstmals seit 2019 wieder statt, und zwar am Wochenende vom 23. und 24. September unter dem Motto «Die Piraten vom Bodamicus».\n\n\n\nDas KaTre 2023 findet ganz in der Nähe statt, nämlich in Romanshorn direkt am schönen Bodensee. Es wird von der Pfadi Seesturm, gemeinsam mit den Pfadi-Abteilungen aus Arbon und Romanshorn, organisiert. Die Biber- und Wolfsstufe werden das KaTre am Sonntag besuchen, während die Pfadi- und Piostufe das ganze Wochenende «Pfadi pur» erleben dürfen. Weitere Informationen zum KaTre 2023 findet ihr unter www.katre.ch oder in unserem Mail vom 2. Juni.\n\n\n\nLeider haben wir bisher erst sehr wenige Anmeldungen erhalten. Es würde uns sehr freuen, wenn sich noch möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das Anmeldeformular aus und sendet es bis am 01. Juli an al@seesturm.ch.\n\n\n\nDanke!",
                aspectRatio: 5568/3712,
                author: "seesturm"
            )
        )
    )
}
