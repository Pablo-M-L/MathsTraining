//
//  ViewController.swift
//  MathsTraining
//
//  Created by admin on 21/04/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var drawingView: DrawingImageView!
    
    let factory = QuestionFactory()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawingView.delegate = self
        title = "Maths Training"
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 2
        
        
    }
    
    func numberDrawn(_ image:UIImage) {
        askNewQuestion()
    }
    
    func askNewQuestion(){
        //borra el imagen.
        drawingView.image = nil
        factory.addNewQuestion()
        
        //pedimos un nuevo indexpath
        let newIndexPath = IndexPath(row: 0, section: 0)
        
        //el tableView añade una fila con animacion.
        tableView.insertRows(at: [newIndexPath], with: .right)
        
        //
        let secondIndexPath = IndexPath(row: 1, section: 0)
        if let cell = tableView.cellForRow(at: secondIndexPath), let question = factory.getQuestionAt(position: 1){
            setText(for: cell, at: secondIndexPath, to: question)
        }
        
        
        
        
    }
    
    //cambiar tamaño fuente de la primera celda
    func setText(for cell:UITableViewCell, at indexPath: IndexPath, to question:Question){
        if indexPath.row == 0 {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 36)
        }
        else{
            cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        
        if let userAnswer = question.userAnswer{
            cell.textLabel?.text = "\(question.text) = \(userAnswer)"
        }
        else{
            cell.textLabel?.text = "\(question.text) = ?"
        }
    }
    
    // - MARK: UITableViewDataSource Methods
    func  numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factory.numberOfQuestions()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let currentQuestion = factory.getQuestionAt(position: indexPath.row){
            setText(for: cell, at: indexPath, to: currentQuestion)
        }
        return cell
    }
    
    // - MARK: UITableViewDelegate Methods
    //altura de la celda que va a aparecer
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //para la celda que este en pantalla
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

