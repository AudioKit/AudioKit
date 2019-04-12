# Render Tap

The render tap allows you to call a block right before rendering audio and immediately after render audio. 

These blocks will be called from the render thread, so no locks, Swift functions or Objective-C messages from within this block.  Make sure not to capture self.