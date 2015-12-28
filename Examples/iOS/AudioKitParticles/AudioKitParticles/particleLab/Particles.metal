//
//  Particles.metal
//  MetalParticles
//
//  Created by Simon Gladman on 17/01/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//
//  Thanks to: http://memkite.com/blog/2014/12/15/data-parallel-programming-with-metal-and-swift-for-iphoneipad-gpu/
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

#include <metal_stdlib>
using namespace metal;

float rand(int x, int y, int z);

// Generate a random float in the range [0.0f, 1.0f] using x, y, and z (based on the xor128 algorithm)
float rand(int x, int y, int z)
{
    int seed = x + y * 57 + z * 241;
    seed = (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

kernel void particleRendererShader(texture2d<float, access::write> outTexture [[texture(0)]],
                                   // texture2d<float, access::read> inTexture [[texture(1)]],
                                   
                                   const device float4x4 *inParticles [[ buffer(0) ]],
                                   device float4x4 *outParticles [[ buffer(1) ]],
                                   
                                   constant float4x4 &inGravityWell [[ buffer(2) ]],
                                   
                                   constant float3 &particleColor [[ buffer(3) ]],
                                   
                                   constant float &imageWidth [[ buffer(4) ]],
                                   constant float &imageHeight [[ buffer(5) ]],
                                   
                                   constant float &dragFactor [[ buffer(6) ]],
                                   
                                   constant bool &respawnOutOfBoundsParticles [[ buffer(7) ]],
                                   
                                   uint id [[thread_position_in_grid]])
{
    const float4x4 inParticle = inParticles[id];

    const uint type = id % 3;
    const float typeTweak = 2 + type * 2;
    
    const float4 outColor = float4(type == 0 ? particleColor.r : type == 1 ? particleColor.g : particleColor.b,
                                   type == 0 ? particleColor.b : type == 1 ? particleColor.r : particleColor.g,
                                   type == 0 ? particleColor.g : type == 1 ? particleColor.b : particleColor.r, 1);
    
    // ---
    
    const float2 gravityWellZeroPosition =  float2(inGravityWell[0].x, inGravityWell[0].y);
    const float2 gravityWellOnePosition =   float2(inGravityWell[1].x, inGravityWell[1].y);
    const float2 gravityWellTwoPosition =   float2(inGravityWell[2].x, inGravityWell[2].y);
    const float2 gravityWellThreePosition = float2(inGravityWell[3].x, inGravityWell[3].y);
    
    const float gravityWellZeroMass = inGravityWell[0].z * typeTweak;
    const float gravityWellOneMass = inGravityWell[1].z * typeTweak;
    const float gravityWellTwoMass = inGravityWell[2].z * typeTweak;
    const float gravityWellThreeMass = inGravityWell[3].z * typeTweak;
    
    const float gravityWellZeroSpin = inGravityWell[0].w * typeTweak;
    const float gravityWellOneSpin = inGravityWell[1].w * typeTweak;
    const float gravityWellTwoSpin = inGravityWell[2].w * typeTweak;
    const float gravityWellThreeSpin = inGravityWell[3].w * typeTweak;
    
    // ---
    
    const uint2 particlePositionA(inParticle[0].x, inParticle[0].y);
    
    if (particlePositionA.x > 0 && particlePositionA.y > 0 && particlePositionA.x < imageWidth && particlePositionA.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionA);
    }
    else if (respawnOutOfBoundsParticles)
    {
        inParticle[0].z = 0;
        inParticle[0].w = 0;
        
        inParticle[0].x = rand(id, inParticle[0].x, inParticle[0].y) * imageWidth;
        inParticle[0].y  = rand(id, inParticle[0].y, inParticle[0].x) * imageWidth;
    }
    
    const float2 particlePositionAFloat(inParticle[0].x, inParticle[0].y);
    
    const float distanceZeroA = fast::max(distance_squared(particlePositionAFloat, gravityWellZeroPosition), 0.01);
    const float distanceOneA = fast::max(distance_squared(particlePositionAFloat, gravityWellOnePosition), 0.01);
    const float distanceTwoA = fast::max(distance_squared(particlePositionAFloat, gravityWellTwoPosition), 0.01);
    const float distanceThreeA = fast::max(distance_squared(particlePositionAFloat, gravityWellThreePosition), 0.01);
    
    const float factorAZero =   (gravityWellZeroMass / distanceZeroA);
    const float factorAOne =    (gravityWellOneMass / distanceOneA);
    const float factorATwo =    (gravityWellTwoMass / distanceTwoA);
    const float factorAThree =  (gravityWellThreeMass / distanceThreeA);
    
    const float spinAZero =   (gravityWellZeroSpin / distanceZeroA);
    const float spinAOne =    (gravityWellOneSpin / distanceOneA);
    const float spinATwo =    (gravityWellTwoSpin / distanceTwoA);
    const float spinAThree =  (gravityWellThreeSpin / distanceThreeA);
    
    // ---
    
    const uint2 particlePositionB(inParticle[1].x, inParticle[1].y);
    
    if (particlePositionB.x > 0 && particlePositionB.y > 0 && particlePositionB.x < imageWidth && particlePositionB.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionB);
    }
    else if (respawnOutOfBoundsParticles)
    {
        inParticle[1].z = 0;
        inParticle[1].w = 0;
        
        inParticle[1].x = rand(id, inParticle[1].x, inParticle[1].y) * imageWidth;
        inParticle[1].y = rand(id, inParticle[1].y, inParticle[1].x) * imageWidth;
    }
    
    const float2 particlePositionBFloat(inParticle[1].x, inParticle[1].y);
    
    const float distanceZeroB = fast::max(distance_squared(particlePositionBFloat, gravityWellZeroPosition), 0.01);
    const float distanceOneB = fast::max(distance_squared(particlePositionBFloat, gravityWellOnePosition), 0.01);
    const float distanceTwoB = fast::max(distance_squared(particlePositionBFloat, gravityWellTwoPosition), 0.01);
    const float distanceThreeB = fast::max(distance_squared(particlePositionBFloat, gravityWellThreePosition), 0.01);
    
    const float factorBZero =   (gravityWellZeroMass / distanceZeroB);
    const float factorBOne =    (gravityWellOneMass / distanceOneB);
    const float factorBTwo =    (gravityWellTwoMass / distanceTwoB);
    const float factorBThree =  (gravityWellThreeMass / distanceThreeB);
    
    const float spinBZero =   (gravityWellZeroSpin / distanceZeroB);
    const float spinBOne =    (gravityWellOneSpin / distanceOneB);
    const float spinBTwo =    (gravityWellTwoSpin / distanceTwoB);
    const float spinBThree =  (gravityWellThreeSpin / distanceThreeB);
    
    // ---
    
    
    const uint2 particlePositionC(inParticle[2].x, inParticle[2].y);
    
    if (particlePositionC.x > 0 && particlePositionC.y > 0 && particlePositionC.x < imageWidth && particlePositionC.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionC);
    }
    else if (respawnOutOfBoundsParticles)
    {
        inParticle[2].z = 0;
        inParticle[2].w = 0;
        
        inParticle[2].x = rand(id, inParticle[2].x, inParticle[2].y) * imageWidth;
        inParticle[2].y = rand(id, inParticle[2].y, inParticle[2].x) * imageWidth;
    }
    
    const float2 particlePositionCFloat(inParticle[2].x, inParticle[2].y);
    
    const float distanceZeroC = fast::max(distance_squared(particlePositionCFloat, gravityWellZeroPosition), 0.01);
    const float distanceOneC = fast::max(distance_squared(particlePositionCFloat, gravityWellOnePosition), 0.01);
    const float distanceTwoC = fast::max(distance_squared(particlePositionCFloat, gravityWellTwoPosition), 0.01);
    const float distanceThreeC = fast::max(distance_squared(particlePositionCFloat, gravityWellThreePosition), 0.01);
    
    const float factorCZero =   (gravityWellZeroMass / distanceZeroC);
    const float factorCOne =    (gravityWellOneMass / distanceOneC);
    const float factorCTwo =    (gravityWellTwoMass / distanceTwoC);
    const float factorCThree =  (gravityWellThreeMass / distanceThreeC);
    
    const float spinCZero =   (gravityWellZeroSpin / distanceZeroC);
    const float spinCOne =    (gravityWellOneSpin / distanceOneC);
    const float spinCTwo =    (gravityWellTwoSpin / distanceTwoC);
    const float spinCThree =  (gravityWellThreeSpin / distanceThreeC);
    
    // ---
    
    
    const uint2 particlePositionD(inParticle[3].x, inParticle[3].y);
    
    if (particlePositionD.x > 0 && particlePositionD.y > 0 && particlePositionD.x < imageWidth && particlePositionD.y < imageHeight)
    {
        outTexture.write(outColor, particlePositionD);
    }
    else if (respawnOutOfBoundsParticles)
    {
        inParticle[3].z = 0;
        inParticle[3].w = 0;
        
        inParticle[3].x = rand(id, inParticle[3].x, inParticle[3].y) * imageWidth;
        inParticle[3].y = rand(id, inParticle[3].y, inParticle[3].x) * imageWidth;
    }
    
    const float2 particlePositionDFloat(inParticle[3].x, inParticle[3].y);
    
    const float distanceZeroD = fast::max(distance_squared(particlePositionDFloat, gravityWellZeroPosition), 0.01);
    const float distanceOneD = fast::max(distance_squared(particlePositionDFloat, gravityWellOnePosition), 0.01);
    const float distanceTwoD = fast::max(distance_squared(particlePositionDFloat, gravityWellTwoPosition), 0.01);
    const float distanceThreeD = fast::max(distance_squared(particlePositionDFloat, gravityWellThreePosition), 0.01);
    
    const float factorDZero =   (gravityWellZeroMass / distanceZeroD);
    const float factorDOne =    (gravityWellOneMass / distanceOneD);
    const float factorDTwo =    (gravityWellTwoMass / distanceTwoD);
    const float factorDThree =  (gravityWellThreeMass / distanceThreeD);
    
    const float spinDZero =   (gravityWellZeroSpin / distanceZeroD);
    const float spinDOne =    (gravityWellOneSpin / distanceOneD);
    const float spinDTwo =    (gravityWellTwoSpin / distanceTwoD);
    const float spinDThree =  (gravityWellThreeSpin / distanceThreeD);
    // ---
    
    float4x4 outParticle;
    
    outParticle[0] = {
        inParticle[0].x + inParticle[0].z,
        inParticle[0].y + inParticle[0].w,
        
        (inParticle[0].z * dragFactor) +
        ((inGravityWell[0].x - inParticle[0].x) * factorAZero) +
        ((inGravityWell[1].x - inParticle[0].x) * factorAOne) +
        ((inGravityWell[2].x - inParticle[0].x) * factorATwo) +
        ((inGravityWell[3].x - inParticle[0].x) * factorAThree) +
        
        ((inGravityWell[0].y - inParticle[0].y) * spinAZero) +
        ((inGravityWell[1].y - inParticle[0].y) * spinAOne) +
        ((inGravityWell[2].y - inParticle[0].y) * spinATwo) +
        ((inGravityWell[3].y - inParticle[0].y) * spinAThree),
        
        (inParticle[0].w * dragFactor) +
        ((inGravityWell[0].y - inParticle[0].y) * factorAZero) +
        ((inGravityWell[1].y - inParticle[0].y) * factorAOne) +
        ((inGravityWell[2].y - inParticle[0].y) * factorATwo) +
        ((inGravityWell[3].y - inParticle[0].y) * factorAThree)+
        
        ((inGravityWell[0].x - inParticle[0].x) * -spinAZero) +
        ((inGravityWell[1].x - inParticle[0].x) * -spinAOne) +
        ((inGravityWell[2].x - inParticle[0].x) * -spinATwo) +
        ((inGravityWell[3].x - inParticle[0].x) * -spinAThree),
    };
    
    
    outParticle[1] = {
        inParticle[1].x + inParticle[1].z,
        inParticle[1].y + inParticle[1].w,
        
        (inParticle[1].z * dragFactor) +
        ((inGravityWell[0].x - inParticle[1].x) * factorBZero) +
        ((inGravityWell[1].x - inParticle[1].x) * factorBOne) +
        ((inGravityWell[2].x - inParticle[1].x) * factorBTwo) +
        ((inGravityWell[3].x - inParticle[1].x) * factorBThree) +
        
        ((inGravityWell[0].y - inParticle[1].y) * spinBZero) +
        ((inGravityWell[1].y - inParticle[1].y) * spinBOne) +
        ((inGravityWell[2].y - inParticle[1].y) * spinBTwo) +
        ((inGravityWell[3].y - inParticle[1].y) * spinBThree),
        
        (inParticle[1].w * dragFactor) +
        ((inGravityWell[0].y - inParticle[1].y) * factorBZero) +
        ((inGravityWell[1].y - inParticle[1].y) * factorBOne) +
        ((inGravityWell[2].y - inParticle[1].y) * factorBTwo) +
        ((inGravityWell[3].y - inParticle[1].y) * factorBThree) +
        
        ((inGravityWell[0].x - inParticle[1].x) * -spinBZero) +
        ((inGravityWell[1].x - inParticle[1].x) * -spinBOne) +
        ((inGravityWell[2].x - inParticle[1].x) * -spinBTwo) +
        ((inGravityWell[3].x - inParticle[1].x) * -spinBThree),
    };
    
    
    outParticle[2] = {
        inParticle[2].x + inParticle[2].z,
        inParticle[2].y + inParticle[2].w,
        
        (inParticle[2].z * dragFactor) +
        ((inGravityWell[0].x - inParticle[2].x) * factorCZero) +
        ((inGravityWell[1].x - inParticle[2].x) * factorCOne) +
        ((inGravityWell[2].x - inParticle[2].x) * factorCTwo) +
        ((inGravityWell[3].x - inParticle[2].x) * factorCThree) +
        
        ((inGravityWell[0].y - inParticle[2].y) * spinCZero) +
        ((inGravityWell[1].y - inParticle[2].y) * spinCOne) +
        ((inGravityWell[2].y - inParticle[2].y) * spinCTwo) +
        ((inGravityWell[3].y - inParticle[2].y) * spinCThree),
        
        (inParticle[2].w * dragFactor) +
        ((inGravityWell[0].y - inParticle[2].y) * factorCZero) +
        ((inGravityWell[1].y - inParticle[2].y) * factorCOne) +
        ((inGravityWell[2].y - inParticle[2].y) * factorCTwo) +
        ((inGravityWell[3].y - inParticle[2].y) * factorCThree) +
        
        ((inGravityWell[0].x - inParticle[2].x) * -spinCZero) +
        ((inGravityWell[1].x - inParticle[2].x) * -spinCOne) +
        ((inGravityWell[2].x - inParticle[2].x) * -spinCTwo) +
        ((inGravityWell[3].x - inParticle[2].x) * -spinCThree),
    };
    
    
    outParticle[3] = {
        inParticle[3].x + inParticle[3].z,
        inParticle[3].y + inParticle[3].w,
        
        (inParticle[3].z * dragFactor) +
        ((inGravityWell[0].x - inParticle[3].x) * factorDZero) +
        ((inGravityWell[1].x - inParticle[3].x) * factorDOne) +
        ((inGravityWell[2].x - inParticle[3].x) * factorDTwo) +
        ((inGravityWell[3].x - inParticle[3].x) * factorDThree) +
        
        ((inGravityWell[0].y - inParticle[3].y) * spinDZero) +
        ((inGravityWell[1].y - inParticle[3].y) * spinDOne) +
        ((inGravityWell[2].y - inParticle[3].y) * spinDTwo) +
        ((inGravityWell[3].y - inParticle[3].y) * spinDThree),
        
        (inParticle[3].w * dragFactor) +
        ((inGravityWell[0].y - inParticle[3].y) * factorDZero) +
        ((inGravityWell[1].y - inParticle[3].y) * factorDOne) +
        ((inGravityWell[2].y - inParticle[3].y) * factorDTwo) +
        ((inGravityWell[3].y - inParticle[3].y) * factorDThree) +
        
        ((inGravityWell[0].x - inParticle[3].x) * -spinDZero) +
        ((inGravityWell[1].x - inParticle[3].x) * -spinDOne) +
        ((inGravityWell[2].x - inParticle[3].x) * -spinDTwo) +
        ((inGravityWell[3].x - inParticle[3].x) * -spinDThree),
    };
    
    outParticles[id] = outParticle;
    
    
    // ----
    /*
     uint2 textureCoordinate(fast::floor(id / imageWidth),id % int(imageWidth));
     
     if (textureCoordinate.x < imageWidth && textureCoordinate.y < imageWidth)
     {
     float4 accumColor = inTexture.read(textureCoordinate);
     
     accumColor.rgb = (accumColor.rgb * 0.9f);
     accumColor.a = 1.0f;
     
     outTexture.write(accumColor, textureCoordinate);
     }
     */
    
}