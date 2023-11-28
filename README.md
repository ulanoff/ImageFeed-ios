## Links

- [Design in Figma](https://tinyurl.com/image-feed-figma)
- [Unsplash API](https://unsplash.com/documentation)

## Purpose and Goals

A multi-page application designed for viewing images via the Unsplash API.

Application Objectives:

- View an endless feed of images from Unsplash Editorial.
- View brief information from the user's profile.

## Brief Description

- User authentication via OAuth Unsplash is mandatory in the application.
- The main screen consists of a feed with images. The user can browse it, add and remove images from favorites.
- Users can view each image individually and share a link to them outside the application.
- The user has a profile with favorite images and brief user information.
- The application has two versions: extended and basic. The extended version includes a favorites mechanism and the ability to like photos when viewing an image in full screen.

## Non-functional Requirements

## Technical Requirements

1. Authentication works through OAuth Unsplash and a POST request to obtain an Auth Token.
2. The feed is implemented using UITableView.
3. The app uses UIImageView, UIButton, UILabel, TabBarController, NavigationController, NavigationBar, UITableView, UITableViewCell.
4. The application should support iPhone devices with iOS 13 or higher, only portrait mode is supported.
5. All fonts in the application are system fonts; no need to download them. In Interface Builder, it is the "System" font in the dropdown list, and in code layout — [`systemFont(ofSize:weight:)`](https://developer.apple.com/documentation/uikit/uifont/1619027-systemfont). In current iOS versions (13—16), the system font is `SF Pro`, but it may change in future versions.

## Functional Requirements

### OAuth Authorization

To log into the application, the user must authenticate via OAuth.

**The authorization screen contains:**

1. Application logo
2. "Log in" button

**Algorithms and available actions:**

1. When entering the application, the user sees a splash screen.
2. After the application is loaded, a screen with the possibility of authorization opens.
   1. When the "Log in" button is pressed, a browser opens on the Unsplash authorization page.
      1. When the "Login" button is pressed, the browser closes. The loading screen appears in the application.
      2. If OAuth Unsplash authorization is not set up, nothing happens when the login button is pressed.
      3. If OAuth Unsplash authorization is set up incorrectly, the user will not be able to log into the application.
      4. In case of an unsuccessful login attempt, a modal window with an error pops up.
         1. When the "OK" button is pressed, the user returns to the authorization screen.
      5. If the authorization is successful, the browser closes. The feed screen opens in the application.

## Viewing the Feed

In the feed, the user can view images, go to view individual images, and add them to favorites.

**The feed screen contains:**

1. Image card.
   1. Like button.
   2. Upload date of the photo.
2. Tab bar for navigation between the feed and the profile.

**Algorithms and available actions:**

1. The feed screen opens by default after entering the application.
2. The feed contains images from Unsplash Editorial.
3. When scrolling down and up, the user can view the feed.
   1. If the image has not loaded, the user sees a system loader.
   2. If the image cannot be loaded, the user sees a placeholder instead of the image.
4. Pressing the Like button (gray heart) allows the user to like the image. After pressing, a loader is displayed:
   1. If the request is successful, the loader disappears, and the icon changes to the Red Like button (red heart).
   2. If the request is unsuccessful, a modal window with the error "try again" pops up.
5. The user can remove the like by pressing the Like button again (red heart). After pressing, a loader is displayed:
   1. If the request is successful, the loader disappears, and the icon changes to the gray heart.
   2. If the request is unsuccessful, a modal window with the error "try again" pops up.
6. Pressing a card with an image enlarges it to the borders of the phone, and the user goes to the image viewing screen (section "Viewing an Image in Full Screen").
7. Pressing the profile icon allows the user to go to the profile.
8. The user can switch between the feed and profile screens using the tab bar.

# Full-Screen Image View

From the feed, the user can go to view the image in full screen and share it.

**The screen contains:**

1. Enlarged image to the borders of the phone.
2. Back button to return to the previous screen.
3. Button to download the image and the ability to share it.

**Algorithms and available actions:**

1. When opening the image in full screen, the user sees the stretched image to the screen borders. The image is centered.
    1. If the image cannot be loaded and displayed, the user sees a placeholder.
    2. If the response to the request is not received, a system alert with an error appears.
2. Pressing the Back button allows the user to return to the feed viewing screen.
3. Using gestures, the user can move around the stretched image, zoom in, and rotate the image. The image is fixed in the selected position.
    1. If gestures for zooming or rotating the image are not configured, these actions will not be available.
4. Pressing the Share button brings up the system menu, where the user can download the image or share it.
    1. After performing the action, the menu disappears.
    2. The user can close the menu by swiping down or by pressing the cross.
    3. If the opening of the system menu when pressing the "download or share image" button is not configured, it will not be displayed.

## Viewing User Profile

The user can go to their profile to view profile data or log out.

**The profile screen contains:**

1. Profile data.
   1. User photo.
   2. User name and username.
   3. About me information.
2. Log out button.
3. Tab bar.

**Algorithms and available actions:**

1. Profile data is loaded from the Unsplash profile. Profile data cannot be changed in the application.
    1. If profile data is not pulled from Unsplash, the user sees a placeholder instead of an avatar. Username and name are not displayed.
2. Pressing the log out button (logout) allows the user to log out of the application. A system alert with logout confirmation pops up.
    1. If the user presses "Yes," they log out and the login screen opens.
        1. If actions with the "Yes" button are not configured or are configured incorrectly, pressing it does not log the user out, and they go to the login screen.
    2. If the user presses "No," they return to the profile screen.
    3. If the alert is not configured, pressing the log out button does nothing; the user cannot log out.
3. The user can switch between the feed and profile screens using the tab bar.
