import SwiftUI
import CodableGeoJSON
import AlertToast

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
        .toast(isPresenting: $viewModel.showToast){
            switch viewModel.alertState {
            case .success(let label):
                return AlertToast(displayMode: .hud, type: .regular, title: label)
            case .error(let title, let subtitle):
                return AlertToast(displayMode: .hud, type: .error(.red), title: title, subTitle: subtitle)
            }
        }
    }
}

#Preview {
    MainView()
}
