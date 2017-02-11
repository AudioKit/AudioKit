//
//  ParticleLab.swift
//  MetalParticles
//
//  Created by Simon Gladman on 04/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
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

import Metal
import UIKit
import MetalPerformanceShaders
import MetalKit

class ParticleLab: MTKView {
    let imageWidth: UInt
    let imageHeight: UInt

    fileprivate var imageWidthFloatBuffer: MTLBuffer!
    fileprivate var imageHeightFloatBuffer: MTLBuffer!

    let bytesPerRow: UInt
    let region: MTLRegion
    let blankBitmapRawData: [UInt8]

    fileprivate var kernelFunction: MTLFunction!
    fileprivate var pipelineState: MTLComputePipelineState!
    fileprivate var defaultLibrary: MTLLibrary! = nil
    fileprivate var commandQueue: MTLCommandQueue! = nil

    fileprivate var threadsPerThreadgroup: MTLSize!
    fileprivate var threadgroupsPerGrid: MTLSize!

    let particleCount: Int
    let alignment: Int = 0x4000
    let particlesMemoryByteSize: Int

    fileprivate var particlesMemory: UnsafeMutableRawPointer?
    fileprivate var particlesVoidPtr: OpaquePointer!
    fileprivate var particlesParticlePtr: UnsafeMutablePointer<Particle>!
    fileprivate var particlesParticleBufferPtr: UnsafeMutableBufferPointer<Particle>!

    fileprivate var gravityWellParticle = Particle(A: Vector4(x: 0, y: 0, z: 0, w: 0),
        B: Vector4(x: 0, y: 0, z: 0, w: 0),
        C: Vector4(x: 0, y: 0, z: 0, w: 0),
        D: Vector4(x: 0, y: 0, z: 0, w: 0))

    fileprivate var frameStartTime: CFAbsoluteTime!
    fileprivate var frameNumber = 0
    let particleSize = MemoryLayout<Particle>.size

    weak var particleLabDelegate: ParticleLabDelegate?

    var particleColor = ParticleColor(R: 1, G: 0.2, B: 0.1, A: 1)
    var dragFactor: Float = 0.95
    var respawnOutOfBoundsParticles = true

    lazy var blur: MPSImageGaussianBlur = {
        [unowned self] in
        return MPSImageGaussianBlur(device: self.device!, sigma: 3)
        }()

    lazy var dilate: MPSImageAreaMax = {
        [unowned self] in
        return MPSImageAreaMax(device: self.device!, kernelWidth: 5, kernelHeight: 5)
        }()

    var clearOnStep = true

    let statusPrefix: String
    var statusPostix: String = ""

    init(width: UInt, height: UInt, numParticles: ParticleCount) {
        particleCount = numParticles.rawValue

        imageWidth = width
        imageHeight = height

        bytesPerRow = 4 * imageWidth

        region = MTLRegionMake2D(0, 0, Int(imageWidth), Int(imageHeight))
        blankBitmapRawData = [UInt8](repeating: 0, count: Int(imageWidth * imageHeight * 4))
        particlesMemoryByteSize = particleCount * MemoryLayout<Particle>.size

        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = NumberFormatter.Style.decimal

        statusPrefix = "\(numParticles.rawValue * 4) Particles"

        super.init(frame: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)), device:  MTLCreateSystemDefaultDevice())

        framebufferOnly = false
        drawableSize = CGSize(width: CGFloat(imageWidth), height: CGFloat(imageHeight))

        setUpParticles()

        setUpMetal()

        isMultipleTouchEnabled = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        free(particlesMemory)
    }

    fileprivate func setUpParticles() {
        posix_memalign(&particlesMemory, alignment, particlesMemoryByteSize)

        particlesVoidPtr = OpaquePointer(particlesMemory)
        particlesParticlePtr = UnsafeMutablePointer<Particle>(particlesVoidPtr)
        particlesParticleBufferPtr = UnsafeMutableBufferPointer(start: particlesParticlePtr, count: particleCount)

        resetParticles(true)
    }

    func resetGravityWells() {
        setGravityWellProperties(gravityWell: .one, normalisedPositionX: 0.5, normalisedPositionY: 0.5, mass: 0, spin: 0)
        setGravityWellProperties(gravityWell: .two, normalisedPositionX: 0.5, normalisedPositionY: 0.5, mass: 0, spin: 0)
        setGravityWellProperties(gravityWell: .three, normalisedPositionX: 0.5, normalisedPositionY: 0.5, mass: 0, spin: 0)
        setGravityWellProperties(gravityWell: .four, normalisedPositionX: 0.5, normalisedPositionY: 0.5, mass: 0, spin: 0)
    }

    func resetParticles(_ edgesOnly: Bool) {
        func rand() -> Float32 {
            return Float(drand48() - 0.5) * 0.005
        }

        let imageWidthDouble = Double(imageWidth)
        let imageHeightDouble = Double(imageHeight)

        for index in particlesParticleBufferPtr.startIndex ..< particlesParticleBufferPtr.endIndex {
            var positionAX = Float(drand48() * imageWidthDouble)
            var positionAY = Float(drand48() * imageHeightDouble)

            var positionBX = Float(drand48() * imageWidthDouble)
            var positionBY = Float(drand48() * imageHeightDouble)

            var positionCX = Float(drand48() * imageWidthDouble)
            var positionCY = Float(drand48() * imageHeightDouble)

            var positionDX = Float(drand48() * imageWidthDouble)
            var positionDY = Float(drand48() * imageHeightDouble)

            if edgesOnly {
                let positionRule = Int(arc4random() % 4)

                if positionRule == 0 {
                    positionAX = 0
                    positionBX = 0
                    positionCX = 0
                    positionDX = 0
                } else if positionRule == 1 {
                    positionAX = Float(imageWidth)
                    positionBX = Float(imageWidth)
                    positionCX = Float(imageWidth)
                    positionDX = Float(imageWidth)
                } else if positionRule == 2 {
                    positionAY = 0
                    positionBY = 0
                    positionCY = 0
                    positionDY = 0
                } else {
                    positionAY = Float(imageHeight)
                    positionBY = Float(imageHeight)
                    positionCY = Float(imageHeight)
                    positionDY = Float(imageHeight)
                }
            }

            let particle = Particle(A: Vector4(x: positionAX, y: positionAY, z: rand(), w: rand()),
                B: Vector4(x: positionBX, y: positionBY, z: rand(), w: rand()),
                C: Vector4(x: positionCX, y: positionCY, z: rand(), w: rand()),
                D: Vector4(x: positionDX, y: positionDY, z: rand(), w: rand()))

            particlesParticleBufferPtr[index] = particle
        }
    }

    fileprivate func setUpMetal() {
        device = MTLCreateSystemDefaultDevice()

        guard let device = device else {
            particleLabDelegate?.particleLabMetalUnavailable()

            return
        }

        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.makeCommandQueue()

        kernelFunction = defaultLibrary.makeFunction(name: "particleRendererShader")

        do {
            try pipelineState = device.makeComputePipelineState(function: kernelFunction!)
        } catch {
            fatalError("newComputePipelineStateWithFunction failed ")
        }

        let threadExecutionWidth = pipelineState.threadExecutionWidth

        threadsPerThreadgroup = MTLSize(width:threadExecutionWidth, height:1, depth:1)
        threadgroupsPerGrid = MTLSize(width:particleCount / threadExecutionWidth, height:1, depth:1)

        frameStartTime = CFAbsoluteTimeGetCurrent()

        var imageWidthFloat = Float(imageWidth)
        var imageHeightFloat = Float(imageHeight)

        imageWidthFloatBuffer =  device.makeBuffer(bytes: &imageWidthFloat, length: MemoryLayout<Float>.size, options: MTLResourceOptions())

        imageHeightFloatBuffer = device.makeBuffer(bytes: &imageHeightFloat, length: MemoryLayout<Float>.size, options: MTLResourceOptions())
    }

    override func draw(_ dirtyRect: CGRect) {
        guard let device = device else {
            particleLabDelegate?.particleLabMetalUnavailable()

            return
        }

        frameNumber += 1

        if frameNumber == 100 {
            let frametime = (CFAbsoluteTimeGetCurrent() - frameStartTime) / 100

            statusPostix = String(format: " at %.1f fps", 1 / frametime)

            frameStartTime = CFAbsoluteTimeGetCurrent()

            frameNumber = 0
        }

        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()

        commandEncoder.setComputePipelineState(pipelineState)

        let particlesBufferNoCopy = device.makeBuffer(bytesNoCopy: particlesMemory!, length: Int(particlesMemoryByteSize),
            options: MTLResourceOptions(), deallocator: nil)

        commandEncoder.setBuffer(particlesBufferNoCopy, offset: 0, at: 0)
        commandEncoder.setBuffer(particlesBufferNoCopy, offset: 0, at: 1)

        let inGravityWell = device.makeBuffer(bytes: &gravityWellParticle, length: particleSize, options: MTLResourceOptions())
        commandEncoder.setBuffer(inGravityWell, offset: 0, at: 2)

        let colorBuffer = device.makeBuffer(bytes: &particleColor, length: MemoryLayout<ParticleColor>.size, options: MTLResourceOptions())
        commandEncoder.setBuffer(colorBuffer, offset: 0, at: 3)

        commandEncoder.setBuffer(imageWidthFloatBuffer, offset: 0, at: 4)
        commandEncoder.setBuffer(imageHeightFloatBuffer, offset: 0, at: 5)

        let dragFactorBuffer = device.makeBuffer(bytes: &dragFactor, length: MemoryLayout<Float>.size, options: MTLResourceOptions())
        commandEncoder.setBuffer(dragFactorBuffer, offset: 0, at: 6)

        let respawnOutOfBoundsParticlesBuffer = device.makeBuffer(bytes: &respawnOutOfBoundsParticles, length: MemoryLayout<Bool>.size, options: MTLResourceOptions())
        commandEncoder.setBuffer(respawnOutOfBoundsParticlesBuffer, offset: 0, at: 7)

        guard let drawable = currentDrawable else {
            commandEncoder.endEncoding()

            print("metalLayer.nextDrawable() returned nil")

            return
        }

        if clearOnStep {
            drawable.texture.replace(region: self.region,
                mipmapLevel: 0,
                withBytes: blankBitmapRawData,
                bytesPerRow: Int(bytesPerRow))
        }

        commandEncoder.setTexture(drawable.texture, at: 0)

        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

        commandEncoder.endEncoding()

        if !clearOnStep {
            let inPlaceTexture = UnsafeMutablePointer<MTLTexture>.allocate(capacity: 1)
            inPlaceTexture.initialize(to: drawable.texture)

            blur.encode(commandBuffer: commandBuffer,
                inPlaceTexture: inPlaceTexture,
                fallbackCopyAllocator: nil)

            dilate.encode(commandBuffer: commandBuffer,
                inPlaceTexture: inPlaceTexture,
                fallbackCopyAllocator: nil)
        }

        commandBuffer.commit()

        drawable.present()

        particleLabDelegate?.particleLabDidUpdate(statusPrefix + statusPostix)
    }

    final func getGravityWellNormalisedPosition(gravityWell: GravityWell) -> (x: Float, y: Float) {
        let returnPoint: (x: Float, y: Float)

        let imageWidthFloat = Float(imageWidth)
        let imageHeightFloat = Float(imageHeight)

        switch gravityWell {
        case .one:
            returnPoint = (x: gravityWellParticle.A.x / imageWidthFloat, y: gravityWellParticle.A.y / imageHeightFloat)

        case .two:
            returnPoint = (x: gravityWellParticle.B.x / imageWidthFloat, y: gravityWellParticle.B.y / imageHeightFloat)

        case .three:
            returnPoint = (x: gravityWellParticle.C.x / imageWidthFloat, y: gravityWellParticle.C.y / imageHeightFloat)

        case .four:
            returnPoint = (x: gravityWellParticle.D.x / imageWidthFloat, y: gravityWellParticle.D.y / imageHeightFloat)
        }

        return returnPoint
    }

    final func setGravityWellProperties(gravityWellIndex: Int, normalisedPositionX: Float, normalisedPositionY: Float, mass: Float, spin: Float) {
        switch gravityWellIndex {
        case 1:
            setGravityWellProperties(gravityWell: .two, normalisedPositionX: normalisedPositionX, normalisedPositionY: normalisedPositionY, mass: mass, spin: spin)

        case 2:
            setGravityWellProperties(gravityWell: .three, normalisedPositionX: normalisedPositionX, normalisedPositionY: normalisedPositionY, mass: mass, spin: spin)

        case 3:
            setGravityWellProperties(gravityWell: .four, normalisedPositionX: normalisedPositionX, normalisedPositionY: normalisedPositionY, mass: mass, spin: spin)

        default:
            setGravityWellProperties(gravityWell: .one, normalisedPositionX: normalisedPositionX, normalisedPositionY: normalisedPositionY, mass: mass, spin: spin)
        }
    }

    final func setGravityWellProperties(gravityWell: GravityWell, normalisedPositionX: Float, normalisedPositionY: Float, mass: Float, spin: Float) {
        let imageWidthFloat = Float(imageWidth)
        let imageHeightFloat = Float(imageHeight)

        switch gravityWell {
        case .one:
            gravityWellParticle.A.x = imageWidthFloat * normalisedPositionX
            gravityWellParticle.A.y = imageHeightFloat * normalisedPositionY
            gravityWellParticle.A.z = mass
            gravityWellParticle.A.w = spin

        case .two:
            gravityWellParticle.B.x = imageWidthFloat * normalisedPositionX
            gravityWellParticle.B.y = imageHeightFloat * normalisedPositionY
            gravityWellParticle.B.z = mass
            gravityWellParticle.B.w = spin

        case .three:
            gravityWellParticle.C.x = imageWidthFloat * normalisedPositionX
            gravityWellParticle.C.y = imageHeightFloat * normalisedPositionY
            gravityWellParticle.C.z = mass
            gravityWellParticle.C.w = spin

        case .four:
            gravityWellParticle.D.x = imageWidthFloat * normalisedPositionX
            gravityWellParticle.D.y = imageHeightFloat * normalisedPositionY
            gravityWellParticle.D.z = mass
            gravityWellParticle.D.w = spin
        }
    }
}

protocol ParticleLabDelegate: NSObjectProtocol {
    func particleLabDidUpdate(_ status: String)
    func particleLabMetalUnavailable()
}

enum GravityWell {
    case one
    case two
    case three
    case four
}

//  Since each Particle instance defines four particles, the visible particle count
//  in the API is four times the number we need to create.
enum ParticleCount: Int {
    case qtrMillion = 65_536
    case halfMillion = 131_072
    case oneMillion =  262_144
    case twoMillion =  524_288
    case fourMillion = 1_048_576
    case eightMillion = 2_097_152
    case sixteenMillion = 4_194_304
}

//  Paticles are split into three classes. The supplied particle color defines one
//  third of the rendererd particles, the other two thirds use the supplied particle
//  color components but shifted to BRG and GBR
struct ParticleColor {
    var R: Float32 = 0
    var G: Float32 = 0
    var B: Float32 = 0
    var A: Float32 = 1
}

struct Particle // Matrix4x4
{
    var A: Vector4 = Vector4(x: 0, y: 0, z: 0, w: 0)
    var B: Vector4 = Vector4(x: 0, y: 0, z: 0, w: 0)
    var C: Vector4 = Vector4(x: 0, y: 0, z: 0, w: 0)
    var D: Vector4 = Vector4(x: 0, y: 0, z: 0, w: 0)
}

// Regular particles use x and y for position and z and w for velocity
// gravity wells use x and y for position and z for mass and w for spin
struct Vector4 {
    var x: Float32 = 0
    var y: Float32 = 0
    var z: Float32 = 0
    var w: Float32 = 0
}
