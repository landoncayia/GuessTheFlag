//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Landon Cayia on 6/13/22.
//

import SwiftUI

struct FlagImage: View {
    var country: String
    
    var body: some View {
        Image(country)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct ContentView: View {
    @State private var showingScore = false
    @State private var showingGameOver = false
    @State private var scoreTitle = ""
    @State private var score = 0
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var lastFlagTapped = 0
    @State private var questionsAsked = 1
    
    @State private var rotationDegrees = 0.0
    @State private var rotationAnimationAmountsY = [0.0, 0.0, 0.0]
    @State private var rotationAnimationAmountsX = [0.0, 0.0, 0.0]
    @State private var opacityValues = [1.0, 1.0, 1.0]
    @State private var scaleValues = [1.0, 1.0, 1.0]
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                            
                            withAnimation {
                                rotationDegrees += 360
                            }
                        } label: {
                            FlagImage(country: countries[number])
                                .opacity(opacityValues[number])
                        }
                        .rotation3DEffect(.degrees(rotationAnimationAmountsY[number]), axis: (x: 0, y: 1, z: 0))
                        .rotation3DEffect(.degrees(rotationAnimationAmountsX[number]), axis: (x: 1, y: 0, z: 0))
                        .scaleEffect(scaleValues[number])
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundColor(.white)
                    .font(.title.bold())
                
                Text("Question \(questionsAsked) / 8")
                    .foregroundColor(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            if scoreTitle == "Wrong" {
                Text("Wrong! That's the flag of \(countries[lastFlagTapped])")
            }
            Text("Your score is \(score)")
        }
        .alert("Game Over", isPresented: $showingGameOver) {
            Button("New Game", action: reset)
        } message: {
            Text("Your final score is \(score)")
        }
    }
    
    func flagTapped(_ number: Int) {
        let flagRotationDuration = 0.5
        
        lastFlagTapped = number
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
        } else {
            scoreTitle = "Wrong"
        }
        
        withAnimation(Animation.easeInOut(duration: flagRotationDuration)) {
            rotationAnimationAmountsY[number] += 360
        }
        
        var flagsNotTapped = [0, 1, 2]
        flagsNotTapped.remove(at: number)
        
        withAnimation {
            opacityValues[flagsNotTapped[0]] = 0.25
            opacityValues[flagsNotTapped[1]] = 0.25
            scaleValues[flagsNotTapped[0]] = 0.5
            scaleValues[flagsNotTapped[1]] = 0.5
        }
        
        showingScore = true
    }
    
    func askQuestion() {
        if questionsAsked == 8 {
            showingGameOver = true
        } else {
            questionsAsked += 1
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
        }
        
        withAnimation {
            opacityValues = [1.0, 1.0, 1.0]
            scaleValues = [1.0, 1.0, 1.0]
        }
        
        withAnimation {
            rotationAnimationAmountsX = rotationAnimationAmountsX.map { $0 + 360 }
        }
    }
    
    func reset() {
        score = 0
        questionsAsked = 0
        askQuestion()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
