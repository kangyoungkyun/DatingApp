//
//  Extensions.swift
//  DatingApp
//
//  Created by MacBookPro on 2018. 4. 4..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView{
    
    //새 메시지 보내기 테이블 뷰에서 호출하는 이미지 캐쉬 함수
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
         self.image = nil
        
        //이미지 캐쉬가 있는지 확인 후 있으면 return
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //이미지 캐치가 없으면 다운로드
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //다운로드 중 에러발생, 종료
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                //이미지 캐쉬에 넣기
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}
