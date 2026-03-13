//
//  Animation3DController.m
//  emp
//
//  Created by 张志恒 on 2025/10/23.
//

#import "Animation3DController.h"
#import <SceneKit/SceneKit.h>

@interface Animation3DController ()
@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) SCNView *sceneView;
@property (nonatomic, strong) SCNNode *catNode;
@end

@implementation Animation3DController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"Cat Animation Demo";

    // Photo view (background)
//    self.photoView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    self.photoView.contentMode = UIViewContentModeScaleAspectFill;
//    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.view addSubview:self.photoView];

    // SceneKit view on top (transparent background)
    self.sceneView = [[SCNView alloc] initWithFrame:self.view.bounds];
    
    self.sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sceneView.backgroundColor = UIColor.clearColor;
    self.sceneView.allowsCameraControl = YES;
    [self.view addSubview:self.sceneView];
    
    
//    self.sceneView.backgroundColor = [UIColor blueColor];
    self.sceneView.scene.background.contents = [UIColor redColor];
    self.sceneView.opaque = NO;
    
    
//    self.sceneView.defaultCameraController.maximumVerticalAngle = 0.01;   // 限制向上
//    self.sceneView.defaultCameraController.minimumVerticalAngle = -0.01;  // 限制向下
//    self.sceneView.defaultCameraController.minimumHorizontalAngle = 5.0;
//    self.sceneView.defaultCameraController.maximumHorizontalAngle = 5.0;

    // Load a default scene (expects Models/cat.usdz or similar in bundle)
    SCNScene *scene = nil;
    // Try usdz first, then fallback to scn/dae
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"smart_chair" ofType:@"usdc"];
    if (modelPath) {
        scene = [SCNScene sceneWithURL:[NSURL fileURLWithPath:modelPath] options:nil error:nil];
    } else {
        scene = [SCNScene sceneNamed:@"Models/cat.scn"];
    }
    if (!scene) {
        // create empty scene
        scene = [SCNScene scene];
    }
    self.sceneView.scene = scene;

    // Camera
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 3);
    [scene.rootNode addChildNode:cameraNode];
//    self.sceneView.pointOfView = cameraNode;
    
    
    
    //
//    SCNNode *rotationNode = [SCNNode node];
//    [rotationNode addChildNode:cameraNode];
//    [scene.rootNode addChildNode:rotationNode];

    // Light
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 0, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // Ambient
    SCNNode *ambient = [SCNNode node];
    ambient.light = [SCNLight light];
    ambient.light.type = SCNLightTypeAmbient;
    ambient.light.intensity = 200;
    [scene.rootNode addChildNode:ambient];

//    // Attempt to find cat node
//    self.catNode = [scene.rootNode childNodeWithName:@"chameleon_anim_mtl_variant" recursively:YES];
//    if (!self.catNode) {
//        // if not found, add a placeholder geometry
//        SCNBox *box = [SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0.1];
//        SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
//        boxNode.position = SCNVector3Make(0, 0.5, 0);
//        boxNode.name = @"chameleon_anim_mtl_variant";
//        [scene.rootNode addChildNode:boxNode];
//        self.catNode = boxNode;
//    }

    // Add ground plane
//    SCNFloor *floor = [SCNFloor floor];
//    SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
//    floorNode.position = SCNVector3Make(0, 0, 10);
//    [scene.rootNode addChildNode:floorNode];

    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        SCNNode *node = scene.rootNode; // 加载的模型根节点
//        SCNVector3 min, max;
//        [node getBoundingBoxMin:&min max:&max];
//
//        SCNVector3 center = SCNVector3Make((min.x + max.x) / 2.0,
//                                           (min.y + max.y) / 2.0,
//                                           (min.z + max.z) / 2.0);
//
//        node.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z);
//        
//        SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:node];
//        constraint.gimbalLockEnabled = YES;
//        cameraNode.constraints = @[constraint];
//    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // ensure views fill
    self.photoView.frame = self.view.bounds;
    self.sceneView.frame = self.view.bounds;
}

- (void)onButtonTapped:(UIButton *)sender {
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:@"拍照"]) {
        
    } else {
        [self playCatAnimationWithTitle:title];
    }
}

- (void)playCatAnimationWithTitle:(NSString *)title {
    if (!self.catNode) return;
    
}

@end
