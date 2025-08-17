
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import TOCropViewController

class FirstTimeLoginViewController: UIViewController {
    
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var budgetSlider: UISlider!
    
    fileprivate var userBduget: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isValueChangedSlider(budgetSlider)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        self.userBduget = Double(budgetSlider.value)
    }
    
    @IBAction func isValueChangedSlider(_ sender: UISlider) {
        let value = Double(sender.value)
        budgetLabel.text = String(format: "%.0f $", value)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let iconVC = segue.destination as? IconSelectViewController {
            iconVC.userBduget = self.userBduget
        }
    }
    
    
}
// MARK: - IconSelectViewController

class IconSelectViewController: UIViewController {
    
    @IBOutlet weak var IconsCollection: UICollectionView!
    @IBOutlet weak var SelectedIconDisplay: UIImageView!
    @IBOutlet weak var photoSelectorButton: UIButton!
    
    fileprivate var userBduget: Double = 0
    private var selectedImage:Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IconsCollection.register(IconCellCollectionViewCell.self, forCellWithReuseIdentifier: IconCellCollectionViewCell.id)
        collectionViewStyle()
        IconsCollection.delegate = self
        IconsCollection.dataSource = self
        initPhotoButtons()
    }
    
    @IBAction func DoneButtonTapped(_ sender: Any) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let iconName = selectedImage as? String {
            // Save icon name to Firestore
            let db = Firestore.firestore()
            db.collection("Users").document(userId).updateData([
                "monthlyBudget": self.userBduget,
                "iconName": iconName,
                "isFirstTime": false
            ]) { error in
                if let error = error {
                    print("Error saving icon name: \(error)")
                } else {
                    print("Icon name saved successfully!")
                    // Transition to main screen
                    self.transitionToMainScreen()
                }
            }
        } else if let imageToUpload = selectedImage as? UIImage,
                  let imageData = imageToUpload.jpegData(compressionQuality: 0.8) {
            // Upload photo to Storage
            let storageRef = Storage.storage().reference().child("userIcons/\(userId).png")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                guard error == nil else {
                    print("Error uploading image: \(error!)")
                    return
                }
                storageRef.downloadURL { url, error in
                    guard let photoURL = url, error == nil else {
                        print("Error getting download URL: \(error!)")
                        return
                    }
                    // Update Auth profile
                    let user = Auth.auth().currentUser
                    let changeRequest = user?.createProfileChangeRequest()
                    changeRequest?.photoURL = photoURL
                    changeRequest?.commitChanges { error in
                        if let error = error {
                            print("Error updating profile photo: \(error)")
                        } else {
                            print("Profile photo updated!")
                        }
                    }
                    // Update Firestore
                    let db = Firestore.firestore()
                    db.collection("Users").document(userId).updateData([
                        "monthlyBudget": self.userBduget,
                        "photoURL": photoURL.absoluteString,
                        "isFirstTime": false
                    ]) { error in
                        if let error = error {
                            print("Error updating budget: \(error)")
                        } else {
                            print("Budget and photoURL saved successfully!")
                            // Transition to main screen
                            self.transitionToMainScreen()
                        }
                    }
                }
            }
        } else {
            print("No image or icon selected")
        }
    }
    
    
    func transitionToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate else { return }
        guard let loaderVC = storyboard.instantiateViewController(withIdentifier: "AppLoaderViewController") as? AppLoaderViewController else { return }
        UIView.transition(with: sceneDelegate.window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            sceneDelegate.window?.rootViewController = loaderVC
        }, completion: nil)
    }
}

// MARK: - Photo Picker & Crop Logic

extension IconSelectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    
    func initPhotoButtons() {
        let takePhoto = UIAction(title: "Take Photo", image: UIImage(systemName: "camera")) { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        }
        
        let choosePhoto = UIAction(title: "Choose from Library", image: UIImage(systemName: "photo")) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }
        
        let menu = UIMenu(title: "", options: .displayInline, children: [takePhoto, choosePhoto])
        photoSelectorButton.menu = menu
        photoSelectorButton.showsMenuAsPrimaryAction = true
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = false
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            let cropVC = TOCropViewController(croppingStyle: .default, image: image)
            cropVC.aspectRatioPreset = .presetSquare
            cropVC.aspectRatioLockEnabled = true
            cropVC.resetAspectRatioEnabled = false
            cropVC.delegate = self
            present(cropVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController,
                            didCropTo image: UIImage,
                            with cropRect: CGRect,
                            angle: Int) {
        cropViewController.dismiss(animated: true)
        SelectedIconDisplay.image = image
        selectedImage = image // Save selected photo
    }
}

// MARK: - UICollectionView Logic

extension IconSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionViewStyle(){
        IconsCollection.clipsToBounds = false
        IconsCollection.superview?.clipsToBounds = false
        IconsCollection.backgroundColor = UIColor.systemGray6
        IconsCollection.layer.cornerRadius = 8
        IconsCollection.layer.borderWidth = 1 / UIScreen.main.scale
        IconsCollection.layer.borderColor = UIColor.gray.cgColor
        IconsCollection.layer.shadowColor = UIColor.black.cgColor
        IconsCollection.layer.shadowOpacity = 0.25
        IconsCollection.layer.shadowOffset = CGSize(width: 0, height: 2)
        IconsCollection.layer.shadowRadius = 4
        IconsCollection.layer.masksToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return IconCellCollectionViewCell.icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCellCollectionViewCell.id, for: indexPath) as! IconCellCollectionViewCell
        cell.iconImageView.image = UIImage(systemName: IconCellCollectionViewCell.icons[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SelectedIconDisplay.image = UIImage(systemName: IconCellCollectionViewCell.icons[indexPath.item])
        selectedImage = IconCellCollectionViewCell.icons[indexPath.item] as String
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let minCellSize: CGFloat = 40
        let availableWidth = collectionView.bounds.width - 16
        let maxItemsInRow = Int(availableWidth / minCellSize)
        let spacing: CGFloat = 8 * CGFloat(maxItemsInRow - 1)
        let totalSpacing = spacing
        let cellWidth = (availableWidth - totalSpacing) / CGFloat(maxItemsInRow)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16) // Adjust values as needed
    }
    
}

