import Foundation
import UIKit
import AsyncDisplayKit
import Postbox
import Display
import SwiftSignalKit

class ChatListEmptyItem: ListViewItem {
    let selectable: Bool = false
    
    init() {
    }
    
    func nodeConfiguredForWidth(async: @escaping (@escaping () -> Void) -> Void, width: CGFloat, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, () -> Void)) -> Void) {
        async {
            let node = ChatListEmptyItemNode()
            node.layoutForWidth(width, item: self, previousItem: previousItem, nextItem: nextItem)
            node.updateItemPosition(first: previousItem == nil, last: nextItem == nil)
            completion(node, {
                return (nil, {})
            })
        }
    }
    
    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: ListViewItemNode, width: CGFloat, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping () -> Void) -> Void) {
        assert(node is ChatListEmptyItemNode)
        if let node = node as? ChatListEmptyItemNode {
            Queue.mainQueue().async {
                node.layoutForWidth(width, item: self, previousItem: previousItem, nextItem: nextItem)
                node.updateItemPosition(first: previousItem == nil, last: nextItem == nil)
                
                completion(ListViewItemNodeLayout(contentSize: node.contentSize, insets: node.insets), {})
            }
        }
    }
}

private let separatorHeight = 1.0 / UIScreen.main.scale

class ChatListEmptyItemNode: ListViewItemNode {
    let separatorNode: ASDisplayNode
    
    required init() {
        self.separatorNode = ASDisplayNode()
        self.separatorNode.backgroundColor = UIColor(0xc8c7cc)
        self.separatorNode.isLayerBacked = true
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.separatorNode)
    }
    
    override func layoutForWidth(_ width: CGFloat, item: ListViewItem, previousItem: ListViewItem?, nextItem: ListViewItem?) {
        self.separatorNode.frame = CGRect(origin: CGPoint(x: 0.0, y: 68.0 - separatorHeight), size: CGSize(width: width, height: separatorHeight))
        
        self.contentSize = CGSize(width: width, height: 68.0)
    }
    
    func updateItemPosition(first: Bool, last: Bool) {
        self.insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}
