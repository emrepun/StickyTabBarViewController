# SampleSporify
Sticky and Collapsible View on top of tab bar development

# Requirements:
- iOS 10.0
- Tab bar is visible as long as there is a sticky view controller allocated on top of it (any vc pushed at any point should not set ```hidesBottomBarWhenPushed``` to ```true```.

Subclass ```StickyViewControllerSupportingTabBarController``` from your tab bar controller.

# Configure animation duration or collapsed view height directly from your tabbar controller:
```
import UIKit
import StickyTabBarViewController

class MainTabBarController: StickyViewControllerSupportingTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateCollapsedHeight(to: 50.0)
        updateAnimationDuration(to: 0.5)
    }
}

```
Can also update it any time by accessing to tabBarController.

# Configure a ViewController in collapsed state as following:

```
if let tabBarController = tabBarController as? StickyViewControllerSupportingTabBarController {
    let viewControllerToStick = SampleChildViewController() // example VC
    tabController?.configureCollapsedTrainingView(withChildViewController: viewControllerToStick)
}
```

Any view controller to have sticky behaviour must conform to ```Expandable``` and implement a ```minimisedView```.

Collapse sticky view from the view controller that conforms to ```Expandable``` as following:

```
expander?.collapseCollapsibleViewController()
```

Remove sticky view from the view controller that conforms to ```Expandable``` as following:

```
expander?.removeCollapsibleViewController(animated:)
```

# Pending Improvements:
- It would be nice to have the ability to hide tab bar and status bar upon expanding, in parameterized way.
