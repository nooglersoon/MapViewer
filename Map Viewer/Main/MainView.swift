import SwiftUI
import CodableGeoJSON

struct MainView: View {
    
    @StateObject var viewModel: MainViewModel = MainViewModel()
    @State private var isImporting: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MVMapView(coordinates: $viewModel.dataSources)
            Button(action: {
                isImporting.toggle()
            }, label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                    HStack(spacing: 8) {
                        Text("Add layer")
                            .foregroundStyle(.black)
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(.black)
                            .shadow(radius: 8)
                    }
                }
                .frame(width: 180, height: 40)
            })
            .padding()
            .buttonStyle(.plain)
        }
        .frame(minWidth: 500, minHeight: 500)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            viewModel.handleImportResult(result)
        }
    }
}

#Preview {
    MainView()
}
