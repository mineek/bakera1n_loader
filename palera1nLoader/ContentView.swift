//
//  ContentView.swift
//  bakera1nLoader
//
//  Created by Lakhan Lothiyi on 11/11/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {   
    @State private var bootstrapping = false
    var body: some View {
        VStack {
            Text("bakera1n Loader")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            Text("by bakera1n developeｒ")
                .font(.caption)
                .padding(.bottom, 20)

            List {
                Section(header: Text("Install")) {
                    Button(action: {
                        let alert = UIAlertController(title: "Install Sileo", message: "Are you sure you want to install Sileo?", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "Install", style: .destructive, handler: { _ in
                            bootstrapping = true
                            strap()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                bootstrapping = false
                                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    exit(0)
                                }
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                    }) {
                        HStack {
                            // web image view
                            WebImage(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/f/fb/Icon_Sileo.png"))
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(10)
                            Text("Sileo")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        // if we're bootstrapping, show a spinner
        .overlay(
            Group {
                if bootstrapping {
                    ProgressView()
                }
            }
        )
    }
    
    private func strap() -> Void {
        
        guard let tar = Bundle.main.path(forResource: "bootstrap", ofType: "tar") else {
            let msg = "Failed to find bootstrap"
            print("[palera1n] \(msg)")
            return
        }
         
        guard let helper = Bundle.main.path(forAuxiliaryExecutable: "palera1nHelper") else {
            let msg = "Could not find Helper"
            print("[palera1n] \(msg)")
            return
        }
         
        guard let deb = Bundle.main.path(forResource: "sileo", ofType: "deb") else {
            let msg = "Could not find Sileo"
            print("[palera1n] \(msg)")
            return
        }
        
        guard let libswift = Bundle.main.path(forResource: "libswift", ofType: "deb") else {
            let msg = "Could not find libswift deb"
            print("[palera1n] \(msg)")
            return
        }
        
        guard let safemode = Bundle.main.path(forResource: "safemode", ofType: "deb") else {
            let msg = "Could not find SafeMode"
            print("[palera1n] \(msg)")
            return
        }
        
        guard let preferenceloader = Bundle.main.path(forResource: "preferenceloader", ofType: "deb") else {
            let msg = "Could not find PreferenceLoader"
            print("[palera1n] \(msg)")
            return
        }
        
        guard let substitute = Bundle.main.path(forResource: "substitute", ofType: "deb") else {
            let msg = "Could not find Substitute"
            print("[palera1n] \(msg)")
            return
        }
        
        guard let strapRepo = Bundle.main.path(forResource: "straprepo", ofType: "deb") else {
            let msg = "Could not find strap repo deb"
            print("[palera1n] \(msg)")
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [self] in
            spawn(command: "/sbin/mount", args: ["-uw", "/private/preboot"], root: true)
            spawn(command: "/sbin/mount", args: ["-uw", "/"], root: true)
            
            let ret = spawn(command: helper, args: ["-i", tar], root: true)
            
            spawn(command: "/usr/bin/chmod", args: ["4755", "/usr/bin/sudo"], root: true)
            spawn(command: "/usr/bin/chown", args: ["root:wheel", "/usr/bin/sudo"], root: true)
            
            DispatchQueue.main.async {
                if ret != 0 {
                    return
                }
                DispatchQueue.global(qos: .utility).async {
                    let ret = spawn(command: "/usr/bin/sh", args: ["/prep_bootstrap.sh"], root: true)
                    DispatchQueue.main.async {
                        if ret != 0 {
                            return
                        }
                        DispatchQueue.global(qos: .utility).async {
                            let ret = spawn(command: "/usr/bin/dpkg", args: ["-i", deb, libswift, safemode, preferenceloader, substitute], root: true)
                            DispatchQueue.main.async {
                                if ret != 0 {
                                    return
                                }
                                DispatchQueue.global(qos: .utility).async {
                                    let ret = spawn(command: "/usr/bin/uicache", args: ["-a"], root: true)
                                    DispatchQueue.main.async {
                                        if ret != 0 {
                                            return
                                        }
                                        DispatchQueue.global(qos: .utility).async {
                                            let ret = spawn(command: "/usr/bin/dpkg", args: ["-i", strapRepo], root: true)
                                            DispatchQueue.main.async {
                                                if ret != 0 {
                                                    return
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
