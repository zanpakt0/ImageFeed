//
//  ImagesListView.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 06.05.2025.
//

import UIKit

final class ImagesListView: UIView {
    // MARK: PROPERTIES
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AppColorSettings.backgroundColor
        tableView.separatorStyle = .none

        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )

        return tableView
    }()

    // MARK: INIT
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColorSettings.backgroundColor

        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
