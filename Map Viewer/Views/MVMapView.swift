import Foundation
import SwiftUI
import AppKit
import MapKit
import CodableGeoJSON

struct MVMapView: NSViewRepresentable {
    @Binding var dataSources: [GeoJSON.Geometry]
    
    init(coordinates: Binding<[GeoJSON.Geometry]>) {
        self._dataSources = coordinates
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
        mapView.pointOfInterestFilter = .excludingAll
        
        return mapView
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        if !dataSources.isEmpty {
            dataSources.forEach { geom in
                switch geom {
                case .point(let dataSource):
                    let region = MKCoordinateRegion(center: .init(latitude: dataSource.latitude, longitude: dataSource.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    nsView.setRegion(region, animated: false)
                    let circle = MKCircle(center: .init(latitude: dataSource.latitude, longitude: dataSource.longitude), radius: 50)
                    nsView.addOverlay(circle)
                case .multiPoint(let coordinates):
                    break
                case .lineString(let dataSources):
                    let region = MKCoordinateRegion(center: .init(latitude: dataSources[0].latitude, longitude: dataSources[0].longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    nsView.setRegion(region, animated: false)
                    let polyline = MKPolyline(coordinates: dataSources.compactMap({.init(latitude: $0.latitude, longitude: $0.longitude)}), count: dataSources.count)
                    nsView.addOverlay(polyline)
                case .multiLineString(let coordinates):
                    break
                case .polygon(let dataSources):
                    let region = MKCoordinateRegion(center: .init(latitude: dataSources[0][0].latitude, longitude: dataSources[0][0].longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    nsView.setRegion(region, animated: false)
                    
                    dataSources.forEach { singleDataSource in
                        let coordinates: [CLLocationCoordinate2D] = singleDataSource.map { position in
                                .init(latitude: position.latitude, longitude: position.longitude)
                        }
                        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
                        nsView.addOverlay(polygon)
                    }
                    
                case .multiPolygon(let coordinates):
                    break
                case .geometryCollection(let geometries):
                    break
                }
            }
        } else {
            nsView.removeOverlays(nsView.overlays)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
