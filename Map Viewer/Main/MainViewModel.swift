import Foundation
import CodableGeoJSON

class MainViewModel: ObservableObject {
    
    @Published
    var dataSources: [GeoJSON.Geometry] = []
    
    func handleImportResult(_ result: Result<[URL], Error>) {
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
    
    func handleGeometry(_ geometry: GeoJSON.Geometry?) {
        guard let geometry = geometry else { return }
        switch geometry {
        case .point(let coordinates):
            self.dataSources.append(.point(coordinates: coordinates))
            break
        case .multiPoint(let coordinates):
            print("DBG \(coordinates)")
            break
        case .lineString(let coordinates):
            self.dataSources = [.lineString(coordinates: coordinates)]
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
