import Foundation
import MapKit

class Coordinator: NSObject, MKMapViewDelegate {
    let parent: MVMapView
    
    init(_ parent: MVMapView) {
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
