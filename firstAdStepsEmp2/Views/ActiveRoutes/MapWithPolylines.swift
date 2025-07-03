import SwiftUI
import MapKit

struct MapWithPolylines: UIViewRepresentable {
    var region: MKCoordinateRegion
    var annotations: [RouteMapAnnotation]
    var polylines: [PolylineWrapper]
    var areaCircles: [MKCircle]          // Area route için çemberler
    var onAnnotationTap: ((RouteMapAnnotation) -> Void)? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Debug: Polyline sayısını kontrol et
        print("🗺️ MapWithPolylines updateUIView - Polylines count: \(polylines.count)")
        print("🗺️ MapWithPolylines updateUIView - Annotations count: \(annotations.count)")
        print("🗺️ MapWithPolylines updateUIView - Area circles count: \(areaCircles.count)")
        
        // Clear overlays and annotations
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Polyline referanslarını dictionary olarak tut
        context.coordinator.polylineToWrapper = [:]
        
        // Add annotations
        let mkAnnotations = annotations.map { annotation -> CustomAnnotation in
            let mk = CustomAnnotation()
            mk.coordinate = annotation.coordinate
            mk.title = annotation.type.rawValue
            mk.subtitle = "Schedule \(annotation.schedule.id)"
            mk.routeAnnotation = annotation
            return mk
        }
        mapView.addAnnotations(mkAnnotations)
        
        // Add area circles
        mapView.addOverlays(areaCircles)
        
        // Add polylines ve dictionary'ye ekle
        for (index, wrapper) in polylines.enumerated() {
            mapView.addOverlay(wrapper.polyline)
            context.coordinator.polylineToWrapper[wrapper.polyline] = wrapper
            print("🗺️ Polyline ekleniyor: \(index) type=\(wrapper.type), scheduleId=\(wrapper.scheduleId)")
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapWithPolylines
        var polylineToWrapper: [MKPolyline: PolylineWrapper] = [:]
        
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
            let size: CGFloat = customAnnotation.isLarge ? 36 : 22
            
            // Mavi renk paleti
            let mainBlue = UIColor.systemBlue
            let lightBlue = UIColor.systemBlue.withAlphaComponent(0.5)
            let veryLightBlue = UIColor.systemBlue.withAlphaComponent(0.25)
            
            // Üst üste üç daire tasarımı oluştur
            let image = createLayeredCircleImage(
                size: size,
                mainColor: mainBlue,
                lightColor: lightBlue,
                veryLightColor: veryLightBlue
            )
            
            annotationView?.image = image
            annotationView?.annotation = annotation
            
            return annotationView
        }
        
        // Üst üste üç daire tasarımı oluşturan fonksiyon
        private func createLayeredCircleImage(size: CGFloat, mainColor: UIColor, lightColor: UIColor, veryLightColor: UIColor) -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
            
            return renderer.image { context in
                let rect = CGRect(x: 0, y: 0, width: size, height: size)
                let center = CGPoint(x: size/2, y: size/2)

                // En büyük daire (en altta) - opacity 25%
                let largestRadius = size * 0.5
                let largestRect = CGRect(
                    x: center.x - largestRadius,
                    y: center.y - largestRadius,
                    width: largestRadius * 2,
                    height: largestRadius * 2
                )
                veryLightColor.setFill()
                context.cgContext.fillEllipse(in: largestRect)

                // Orta daire - opacity 50%
                let mediumRadius = size * 0.35
                let mediumRect = CGRect(
                    x: center.x - mediumRadius,
                    y: center.y - mediumRadius,
                    width: mediumRadius * 2,
                    height: mediumRadius * 2
                )
                lightColor.setFill()
                context.cgContext.fillEllipse(in: mediumRect)

                // En küçük daire (en üstte) - normal opacity
                let smallestRadius = size * 0.2
                let smallestRect = CGRect(
                    x: center.x - smallestRadius,
                    y: center.y - smallestRadius,
                    width: smallestRadius * 2,
                    height: smallestRadius * 2
                )
                mainColor.setFill()
                context.cgContext.fillEllipse(in: smallestRect)
            }
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline,
               let wrapper = polylineToWrapper[polyline] {
                let renderer = MKPolylineRenderer(polyline: polyline)
                print("🗺️ Rendering polyline: type=\(wrapper.type), scheduleId=\(wrapper.scheduleId)")
                print("🗺️ Polyline coordinates count: \(polyline.pointCount)")
                switch wrapper.type {
                case .direction:
                    renderer.strokeColor = UIColor.systemRed
                    renderer.lineWidth = 12.0
                    renderer.alpha = 1.0
                    print("🗺️ Applied direction styling: red, width=12, alpha=1.0")
                case .session:
                    renderer.strokeColor = UIColor.systemBlue
                    renderer.lineWidth = 3.0
                    renderer.alpha = 0.8
                    print("🗺️ Applied session styling: blue, width=3, alpha=0.8")
                }
                return renderer
            }
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.5)
                renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.15)
                renderer.lineWidth = 2.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? CustomAnnotation, let routeAnnotation = annotation.routeAnnotation {
                parent.onAnnotationTap?(routeAnnotation)
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

// Custom annotation class for map markers
class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var routeAnnotation: RouteMapAnnotation?
    var isLarge: Bool = false
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        super.init()
    }
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
