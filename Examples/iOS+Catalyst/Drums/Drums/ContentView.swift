//
//  ContentView.swift
//  Drums
//
//  Created by Matthias Frick on 11/09/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import SwiftUI

struct PadsView: View {
  @EnvironmentObject var conductor: Conductor

  var padsAction: (_ padNumber: Int) -> Void

  var body: some View {
    VStack(spacing: 10) {
      ForEach((0..<2), id: \.self) { row in
        HStack(spacing: 10) {
          ForEach((0..<4), id: \.self) { column in
            Button(action: {
              self.padsAction(getPadId(row: row, column: column))
            }) {
              ZStack {
                Rectangle()
                  .fill(Color(self.conductor.drumSamples.map({$0.color})[getPadId(row: row, column: column)]))
                Text(self.conductor.drumSamples.map({$0.name})[getPadId(row: row, column: column)])
                  .foregroundColor(Color("FontColor")).fontWeight(.bold)

              }
            }
          }
        }
      }
    }.onAppear {
      // Important to start AudioKit after the app has moved to the foreground on Catalyst
      self.conductor.start()
    }
  }
}

struct ContentView: View {
  @EnvironmentObject var conductor: Conductor

  var body: some View {
    VStack(spacing: 2) {
      PadsView { (pad) in
        self.conductor.playPad(padNumber: pad)
      }
      Spacer().fixedSize().frame(minWidth: 0, maxWidth: .infinity,
                                 minHeight: 0, maxHeight: 5, alignment: .topLeading)
    }
  }
}

private func getPadId(row: Int, column: Int) -> Int {
  return (row * 4) + column
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
