//
//  Message.swift
//  ChatbotClient
//

import SwiftUI


struct MessageView: View {
    let messageText: String
    let role: String

    var body: some View {
        var marginSide: Edge.Set = (role == "user") ? .trailing : .leading
        var margin = (role.isEmpty || role == "system") ? 0 : 25.0
        VStack {
            HStack {
                Text(messageText)
                Spacer()
            }
        }
        .padding(.horizontal, 15.0)
        .padding(.vertical, 10.0)
        .background(.tint, in: RoundedRectangle(cornerRadius: 5.0))
        .padding(marginSide, margin)
        .foregroundStyle(.white)
    }
}

#Preview {
    MessageView(messageText: "Hello, I'm an AI chat bot. I would like to talk to you.", role: "system")
    MessageView(messageText: "Hello, I'm an AI chat bot. I would like to talk to you.", role: "user")
    MessageView(messageText: "Hello, I'm an AI chat bot. I would like to talk to you.", role: "assistant")
}
