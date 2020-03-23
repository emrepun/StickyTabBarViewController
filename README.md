# SampleSporify
Sticky and Collapsible View on top of tab bar development

Conform to ```StickyViewControllerSupporting``` from your custom tab bar controller

# Implement following properties:
```
var collapsedHeight: CGFloat (Set it to minimised view's height you want)
var collapsableVCFlow: ExpandableViewController? (keep it as optional)
```

# Do not override or implement following methods:
```
func configureCollapsedTrainingView(withChildViewController childViewController: Expandable)
func removeCollapsedView(withAnimation: Bool, duration: TimeInterval)
```

# Configure a ViewController in collapsed state as following:

```
if let tabBarController = tabBarController as? StickyViewControllerSupporting {
    let viewControllerToStick = SampleChildViewController() // example VC
    tabController?.configureCollapsedTrainingView(withChildViewController: viewControllerToStick)
}
```

Any view controller to have sticky behaviour must conform to ```Expandable``` and implement a ```minimisedView``` outlet.

Later remove sticky view from the view controller that conforms to ```Expandable``` as following:

```
expander?.removeCollapsedView(withAnimation: true, duration: 0.5)
```

# Known issues:
- Tap does not expand view sometimes when the view is collapsed (user needs to drag, then it works fine again)

# Pending Improvements:
- It would be nice to have the ability to hide tab bar and status bar upon expanding, in parameterized way.
