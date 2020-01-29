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

   var device : MTLDevice!
    var metalLayer : CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    
    let vertexData: [Float] = [
       0.0,  1.0, 0.0,
      -1.0, -1.0, 0.0,
       1.0, -1.0, 0.0
    ]
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
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
      let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
      vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
      
      
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
      timer = CADisplayLink(target: self, selector: #selector(gameloop))
      timer.add(to: RunLoop.main, forMode: .default)

      
    }
    
    func render() {
      
      guard let drawable = metalLayer?.nextDrawable() else { return }
      let renderPassDescriptor = MTLRenderPassDescriptor()
      renderPassDescriptor.colorAttachments[0].texture = drawable.texture
      renderPassDescriptor.colorAttachments[0].loadAction = .clear
      renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
        red: 0.0,
        green: 104.0/255.0,
        blue: 55.0/255.0,
        alpha: 1.0)
      
      //Creating a Command Buffer
      let commandBuffer = commandQueue.makeCommandBuffer()!
      
    ///  The list of render commands that you wish to execute for this frame. Nothing actually happens until you commit the command buffer, giving you fine-grained control over when things occur
    ///  A command buffer contains one or more render commands. You’ll create one of these next.
      
      //Creating a Render Command Encoder
      let renderEncoder = commandBuffer
        .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
      renderEncoder.setRenderPipelineState(pipelineState)
      renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
      renderEncoder
        .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
      renderEncoder.endEncoding()
      
       //Committing Your Command Buffer
       commandBuffer.present(drawable)
       commandBuffer.commit()

      
    }

    @objc func gameloop() {
      autoreleasepool {
        self.render()
      }
    }


}

