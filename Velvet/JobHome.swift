//
//  JobHome.swift
//  Velvet
//
//  Created by Rayan Tahira on 2/10/24.
//

import SwiftUI

struct HomeJob: View {
    // View properties
    @State private var activeTag: String = "Fast Food"
    @State private var carouselMode: Bool = false
    // matched geometry effect
    @Namespace private var animation
    // Detail View for Job properties
    @State private var showDetailView: Bool = false
    @State private var selectedJob: Job?
    @State private var animateCurrentJob: Bool = false
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Velvet")
                    .font(.largeTitle.bold())
                    .foregroundColor(.orange)
                    .font(.custom("AmericanTypewriter", fixedSize: 36))
                    .offset(x:100)
                
                Text("Boba!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 15)
                    .foregroundColor(.blue)
                    .font(.custom("AmericanTypewriter", fixedSize: 36))
                    .offset(x: 85)
                
                Spacer(minLength: 10)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
            
            GeometryReader {
                let size = $0.size
                
                ScrollView(.vertical, showsIndicators: false) {
                    // job card view
                    VStack(spacing: 35) {
                        ForEach(sampleJobs) { Job in
                            JobCardView(Job)
                                // opening the detail view of the jobs when pressed by user
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        animateCurrentJob = true
                                        selectedJob = Job
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                            showDetailView = true
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                    .padding(.bottom, bottomPadding(size))
                    .background {
                        ScrollViewDetector(carouselMode: $carouselMode, totalCardCount: sampleJobs.count)
                    }
                }
                // offset here not from global view
                .coordinateSpace(name: "SCROLLVIEW")
            }
            .padding(.top, 15)
        }
        .overlay {
            if let selectedJob, showDetailView {
                DetailView(show: $showDetailView, animation: animation, job: selectedJob)
                // animation transition
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
            }
        }
        .onChange(of: showDetailView) { newValue in
            if !newValue {
                // resetting job animation
                withAnimation(.easeInOut(duration: 0.15).delay(0.4)) {
                    animateCurrentJob = false
                }
            }
        }
    }
    
    // padding for the bottom card
    func bottomPadding(_ size: CGSize = .zero) -> CGFloat {
        let cardHeight: CGFloat = 220
        let scrollViewHeight: CGFloat = size.height
        
        return scrollViewHeight - cardHeight - 40
    }
    
    // job card view
    @ViewBuilder
    func JobCardView(_ job: Job) -> some View {
        GeometryReader {
            let size = $0.size
            let rect = $0.frame(in: .named("SCROLLVIEW"))
            
            HStack(spacing: -25) {
                // Job Detail Card
                // job card overlapping the image
                VStack(alignment: .leading, spacing: 6) {
                    Text(job.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(job.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // job rating view
                    RatingView(rating: job.rating)
                        .padding(.top, 10)
                    
                    Spacer(minLength: 10)
                    
                    HStack(spacing: 4) {
                        Text("\(job.jobViews)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        Text("Student Applications")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(20)
                .frame(width: size.width / 2, height: size.height * 0.8)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        // shadow for jobcard
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 5, y: 5)
                        .shadow(color: .black.opacity(0.08), radius: 8, x: -5, y: -5)
                }
                .zIndex(1)
                // moving job once its tapped
                .offset(x: animateCurrentJob && selectedJob?.id == job.id ? -20 : 0)
                
                // Job Image
                ZStack {
                    if !(showDetailView && selectedJob?.id == job.id) {
                        Image(job.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width / 2, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            // matched geometry Id
                            .matchedGeometryEffect(id: job.id, in: animation)
                            // shadow for jobcard
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: -5, y: -5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: size.width)
            .rotation3DEffect(.init(degrees: convertOffsetToRotation(rect)), axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 1, perspective: 1.2)
        }
        .frame(height: 220)
    }
    
    // we need minY to become the rotation
    func convertOffsetToRotation(_ rect: CGRect) -> CGFloat {
        let cardHeight = rect.height + 20
        let minY = rect.minY - 20
        let progress = minY < 0 ? (minY / cardHeight) : 0
        let constrainedProgress = min(-progress, 1.0)
        return constrainedProgress * 90
    }
    
    // option tab view
    @ViewBuilder
    func TagsView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background {
                            if activeTag == tag {
                                Capsule()
                                    .fill(Color("Orange"))
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            } else {
                                Capsule()
                                    .fill(.gray.opacity(0.1))
                            }
                        }
                        .foregroundColor(activeTag == tag ? .white : .gray)
                        // changing active tag when user taps
                        .onTapGesture {
                            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)) {
                                activeTag = tag
                            }
                        }
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

// tags
var tags : [String] = [
    "Commercial", "Tutoring", "Fast Food", "Education", "Assistants", "Internship"
]

struct HomeJob_Previews: PreviewProvider {
    static var previews: some View {
        HomeJob()
    }
}

// rating view for jobs
struct RatingView: View {
    var rating: Int
    var body: some View{
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.5))
            }
            
            Text("(\(rating))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.yellow)
                .padding(.leading, 5)
        }
    }
}

// ScrollView Detector
// this extracts the UIScrollView from SwiftUI ScrollView so I can add the rotation effect
struct ScrollViewDetector: UIViewRepresentable {
    @Binding var carouselMode: Bool
    var totalCardCount: Int
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview?.superview as? UIScrollView {
                scrollView.decelerationRate = carouselMode ? .fast : .normal
                if carouselMode {
                    scrollView.delegate = context.coordinator
                } else {
                    scrollView.delegate = nil
                }
                // updating total count
                context.coordinator.totalCount = totalCardCount
            }
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: ScrollViewDetector
        init(parent: ScrollViewDetector) {
            self.parent = parent
        }
        
        var totalCount: Int = 0
        var velocityY: CGFloat = 0
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            // removing invalid scroll
            let cardHeight: CGFloat = 220
            let cardSpacing: CGFloat = 35
            // adding velocity
            let targetEnd: CGFloat = scrollView.contentOffset.y + (velocity.y * 60)
            let index = (targetEnd / cardHeight).rounded()
            let modifiedEnd = index * cardHeight
            let spacing = cardSpacing * index
            
            if !scrollView.isDecelerating {
                targetContentOffset.pointee.y = modifiedEnd + spacing
            }
            velocityY = velocity.y
        }
        
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            // removing invalid scroll
            let cardHeight: CGFloat = 220
            let cardSpacing: CGFloat = 35
            // adding velocity
            let targetEnd: CGFloat = scrollView.contentOffset.y + (velocityY * 60)
            let index = max(min((targetEnd / cardHeight).rounded(), CGFloat(totalCount - 1)), 0.0)
            let modifiedEnd = index * cardHeight
            let spacing = cardSpacing * index
            
            scrollView.setContentOffset(.init(x: 0, y: modifiedEnd + spacing), animated: true)
        }
    }
}

struct Job: Identifiable,Hashable{
    var id: String = UUID().uuidString
    var title: String
    var imageName: String
    var description: String
    var rating: Int
    var jobViews: Int
    var jobdescription: String
    var joblink: String
}

var sampleJobs: [Job] = [
    .init(title: "Chipotle", imageName: "realchipotle", description: "Age: 16+   Pay: $12 hr", rating: 5, jobViews: 54, jobdescription: "Chipotle is a popular fast-casual restaurant chain that specializes in Mexican cuisine. The company offers a range of job opportunities in its restaurants, catering operations, and corporate offices. Chipotle offers a diverse range of job opportunities for individuals with different backgrounds and levels of experience. The company emphasizes teamwork, high-quality food, and a commitment to sustainability, making it an attractive workplace for those interested in the restaurant industry.", joblink: "https://chipotle.com"),
    .init(title: "Chik-Fil-A", imageName: "realchik", description: "Age: 14+   Pay: $15 hr", rating: 4, jobViews: 65, jobdescription: "Team members are responsible for providing exceptional customer service, preparing food and drinks, and maintaining a clean and organized restaurant. Cashiers are responsible for taking orders, handling payments, and maintaining a friendly and efficient checkout process. Kitchen staff are responsible for preparing food and ensuring quality and safety standards are met. Management roles may include positions such as shift supervisor, assistant manager, and restaurant general manager, which involve overseeing operations, managing team members, and maintaining high standards of customer service and food quality.", joblink: "https://chikfila.com"),
    .init(title: "McDonald's", imageName: "realmcdonald", description: "Age: 16+   Pay: $13 hr", rating: 1, jobViews: 18, jobdescription: "McDonald's is a fast food chain that operates in over 100 countries. They have a variety of job opportunities available, ranging from entry-level positions to managerial roles. Some common job positions include crew member, cashier, cook, shift manager, and general manager. Most positions at McDonald's are part-time and offer flexible schedules, making it a popular choice for students and those looking for a second job. McDonald's also offers opportunities for advancement and career development for those interested in pursuing a long-term career with the company.", joblink: "https://mcdonalds.com"),
    .init(title: "Kumon", imageName: "realkumon", description: "Age: 14+   Pay: $7 hr", rating: 2, jobViews: 24, jobdescription: "Kumon is a private tutoring company that offers personalized math and reading instruction for students from pre-K through high school. The company is dedicated to helping students improve their academic skills and reach their full potential through individualized instruction and self-paced learning.Kumon tutors work with students on a one-on-one basis, developing personalized lesson plans based on each student's strengths, weaknesses, and goals. They provide feedback and support to help students master new concepts and build confidence in their abilities. As a Kumon tutor, you would be responsible for working with students in a supportive and encouraging environment, providing individualized instruction and feedback, and helping students build the skills and confidence they need to succeed. You would also be responsible for maintaining accurate records of student progress and communicating regularly with parents and other Kumon staff members.", joblink: "https://kumon.com"),
    .init(title: "Starbucks", imageName: "realstarbucks", description: "Age: 16+   Pay: $15 hr", rating: 4, jobViews: 45, jobdescription: "Working at Starbucks can be a rewarding experience for those who are passionate about customer service, teamwork, and coffee. To work at Starbucks, candidates should possess a positive attitude, excellent communication skills, and the ability to work in a fast-paced environment. Starbucks also values diversity and inclusion and is committed to creating a welcoming and inclusive workplace for all. Prior barista experience is not required, as Starbucks provides comprehensive training for all new hires. However, a love of coffee and a willingness to learn and grow are important qualities for success at Starbucks. As a Starbucks employee, you can expect to receive competitive pay, benefits, and opportunities for career development and advancement.", joblink: "https://starbucks.com"),
    .init(title: "Publix", imageName: "realpublix", description: "Age: 14+   Pay: $12 hr", rating: 3, jobViews: 33, jobdescription: "Publix is often recognized for its employee-friendly policies, including competitive pay, flexible scheduling, and benefits such as health insurance, retirement plans, and employee stock ownership. They also offer opportunities for career advancement and education through their tuition reimbursement program.To work at Publix, candidates should have a strong work ethic, customer service skills, and the ability to work in a fast-paced environment. Some positions may require specific skills or experience, such as food handling or pharmacy technician certification.", joblink: "https://publix.com"),
    .init(title: "Dairy Queen", imageName: "dairyqueen", description: "Age: 14+   Pay: $8 hr", rating: 4, jobViews: 11, jobdescription: "Dairy Queen is a fast food chain known for its soft-serve ice cream and other treats. Job opportunities at Dairy Queen include entry-level roles such as crew member and cashier, as well as more advanced positions such as shift supervisor and manager. Crew members are responsible for tasks such as taking orders, preparing food, and cleaning the restaurant. Cashiers handle cash transactions and ensure accurate order taking. Shift supervisors oversee the crew and ensure the smooth operation of the restaurant during their shifts. Managers are responsible for overall restaurant operations, including hiring and training staff, managing inventory, and ensuring customer satisfaction. Some key skills for success in Dairy Queen jobs include strong customer service skills, attention to detail, and the ability to work in a fast-paced environment. Opportunities for career growth and advancement are available for those who demonstrate exceptional performance and leadership abilities.", joblink: "https://chipotle.com"),
    .init(title: "Crumbl Cookies", imageName: "crumblecookies", description: "Age: 16+   Pay: $10 hr", rating: 5, jobViews: 19, jobdescription: "Crumbl Cookies is a chain of gourmet cookie shops that prides itself on its delicious and innovative cookie flavors. As a Crumbl Cookies employee, you would be responsible for baking and decorating cookies, maintaining a clean and organized kitchen, interacting with customers, and ensuring that all orders are fulfilled accurately and efficiently. You may also be responsible for handling cash and credit card transactions and keeping track of inventory. The ideal candidate for a job at Crumbl Cookies would be a hard-working, detail-oriented individual who is passionate about baking and providing excellent customer service.", joblink: "https://chipotle.com"),
    .init(title: "Wendy's", imageName: "wendy", description: "Age: 15+   Pay: $12 hr", rating: 4, jobViews: 26, jobdescription: "Wendy's is a fast food restaurant chain that serves hamburgers, chicken sandwiches, and other quick meal options. As a team member at Wendy's, you would be responsible for taking customer orders, preparing food, and maintaining a clean and organized restaurant environment. You would also be expected to handle cash transactions and provide friendly customer service. Ideal candidates for Wendy's team member positions should be able to work in a fast-paced environment, possess good communication and problem-solving skills, and be willing to work flexible schedules that may include evenings, weekends, and holidays. Wendy's also values employees who exhibit a positive attitude, attention to detail, and a strong work ethic. With opportunities for advancement, competitive pay rates, and a supportive work environment, Wendy's is a great choice for those looking for an entry-level position in the fast food industry.", joblink: "https://starbucks.com"),
]
