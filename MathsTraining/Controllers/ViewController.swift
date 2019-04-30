//
//  ViewController.swift
//  MathsTraining
//
//  Created by admin on 21/04/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var drawingView: DrawingImageView!
    
    @IBOutlet weak var progressView: UIProgressView!
    let factory = QuestionFactory()
    
    var mnistModel = MnistModel()
    
    var gameTimer : Timer!
    var totalTime = 60 //segundos
    var timeLeft: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawingView.delegate = self
        title = "Maths Training"
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 2
        timeLeft = totalTime
        self.progressView.progress = 1.0
        
        //temporizador
        restartGame(action: nil)
        
        
    }
    
    func numberDrawn(_ image:UIImage) {
        //askNewQuestion()
        
        //pasos:
        
        //1, redimensionar la imagen del usuario a una imagen de 299*299, que es el tamaño que espera el modelo ML
        let modelSize = 299
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //2, pasar UIImage a CIImage
        guard let ciImage = CIImage(image: newImage) else{
            fatalError("error al convertir de uiimage a ciimage")
        }
        
        
        //3, cargar el modelo en Vision
        guard let model = try? VNCoreMLModel(for: mnistModel.model) else {
            fatalError("no se ha podido preparar el modelo para clasificacion para vision")
        }
        
        //4, Peticion VNCoreMLRequest
        let request = VNCoreMLRequest(model: model){ [weak self]
            (request, error) in
            //5, al detectar la imagen, tenemos que saber el numero que ha escrito y validar la respuesta.
            
            //devuelve una array de posibles resultados, ordenados.
            guard let results = request.results as? [VNClassificationObservation], let prediction = results.first else{
                fatalError("Error al hacer la prediccion: \(error?.localizedDescription ?? "error desconocido")")
            }
            
            //recogemos la respuesta del hilo secundario (paso 6)
            DispatchQueue.main.sync {
                let result = Int(prediction.identifier) ?? 0
                //asignamos la respuesta de usuario a la pregunta actual.
                self?.factory.updateQuestion(at: 0, with: result)
                // actualizar la celda
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                //validamos si la respuesta es correcta
                self?.factory.validateQuestion(at: 0)
                //creamos una nueva pregunta
                self?.askNewQuestion()
            }
        }
        
        
        
        
        //6, justar todo en un VNImageRequestHandler
        let handler = VNImageRequestHandler(ciImage: ciImage)
        //ejecutamos la prediccion en un hilo secundario para no bloquer la UI.
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                try handler.perform([request])
            }catch{
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    func askNewQuestion(){
        //borra el imagen.
        drawingView.image = nil
        
        if(timeLeft > 0 ){
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
        else{
            //para el temporizador
            gameTimer.invalidate()
            
            let controller = UIAlertController(title: "fin de la partida", message: "has acertado \(self.factory.score) de \(self.factory.numberOfQuestions() * self.factory.pointsPerQuestion) puntos", preferredStyle: .alert)
            let action = UIAlertAction(title: "jugar otra mas", style: .default, handler: restartGame) //restarGame es la funcion.
            
            controller.addAction(action)
            present(controller,animated: true, completion: nil)
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
        
        if question.answer == question.userAnswer{
            cell.backgroundColor = UIColor.green
        }
        else{
            cell.backgroundColor = UIColor.red
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
    
    
    //para poder llamar la funcion desde el handler del action hay que pasarle el argumento, action: UIAlertAction
    func restartGame(action: UIAlertAction?){
        timeLeft = totalTime
        self.progressView.progress = 1.0
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
            self.timeLeft -= 1
            self.progressView.progress = Float(max(self.timeLeft,0)) / Float(self.totalTime)
            
            //colores, va cambiando el color de verde a rojo segun se va acabando el tiempo.
            let greenValue = CGFloat(Float(self.timeLeft)/Float(self.totalTime))
            let redValue = 1.0 - greenValue
                
            self.progressView.progressTintColor = UIColor(red: redValue, green: greenValue, blue: 0.2, alpha: 1.0)
        })
        factory.restartData()
        self.tableView.reloadData()
    }
    
}

