import SwiftUI
import CodableGeoJSON

struct MainView: View {
    @State private var isImporting: Bool = false
    @State private var coordinates: [GeoJSON.Geometry] = [
        .point(coordinates: .init(longitude: 107.61059540803228, latitude: -6.9069316579300875))
    ]
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MVMapView(coordinates: $coordinates)
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
            do {
                guard
                    let selectedFile: URL = try result.get().first,
                    selectedFile.startAccessingSecurityScopedResource()
                else { return }
                guard let restoredData = try? Data(contentsOf: selectedFile) else {
                    return
                }
                do {
                    switch try JSONDecoder().decode(GeoJSON.self, from: restoredData) {
                    case .feature(let feature, _):
                        handleGeometry(feature.geometry)
                    case .featureCollection(let featureCollection, _):
                        for feature in featureCollection.features {
                            handleGeometry(feature.geometry)
                        }
                    case .geometry(let geometry, _):
                        handleGeometry(geometry)
                    }
                } catch {
                    // Handle decoding error
                }
            } catch (let error) {
                print(error)
                // Handle failure.
            }
        }
    }
    
    func handleGeometry(_ geometry: GeoJSON.Geometry?) {
        guard let geometry = geometry else { return }
        switch geometry {
        case .point(let coordinates):
            self.coordinates.append(.point(coordinates: coordinates))
            break
        case .multiPoint(let coordinates):
            print("DBG \(coordinates)")
            break
        case .lineString(let coordinates):
            self.coordinates = [.lineString(coordinates: coordinates)]
            break
        case .multiLineString(let coordinates):
            print("DBG \(coordinates)")
            break
        case .polygon(let coordinates):
            print("DBG \(coordinates)")
            break
        case .multiPolygon(let coordinates):
            print("DBG \(coordinates)")
            break
        case .geometryCollection(let geometries):
            for geometry in geometries {
                handleGeometry(geometry)
            }
        }
    }
}

#Preview {
    MainView()
}
