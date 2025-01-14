//
//  TodayPresenter.swift
//  Today Extension
//
//  Created by Basem Emara on 2018-10-21.
//  Copyright © 2018 Zamzam Inc. All rights reserved.
//

import SwiftyPress
import ZamzamKit

struct TodayPresenter: TodayPresentable {
    private weak var viewController: TodayDisplayable?
    private let dateFormatter: DateFormatter
    
    init(viewController: TodayDisplayable?) {
        self.viewController = viewController
        
        self.dateFormatter = DateFormatter(
            dateFormat: "MMMM d yyyy"
        )
    }
}

extension TodayPresenter {
    
    func presentLatestPosts(for response: TodayModels.Response) {
        let viewModels = response.posts.map { post in
            PostsDataViewModel(
                from: post,
                mediaURL: response.media.first { $0.id == post.mediaID }?.thumbnailLink,
                favorite: nil,
                dateFormatter: self.dateFormatter
            )
        }
        
        viewController?.displayLatestPosts(with: viewModels)
    }
    
    func presentLatestPosts(error: DataError) {
        let viewModel = AppModels.Error(
            title: .localized(.latestPostsErrorTitle),
            message: error.localizedDescription
        )
        
        viewController?.display(error: viewModel)
    }
}
