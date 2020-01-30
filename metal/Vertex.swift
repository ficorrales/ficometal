//
//  vertex.swift
//  metal
//
//  Created by Fidel Corrales on 1/29/20.
//  Copyright © 2020 Fidel Corrales. All rights reserved.
//

import Foundation


struct Vertex{

  var x,y,z: Float     // position data
  var r,g,b,a: Float   // color data

  func floatBuffer() -> [Float] {
    return [x,y,z,r,g,b,a]
  }

}
