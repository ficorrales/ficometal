//
//  Shaders.metal
//  metal
//
//  Created by Fidel Corrales on 1/28/20.
//  Copyright © 2020 Fidel Corrales. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
  packed_float3 position;
  packed_float4 color;
};


struct VertexOut{
  float4 position [[position]];
  float4 color;
};

/*
 
 You add a second parameter for the uniform buffer, marking that it’s incoming in slot 1 to match up with the code you wrote earlier.
 You then get a handle to the model matrix in the uniforms structure.
 To apply the model transformation to a vertex, you simply multiply the vertex position by the model matrix.
 
**************************/


struct Uniforms{
  float4x4 modelMatrix;
  float4x4 projectionMatrix;
};



vertex VertexOut basic_vertex(
  const device VertexIn* vertex_array [[ buffer(0) ]],
  const device Uniforms&  uniforms    [[ buffer(1) ]],           //1
  unsigned int vid [[ vertex_id ]]) {

  float4x4 mv_Matrix = uniforms.modelMatrix;                     //2
  float4x4 proj_Matrix = uniforms.projectionMatrix;



  VertexIn VertexIn = vertex_array[vid];

  VertexOut VertexOut;
  VertexOut.position = proj_Matrix * mv_Matrix * float4(VertexIn.position,1);
  VertexOut.color = VertexIn.color;

  return VertexOut;
}




/*
 
 The vertex shader passes the VertexOut structure, but its values will be interpolated based on the position of the fragment you’re rendering. More on this later.
 Now you simply return the color for the current fragment instead of the hardcoded white color.
 
**************************/

fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]) {  //1
  return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]); //2
}
