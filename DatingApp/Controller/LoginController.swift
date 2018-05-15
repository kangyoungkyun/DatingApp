
//  Copyright © 2018년 MacBookPro. All rights reserved.
// t\색상68cd4c

import UIKit
import Firebase
class LoginController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    //사진 선택했는지 체크
    var picCheck = false
    
    //피커뷰 데이터
    let gender = ["남자","여자"]
    var age:[String] = []
    
    var mainViewController: MainViewController?
    
    //피커뷰 객체
    let genderPickerView :UIPickerView = {
        let pick = UIPickerView()
        pick.tag = 1
        return pick
    }()
    //나이 피커뷰 객체
    let agePickerView :UIPickerView = {
        let pick = UIPickerView()
        pick.tag = 2
        return pick
    }()
    
    //피커뷰 상속 메서드
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    //피커뷰 row 개수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        var countrows : Int = age.count
        if (pickerView == genderPickerView){
            countrows = gender.count
        }
        return countrows
    }
    
    //피커뷰 제목
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPickerView {
            let titleRow = gender[row]
            return titleRow
        } else if pickerView == agePickerView {
            let titleRow = age[row]
            return titleRow
        }
        return ""
    }
    //피커뷰를 선택했을 때
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genderPickerView {
            let titleRow = gender[row]
            genderSegmentControl.text = titleRow
            genderSegmentControl.resignFirstResponder()
        } else if pickerView == agePickerView {
            let titleRow = age[row]
            ageTextField.text = titleRow
            ageTextField.resignFirstResponder()
        }
    }
    
    //컨테이너 뷰
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    //로그인 버튼
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        button.setTitle("가입ㄱㄱ", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "SDMiSaeng", size: 30)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    //로그인 버튼 액션
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("값이 없거나 잘못된 형식")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            //로그인 할때 네비게이션 바 데이터 변경 함수 호출
            self.mainViewController?.fetchUserAndSetupNavBarTitle()
            //로그인 성공시 로그인창 내려주기
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    //닉네임 텍스트 필드
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "어렸을때 별명ㅋㅋ"
        if let placeholder = tf.placeholder {
            tf.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)])
        }
        tf.font = UIFont(name: "SDMiSaeng", size: 25)
        tf.textColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.tintColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    //닉네임 구분선
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //이메일 텍스트 필드
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비번 찾을때 이메일"
        if let placeholder = tf.placeholder {
            tf.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)])
        }
        tf.font = UIFont(name: "SDMiSaeng", size: 25)
        tf.textColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.tintColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    //이메일 구분선
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //패스워드 텍스트 필드
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호는 여섯자리 이상"
        if let placeholder = tf.placeholder {
            tf.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)])
        }
        tf.font = UIFont(name: "SDMiSaeng", size: 25)
        tf.textColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.tintColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    //패스워드 구분선
    let passwordSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //성별
    lazy var genderSegmentControl: UITextField = {
        let tf = UITextField()
        tf.placeholder = "남자 여자?"
        if let placeholder = tf.placeholder {
            tf.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)])
        }
        tf.font = UIFont(name: "SDMiSaeng", size: 25)
        tf.textColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.tintColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
        
    }()
    
    //성별 구분선
    let genderSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    //나이
    lazy var ageTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "나이"
        if let placeholder = tf.placeholder {
            tf.attributedPlaceholder = NSAttributedString(string:placeholder,
                                                          attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)])
        }
        tf.font = UIFont(name: "SDMiSaeng", size: 25)
        tf.textColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.tintColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    
    //프로필 이미지
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "main2")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        //클릭시 이벤트 등록
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl:UISegmentedControl = {
        
        let sc = UISegmentedControl(items: ["로그인","가입ㄱㄱ"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        let font = UIFont(name: "SDMiSaeng", size: 20)
        sc.setTitleTextAttributes([NSAttributedStringKey.font: font as Any],
                                                for: .normal)
        sc.tintColor = UIColor(red:0.41, green:0.80, blue:0.30, alpha:1.0)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    //로그인 등록 세그먼트
    @objc func handleLoginRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        let containerHeight =  loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? 100 : 200
        inputsContainerViewHeightAnchor?.constant = CGFloat(containerHeight)
        
        //이름 필드 높이
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0) : nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        nameTextFieldHeightAnchor?.isActive = true
        
        //이메일 필드 높이
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2) : emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        emailTextFieldHeightAnchor?.isActive = true
        
        //비밀번호 필드 높이
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2) : passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        passwordTextFieldHeightAnchor?.isActive = true
        
        //성별 높이
        genderSegmentControlHeightAnchor?.isActive = false
        genderSegmentControlHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? genderSegmentControl.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0) : genderSegmentControl.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        genderSegmentControlHeightAnchor?.isActive = true
        
        //나이 높이
        ageTextFieldHeightAnchor?.isActive = false
        ageTextFieldHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex  == 0 ? ageTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0) : ageTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        ageTextFieldHeightAnchor?.isActive = true
        
    }
    
    
    
    //진입점
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //나이 피커뷰에 데이터 넣어주기
        for i in 8...99{
            self.age.append("\(i)")
        }
        
        //바깥탭 -> 키보드 숨기기
        self.hideKeyboard()
        
        //피커뷰 델리게이트
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        agePickerView.delegate = self
        agePickerView.dataSource = self
        
        view.backgroundColor = .black
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        
        //입력 객체
        setupInputsContainerView()
        //로그인버튼 객체
        setupLoginRegisterButton()
        //이미지뷰 객체
        setupProfileImageView()
        //로그인 세그먼트 컨트롤
        setupLoginRegisterSegmentedControl()
        
    }
    
    //로그인등록 버튼 세그먼트 제약조건
    func setupLoginRegisterSegmentedControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -15).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
    }
    
    //높이 제약조건
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var genderSegmentControlHeightAnchor: NSLayoutConstraint?
    var ageTextFieldHeightAnchor: NSLayoutConstraint?
    
    //컨테이너 뷰 제약조건 설정
    func setupInputsContainerView(){
        //컨테이너 뷰 제약조건
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo:view.widthAnchor,constant:-24).isActive = true
        
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 200)
        inputsContainerViewHeightAnchor?.isActive = true
        
        
        //컨테이너 뷰 안에 뷰객체 넣기
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        inputsContainerView.addSubview(passwordSeparatorView)
        inputsContainerView.addSubview(genderSegmentControl)
        genderSegmentControl.inputView = genderPickerView
        inputsContainerView.addSubview(genderSeperatorView)
        inputsContainerView.addSubview(ageTextField)
        ageTextField.inputView = agePickerView
        
        //뷰객체 제약조건 설정
        //이름
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: 0).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        nameTextFieldHeightAnchor?.isActive = true
        
        //이름 구분선
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //이메일
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 0).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        emailTextFieldHeightAnchor?.isActive = true
        
        //이메일 구분선
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //비밀번호
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 0).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        passwordTextFieldHeightAnchor?.isActive = true
        
        //비밀번호 구분선
        passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //성별
        genderSegmentControl.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        genderSegmentControl.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 0).isActive = true
        genderSegmentControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        genderSegmentControlHeightAnchor = genderSegmentControl.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        genderSegmentControlHeightAnchor?.isActive = true
        
        //성별 구분선
        genderSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        genderSeperatorView.topAnchor.constraint(equalTo: genderSegmentControl.bottomAnchor).isActive = true
        genderSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        genderSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //나이
        ageTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        ageTextField.topAnchor.constraint(equalTo: genderSegmentControl.bottomAnchor, constant: 0).isActive = true
        ageTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: 0).isActive = true
        ageTextFieldHeightAnchor = ageTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/5)
        ageTextFieldHeightAnchor?.isActive = true
        
    }
    
    //로그인버튼 제약 조건 설정
    func setupLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    //프로필 이미지 제약 조건 설정
    func setupProfileImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -75).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

//바탕화면 텝 했을 때 키보드 숨기기
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
