import Foundation
import CodableGeoJSON

enum AlertState {
    case success(label: String)
    case error(title: String, subtitle: String?)
}

class MainViewModel: ObservableObject {

    @Published
    var dataSources: [GeoJSON.Geometry] = []
    
    @Published
    var alertState: AlertState = .success(label: "")
    
    @Published
    var showToast: Bool = false

    func handleImportResult(_ result: Result<[URL], Error>) {
        do {
            guard
                let selectedFileURL: URL = try result.get().first,
                selectedFileURL.startAccessingSecurityScopedResource()
            else { return }

            // Read file data asynchronously
            DispatchQueue.global().async { [weak self] in
                do {
                    let restoredData = try Data(contentsOf: selectedFileURL)

                    self?.handleDecodedData(restoredData)
                } catch {
                    // Handle file read error
                    DispatchQueue.main.async { [weak self] in
                        self?.handleError(error)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.handleError(error)
            }
        }
    }

    func handleDecodedData(_ data: Data) {
        DispatchQueue.global().async { [weak self] in
            do {
                let geoJSON = try JSONDecoder().decode(GeoJSON.self, from: data)

                // Perform geometry handling on the main thread
                DispatchQueue.main.async { [weak self] in
                    self?.handleGeometry(geoJSON)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.handleError(error)
                }
            }
        }
    }

    func handleGeometry(_ geoJSON: GeoJSON) {
        switch geoJSON {
        case .feature(let feature, _):
            handleGeometry(feature.geometry)
        case .featureCollection(let featureCollection, _):
            for feature in featureCollection.features {
                handleGeometry(feature.geometry)
            }
        case .geometry(let geometry, _):
            handleGeometry(geometry)
        }
        handleSuccess(label: "Success import the data")
    }

    func handleGeometry(_ geometry: GeoJSON.Geometry?) {
        guard let geometry = geometry else { return }
        var newGeometries: [GeoJSON.Geometry] = []

        switch geometry {
        case .point(let coordinates):
            newGeometries.append(.point(coordinates: coordinates))
        case .multiPoint(let coordinates):
            print("DBG \(coordinates)")
        case .lineString(let coordinates):
            newGeometries = [.lineString(coordinates: coordinates)]
        case .multiLineString(let coordinates):
            print("DBG \(coordinates)")
        case .polygon(let coordinates):
            newGeometries.append(.polygon(coordinates: coordinates))
        case .multiPolygon(let coordinates):
            print("DBG \(coordinates)")
        case .geometryCollection(let geometries):
            for geometry in geometries {
                handleGeometry(geometry)
            }
        }

        DispatchQueue.main.async { [weak self] in
            if !newGeometries.isEmpty {
                self?.dataSources.append(contentsOf: newGeometries)
            }
        }
    }


    func handleError(_ error: Error) {
        showToast.toggle()
        alertState = .error(title: "Failed to import data", subtitle: "Your data is not supported at the moment")
    }
    
    func handleSuccess(label: String) {
        showToast.toggle()
        alertState = .success(label: label)
    }
    
    func resetLayers() {
        handleSuccess(label: "Success remove data")
        dataSources.removeAll()
    }
}
