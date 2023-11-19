//
//  CardsPlayinApp.swift
//  CardsPlayin
//
//  Created by Mike Kavouras on 7/26/23.
//

import SwiftUI

@main
struct CardsPlayinApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(.black)
        }
    }
}
