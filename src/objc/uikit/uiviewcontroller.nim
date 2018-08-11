import objc
import objc / [foundation, coregraphics]
import uiclasses

type
  UIModalPresentationStyle* {. pure .} = enum
    todo
  UIModalTransitionStyle* {. pure .} = enum
    todo

UIViewController.importProperties:
  view is UIView
  title is NSString
  preferredContentSize is CGSize
  modalPresentationStyle is UIModalPresentationStyle
  modalTransitionStyle is UIModalTransitionStyle
  providesPresentationContextTransitionStyle is Boolean
  definesPresentationContext is Boolean
  (disablesAutomaticKeyboardDismissal is Boolean)[readonly = true]
  (modalInPopover is Boolean)[getName = "isModalInPopover"]
  (viewIfLoaded is UIView)[readonly = true]
  (viewLoaded is Boolean)[readonly = true, getName = "isViewLoaded"]
  (storyboard is UIStoryBoard)[readonly = true]

  # custom transitions
  transitioningDelegate is UIViewControllerTransitioningDelegate
  transitionCoordinator is UIViewControllerTransitionCoordinator
  restoresFocusAfterTransition is Boolean
  (presentationController is UIPresentationController)[readonly = true]
  (popoverPresentationController is UIPopoverPresentationController)[readonly = true]

  # events
  (beingDismissed is Boolean)[readonly = true, getName = "isBeingDismissed"]
  (beingPresented is Boolean)[readonly = true, getName = "isBeingPresented"]
  (movingFromParentViewController is Boolean)[readonly = true, getName = "isMovingFromParentViewController"]
  (movingToParentViewController is Boolean)[readonly = true, getName = "isMovingToParentViewController"]

proc init*(self: UIViewController; coder: NSCoder): UIViewController {.
  importMethod: "initWithCoder:"
.}
proc init*(self: UIViewController; nibName: NSString; bundle: NSBundle): UIViewController {.
  importMethod: "initWithNibName:bundle:"
.}

# view interaction:

proc loadView*(self: UIViewController): void {. importMethod: "loadView" .}
proc viewDidLoad*(self: UIViewController): void {. importMethod: "viewDidLoad" .}
proc loadViewIfNeeded*(self: UIViewController): void {. importMethod: "loadViewIfNeeded" .}

# view controller presentation

proc show*(self: UIViewController; controller: UIViewController; sender: Object): void {.
  importMethod: "showViewController:sender:"
.}
proc showDetail*(self: UIViewController; controller: UIViewController; sender: Object): void {.
  importMethod: "showDetailViewController:sender:"
.}
proc present*(self: UIViewController; controller: UIViewController; animated: Boolean;
              completion: proc: void {. cdecl .}): void {.
  importMethod: "presentViewController:animated:completion:"
.}
proc dismiss*(self: UIViewController; animated: Boolean;
              completion: proc: void {. cdecl .}): void {.
  importMethod: "dismissViewControllerAnimated:completion:"              
.}

# custom transitions / presentations

proc target*(self: UIViewController; action: Selector; sender: Object): UIViewController {.
  importMethod: "targetViewControllerForAction:sender:"
.}

# responding to events

proc willAppear*(self: UIViewController; animated: Boolean): void {.
  importMethod: "viewWillAppear:"
.}
proc didAppear*(self: UIViewController; animated: Boolean): void {.
  importMethod: "viewDidAppear:"
.}
proc willDisappear*(self: UIViewController; animated: Boolean): void {.
  importMethod: "viewWillDisappear:"
.}
proc didDisappear*(self: UIViewController; animated: Boolean): void {.
  importMethod: "viewDidDisappear:"
.}

# TODO: storyboard interaction ...
