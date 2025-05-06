//
//  completions.swift
//  ChatbotClient
//


struct CompletionsChoice: Codable {
    let index: Int
    let message: CompletionsMessage
}


struct CompletionsMessage: Codable {
    let role: String
    let content: String
}


struct CompletionsRequest: Codable
{
    let messages: [CompletionsMessage]
}


struct CompletionsResponse: Codable {
    let choices: [CompletionsChoice]
    let id: String
}
