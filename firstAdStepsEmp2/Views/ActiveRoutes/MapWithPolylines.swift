import SwiftUI
import MapKit

struct MapWithPolylines: UIViewRepresentable {
    let region: MKCoordinateRegion
    let annotations: [RouteMapAnnotation]
    let directionPolylines: [MKPolyline] // Directions API'den gelen polyline
    let sessionPolylines: [MKPolyline]   // ScreenSession'dan gelen polyline
    let areaCircles: [MKCircle]          // Area route için çemberler
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Clear overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Add annotations
        let mkAnnotations = annotations.map { annotation -> CustomAnnotation in
            let mk = CustomAnnotation()
            mk.coordinate = annotation.coordinate
            mk.title = annotation.type.rawValue
            mk.annotationType = annotation.type
            mk.color = annotation.color
            mk.isLarge = annotation.isLarge
            return mk
        }
        mapView.addAnnotations(mkAnnotations)
        
        // Add direction polylines (kalın, açık mavi, opacity 0.5)
        for polyline in directionPolylines {
            mapView.addOverlay(polyline)
            print("🔵 Direction polyline eklendi: \(polyline.pointCount) nokta")
        }
        // Add session polylines (ince, koyu mavi)
        for polyline in sessionPolylines {
            mapView.addOverlay(polyline)
            print("🔵 Session polyline eklendi: \(polyline.pointCount) nokta")
        }
        // Add area circles (mor, şeffaf)
        for circle in areaCircles {
            mapView.addOverlay(circle)
            print("🔵 Area Circle haritaya eklendi: Merkez(\(circle.coordinate.latitude), \(circle.coordinate.longitude)), Radius: \(circle.radius)m")
        }
        
        // Set region
        mapView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithPolylines
        
        init(_ parent: MapWithPolylines) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomAnnotation else {
                return nil
            }
            
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKAnnotationView
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            // İkon boyutunu belirle
            let size: CGFloat = customAnnotation.isLarge ? 40 : 20
            
            // İkon rengini belirle
            let uiColor = UIColor(customAnnotation.color)
            
            // İkon tipini belirle
            let imageName: String
            switch customAnnotation.annotationType {
            case .start:
                imageName = "mappin.circle.fill" // Başlangıç için mappin.circle.fill
            case .end:
                imageName = "flag.circle.fill" // Bitiş için flag.circle.fill
            case .waypoint:
                imageName = "circle.fill"
            }
            
            // SF Symbol kullanarak ikon oluştur
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .medium)
            let image = UIImage(systemName: imageName, withConfiguration: config)?.withTintColor(uiColor, renderingMode: .alwaysOriginal)
            
            annotationView?.image = image
            annotationView?.annotation = annotation
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                // Directions API'den gelen polyline'lar
                if parent.directionPolylines.contains(where: { $0 === polyline }) {
                    renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8) // Daha görünür
                    renderer.lineWidth = 6.0 // Biraz daha ince ama görünür
                } else {
                    // ScreenSession polyline'ları
                    renderer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.7) // Yeşil renk
                    renderer.lineWidth = 3.0 // Daha kalın
                }
                return renderer
            } else if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.25) // Mavi, yarı saydam fill
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.8) // Mavi, opak stroke
                renderer.lineWidth = 6.0 // Kalın çizgi
                return renderer
            } else {
                return MKOverlayRenderer(overlay: overlay)
            }
        }
    }
}

// MARK: - Polyline Info Struct
struct PolylineInfo {
    let color: Color
    let lineWidth: CGFloat
    let routeType: RoutePolyline.RouteType
}

// MARK: - Custom Annotation Class
class CustomAnnotation: MKPointAnnotation {
    var annotationType: RouteMapAnnotation.AnnotationType = .waypoint
    var color: Color = .blue
    var isLarge: Bool = false
}

// MARK: - Annotation Type Extension
extension RouteMapAnnotation.AnnotationType: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: String) {
        switch rawValue {
        case "start": self = .start
        case "end": self = .end
        case "waypoint": self = .waypoint
        default: return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .start: return "start"
        case .end: return "end"
        case .waypoint: return "waypoint"
        }
    }
} 