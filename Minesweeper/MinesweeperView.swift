
//
//  MinesweeperView.swift
//  Minesweeper
//
//  Created by Blake McAnally on 12/22/20.
//

import SwiftUI

struct MinesweeperView: View {
    
    @ObservedObject
    var minesweeper: Minesweeper
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                if minesweeper.gameState == .lost {
                    Text("You Lose!")
                } else if minesweeper.gameState == .won {
                    Text("You Win! Congrats!")
                } else {
                    Text("Happy Hunting!")
                }
                Text("\(minesweeper.time)")
                Button("Reset") {
                    minesweeper.reset()
                }
            }
            HStack(spacing: 0) {
                ForEach(0..<minesweeper.board.count) { row in
                    VStack(spacing: 0) {
                        ForEach(0..<minesweeper.board[row].count) { column in
                            makeSquare(
                                row: row,
                                column: column
                            )
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func makeSquare(row: Int, column: Int) -> some View {
        Group {
            let square = minesweeper.board[row][column]
            if square.isRevealed {
                ZStack {
                    Rectangle()
                        .foregroundColor(.gray)
                    if square.contents == .mine {
                        Circle()
                            .foregroundColor(.red)
                            .padding(1)
                    } else {
                        if square.neighboringMines != 0 {
                            Text("\(square.neighboringMines)")
                                .foregroundColor(textColor(for: square.neighboringMines))
                                .minimumScaleFactor(0.001)
                        }
                    }
                }
            } else if square.isFlagged {
                Rectangle()
                    .foregroundColor(.orange)
                    .onLongPressGesture {
                        minesweeper.flag(x: row, y: column)
                    }
            } else {
                Rectangle()
                    .foregroundColor(.green)
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        minesweeper.reveal(x: row, y: column)
                    })
                    .onLongPressGesture {
                        minesweeper.flag(x: row, y: column)
                    }
            }
        }.border(Color(UIColor.systemBackground).opacity(0.75), width: 1)
    }
    
    private func textColor(for count: Int) -> Color {
        switch count {
        case 1: return Color(red: 0 / 255, green: 24 / 255, blue: 244 / 255)
        case 2: return Color(red: 55 / 255, green: 125 / 255, blue: 34 / 255)
        case 3: return Color(red: 186 / 255, green: 40 / 255, blue: 28 / 255)
        case 4: return Color(red: 0 / 255, green: 4 / 255, blue: 71 / 255)
        case 5: return Color(red: 118 / 255, green: 21 / 255, blue: 14 / 255)
        case 6: return Color(red: 54 / 255, green: 126 / 255, blue: 128 / 255)
        case 7: return .black
        case 8: return .gray
        default: return .clear
        }
    }
    
    private func size(
        for boardSize: CGSize,
        boardWidth: Int,
        boardHeight: Int
    ) -> CGSize {
        let boardScale = CGFloat(min(boardWidth, boardHeight))
        let squareSize: CGFloat = min(boardSize.width, boardSize.height) / boardScale
        //TODO: enable when scrolling fields work.
//        let constrained = CGFloat(max(CGFloat(30.0), squareSize))
//        print(boardScale)
//        print(squareSize)
//        print(constrained)
        return CGSize(
            width: squareSize,
            height: squareSize
        )
    }
}
