import Foundation
import SwiftUI
import AppKit
import MapKit
import CodableGeoJSON

struct MVMapView: NSViewRepresentable {
    @Binding var coordinates: [GeoJSON.Geometry]
    
    init(coordinates: Binding<[GeoJSON.Geometry]>) {
        self._coordinates = coordinates
    }
    
    func makeNSView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Initial Region
        let centerCoordinate = CLLocationCoordinate2D(
            latitude: -6.914744,
            longitude: 107.609810)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.region = region
        
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
