//
//  ViewController.swift
//  HaritaUygulamasi
//
//  Created by Oktay Kuzu on 22.08.2023.
//

import UIKit
import MapKit
//konum ayarları icin bu kütüphane kullanılır
import CoreLocation
import CoreData


class MapsViewController: UIViewController  ,MKMapViewDelegate, CLLocationManagerDelegate{
    @IBOutlet weak var mapview: MKMapView!
    
    @IBOutlet weak var notTextFlied: UITextField!
    @IBOutlet weak var isimTextFlied: UITextField!
    var locationmanager = CLLocationManager()
    
    var secilenlatitude = Double()
    var secilenlongtitude = Double()
    
    var secilenisim = ""
    var secilenid : UUID?
    
    var anatitontitle = ""
    var anationsubtitle = ""
    var ananitonlatitude = Double ()
    var anatitonlongtitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapview.delegate = self
        locationmanager.delegate = self
        //konumu ne kadar düzgün alabiliriz onu yapıyoruz ?
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        //kullanicidan izin istemek icin ?
        locationmanager.requestWhenInUseAuthorization()
        // konumu güncelleme başla
        locationmanager.startUpdatingLocation()
         
        //jest algılayıcı konum olan yere uzun bastığını anlama kicin
        let getureReguestır =  UILongPressGestureRecognizer(target: self , action: #selector(konumabasma(getureReguestır:)))
        
        //kaç saniye baıldığında algılaması icin
        getureReguestır.minimumPressDuration = 2
        //olusturduğumuz jest algılayıcıyı mapview eklemek
        
        mapview.addGestureRecognizer(getureReguestır)
        
        
        if  secilenisim != "" {
            //core data verileri cek
            
            if let uuidString = secilenid?.uuidString {
                let appdeletegate = UIApplication.shared.delegate as! AppDelegate
                let contex = appdeletegate.persistentContainer.viewContext
                
                let fethrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                 //filtreleme işlemi için HAngi kolanı filtreleceğiz
                fethrequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fethrequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar = try contex.fetch(fethrequest)
                    if sonuclar.count > 0 {
                        //veri tabandaki güncel kaydedilen konumları cekme
                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                anatitontitle = isim
                                if let not = sonuc.value(forKey: "not") as? String{
                                    anationsubtitle  = not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double{
                                        ananitonlatitude = latitude
                                        if let longtitude = sonuc.value(forKey: "longtude") as? Double{
                                            anatitonlongtitude = longtitude
                                            
                                            //veri tabanında cekilen ve kaydelilen konumları annotiomda kullanma
                                            let annotion = MKPointAnnotation()
                                            annotion.title = anatitontitle
                                            annotion.subtitle = anationsubtitle
                                            
                                            let cordinate = CLLocationCoordinate2D(latitude: ananitonlatitude, longitude: anatitonlongtitude)
                                            annotion.coordinate = cordinate
                                            mapview.addAnnotation(annotion)
                                            
                                            isimTextFlied.text = anatitontitle
                                            notTextFlied.text = anationsubtitle
                                            
                                            
                                            locationmanager.startUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                            let region = MKCoordinateRegion(center: cordinate, span:span )
                                            mapview.setRegion(region, animated: true)
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                          
                           
                           
                        }
                                
                    }
                    
                }
                catch{
                    
                }
            }
         
            
        }
        else{
            //yeni eklemeye geldi
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        if secilenisim == "" {
            //kordinatları alma enlem ve boylam
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            //span değeri oluşturma Bölgenin genişliği ve yüksekliği
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            //region değeri alma ama buda span istiyor span ise düzlem ve genilik değeri
            let region = MKCoordinateRegion(center: location, span: span)
            //Bölgeyi değiştirme ama region değeri istiyor?
            mapview.setRegion(region, animated: true)
            
            
        }
        
    }
    
    @objc func konumabasma(getureReguestır : UILongPressGestureRecognizer){
         // jest algılayıcı başlayınca ne olucak ?
        if getureReguestır.state == .began {
             //dokunulan noktayı alma
            let dokunulannokta = getureReguestır.location(in: mapview)
            
            //dokunulan noktayı kordinata cevirmek icin
            let dokunulankordinat = mapview.convert(dokunulannokta, toCoordinateFrom: mapview)
            
            secilenlatitude = dokunulankordinat.latitude
            secilenlongtitude = dokunulankordinat.longitude
             //işaretleme için yapılan şey
            
            let annimation = MKPointAnnotation()
            annimation.coordinate = dokunulankordinat
            annimation.title = isimTextFlied.text
            annimation.subtitle = notTextFlied.text
            mapview.addAnnotation(annimation)
        }
        
        
        
    }
    

    @IBAction func Kaydetbutonutiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let contex = appDelegate.persistentContainer.viewContext
        
        let yeniyer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: contex)
        
        yeniyer.setValue(isimTextFlied.text!, forKey: "isim")
        yeniyer.setValue(notTextFlied.text!, forKey: "not")
        yeniyer.setValue(secilenlatitude, forKey: "latitude")
        yeniyer.setValue(secilenlongtitude, forKey: "longtude")
        yeniyer.setValue(UUID(), forKey: "id")
        
        do {
            try contex.save()
            print("başarılı kayıt edildi")
        
        }
        catch{
            print("hata var ")
        }
        
         
        // kaydedildektne sonra geriye dönücek
        NotificationCenter.default.post(name: NSNotification.Name("YeniyerOlusturuldu"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
    //bu
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        else{
            var reuseID = "benimannotionum"
            var pinview = mapView.dequeueReusableAnnotationView(withIdentifier:reuseID)
            if pinview == nil {
                
                pinview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                //bizim annotiomuz ekstra birşey göstersin mi?
                pinview?.canShowCallout = true
                pinview?.tintColor = .red
                //butonu olusturup annotion icinde göstermek 
                let button = UIButton(type: .detailDisclosure)
                pinview?.rightCalloutAccessoryView = button
                
            }
            else {
                pinview?.annotation = annotation
                
            }
            return pinview
        }
        
    }
    
}

