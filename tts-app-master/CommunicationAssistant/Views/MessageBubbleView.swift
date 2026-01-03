import SwiftUI

struct MessageBubbleView: View {
    let message: String
    let senderType: String
    let translatedText: String?
    
    var isUser: Bool { senderType == "user" }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                Text(message)
                    .padding(14)
                    .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isUser ? .white : .primary)
                    .cornerRadius(18)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                if let translated = translatedText {
                    Text(translated)
                        .font(.callout)
                        .italic()
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                }
            }
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(isUser ? "Sent" : "Received") message: \(message)\(translatedText != nil ? ". Translation: \(translatedText!)" : "")")
    }
}
