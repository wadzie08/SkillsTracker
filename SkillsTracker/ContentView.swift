//
//  ContentView.swift
//  SkillsTracker
//
//  Created by wadzie on 4/9/2026.
//

import SwiftUI

struct welcome: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Welcome page")
                    .resizable()
                    .ignoresSafeArea(edges: .all)
                    .frame(width: 440, height: 1000)
                    .opacity(150)
                Text("Welcome To MCRI")
                    .offset(x:7 ,y: -50)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                    .opacity(0.9)
                    .padding()
                
                
                VStack{
                    
                    Spacer()
                    
                    HStack{
                                Text("Get Started")
                                    .font(.system(size: 20))
                                    .fontWeight(.heavy)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.white)
                                    .padding(10)
                                    
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.white)
                                    .padding(10)
                                    .opacity(0.9)
                                
                                
                            }
                        
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 1.5))
                                    .foregroundStyle(Color.white)
                                    
                                
                            )
                            
                        }
                    .offset(x: 0, y: -20)
                        .padding(.bottom, 100)
                        
                    }.padding(24)
                    
                }
            }
        }
    

#Preview {
    welcome()
}

