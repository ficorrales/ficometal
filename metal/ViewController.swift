//
//  ViewController.swift
//  metal
//
//  Created by Fidel Corrales on 1/28/20.
//  Copyright © 2020 Fidel Corrales. All rights reserved.
//

import UIKit
import Metal

class ViewController: UIViewController {

    var lastFrameTimestamp: CFTimeInterval = 0.0

    
    var projectionMatrix: Matrix4!
    var device : MTLDevice!
    var metalLayer : CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    //var objectToDraw: Triangle!
    var objectToDraw: Cube!
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        //creating the metal device referance
        device = MTLCreateSystemDefaultDevice()
      
        //Creating a CAMetalLayer
      
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
      
      
        //Creating a Vertex Buffer
     
        //objectToDraw = Triangle(device: device)
      
        objectToDraw = Cube(device: device)
//        objectToDraw.positionX = 0.0
//        objectToDraw.positionY =  0.0
//        objectToDraw.positionZ = -2.0
//        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45);
//        objectToDraw.scale = 0.5

     
        
      
      
      
        let defaultLibrary = device.makeDefaultLibrary()!
      
        //adding the fragment function to the library
      
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        //adding the vertex function to the library
      
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
          
        //Creating a Render Pipeline
      
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
      
        pipelineStateDescriptor.vertexFunction = vertexProgram
      
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
     
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
          
      
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
      
      
        commandQueue = device.makeCommandQueue()
      
      /*********
       
       Rendering
       
      ************/
      
      
        //Creating a Display Link that calls gameloop everytime the screen refreshes
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))
        timer.add(to: RunLoop.main, forMode: .default)

      
    }
    
    
    
    func render() {
      guard let drawable = metalLayer?.nextDrawable() else { return }
      let worldModelMatrix = Matrix4()
      worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
          
      objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)


    }


    // 1
    @objc func newFrame(displayLink: CADisplayLink){
        
      if lastFrameTimestamp == 0.0
      {
        lastFrameTimestamp = displayLink.timestamp
      }
        
      // 2
      let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
      lastFrameTimestamp = displayLink.timestamp
        
      // 3
      gameloop(timeSinceLastUpdate: elapsed)
    }
      
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        
      // 4
      objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        
      // 5
      autoreleasepool {
        self.render()
      }
    }



}

