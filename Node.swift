//
//  Node.swift
//  ficometal
//
//  Created by Fidel Corrales on 1/30/20.
//  Copyright © 2020 Fidel Corrales. All rights reserved.
//

import Foundation
import QuartzCore
import Metal

class Node {
  
  let device: MTLDevice
  let name: String
  var vertexCount: Int
  var vertexBuffer: MTLBuffer
  var time:CFTimeInterval = 0.0
  
  var positionX: Float = 0.0
  var positionY: Float = 0.0
  var positionZ: Float = 0.0
  
  var rotationX: Float = 0.0
  var rotationY: Float = 0.0
  var rotationZ: Float = 0.0
  var scale: Float     = 1.0
  
  init(name: String, vertices: Array<Vertex>, device: MTLDevice){
    // 1
    var vertexData = Array<Float>()
    for vertex in vertices{
      vertexData += vertex.floatBuffer()
    }
    
    // 2
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
    
    // 3
    self.name = name
    self.device = device
    vertexCount = vertices.count
  }
  
  func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {
    
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
    renderPassDescriptor.colorAttachments[0].storeAction = .store
    
    let commandBuffer = commandQueue.makeCommandBuffer()
    
    let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
    //For now cull mode is used instead of depth buffer
    renderEncoder!.setCullMode(MTLCullMode.front)
    renderEncoder!.setRenderPipelineState(pipelineState)
    renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    
    // 1
    let nodeModelMatrix = self.modelMatrix()
    nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
    // 2
    let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2, options: [])
    // 3
    let bufferPointer = uniformBuffer!.contents()
    // 4
    memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
    memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
    // 5
    renderEncoder!.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
    renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
    renderEncoder!.endEncoding()
    
    commandBuffer?.present(drawable)
    commandBuffer!.commit()
  }
  
  func modelMatrix() -> Matrix4 {
    let matrix = Matrix4()
    matrix.translate(positionX, y: positionY, z: positionZ)
    matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
    matrix.scale(scale, y: scale, z: scale)
    return matrix
  }
  
  func updateWithDelta(delta: CFTimeInterval){
    time += delta
  }
  
}

