/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Reads the fake messages database plist resource and instantiates a model for the
        rest of the app to use.
*/

import UIKit

struct ChatItem {
    var sender: String
    var text: String
}

class Conversation {
    let participants: Set<String>
    var chatItems: [ChatItem]

    private let identifier = UUID()

    var otherParticipant: String? {
        return participants.first(where: { $0 != "me" })
    }

    init(fromSerializedArray serializedArray: [[String: String]]) {
        var chatItems = [ChatItem]()
        var uniqueSenders = Set<String>()
        for dict in serializedArray {
            let chatItem = ChatItem(sender: dict["sender"] ?? "", text: dict["text"] ?? "")
            uniqueSenders.insert(chatItem.sender)
            chatItems.append(chatItem)
        }

        participants = uniqueSenders
        self.chatItems = chatItems
    }

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return (lhs.identifier == rhs.identifier)
    }
}

class ChatDataSource: NSObject {
    private var conversations: [Conversation]?

    private func getConversations() -> [Conversation] {
        if conversations == nil {
            // Load from file
            guard let chatsURL = Bundle.main.url(forResource: "Chats", withExtension: "plist"),
                  let rawConversations = NSArray(contentsOf: chatsURL) as? [ [ [String: String] ] ]
            else {
                return []
            }

            let conversationsFromDisk: [Conversation] = rawConversations.map(Conversation.init(fromSerializedArray:))
            conversations = conversationsFromDisk
        }

        return conversations!
    }

    var numberOfConversations: Int {
        return getConversations().count
    }

    subscript(index: Int) -> Conversation {
        return getConversations()[index]
    }

    func index(of conversationItem: Conversation) -> Int? {
        return getConversations().index(where: { $0 == conversationItem })
    }
}
