//
//  AktuellView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct AktuellView: View {
        
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: AktuellViewModel = AktuellViewModel()
            
    var body: some View {
        NavigationStack(path: $appState.tabNavigationPaths[AppMainTab.aktuell.id]) {
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        switch viewModel.initialPostsLoadingState {
                        case .loading, .none, .errorWithReload(_):
                            Section(header:
                                        BasicStickyHeader(title: "Pfadijahr 2024")
                                .redacted(reason: .placeholder)
                                .customLoadingBlinking()
                            ) {
                                ForEach(0..<4) {index in
                                    AktuellSkeletonCardView()
                                        .padding(.top, index == 0 ? 16 : 0)
                                }
                            }
                        case .error(let error):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: error.localizedDescription,
                                asyncRetryAction: {
                                    await viewModel.loadInitialSetOfPosts(isPullToRefresh: false)
                                }
                            )
                            .padding(.vertical)
                        case .success:
                            ForEach(Array(viewModel.groupedPosts().enumerated()), id: \.element.year) { sectionIndex, section in
                                Section {
                                    ForEach(Array(section.posts.enumerated()), id: \.element.id) { index, post in
                                        NavigationLink(value: AktuellDetailViewInputType.object(post)) {
                                            AktuellCardView(
                                                post: post,
                                                width: geometry.size.width
                                            )
                                            .padding(.top, index == 0 ? 16 : 0)
                                        }
                                        .foregroundStyle(Color.primary)
                                    }
                                } header: {
                                    BasicStickyHeader(title: "Pfadijahr \(section.year)")
                                        .background(Color.customBackground)
                                }
                                
                            }
                            switch viewModel.morePostsLoadingState {
                            case .error(let error):
                                CardErrorView(
                                    errorTitle: "Es konnten keine weiteren Posts geladen werden",
                                    errorDescription: error.localizedDescription,
                                    asyncRetryAction: {
                                        await viewModel.loadMorePosts()
                                    }
                                )
                                .padding(.bottom)
                            default:
                                if viewModel.postsLoadedCount < viewModel.totalPostsAvailable {
                                    AktuellSkeletonCardView()
                                        .onAppear {
                                            if viewModel.morePostsLoadingState.infiniteScrollTaskShouldRun {
                                                Task {
                                                    await viewModel.loadMorePosts()
                                                }
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                // push notifications
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: AktuellNavigationDestination.pushNotifications) {
                            Image(systemName: "bell.badge")
                        }
                    }
                }
                .background(Color.customBackground)
                .scrollDisabled(viewModel.initialPostsLoadingState.scrollingDisabled)
                .task {
                    if viewModel.initialPostsLoadingState.taskShouldRun {
                        await viewModel.loadInitialSetOfPosts(isPullToRefresh: false)
                    }
                }
                .refreshable {
                    await Task {
                        await viewModel.loadInitialSetOfPosts(isPullToRefresh: true)
                    }.value
                }
                .navigationTitle("Aktuell")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: AktuellNavigationDestination.self) { destination in
                    switch destination {
                    case .pushNotifications:
                        PushNotificationVerwaltenView()
                    }
                }
                .navigationDestination(for: AktuellDetailViewInputType.self) { input in
                    AktuellDetailView(input: input)
                }
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

enum AktuellNavigationDestination: Hashable {
    case pushNotifications
}

#Preview() {
    AktuellView()
        .environmentObject(AppState())
}
