# AudioKit Operations

AudioKit operations are different than AudioKit nodes in that operations are components that build one generator or effect processor node.  Because you can connect operations to other operations as both audio and control inputs, you can create interesting and dynamic sounds. 

Operations are actually bits of [Sporth code](https://github.com/PaulBatchelor/Sporth) that get chained into a Sporth program. 

The canonical example is creating a siren sound by connecting to sine generators:

```
    let generator = AKOperationGenerator {
        let sine = AKOperation.sineWave(frequency: 1)
        let siren = AKOperation.sineWave(frequency: sine * 100 + 400)
        return siren
    }
```
    
