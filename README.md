# SampleSporify
Sticky and Collapsible View on top of tab bar development

# Requirements:
- iOS 10.0
- Tab bar is visible as long as there is a sticky view controller allocated on top of it (any vc pushed at any point should not set ```hidesBottomBarWhenPushed``` to ```true```.

Subclass ```StickyViewControllerSupportingTabBarController``` from your tab bar controller.

# Override following properties:
```
override var collapsedHeight: CGFloat (Set it to minimised view's height you want)
override var animationDuration: TimeInterval (Set it to general animation duration)
```

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
