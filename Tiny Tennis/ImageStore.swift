//
//  ImageStore.swift
//  Tiny Tennis
//
//  Created by David Bireta on 10/20/16.
//  Copyright © 2016 David Bireta. All rights reserved.
//


/// Provides access to all images. 
/// Currently this is just champion avatars.
class ImageStore {
    
    /// Returns an avatar for a given champion. This will look for images in the following order:
    /// * Check to see if a downloaded image has been cached in the 'Documents/Images' directory
    /// * Check to see if there is an image in the bundle matching the champion's nickname
    /// * Attempt to download (and subsequently cache) and image using the `avatar` property
    ///
    /// - parameter champion: The `Champion` for which the image is being requested.
    ///
    /// - returns: Matching avatar image if found, else returns the "default.png" image.
    static func avatar(for champion: Champion) -> UIImage {
        var avatarImage = UIImage(named: "default")!
        
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imagesDirPath = documentsPath.appendingPathComponent("Images", isDirectory: true)
            let imagePath = imagesDirPath.appendingPathComponent("\(champion.id).jpg")
            
            if let image = UIImage(contentsOfFile: imagePath.path) {
                avatarImage = image
            } else if champion.avatar == "" {
                if let lastName = champion.lastName, let image = UIImage(named: lastName) {
                    avatarImage = image
                }
            } else if let avatarURL = URL(string: champion.avatar), let imageData = try? Data(contentsOf: avatarURL), let image = UIImage(data: imageData) {
                // "Cache" it to disk
                do {
                    try imageData.write(to: imagePath, options: .atomic)
                } catch let error {
                    print("Error caching image to disk: \(error)")
                }
                
                avatarImage = image
            }
        }
        
        return avatarImage
    }
}
