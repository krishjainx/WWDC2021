
// #-hidden-code
import AVFoundation
import BookCore
import CoreGraphics
import GameplayKit
import PlaygroundSupport
import SpriteKit
import UIKit

public extension UIImage {
    static func pixel(ofColor color: UIColor) -> UIImage {
        let pixel = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

        UIGraphicsBeginImageContext(pixel.size)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        context.setFillColor(color.cgColor)
        context.fill(pixel)

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}

extension UIButton {
    func setBackgroundColor(_ backgroundColor: UIColor, for state: UIControl.State) {
        setBackgroundImage(.pixel(ofColor: backgroundColor), for: state)
    }
}

var thePercentageOfScreenX = CGFloat.random(in: 0.3..<0.7)
var torqueValue: CGFloat = 0
var prizeIsWhat: String = "Pineapple"

let fontURL = Bundle.main.url(forResource: "GreatVibes-Regular", withExtension: "ttf")
CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)

public class GameView: SKView {
    var gameScene: GameScene { return self.scene as! GameScene }
    override public init(frame: CGRect) {
        super.init(frame: frame)

        // Configure the view.
        showsFPS = true
        showsNodeCount = true
        ignoresSiblingOrder = true

        // Create and configure the scene.
        let scene = GameScene(size: frame.size)
        scene.scaleMode = .aspectFill

//        BUTTON STUFF

        let button = UIButton(type: .system)
        button.frame = CGRect(x: self.frame.size.width / 2, y: 1200, width: 200, height: 80)
        button.tintColor = .white
        button.setBackgroundColor(.red, for: .normal)
        button.setTitle("New game", for: .normal)
        button.titleLabel?.font = UIFont(name: "GreatVibes-Regular", size: 40)!
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        addSubview(button)

        let button1 = UIButton(type: .system)
        button1.frame = CGRect(x: self.frame.size.width / 2, y: 1100, width: 200, height: 80)
        button1.tintColor = .white
        button1.setBackgroundColor(.red, for: .normal)
        button1.setTitle("🍬", for: .normal)
        button1.titleLabel?.font = UIFont(name: "Arial", size: 80)
        button1.layer.cornerRadius = 20
        button1.layer.masksToBounds = true
        button1.addTarget(self, action: #selector(makeCandy), for: .touchUpInside)
        addSubview(button1)

        let button2 = UIButton(type: .system)
        button2.frame = CGRect(x: self.frame.size.width / 2 + 210, y: 1100, width: 200, height: 80)
        button2.tintColor = .white
        button2.setBackgroundColor(.blue, for: .normal)
        button2.setTitle("🍐", for: .normal)
        button2.titleLabel?.font = UIFont(name: "Arial", size: 80)
        button2.layer.cornerRadius = 20
        button2.layer.masksToBounds = true
        button2.addTarget(self, action: #selector(makePear), for: .touchUpInside)
        addSubview(button2)

        let button3 = UIButton(type: .system)
        button3.frame = CGRect(x: self.frame.size.width / 2 - 210, y: 1100, width: 200, height: 80)
        button3.tintColor = .white
        button3.setBackgroundColor(.blue, for: .normal)
        button3.setTitle("🍫", for: .normal)
        button3.titleLabel?.font = UIFont(name: "Arial", size: 80)
        button3.layer.cornerRadius = 20
        button3.layer.masksToBounds = true
        button3.addTarget(self, action: #selector(makeChocolate), for: .touchUpInside)
        addSubview(button3)

//        ENDBUTTON STUFF

        // Present the scene.
        presentScene(scene)
    }

    @objc func makePear() {
        prizeIsWhat = "Pineapple"
        gameScene.switchToNewGame(withTransition: .fade(withDuration: 0.5))
    }

    @objc func makeChocolate() {
        prizeIsWhat = "Chocolate"
        gameScene.switchToNewGame(withTransition: .fade(withDuration: 0.5))
    }

    @objc func makeCandy() {
        prizeIsWhat = "Candy"
        gameScene.switchToNewGame(withTransition: .fade(withDuration: 0.5))
    }

    @objc func buttonClicked() {
        gameScene.switchToNewGame(withTransition: .fade(withDuration: 0.5))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VineNode: SKNode {
    private let length: Int
    private let anchorPoint: CGPoint
    private var vineSegments: [SKNode] = []

    init(length: Int, anchorPoint: CGPoint, name: String) {
        self.length = length
        self.anchorPoint = anchorPoint

        super.init()

        self.name = name
    }

    required init?(coder aDecoder: NSCoder) {
        length = aDecoder.decodeInteger(forKey: "length")
        anchorPoint = aDecoder.decodeCGPoint(forKey: "anchorPoint")

        super.init(coder: aDecoder)
    }

    func addToScene(_ scene: SKScene) {
        // add vine to scene
        zPosition = Layer.vine
        scene.addChild(self)

        // create vine holder
        let vineHolder = SKSpriteNode(imageNamed: ImageName.vineHolder)
        vineHolder.position = anchorPoint
        vineHolder.zPosition = 1

        addChild(vineHolder)

        vineHolder.physicsBody = SKPhysicsBody(circleOfRadius: vineHolder.size.width / 2)
        vineHolder.physicsBody?.isDynamic = false
        vineHolder.physicsBody?.categoryBitMask = PhysicsCategory.vineHolder
        vineHolder.physicsBody?.collisionBitMask = 0

        // add each of the vine parts
        for i in 0..<length {
            let vineSegment = SKSpriteNode(imageNamed: ImageName.vineTexture)
            let offset = vineSegment.size.height * CGFloat(i + 1)
            vineSegment.position = CGPoint(x: anchorPoint.x, y: anchorPoint.y - offset)
            vineSegment.name = name

            vineSegments.append(vineSegment)
            addChild(vineSegment)

            vineSegment.physicsBody = SKPhysicsBody(rectangleOf: vineSegment.size)
            vineSegment.physicsBody?.categoryBitMask = PhysicsCategory.vine
            vineSegment.physicsBody?.collisionBitMask = PhysicsCategory.vineHolder
        }

        // set up joint for vine holder
        let joint = SKPhysicsJointPin.joint(
            withBodyA: vineHolder.physicsBody!,
            bodyB: vineSegments[0].physicsBody!,
            anchor: CGPoint(
                x: vineHolder.frame.midX,
                y: vineHolder.frame.midY))

        scene.physicsWorld.add(joint)

        // set up joints between vine parts
        for i in 1..<length {
            let nodeA = vineSegments[i - 1]
            let nodeB = vineSegments[i]
            let joint = SKPhysicsJointPin.joint(
                withBodyA: nodeA.physicsBody!,
                bodyB: nodeB.physicsBody!,
                anchor: CGPoint(
                    x: nodeA.frame.midX,
                    y: nodeA.frame.minY))
            joint.frictionTorque = torqueValue
            scene.physicsWorld.add(joint)
        }
    }

    func attachToPrize(_ prize: SKSpriteNode) {
        let lastNode = vineSegments.last!
        lastNode.position = CGPoint(x: prize.position.x,
                                    y: prize.position.y + prize.size.height * 0.1)

        // set up connecting joint
        let joint = SKPhysicsJointPin.joint(withBodyA: lastNode.physicsBody!,
                                            bodyB: prize.physicsBody!,
                                            anchor: lastNode.position)

        prize.scene?.physicsWorld.add(joint)
    }
}

struct VineData: Decodable {
    let length: Int
    let relAnchorPoint: CGPoint
}

public enum ImageName {
    static let background = "Background"
    static let ground = "Ground"
    static let water = "Water"
    static let vineTexture = "VineTexture"
    static let vineHolder = "VineHolder"
    static let crocMouthClosed = "CrocMouthClosed"
    static let crocMouthOpen = "CrocMouthOpen"
    static let crocMask = "CrocMask"
    static let prize = prizeIsWhat
    static let prizeMask = "PineappleMask"
}

enum SoundFile {
    static let backgroundMusic = "CheeZeeJungle.caf"
    static let slice = "Slice.caf"
    static let splash = "Splash.caf"
    static let nomNom = "NomNom.caf"
}

public enum Layer {
    static let background: CGFloat = 0
    static let crocodile: CGFloat = 1
    static let vine: CGFloat = 1
    static let prize: CGFloat = 2
    static let foreground: CGFloat = 3
}

public enum PhysicsCategory {
    static let crocodile: UInt32 = 1
    static let vineHolder: UInt32 = 2
    static let vine: UInt32 = 4
    static let prize: UInt32 = 8
}

public enum GameConfiguration {
    static let vineDataFile = "VineData.plist"
    static let canCutMultipleVinesAtOnce = false
}

public enum Scene {
    static let particles = "Particle.sks"
}

class GameScene: SKScene {
    private var crocodile: SKSpriteNode!
    private var prize: SKSpriteNode!
    private var particles: SKEmitterNode?
    private var didCutVine = false
    
    private static var backgroundMusicPlayer: AVAudioPlayer!
    
    private var sliceSoundAction: SKAction!
    private var splashSoundAction: SKAction!
    private var nomNomSoundAction: SKAction!
    
    private var isLevelOver = false
 

    override func didMove(to view: SKView) {
        setUpPhysics()
        setUpScenery()
        setUpPrize()
        setUpVines()
        setUpCrocodile()
        setUpAudio()
    }

    private func setUpPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        physicsWorld.speed = 1.0
    }

    private func setUpScenery() {
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background
        background.size = CGSize(width: size.width, height: size.height)
        addChild(background)

        let water = SKSpriteNode(imageNamed: "Water")
        water.anchorPoint = CGPoint(x: 0, y: 0)
        water.position = CGPoint(x: 0, y: 0)
        water.zPosition = Layer.foreground
        water.size = CGSize(width: size.width, height: size.height * 0.2139)
        addChild(water)
    }

    private func setUpPrize() {
        prize = SKSpriteNode(imageNamed: prizeIsWhat)
        prize.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        prize.zPosition = Layer.prize
        prize.physicsBody = SKPhysicsBody(circleOfRadius: prize.size.height / 2)
        prize.physicsBody?.categoryBitMask = PhysicsCategory.prize
        prize.physicsBody?.collisionBitMask = 0
        prize.physicsBody?.density = 0.5

        addChild(prize)
    }

    private func setUpVines() {
        let decoder = PropertyListDecoder()
        guard
            let dataFile = Bundle.main.url(
                forResource: GameConfiguration.vineDataFile,
                withExtension: nil),
            let data = try? Data(contentsOf: dataFile),
            let vines = try? decoder.decode([VineData].self, from: data)
        else {
            return
        }

        for (i, vineData) in vines.enumerated() {
            let anchorPoint = CGPoint(
                x: vineData.relAnchorPoint.x * size.width,
                y: vineData.relAnchorPoint.y * size.height)
            let vine = VineNode(
                length: vineData.length,
                anchorPoint: anchorPoint,
                name: "\(i)")

            // 2 add to scene
            vine.addToScene(self)

            // 3 connect the other end of the vine to the prize
            vine.attachToPrize(prize)
        }
    }

    private func setUpCrocodile() {
        crocodile = SKSpriteNode(imageNamed: "CrocMouthClosed")

        crocodile.position = CGPoint(x: size.width * thePercentageOfScreenX, y: size.height * 0.312)
        crocodile.zPosition = Layer.crocodile
        crocodile.physicsBody = SKPhysicsBody(
            texture: SKTexture(imageNamed: "CrocMask"),
            size: crocodile.size)
        crocodile.physicsBody?.categoryBitMask = PhysicsCategory.crocodile
        crocodile.physicsBody?.collisionBitMask = 0
        crocodile.physicsBody?.contactTestBitMask = PhysicsCategory.prize
        crocodile.physicsBody?.isDynamic = false

        addChild(crocodile)

        animateCrocodile()
        let duration = Double.random(in: 2 ... 4)
        let open = SKAction.setTexture(SKTexture(imageNamed: "CrocMouthOpen"))
        let wait = SKAction.wait(forDuration: duration)
        let close = SKAction.setTexture(SKTexture(imageNamed: "CrocMouthClosed"))
        let sequence = SKAction.sequence([wait, open, wait, close])

        crocodile.run(.repeatForever(sequence))
    }

    private func animateCrocodile() {}

    private func runNomNomAnimation(withDelay delay: TimeInterval) {
        crocodile.removeAllActions()

        let closeMouth = SKAction.setTexture(SKTexture(imageNamed: "CrocMouthClosed"))
        let wait = SKAction.wait(forDuration: delay)
        let openMouth = SKAction.setTexture(SKTexture(imageNamed: "CrocMouthOpen"))
        let sequence = SKAction.sequence([closeMouth, wait, openMouth, wait, closeMouth])

        crocodile.run(sequence)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didCutVine = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let startPoint = touch.location(in: self)
            let endPoint = touch.previousLocation(in: self)

            // check if vine cut
            scene?.physicsWorld.enumerateBodies(
                alongRayStart: startPoint,
                end: endPoint,
                using: { body, _, _, _ in
                    self.checkIfVineCut(withBody: body)
                })

            // produce some nice particles
            showMoveParticles(touchPosition: startPoint)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        particles?.removeFromParent()
        particles = nil
    }

    private func showMoveParticles(touchPosition: CGPoint) {
        if particles == nil {
            particles = SKEmitterNode(fileNamed: Scene.particles)
            particles!.zPosition = 1
            particles!.targetNode = self
            addChild(particles!)
        }
        particles!.position = touchPosition
    }

    private func checkIfVineCut(withBody body: SKPhysicsBody) {
      if didCutVine && !GameConfiguration.canCutMultipleVinesAtOnce {
        return
      }
      
      let node = body.node!

      // if it has a name it must be a vine node
      if let name = node.name {
        // snip the vine
        node.removeFromParent()

        // fade out all nodes matching name
        enumerateChildNodes(withName: name, using: { node, _ in
          let fadeAway = SKAction.fadeOut(withDuration: 0.25)
          let removeNode = SKAction.removeFromParent()
          let sequence = SKAction.sequence([fadeAway, removeNode])
          node.run(sequence)
        })
        
        crocodile.removeAllActions()
        crocodile.texture = SKTexture(imageNamed: ImageName.crocMouthOpen)
        animateCrocodile()
        run(sliceSoundAction)
        didCutVine = true
      }
    }

    @objc func switchToNewGame(withTransition transition: SKTransition) {
        torqueValue = torqueValue + 0.1
        thePercentageOfScreenX = CGFloat.random(in: 0.3..<0.7)
        let delay = SKAction.wait(forDuration: 1)
        let sceneChange = SKAction.run {
            let scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: transition)
        }

        run(.sequence([delay, sceneChange]))
    }

    private func setUpAudio() {
      if GameScene.backgroundMusicPlayer == nil {
        let backgroundMusicURL = Bundle.main.url(
          forResource: SoundFile.backgroundMusic,
          withExtension: nil)
        
        do {
          let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
          GameScene.backgroundMusicPlayer = theme
        } catch {
          // couldn't load file :[
        }
        
        GameScene.backgroundMusicPlayer.numberOfLoops = -1
      }
      
      if !GameScene.backgroundMusicPlayer.isPlaying {
        GameScene.backgroundMusicPlayer.play()
      }
      
      sliceSoundAction = .playSoundFileNamed(
        SoundFile.slice,
        waitForCompletion: false)
      splashSoundAction = .playSoundFileNamed(
        SoundFile.splash,
        waitForCompletion: false)
      nomNomSoundAction = .playSoundFileNamed(
        SoundFile.nomNom,
        waitForCompletion: false)
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    override func update(_ currentTime: TimeInterval) {
      if isLevelOver {
        return
      }
      
      if prize.position.y <= 0 {
        isLevelOver = true
        run(splashSoundAction)
        switchToNewGame(withTransition: .fade(withDuration: 1.0))
      }
    }

    func didBegin(_ contact: SKPhysicsContact) {
      if isLevelOver {
        return
      }

      if (contact.bodyA.node == crocodile && contact.bodyB.node == prize)
        || (contact.bodyA.node == prize && contact.bodyB.node == crocodile) {
        
        isLevelOver = true
        
        // shrink the pineapple away
        let shrink = SKAction.scale(to: 0, duration: 0.08)
        let removeNode = SKAction.removeFromParent()
        let sequence = SKAction.sequence([shrink, removeNode])
        prize.run(sequence)
        run(nomNomSoundAction)
        runNomNomAnimation(withDelay: 0.15)
        // transition to next level
        switchToNewGame(withTransition: .doorway(withDuration: 1.0))
      }
    }
    
}

let gameView = GameView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
PlaygroundPage.current.setLiveView(gameView)

// #-end-hidden-code
