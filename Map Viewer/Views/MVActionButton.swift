import SwiftUI

struct MVActionButtonModel {
    let callback: () -> Void
    let buttonColor: Color
    let textColor: Color
    let icon: Image
    let text: String
}

struct MVActionButton: View {
    let model: MVActionButtonModel
    var body: some View {
        Button(action: {
            model.callback()
        }, label: {
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(model.buttonColor)
                HStack(alignment: .center, spacing: 8) {
                    Text(model.text)
                        .foregroundStyle(model.textColor)
                    model.icon
                        .font(.headline)
                        .bold()
                        .foregroundStyle(model.textColor)
                }
            }
            .frame(width: 120, height: 40)
        })
        .buttonStyle(.plain)
        .shadow(radius: 8)
    }
}

#Preview {
    MVActionButton(
        model: .init(callback: {print("")}, buttonColor: .red, textColor: .white, icon: Image(systemName: "minus.circle.fill"), text: "Reset layer")
    )
}
