//
//  MenuDetailView.swift
//  VelvetBobaApp
//
//  Created by Rayan Tahira on 2/10/24.
//

import SwiftUI

struct DetailView: View {
    @Binding var show: Bool
    var animation: Namespace.ID
    var job: Job
    // View Properties
    @State private var animateContent: Bool = false
    @State private var offsetAnimation: Bool = false
    @State var selected = -1
    @State var newselected = -1
    @State var message = false
    @State var TeamCode = ""
    @State private var isLiked: Bool = false
    init(show: Binding<Bool>, animation: Namespace.ID, job: Job) {
        self._show = show
        self.animation = animation
        self.job = job
        // Initialize @State properties here
        _isLiked = State(initialValue: UserDefaults.standard.bool(forKey: "isLiked-\(job.id)"))
        _selected = State(initialValue: UserDefaults.standard.integer(forKey: "selected-\(job.id)"))
    }
    var body: some View {
        VStack(spacing: 15) {
            // close button for detail view
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    offsetAnimation = false
                }
                
                // closing the job detail view
                withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                    animateContent = false
                    show = false
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .padding([.leading, .vertical], 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(animateContent ? 1 : 0)
            
            // job preview with matched geometry effect
            GeometryReader {
                let size = $0.size
                
                HStack(spacing: 20) {
                    Image(job.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (size.width - 30) / 2, height: size.height)
                        // corner shape
                        .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 20))
                        // matched geometry ID
                        .matchedGeometryEffect(id: job.id, in: animation)
                    
                    // Job Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(job.title)
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text(job.description)
                            .font(.callout)
                            .foregroundColor(.gray)
                        
                        RatingsView(selected: $selected, message: $message, job: job)
                        
                    }.alert(isPresented: $message) {
                        Alert(title: Text("Star Rating Submission"), message: Text("Thanks for rating \(job.title)"), dismissButton: .none)
                    }
                    .padding(.trailing, 15)
                    .padding(.top, 30)
                    .offset(y: offsetAnimation ? 0 : 100)
                    .opacity(offsetAnimation ? 1 : 0)
                }
            }
            .frame(height: 220)
            // placing the rectangle above
            .zIndex(1)
            
            Rectangle()
                .fill(.gray.opacity(0.04))
                .ignoresSafeArea()
                .overlay(alignment: .top, content: {
                    JobDetails()
                })
                .padding(.leading, 30)
                .padding(.top, -180)
                .zIndex(0)
                .opacity(animateContent ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle()
                .fill(.white)
                .ignoresSafeArea()
                .opacity(animateContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                animateContent = true
            }
            
            withAnimation(.easeInOut(duration: 0.35).delay(0.1)) {
                offsetAnimation = true
            }
        }
    }
    
    @ViewBuilder
    func JobDetails() -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    
                } label: {
                    Label("Review", systemImage: "doc.plaintext")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {ShareID(Info: TeamCode)}){
                    Image(systemName: "square.and.arrow.up")
                        .font(.callout)
                        .foregroundColor(.gray)
                    Text("Share")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                Button {
                    self.isLiked.toggle()
                    UserDefaults.standard.set(self.isLiked, forKey: "isLiked-\(job.id)")
                } label: {
                    ZStack {
                        image(Image(systemName: "heart.fill"), show: isLiked)
                        image(Image(systemName: "heart"), show: !isLiked)
                    }
                    Text("Like")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
            }
            
            Divider()
                .padding(.top, 25)
            
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 15) {
                    Text("Job Details")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 110)
                        .foregroundColor(.black)
                    
                    // Job Details
                    Text(job.jobdescription)
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    // apply now button
                    Button(action: {
                         UIApplication.shared.open(URL(string: job.joblink)!)
                     }) {
                         Text("Order Now!")
                             .bold()
                             .font(.title3)
                             .frame(width: 250, height: 50)
                             .foregroundColor(.white)
                             .background(Color("Lavender"))
                             .cornerRadius(20)
                     }
                    .padding(.bottom, 15)
                    .padding(.top, 20)

                }
            }
        }
        .padding(.top, 180)
        .padding([.horizontal, .top], 15)
        // offset animation
        .offset(y: offsetAnimation ? 0 : 100)
        .opacity(offsetAnimation ? 1 : 0)
    }
    
    func ShareID(Info: String) {
        let customLink = "https://apple.com"
        let activityViewController = UIActivityViewController(activityItems: [customLink], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2.1, y: UIScreen.main.bounds.height / 1.3, width: 200, height: 200)
        }
    }
    
    func image(_ image: Image, show: Bool) -> some View {
        image
            .tint(isLiked ? .red : .gray)
            .font(.callout)
            .scaleEffect(show ? 1 : 0)
            .opacity(show ? 1 : 0)
            .animation(.interpolatingSpring(stiffness: 200, damping: 15), value: show)
    }
}



struct RatingsView: View {
    @Binding var selected: Int
    @Binding var message: Bool
    var job: Job
    
    init(selected: Binding<Int>, message: Binding<Bool>, job: Job) {
        self._selected = selected
        self._message = message
        self.job = job
        // Initialize selected to the stored value or default to 0
        _selected = Binding(
            get: { UserDefaults.standard.integer(forKey: "selected-\(job.id)") },
            set: { newValue in
                UserDefaults.standard.set(newValue, forKey: "selected-\(job.id)")
            }
        )
    }
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(0..<5) { i in
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(self.selected > i ? .yellow : .gray)
                    .onTapGesture {
                        self.selected = i + 1
                        self.message.toggle()
                    }
            }
        }
    }
}
struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
                                
        return Path(path.cgPath)
    }
}
