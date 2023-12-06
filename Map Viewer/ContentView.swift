import SwiftUI
import CodableGeoJSON
import MapKit
import AppKit

struct ContentView: View {
    @State private var isImporting: Bool = false
    @State private var coordinates: [GeoJSON.Geometry] = [
        .point(coordinates: .init(longitude: 107.61059540803228, latitude: -6.9069316579300875))
    ]
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapView(coordinates: $coordinates)
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

struct MapView: NSViewRepresentable {
    // Where you put the coordinates array
    @Binding var coordinates: [GeoJSON.Geometry]
    
    init(coordinates: Binding<[GeoJSON.Geometry]>) {
        self._coordinates = coordinates
    }
    
    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        if !coordinates.isEmpty {
            coordinates.forEach { geom in
                switch geom {
                case .point(let coordinate):
                    let region = MKCoordinateRegion(center: .init(latitude: coordinate.latitude, longitude: coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    nsView.setRegion(region, animated: false)
                    let circle = MKCircle(center: .init(latitude: coordinate.latitude, longitude: coordinate.longitude), radius: 50)
                    nsView.addOverlay(circle)
                case .multiPoint(let coordinates):
                    break
                case .lineString(let coordinates):
                    let region = MKCoordinateRegion(center: .init(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    nsView.setRegion(region, animated: false)
                    let polyline = MKPolyline(coordinates: coordinates.compactMap({.init(latitude: $0.latitude, longitude: $0.longitude)}), count: coordinates.count)
                    nsView.addOverlay(polyline)
                case .multiLineString(let coordinates):
                    break
                case .polygon(let coordinates):
                    break
                case .multiPolygon(let coordinates):
                    break
                case .geometryCollection(let geometries):
                    break
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// To handle mapview delegate method
class Coordinator: NSObject, MKMapViewDelegate {
    let parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(overlay: circleOverlay)
            renderer.fillColor = NSColor.yellow.withAlphaComponent(0.75)
            renderer.strokeColor = NSColor.yellow
            renderer.lineWidth = 2
            return renderer
        }
        
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = NSColor.yellow.withAlphaComponent(0.5)
            return renderer
        }
        
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 4
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
        
    }
}

#Preview {
    ContentView()
}
