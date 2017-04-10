//
//  RouteViewController.swift
//  RouteDemo
//
//  Created by Pablo Mateo Fernández on 02/02/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self

        let longGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(pinLocation))
        longGestureRecognizer.minimumPressDuration = 0.3
        
        mapView.addGestureRecognizer(longGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pinLocation(sender: UILongPressGestureRecognizer){
    
        if sender.state != .ended{
            return}
    
        //Detectar la posicion del Tap
        let tappedPoint = sender.location(in: mapView)
        print(tappedPoint)
        
        //Convertir esa posición en coordenadas geográficas
        let tappedCoordinate = mapView.convert(tappedPoint, toCoordinateFrom: mapView)
        print(tappedCoordinate)
        
        //Mostrar la chincheta en el mapa (Annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = tappedCoordinate
        
        //Guardamos la anotacion
        annotations.append(annotation)
        
        //Mostrar todas las anotaciones del array
        mapView.showAnnotations(annotations, animated: true)
        
    }
    
    //Cuando se va a añadir una chincheta al mapa
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let annotationView = views[0]
        let endFrame = annotationView.frame
        annotationView.frame = endFrame.offsetBy(dx: 0, dy: -600)
        UIView.animate(withDuration: 0.9) {
            
            annotationView.frame = endFrame
        }
    }

    @IBAction func drawPolyline(_ sender: AnyObject) {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        
        for annotation in annotations{
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.add(polyline) //Lo añado al mapa, pero eso no significa que se vaya a pintar. Ahora hay que pintarlo
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { //A esta funcion la llama con mapView.add
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.purple
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func drawDirection(startPoint: CLLocationCoordinate2D, endPoint: CLLocationCoordinate2D){
    
        //Creamos los items para las coordenadas
        let startPlacemark = MKPlacemark(coordinate: startPoint, addressDictionary: nil)
        let endPlacemark = MKPlacemark(coordinate: endPoint, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        //Definimos el inicio y destino de la ruta a calcular
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType =  .automobile
        
        //Calcular la direccion
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (routeResponse, routeError) in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                return
            }
            let route = routeResponse.routes[0]
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
    }
    
    @IBAction func drawRoute(_ sender: AnyObject) {
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        let visibleMapRect = mapView.mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
        
        mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        var index = 0
        while index < annotations.count - 1  {
            drawDirection(startPoint: annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            index += 1
        }
    }
    @IBAction func removeAnnotations(_ sender: AnyObject) {
        //Eliminamos las anotaciones y los overlays del mapa
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(annotations)
        
        annotations.removeAll()
    }
    
}
