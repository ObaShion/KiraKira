//
//  CollectionViewController.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import UIKit
import SwiftUI

class CollectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


struct CollectionView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CollectionViewController
    
    func makeUIViewController(context: Context) -> CollectionViewController {
        return CollectionViewController()
    }
    
    func updateUIViewController(_ uiViewController: CollectionViewController, context: Context) {}
}
