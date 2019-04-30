//
//  QuestionFactory.swift
//  MathsTraining
//
//  Created by admin on 29/04/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

class QuestionFactory{
    private var questions = [Question]()
    
    // private(set) indica que set es privado
    // y no tiene acceso desde fuera de la clase.
    // pero la variable sigue siendo publica.
    private(set) var score = 0
    
    init(){
        addNewQuestion()
    }
    
    //añade las preguntas al inicio del array
    func addNewQuestion(){
        questions.insert(createQuestion(), at: 0)
    }
    
    
    func getQuestionAt(position: Int) -> Question? {
        if(position < 0 || position >= questions.count){
            return nil
        }
        return self.questions[position]
    }
    
    func numberOfQuestions()->Int{
        return questions.count
    }
    
    func createQuestion()-> Question{
        
        var question = ""
        var correctAnswer = 0
        
        while true{
            let firstNumber = Int.random(in: 0...9)
            let secondNumber = Int.random(in: 0...9)
            
            if Bool.random(){
                //generamos operacion suma
                // solo si es menor de diez porque solo se acepta un digito como respuesta
                let result = firstNumber + secondNumber
                if result < 10 {
                    question = "\(firstNumber) + \(secondNumber)"
                    correctAnswer = result
                    break
                }
            }else{
                //generamos operacion resta
                let result = firstNumber - secondNumber
                if result < 10 {
                    question = "\(firstNumber) - \(secondNumber)"
                    correctAnswer = result
                    break
                }
            }
            
        }
        return Question(text: question, answer: correctAnswer, userAnswer: nil)
    }
}
