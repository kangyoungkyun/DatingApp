
import UIKit

class PictureCell: UICollectionViewCell {

    let imageView: UIImageView = {
        let image = UIImageView(image:#imageLiteral(resourceName: "kkk.jpg"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    //초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.cyan
        addSubview(imageView)
        setupViews()
    }
    
    //제약조건 설정
    func setupViews(){
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive=true
        imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

