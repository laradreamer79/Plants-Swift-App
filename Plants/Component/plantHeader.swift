//
//  PlantHeader.swift
//  Plants
//
//  Created by LARA on 01/06/1448 AH.
//

import SwiftUI

struct PlantHeader: View {
    var body: some View {
        Text("My Plants 🌱")
            .frame(maxWidth: .infinity,  alignment: .leading)
            .padding(.leading, 16)
            .padding(.top, 41)
            .font(.custom("SFCompactDisplay-Semibold", size: 25))
            .foregroundStyle(Color(red: 1.000, green: 1.000, blue: 1.000, opacity: 1.00))
        Divider()
            .overlay(Color(red: 0.224, green: 0.224, blue: 0.231, opacity: 1.00))
    }
}

#Preview {
    PlantHeader()
}
