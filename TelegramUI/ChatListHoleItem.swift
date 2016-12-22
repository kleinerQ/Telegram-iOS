import Foundation
import UIKit
import AsyncDisplayKit
import Postbox
import Display
import SwiftSignalKit

private let titleFont = Font.regular(17.0)

class ChatListHoleItem: ListViewItem {
    let selectable: Bool = false
    
    init() {
    }
    
    func nodeConfiguredForWidth(async: @escaping (@escaping () -> Void) -> Void, width: CGFloat, previousItem: ListViewItem?, nextItem: ListViewItem?, completion: @escaping (ListViewItemNode, @escaping () -> (Signal<Void, NoError>?, () -> Void)) -> Void) {
        async {
            let node = ChatListHoleItemNode()
            node.relativePosition = (first: previousItem == nil, last: nextItem == nil)
            node.insets = ChatListItemNode.insets(first: false, last: false, firstWithHeader: false)
            node.layoutForWidth(width, item: self, previousItem: previousItem, nextItem: nextItem)
            completion(node, {
                return (nil, {})
            })
        }
    }
    
    func updateNode(async: @escaping (@escaping () -> Void) -> Void, node: ListViewItemNode, width: CGFloat, previousItem: ListViewItem?, nextItem: ListViewItem?, animation: ListViewItemUpdateAnimation, completion: @escaping (ListViewItemNodeLayout, @escaping () -> Void) -> Void) {
        assert(node is ChatListHoleItemNode)
        if let node = node as? ChatListHoleItemNode {
            Queue.mainQueue().async {
                let layout = node.asyncLayout()
                async {
                    let first = previousItem == nil
                    let last = nextItem == nil
                    
                    let (nodeLayout, apply) = layout(width, first, last)
                    Queue.mainQueue().async {
                        completion(nodeLayout, { [weak node] in
                            apply()
                            node?.updateBackgroundAndSeparatorsLayout()
                        })
                    }
                }
            }
        }
    }
}

private let separatorHeight = 1.0 / UIScreen.main.scale

class ChatListHoleItemNode: ListViewItemNode {
    let separatorNode: ASDisplayNode
    let labelNode: TextNode
    
    var relativePosition: (first: Bool, last: Bool) = (false, false)
    
    required init() {
        self.separatorNode = ASDisplayNode()
        self.separatorNode.backgroundColor = UIColor(0xc8c7cc)
        self.separatorNode.isLayerBacked = true
        
        self.labelNode = TextNode()
        
        super.init(layerBacked: false, dynamicBounce: false)
        
        self.addSubnode(self.separatorNode)
        self.addSubnode(self.labelNode)
    }
    
    override func layoutForWidth(_ width: CGFloat, item: ListViewItem, previousItem: ListViewItem?, nextItem: ListViewItem?) {
        let layout = self.asyncLayout()
        let (_, apply) = layout(width, self.relativePosition.first, self.relativePosition.last)
        apply()
    }
    
    func asyncLayout() -> (_ width: CGFloat, _ first: Bool, _ last: Bool) -> (ListViewItemNodeLayout, () -> Void) {
        let labelNodeLayout = TextNode.asyncLayout(self.labelNode)
        
        return { width, first, last in
            let (labelLayout, labelApply) = labelNodeLayout(NSAttributedString(string: "Loading", font: titleFont, textColor: UIColor(0xc8c7cc)), nil, 1, .end, CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), nil)
            
            let insets = ChatListItemNode.insets(first: first, last: last, firstWithHeader: false)
            let layout = ListViewItemNodeLayout(contentSize: CGSize(width: width, height: 68.0), insets: insets)
            
            return (layout, { [weak self] in
                if let strongSelf = self {
                    strongSelf.relativePosition = (first, last)
                    
                    let _ = labelApply()
                    
                    strongSelf.labelNode.frame = CGRect(origin: CGPoint(x: floor((width - labelLayout.size.width) / 2.0), y: floor((layout.contentSize.height - labelLayout.size.height) / 2.0)), size: labelLayout.size)
                    
                    strongSelf.separatorNode.frame = CGRect(origin: CGPoint(x: 80.0, y: 68.0 - separatorHeight), size: CGSize(width: width - 78.0, height: separatorHeight))
                    
                    strongSelf.contentSize = layout.contentSize
                    strongSelf.insets = layout.insets
                    strongSelf.updateBackgroundAndSeparatorsLayout()
                }
            })
        }
    }
    
    func updateBackgroundAndSeparatorsLayout() {
        //let size = self.bounds.size
        //let insets = self.insets
    }
}
