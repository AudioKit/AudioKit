//
//  ContentView.swift
//  DrumsSwiftUI
//
//  Created by Matthias Frick on 11/09/2019.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import SwiftUI

struct PadsView: View {
    @EnvironmentObject var conductor: Conductor

    var body: some View {
        VStack(spacing: 2) {
            ForEach((0...2).reversed(), id: \.self) { row in
                HStack(spacing: 2) {
                  ForEach((0..<3), id: \.self) { column in
                      Button(action: {
                          self.conductor.playPad(padNumber: getPadId(row: row, column: column))
                      }) {
                          ZStack {
                              Rectangle()
                                .fill(Color.black)
                                .aspectRatio(contentMode: .fit)
                              Text(String(getPadId(row: row, column: column))).foregroundColor(.white)
                          }
                      }
                  }
                }
            }
        }
    }
}

struct TopView: View {
    @EnvironmentObject var conductor: Conductor

    var body: some View {
        VStack {
            Spacer()
            Text("AudioKit Drum Pads").font(.system(size: 20)).fontWeight(.bold)
            Spacer()
            Text("Last played Sample").fontWeight(.bold)
            Text(conductor.lastPlayed)
            Spacer().fixedSize(horizontal: false, vertical: true)
              .frame(width: 0, height: 40, alignment: .bottom)
        }
    }
}

struct ContentView: View {

    var body: some View {
        VStack(spacing: 2) {
          TopView()
          PadsView()
          Spacer().fixedSize().frame(minWidth: 0, maxWidth: .infinity,
                                     minHeight: 0, maxHeight: 5, alignment: .topLeading)
        }
    }
}

private func getPadId(row: Int, column: Int) -> Int {
    return (row * 3) + column
}

// Disable Previews because of HoundCI on AudioKit Repo
// Underscore violation

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
