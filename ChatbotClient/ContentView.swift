//
//  ContentView.swift
//  ChatbotClient
//

import SwiftUI


enum ServiceError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}


class MessageStruct: Identifiable {
    let messageText: String
    let role: String
    
    init(messageText: String, role: String) {
        self.messageText = messageText
        self.role = role
    }
}

struct ContentView: View {
    @State private var serverAddress: String = ""
    @State private var messages: [MessageStruct] = []
    @State private var messageTextToSend: String = ""
    @State private var submitErrorMsg: String = "Ready"
    @State private var inProgress: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Server")
                TextField("Enter address", text: $serverAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            // TODO: fix the space that appears in the top.
            ScrollView {
                VStack {
                    ForEach(messages) { messageObject in
                        MessageView(messageText: messageObject.messageText,
                                    role: messageObject.role)
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            Spacer()
            TextEditor(text: $messageTextToSend)
                .frame(height: 80.0)
                .scrollContentBackground(.hidden)
                .background(Color.init(red: 0.9, green: 0.9, blue: 0.9))
            Button("Send") {
                self.sendMessage();
            }
            .buttonStyle(.bordered)
            .disabled(serverAddress.isEmpty || messageTextToSend.isEmpty || inProgress)
            if !submitErrorMsg.isEmpty {
                Text(submitErrorMsg).foregroundStyle(.red)
            }
        }
        .padding()
    }
    
    
    func sendMessage() {
        guard let url = URL(string: self.serverAddress) else {
            self.submitErrorMsg = "Invalid url"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        // Append the message that is going to be sent.
        self.messages.append(MessageStruct(messageText: self.messageTextToSend, role: "user"))
        
        var compMsgs: [CompletionsMessage] = []
        for msg in self.messages {
            compMsgs.append(CompletionsMessage(role: msg.role, content: msg.messageText))
        }
        
        let compReqestObject = CompletionsRequest(messages: compMsgs)
        
        var jsonData: Data
        do {
            jsonData = try encoder.encode(compReqestObject)
        } catch {
            self.submitErrorMsg = "Internal error"
            return
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: jsonData) {
            data, response, error in
            self.inProgress = false
            
            guard let response = response as? HTTPURLResponse else {
                self.submitErrorMsg = error != nil ? error!.localizedDescription :
                    "Unexpected response"
                return
            }
            
            if !((200...299).contains(response.statusCode)) {
                self.submitErrorMsg = "Invalid response. Code \(response.statusCode)."
                return
            }
            
            guard let data = data as? Data else {
                self.submitErrorMsg = "Internal error"
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(CompletionsResponse.self, from: data)
                let respMsg = response.choices[0].message
                self.messages.append(MessageStruct(messageText: respMsg.content, role: respMsg.role))
                self.messageTextToSend = ""
                self.submitErrorMsg = "Ready"
            } catch {
                self.submitErrorMsg = "Unexpected response"
            }
        }
        
        self.submitErrorMsg = "In progress..."
        self.inProgress = true
        task.resume()
    }
}


#Preview {
    ContentView()
}
