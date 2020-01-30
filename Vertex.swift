//
//  Vertex.swift
//  ficometal
//
//  Created by Fidel Corrales on 1/30/20.
//  Copyright © 2020 Fidel Corrales. All rights reserved.
//

//struct Vertex{
//
//  var x,y,z: Float     // position data
//  var r,g,b,a: Float   // color data
//
//  func floatBuffer() -> [Float] {
//    return [x,y,z,r,g,b,a]
//  }
//
//}

struct Vertex{
  
  var x,y,z: Float     // position data
  var r,g,b,a: Float   // color data
  var s,t: Float       // texture coordinates
  
  func floatBuffer() -> [Float] {
    return [x,y,z,r,g,b,a,s,t]
  }
  
};

