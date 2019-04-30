//
//  DrawingImageView.swift
//  MathsTraining
//
//  Created by admin on 22/04/2019.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class DrawingImageView: UIImageView {


    //referencia debil, para evitar referencias mutua
    weak var delegate: ViewController?
    var currentTouchPosition: CGPoint?
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
        
    }
    */
    
    func draw(from start: CGPoint, to end: CGPoint){
        let rendered = UIGraphicsImageRenderer(size: self.bounds.size)
        //crea la imagen, dentro de la imagen de la imageView con los limites de esta, que se indica con los bounds
        self.image = rendered.image{ ctx in
            self.image?.draw(in: self.bounds)
            
            //definir:
            //color
            UIColor.darkGray.setStroke()
            //linea
            ctx.cgContext.setLineCap(.round)
            //tamaño linea
            ctx.cgContext.setLineWidth(12)
            
            //crea el digujo:
            //va al inicio
            ctx.cgContext.move(to: start)
            //hasta el final
            ctx.cgContext.addLine(to: end)
            //ahora lo dibuja
            ctx.cgContext.strokePath()
            
        }
        
    }
    
    
    //pone el dedo
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(touches.first?.location(in: self))
        
        super .touchesBegan(touches, with: event)
        //obtiene donde pone el dedo para empezar.
        self.currentTouchPosition = touches.first?.location(in: self)
        
        // si se pulsa una segunda vez, antes que el reatrdo (perform) llame a la funcion
        // numberDraw...., para el perform para no llamarlo dos veces.
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    //mueve el dedo
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(touches.first?.location(in: self))
        super .touchesMoved(touches, with: event)
        //obtiene el utimo toque obtenido.
        guard let newTouchPoint = touches.first?.location(in: self) else {
            return
        }
        //obtiene el primer punto.
        guard let previousTouchPoint = self.currentTouchPosition else {
            return
        }
        draw(from: previousTouchPoint, to: newTouchPoint)
        self.currentTouchPosition = newTouchPoint
    }
    
    //levanta el dedo
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(touches.first?.location(in: self))
        super .touchesEnded(touches, with: event)
        self.currentTouchPosition = nil
        
        //creamos un retardo de medio segudo antes de llamar al numberDrawOnSreen para asegurar que se ha acabado de
        // escribir el numero.
        // las funciones llamadas desde un perform tienen que ser @objc
        perform(#selector(numberDrawOnScreen), with: nil, afterDelay: 0.5)
        
        
    }
    
    @objc func numberDrawOnScreen(){
        
        //comprueba que existe la imagen, que es el numero dibujado por el usuario
        guard let image = self.image else {
            return
        }
        //transforma a un tamaño de 28*28 que es el tamaño de las imagenes del modelo AI
        //indica el tamaño del "lienzo"
        let drawRect = CGRect(x: 0, y: 0, width: 28, height: 28)
        let format = UIGraphicsImageRendererFormat( )
        //para que mapee la imagen al tamaño indicado en el CGRect es decir 28*28
        format.scale = 1
        
        // crea el render con el tamaño del "lienzo" y el escalado indicado
        let renderer = UIGraphicsImageRenderer(bounds: drawRect, format: format)
        
        //creamos la imagen y añadimos un fondo blanco.
        // ctx es contexto
        let imageWithWhiteBackground = renderer.image{ ctx in
            //fondo blanco
            UIColor.white.setFill()
            //pinta
            ctx.fill(bounds)
            image.draw(in: drawRect)
        }
        
        //pasamos la imagen de CoreGrafich a CoreImage
        let ciImage = CIImage(cgImage: imageWithWhiteBackground.cgImage!)
        
        //hacemos inversion de color para dejar la imagen como en el modelo, que era fondo negro y dibujo
        //blanco
        if let filter = CIFilter(name: "CIColorInvert"){
            // define la CIImage con¡mo imagen a ser filtrada (transformada)
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            //contexto para llevar a cabo el filtro, la conversion
            let context = CIContext(options: nil)
            
            
            // si nos deja hacer la conversion de la CIImage..
            if let outImage = filter.outputImage{
                //intentamos hacer la creacion a CGImage
                if let imageRef = context.createCGImage(outImage, from: ciImage.extent){
                    //convertimos el imageRef en un UIImae con el que poder trabajar
                    let resultImage = UIImage(cgImage: imageRef)
                    
                    //pasamos el resultado al delegado viewControler
                    self.delegate?.numberDrawn(resultImage)
                }
            }
        }
        
        
        
    }

}
