//
//  ContentView.swift
//  App
//
//  Created by John Hanna on 3/6/26.
//

import SwiftUI
import WebKit
struct AppViewController: View {
    @State private var showLoading = true
    @AppStorage("theme") private var theme: String = "system"

    var body: some View {
        ZStack{
            if showLoading {
                LoadingScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showLoading = false
                        }
                    }
            } else {
                ContentView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showLoading)
        .preferredColorScheme(theme == "light" ? .light : theme == "dark" ? .dark : nil)
    }
}

struct LoadingScreen: View{
    @AppStorage("appFontSize") var appFontSize: Double = 16
    var body: some View{
        ZStack{
            Image("img")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                Text("Welcome to St. Julitta")
                    .foregroundStyle(Color.white)
                    .font(.system(size: appFontSize + 15))
                    .bold()
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 2, y: 2)
                
                Image("cross")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200)
                Text("COC")
                    .foregroundStyle(Color.white)
                    .font(.system(size: appFontSize + 15))
                    .bold()
                    .shadow(color: .black.opacity(0.7), radius: 3, x: 2, y: 2)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.5)
                    .padding(.top, 20)
                

    
            }
            
        }
       
        
    }
}

struct ContentView: View {
    @AppStorage("appFontSize") var appFontSize: Double = 16
    var body: some View {
        NavigationStack{
            ScrollView {
                ZStack{
                    CrossBorder()
                    
                    VStack(spacing: 30) {
                        Text("St. Julitta Coptic Orthodox Church")
                            .font(.system(size: appFontSize + 10))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.top, 40)
                        
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 30
                        ) {
                            
                            
                            NavigationLink{
                                VStack{
                                    ChurchCalendar()
                                   
                                }
                            }
                            label:{
                                VStack{
                                    Image("cal")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100, height:100)
                                    Text("Church Calendar")
                                        .font(.system(size: appFontSize))
                                        .foregroundColor(.primary)
                                }
                            }
                            NavigationLink{
                                VStack{
                                    Sermons()

                                }
                            }
                            label:{
                                VStack{
                                    Image("sermons")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100, height:100)
                                    Text("Sermons")
                                        .font(.system(size: appFontSize))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            
                            NavigationLink{
                                VStack{
                                    Donation()
                                }
                                
                            }
                            label:{
                                VStack{
                                    Image("img")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100, height:100)
                                    
                                    Text("Donation")
                                        .font(.system(size: appFontSize))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                        
                          
                            NavigationLink{
                                VStack{
                                   Hymns()
                                   
                                }
                            }
                            label:{
                                VStack{
                                    Image("hymns")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100, height:100)
                                    Text("Hymns Corner")
                                        .font(.system(size: appFontSize))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            NavigationLink{AppSettingsView()}
                            label:{
                                VStack{
                                    Image("settings")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:100, height:100)
                                    Text("App Settings")
                                        .font(.system(size: appFontSize))
                                        .foregroundColor(.primary)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 40)
                    }
                    .padding(40)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
        

        
        struct CrossBorder: View {
            var body: some View {
                GeometryReader { geo in
                    ZStack {
                        
                        // Top border
                        HStack(spacing: 8) {
                            ForEach(0..<min(Int(geo.size.width / 24), 30), id: \.self) { _ in
                                Image("cross")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.red)
                                    .frame(width: 16, height: 16)
                                    
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .top)

                        // Bottom border
                        HStack(spacing: 8) {
                            ForEach(0..<min(Int(geo.size.width / 24), 30), id: \.self) { _ in
                                Image("cross")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.red)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)

                        // Left border
                        VStack(spacing: 8) {
                            ForEach(0..<min(Int(geo.size.height / 24), 50), id: \.self) { _ in
                                Image("cross")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.red)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Right border
                        VStack(spacing: 8) {
                            ForEach(0..<min(Int(geo.size.height / 24), 50), id: \.self) { _ in
                                Image("cross")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.red)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .drawingGroup()
                    .ignoresSafeArea()
                }
                .allowsHitTesting(false)
            }
        }

        struct ThemeSettingsView: View {
            @AppStorage("theme") private var theme: String = "system"

            var body: some View {
                Form {
                    Section(header: Text("Appearance")) {

                        Picker("Theme", selection: $theme) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)

                    }
                }
                .navigationTitle("App Settings")
            }
        }
        
        #Preview {
            AppViewController()
        }
    }
