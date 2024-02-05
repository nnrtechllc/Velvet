//
//  VelvetApp.swift
//  Velvet
//
//  Created by Nikhil Vaddey on 2/4/24.
//

//GIT HUB PUSH RULES : FIRST PRESS COMIT
// SECOND PRESS PULL AND THEN PRESS LEFT SIDE TO KEEP THE UPDATED CODE
//THIRD MAKE A SMALL CHANGE LIKE ADDING SPACE THEN PRESS COMMIT AGAIN

import SwiftUI
import Firebase

@main
struct Velvet: App {
    init() {
        FirebaseApp.configure()
       
    }

    var body: some Scene {
        WindowGroup {
            EmployeeCheckinView()
        }
    }
}
