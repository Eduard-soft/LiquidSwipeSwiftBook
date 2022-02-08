//
//  HomeView.swift
//  LiquidSwipeSwiftBook
//
//  Created by Эдуард on 07.02.2022.
//

import SwiftUI

struct HomeView: View {
    
   // @State var offset: CGSize = .zero
    @State var intros: [Intro] = [
    
        Intro(title: "Plan", subTitle: "your routes", description: "Первая страница", pic: "Sm1", color: Color("Green")),
        Intro(title: "Quick Waste", subTitle: "Transfer Note", description: "Вторая страница", pic: "Sm2", color: Color("DarkGrey")),
        Intro(title: "Invite", subTitle: "restaurants", description: "Третья страница", pic: "Sm3", color: Color("Yellow"))
    ]
    
    // Gesture Properties...
    @GestureState var isDragging: Bool = false
    
    @State var fakeIndex: Int = 0
    @State var currentIndex: Int = 0
    
    var body: some View {
        
        ZStack {
            // Why we using indicies...
            //Since the app supports iOS 14
            //as well as were updating offset on real time...
            
            ForEach(intros.indices.reversed(), id: \.self) {index in
                
                //Intro View...
                IntroView(intro: intros[index])
                // Custom Liquid Shape...
                    .clipShape(LiquidShape(offset: intros[index].offset, curvePoint: fakeIndex == index ? 50 : 0))
                    .padding(.trailing, fakeIndex == index ? 15 : 0)
                    .ignoresSafeArea()
            }
            
            HStack(spacing: 8) {
                
                ForEach(0..<intros.count - 2, id: \.self) { index in
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentIndex == index ? 1.15 : 0.85)
                        .opacity(currentIndex == index ? 1 : 0.25)
                    
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Skin")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        // arrow with Drag Gesture...
        .overlay(
        
            Button(action: {
                
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.largeTitle)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                    .gesture(
                    
                        //Drag Gesture...
                        DragGesture()
                            .updating($isDragging, body: { value, out, _ in
                                out = true
                            })
                            .onChanged({ value in
                                
                                // updating offset...
                                withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.6)) {
                                    intros[fakeIndex].offset = value.translation
                                }
                            })
                            .onEnded({ value in
                                
                                withAnimation(.spring()) {
                                    // checking...
                                   if -intros[fakeIndex].offset.width > getRect().width / 2 {
                                       intros[fakeIndex].offset.width = -getRect().height * 1.5
                                       fakeIndex += 1
                                       
                                       if currentIndex == intros.count - 3 {
                                           currentIndex = 0
                                       } else {
                                           currentIndex += 1
                                       }
                                       
                                       DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                       
                                       if fakeIndex == (intros.count - 2) {
                                           for index in 0..<intros.count - 2 {
                                               intros[index].offset = .zero
                                           }
                                           fakeIndex = 0
                                       }
                                       }
                                    }
                                    else {
                                        intros[fakeIndex].offset = .zero
                                    }
                                }
                            })
                    )
            })
            .offset(y: 53)
                .opacity(isDragging ? 0 : 1)
                .animation(.linear, value: isDragging)
            , alignment: .topTrailing
        )
        .onAppear {
            guard let first = intros.first else {
                return
            }
            
            guard var last = intros.last else {
                return
            }
            
            last.offset.width = -getRect().height * 1.5
            intros.append(first)
            intros.insert(last, at: 0)
            fakeIndex = 1
        }
    }
    
    @ViewBuilder
    func IntroView(intro: Intro) -> some View {
        
        VStack {
            
            Image(intro.pic)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(40)
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(intro.title)
                    .font(.system(size: 45))
                Text(intro.subTitle)
                    .font(.system(size: 50, weight: .bold))
                Text(intro.description)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .padding(.top)
                    .frame(width: getRect().width - 100)
                    .lineSpacing(8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            .padding([.trailing, .top])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
        
            intro.color
        )
    }
}

//Extending View to get Screen Bounds...
extension View {

    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct LiquidShape: Shape {
    
    var offset: CGSize
    var curvePoint: CGFloat
    
    var animatableData: AnimatablePair<CGSize.AnimatableData, CGFloat> {
        get {
            return AnimatablePair(offset.animatableData, curvePoint)
        }
        set {
            offset.animatableData = newValue.first
            curvePoint = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        
        return Path {path in
            
            let width = rect.width + (-offset.width > 0 ? offset.width : 0)
            
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            
            
            let from = 80 + (offset.width)
            path.move(to: CGPoint(x: rect.width, y: from > 80 ? 80 : from))
            
            var to = 180 + (offset.height) + (-offset.width)
            to = to < 180 ? 180 : to
            
            let mid: CGFloat = 80 + ((to - 80) / 2)
            
            path.addCurve(to: CGPoint(x: rect.width, y: to),
                                   control1: CGPoint(x: width - curvePoint, y: mid),
                                   control2: CGPoint(x: width - curvePoint, y: mid))
        }
    }
}
