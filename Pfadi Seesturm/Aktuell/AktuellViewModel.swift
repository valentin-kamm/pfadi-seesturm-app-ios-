//
//  WordpressAPIUtil.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

@MainActor
class AktuellViewModel: ObservableObject {
    
    private let aktuellNetworkManager = AktuellNetworkManager.shared
    
    @Published var posts: [TransformedAktuellPostResponse] = []
    @Published var totalPostsAvailable: Int = 0
    @Published var postsLoadedCount: Int = 0
    private let numberOfPostsPerPage: Int = 5
    
    @Published var initialPostsLoadingState: SeesturmLoadingState = .none
    @Published var morePostsLoadingState: SeesturmLoadingState = .none
    
    // function to fetch the initial set of posts
    func loadInitialSetOfPosts(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.initialPostsLoadingState = isPullToRefresh ? initialPostsLoadingState : .loading
        }
        
        do {
            let loadedPosts = try await aktuellNetworkManager.fetchPosts(start: 0, length: numberOfPostsPerPage)
            withAnimation {
                self.totalPostsAvailable = loadedPosts.totalPosts
                self.postsLoadedCount = loadedPosts.posts.count
                self.posts = loadedPosts.posts.map { $0.toTransformedPost() }
                self.initialPostsLoadingState = .success
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.initialPostsLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.initialPostsLoadingState = .error(error: pfadiSeesturmError)
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.initialPostsLoadingState = .error(error: pfadiSeesturmError)
            }
        }
    }
    
    // function to fetch more posts
    func loadMorePosts() async {
        
        withAnimation {
            self.morePostsLoadingState = .loading
        }
        
        do {
            let moreLoadedPosts = try await aktuellNetworkManager.fetchPosts(start: postsLoadedCount, length: numberOfPostsPerPage)
            self.postsLoadedCount += moreLoadedPosts.posts.count
            self.posts.append(contentsOf: moreLoadedPosts.posts.map{ $0.toTransformedPost() })
            self.morePostsLoadingState = .success
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                self.morePostsLoadingState = .errorWithReload(error: pfadiSeesturmError)
            }
            else {
                self.morePostsLoadingState = .error(error: pfadiSeesturmError)
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            self.morePostsLoadingState = .error(error: pfadiSeesturmError)
        }
        
    }
    
    // function to get the posts grouped by year
    func groupedPosts() -> [(year: String, posts: [TransformedAktuellPostResponse])] {
        let groupedDictionary = Dictionary(grouping: posts, by: { $0.publishedYear })
        return groupedDictionary
            .sorted { $0.key > $1.key }
            .map { (year: $0.key, posts: $0.value) }
    }
    
}
