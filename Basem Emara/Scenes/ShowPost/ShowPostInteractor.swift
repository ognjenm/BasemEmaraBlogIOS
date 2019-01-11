//
//  ShowPostInteractor.swift
//  Basem Emara
//
//  Created by Basem Emara on 2018-10-02.
//  Copyright © 2018 Zamzam Inc. All rights reserved.
//

import SwiftyPress

struct ShowPostInteractor: ShowPostBusinessLogic {
    private let presenter: ShowPostPresentable
    private let postWorker: PostWorkerType
    private let mediaWorker: MediaWorkerType
    private let authorWorker: AuthorWorkerType
    private let taxonomyWorker: TaxonomyWorkerType
    
    init(presenter: ShowPostPresentable,
         postWorker: PostWorkerType,
         mediaWorker: MediaWorkerType,
         authorWorker: AuthorWorkerType,
         taxonomyWorker: TaxonomyWorkerType) {
        self.presenter = presenter
        self.postWorker = postWorker
        self.mediaWorker = mediaWorker
        self.authorWorker = authorWorker
        self.taxonomyWorker = taxonomyWorker
    }
}

extension ShowPostInteractor {
    
    func fetchPost(with request: ShowPostModels.Request) {
        postWorker.fetch(id: request.postID) {
            guard let value = $0.value, $0.isSuccess else {
                return self.presenter.presentPost(
                    error: $0.error ?? .unknownReason(nil)
                )
            }
            
            self.presenter.presentPost(
                for: ShowPostModels.Response(
                    post: value.post,
                    media: value.media,
                    categories: value.categories,
                    tags: value.tags,
                    author: value.author,
                    favorite: self.postWorker.hasFavorite(id: value.post.id)
                )
            )
        }
    }
}

extension ShowPostInteractor {
    
    func fetchByURL(with request: ShowPostModels.FetchWebRequest) {
        postWorker.fetch(url: request.url) {
            // Handle if URL is not for a post
            if case .nonExistent? = $0.error {
                self.taxonomyWorker.fetch(url: request.url) {
                    guard let term = $0.value, $0.isSuccess else {
                        // URL could not be found
                        return self.presenter.presentByURL(
                            for: ShowPostModels.FetchWebResponse(
                                post: nil,
                                term: nil,
                                decisionHandler: request.decisionHandler
                            )
                        )
                    }
                    
                    // URL was a taxonomy term
                    self.presenter.presentByURL(
                        for: ShowPostModels.FetchWebResponse(
                            post: nil,
                            term: term,
                            decisionHandler: request.decisionHandler
                        )
                    )
                }
                
                return
            }
            
            guard let post = $0.value, $0.isSuccess else {
                // URL could not be found
                return self.presenter.presentByURL(
                    for: ShowPostModels.FetchWebResponse(
                        post: nil,
                        term: nil,
                        decisionHandler: request.decisionHandler
                    )
                )
            }
            
            // URL was a post
            self.presenter.presentByURL(
                for: ShowPostModels.FetchWebResponse(
                    post: post,
                    term: nil,
                    decisionHandler: request.decisionHandler
                )
            )
        }
    }
}

extension ShowPostInteractor {
    
    func toggleFavorite(with request: ShowPostModels.FavoriteRequest) {
        postWorker.toggleFavorite(id: request.postID)
        
        presenter.presentToggleFavorite(
            for: ShowPostModels.FavoriteResponse(
                favorite: postWorker.hasFavorite(id: request.postID)
            )
        )
    }
}
