import SwiftUI
import MapKit

struct ContentView: View {
    @State private var isImporting: Bool = false
    @State private var region = MKCoordinateRegion(
            // Set your desired location
            center: CLLocationCoordinate2D(
                latitude: 51.507222,
                longitude: -0.1275),
            // Give location span from the center
            span: MKCoordinateSpan(
                latitudeDelta: 0.5,
                longitudeDelta: 0.5)
        )
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(coordinateRegion: $region)
                .ignoresSafeArea()
            Button(action: {
                isImporting.toggle()
            }, label: {
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.white)
                    HStack(spacing: 8) {
                        Text("Upload geojson")
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
            do {
                guard
                    let selectedFile: URL = try result.get().first,
                    selectedFile.startAccessingSecurityScopedResource()
                else { return }
                guard let restoredData = try? Data(contentsOf: selectedFile) else {
                    return
                  }
                print("DBG \(restoredData)")
            } catch (let error) {
                print(error)
                // Handle failure.
            }
        }
    }
}

#Preview {
    ContentView()
}
