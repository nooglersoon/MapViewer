import SwiftUI
import CodableGeoJSON

struct MainView: View {
    
    @StateObject var viewModel: MainViewModel = MainViewModel()
    @State private var isImporting: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MVMapView(coordinates: $viewModel.dataSources)
            VStack(spacing: 16) {
                MVActionButton(
                    model: .init(callback: {
                        viewModel.resetLayers()
                    }, buttonColor: .red, textColor: .white, icon: Image(systemName: "minus.circle.fill"), text: "Reset layer")
                )
                .disabled(viewModel.dataSources.isEmpty)
                MVActionButton(
                    model: .init(callback: {
                        isImporting.toggle()
                    }, buttonColor: .white, textColor: .black, icon: Image(systemName: "plus.circle.fill"), text: "Add layer")
                )
            }
            .padding()
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
