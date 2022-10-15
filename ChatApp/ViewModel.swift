//  ViewModel.swift
//  ImageSocket
//
//  Created by Igor Samoel da Silva on 14/10/22.
//

import Foundation

struct Message: Identifiable, Hashable {
    var id = UUID()
    var image: Data?
    var text: String?
}

class ViewModel: ObservableObject {
    
    private var webSocket: URLSessionWebSocketTask!
    @Published var messages: [Message] = []
    
    init() {
        guard let url = URL(string: "wss://zureta-mandrak.herokuapp.com/chat") else { return }
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket.resume()
        sendPing()
        onReceive()
    }
    
    private func onReceive() {
        
        let workItem = DispatchWorkItem{ [weak self] in
            
            self?.webSocket?.receive(completionHandler: { result in
                
                switch result {
                case .success(let message):
                    
                    switch message {
                        
                    case .data(let data):
                        let message = Message(image: data)
                        DispatchQueue.main.async {
                            self?.messages.append(message)
                        }
                        
                    case .string(let msg):
                        DispatchQueue.main.async {
                            self?.messages.append(Message(text: msg))
                        }
                        
                    default:
                        break
                    }
                    self?.onReceive()
                case .failure(let error):
                    print("Error Receiving \(error)")
                }
            })
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1 , execute: workItem)
    }
    
    func sendMessage(text: String) {
        let workItem = DispatchWorkItem {
            
            self.webSocket?.send(URLSessionWebSocketTask.Message.string(text), completionHandler: { error in
                
            })
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.5, execute: workItem)
    }
    
    func sendImage(image: Data) {
        let workItem = DispatchWorkItem {
            
            self.webSocket?.send(URLSessionWebSocketTask.Message.data(image), completionHandler: { error in
                print("[ERROR SEND DATA]: \(error)")
            })
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.5, execute: workItem)
    }
    
    func sendPing() {
      webSocket.sendPing { (error) in
        if let error = error {
          print("Falha ao enviar PING: \(error)")
        }
     
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
          self.sendPing()
        }
      }
    }
}
