//
// PullUpToRefreshTableview.swift
//
// Created by Marwen on 17/08/2018.
// Copyright :Marwen Doukh 2018. All rights reserved.
//

// MARK: Delegate
@objc public protocol PullUpToRefreshTableviewDelegate: class {
    func tableviewDidPullUp()
}

public class PullUpToRefreshTableview: UITableView, UITableViewDelegate {
    
    // MARK: Customization vars
    @IBInspectable
    public var differenceThreshold: CGFloat = 10.0
    @IBInspectable
    public var refreshThreshold: CGFloat = 100
    public var bottomView: UIView = UIView()
    @IBOutlet public weak var pullUpToRefreshDelegate: PullUpToRefreshTableviewDelegate?
    
    // MARK: Private vars
    fileprivate var previousScrollingPosition: CGFloat = 0.0
    fileprivate var isBottomViewAdded = false
    fileprivate var animationDuration: Double = 0.2
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    // MARK: Utils functions
    
    // detect how much the user scrolled
    fileprivate func calculateScrollingDistance() -> CGFloat {
        let currentOffset = self.contentOffset.y
        let maximumOffset = self.contentSize.height - self.frame.size.height
        return maximumOffset - currentOffset
    }
    
    // check if the user is scrolling from the tableview bottom
    fileprivate func isLoadingFromBottom() -> Bool {
        let contentSize = self.contentSize.height
        let tableSize = self.frame.size.height - self.contentInset.top - self.contentInset.bottom
        return contentSize > tableSize
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let isLoadingFromBottom = self.isLoadingFromBottom()
        let scrollingDistance = calculateScrollingDistance()
        // if the user scrolled from the tabelview bottom and passed the threshold , then save the current position
        if isLoadingFromBottom, scrollingDistance <= differenceThreshold {
            // Save the current position
            previousScrollingPosition = scrollView.contentInset.bottom
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let isLoadingFromBottom = self.isLoadingFromBottom()
        let scrollingDistance = calculateScrollingDistance()
        
        if isLoadingFromBottom, scrollingDistance <= -differenceThreshold {
            // check if the bottomView has already been added
            if !isBottomViewAdded {
                // add bottomView
                self.tableFooterView = bottomView
                isBottomViewAdded = true
                // add space in the tableview bottom
                UIView.animate(withDuration: animationDuration) {
                    scrollView.contentInset.bottom = self.previousScrollingPosition
                }
            }
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let isLoadingFromBottom = self.isLoadingFromBottom()
        let scrollingDistance = calculateScrollingDistance()
        
        if isBottomViewAdded && isLoadingFromBottom && scrollingDistance < -refreshThreshold {
            pullUpToRefreshDelegate?.tableviewDidPullUp()
        }
        
        // remove bottomView
        isBottomViewAdded = false
        UIView.animate(withDuration: animationDuration) {
            scrollView.contentInset.bottom = self.previousScrollingPosition
            self.tableFooterView = nil
        }
    }
    
    // remove bottomView after finishing scroll
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // remove bottomView
        UIView.animate(withDuration: animationDuration) {
            scrollView.contentInset.bottom = self.previousScrollingPosition
            self.tableFooterView = nil
        }
        isBottomViewAdded = false
    }
    
}
