//
//  ContentView.swift
//  Minesweeper
//
//  Created by Blake McAnally on 12/22/20.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State var widthText: String = "8"
    @State var heightText: String = "12"
    @State var minesText: String = "10"
    
    private var width: Int {
        Int(widthText) ?? 8
    }
    
    private var height: Int {
        Int(heightText) ?? 12
    }
    
    private var mines: Int {
        Int(minesText) ?? 10
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    /// TODO: extract to extension/viewmodifier to get rid of duplication
                    TextField("Width", text: $widthText)
                        .onReceive(Just(widthText)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.widthText = filtered
                            }
                        }
                    TextField("Height", text: $heightText)
                        .onReceive(Just(heightText)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.heightText = filtered
                            }
                        }
                    TextField("Mines", text: $minesText)
                        .onReceive(Just(minesText)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.minesText = filtered
                            }
                        }
                }
                
                NavigationLink(
                    "Start Game",
                    destination: MinesweeperView(
                        minesweeper: Minesweeper(
                            width: width,
                            height: height,
                            mines: mines
                        )
                    )
                )
            }
            .navigationTitle("Minesweeper")
        }
    }
}
