//
//  ContentView.swift
//  ChatApp
//
//  Created by Igor Samoel da Silva on 14/10/22.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State var mensagem = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    var body: some View {
        VStack {
            Spacer()
            ScrollView {
                ForEach(viewModel.messages, id: \.id) { message in
                    if let msg = message.text {
                        Text(msg)
                    }
                    if let image = message.image {
                        Image(uiImage: UIImage(data: image)!)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                }
            }
            Spacer()
            HStack {
                TextEditor(text: $mensagem)
                    .frame(height: 45)
                    .border(.black)
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            // Retrieve selected asset in the form of Data
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                viewModel.sendImage(image: data)
                            }
                        }
                    }
                Button {
                    viewModel.sendMessage(text: mensagem)
                    mensagem = ""
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
