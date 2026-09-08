//
//  ButtonWithExplanation.swift
//  Coordinators
//
//  Created by David Pall on 2026. 09. 08..
//

import SwiftUI

struct ButtonWithExplanation: View {
    
    let title: String
    var description: String?
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.black)
                
                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(
                .regular.tint(.white.opacity(0.5)),
                in: .rect(cornerRadius: 20)
            )
            .padding(.horizontal, 24)
        }
    }
}
