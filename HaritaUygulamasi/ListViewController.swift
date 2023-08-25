//
//  ListViewController.swift
//  HaritaUygulamasi
//
//  Created by Oktay Kuzu on 22.08.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    
    var secilenyerisim = ""
    var secilenyerid : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        TableView.dataSource = self
        TableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(artibutonutikla))
        
        verilerial()
      
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verilerial), name: NSNotification.Name("YeniyerOlusturuldu"), object: nil)
    }
   @objc func verilerial()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        fetchrequest.returnsObjectsAsFaults = false
        
        do{
            let sonuclar = try context.fetch(fetchrequest)
            if sonuclar.count > 0 {
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar  as! [NSManagedObject] {
                    if let isim = sonuc.value(forKey:"isim") as? String {
                        isimDizisi.append(isim)
                      
                        
                    }
                    
                    if let id = sonuc.value(forKey:"id") as? UUID{
                        idDizisi.append(id)
                    }
                   
                }
                TableView.reloadData()
            }
            
        } catch{
            print("hata...!!!")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
        
    }
    
    
    
    
    @objc func artibutonutikla(){
        secilenyerisim = ""
        performSegue(withIdentifier: "ToMapsDetay", sender: nil)
    }
    
     //table viewde birşeye tıklanırsa
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenyerisim = isimDizisi[indexPath.row]
        secilenyerid = idDizisi[indexPath.row]
        performSegue(withIdentifier: "ToMapsDetay", sender: nil)
    }
    //verileri diğer sayfaya aktarma 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier ==  "ToMapsDetay" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.secilenisim=secilenyerisim
            destinationVC.secilenid=secilenyerid
        }
    }
}
