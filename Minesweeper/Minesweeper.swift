//
//  Minesweeper.swift
//  Minesweeper
//
//  Created by Blake McAnally on 12/22/20.
//

import Foundation
import Combine
import SwiftUI

enum GameState {
    case playing
    case lost
    case won
}

struct Square {
    enum Contents {
        case empty
        case mine
    }
    var contents: Contents
    var neighboringMines: Int = 0
    var isRevealed: Bool = false
    var isFlagged: Bool = false
}

class Minesweeper: ObservableObject {
    //TODO: Make these more difficult
    private var mines = 10
    private var width: Int = 8
    private var height: Int = 12
    
    @Published
    var gameState: GameState = .playing
    
    @Published
    var board: [[Square]] = []
    
    @Published
    var time: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        setup()
    }
    
    private func setup() {
        board = [[Square]](
            repeating: [Square](
                repeating: Square(contents: .empty),
                count: height),
            count: width
        )
        
        // place mines randomly
        for _ in 0..<mines {
            let x = Int.random(in: 0..<width)
            let y = Int.random(in: 0..<height)
            board[x][y] = Square(contents: .mine)
        }
        
        // compute neighboring mines
        for row in 0..<width {
            for column in 0..<height {
                var count = 0
                for xOffset in -1...1 {
                    for yOffset in -1...1 {
                        let xIndex = row + xOffset
                        let yIndex = column + yOffset
                        guard (0..<width).contains(xIndex),
                            (0..<height).contains(yIndex) else {
                            continue
                        }
                        if board[xIndex][yIndex].contents == .mine {
                            count += 1
                        }
                    }
                }
                board[row][column].neighboringMines = count
            }
        }
        
        gameState = .playing
        
        cancellables.forEach {
            $0.cancel()
        }

        time = 0
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] time in
                self?.time += 1
            }.store(in: &cancellables)
    }
    
    
    func reveal(x: Int, y: Int) {
        // Validate Indices
        guard (0..<width).contains(x),
              (0..<height).contains(y),
              gameState == .playing,
              !board[x][y].isRevealed else {
            return
        }
        
        board[x][y].isRevealed = true
        
        if board[x][y].contents == .mine {
            gameState = .lost
            cancellables.forEach { $0.cancel() }
            return
        } else {
            if board[x][y].neighboringMines == 0 {
                for xOffset in -1...1 {
                    for yOffset in -1...1 {
                        reveal(x: x + xOffset, y: y + yOffset)
                    }
                }
            }
        }
        
        checkForWin()
    }
    
    func flag(x: Int, y: Int) {
        board[x][y].isFlagged.toggle()
        checkForWin()
    }
    
    private func checkForWin() {
        if board.allSatisfy({ $0.allSatisfy { $0.isRevealed || ($0.isFlagged && $0.contents == .mine) } }) {
            gameState = .won
        }
    }
    
    func reset() {
        setup()
    }
}


extension Minesweeper: CustomStringConvertible {
    var description: String {
        var str = ""
        for row in board {
            for column in row {
                str += (column.contents == .mine ? "*" : "_")
            }
            str += "\n"
        }
        return str
    }
}
