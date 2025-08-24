import UIKit
import TOCropViewController

class ChangeIconViewController: UIViewController {
    @IBOutlet weak var IconSection: UICollectionView!
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var photoSelectorButton: UIButton!
    
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        IconSection.register(IconCellCollectionViewCell.self,forCellWithReuseIdentifier: IconCellCollectionViewCell.id)
        collectionViewStyle()
        IconSection.delegate = self
        IconSection.dataSource = self
        initPhotoButtons()
    }
    
    @IBAction func onTapDone(_ sender: UIButton) {
        guard let image = selectedImage else {
            dismiss(animated: true)
            return
        }
        Task {
            do {
                _ = try await UserViewModel.shared.setUserIcon(image: image)
            } catch {
                print("setUserIcon error: \(error)")
            }
            dismiss(animated: true)
        }
    }

}

extension ChangeIconViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    func initPhotoButtons() {
        let takePhoto = UIAction(title: "Take Photo", image: UIImage(systemName: "camera")) { [weak self] _ in
            self?.presentImagePicker(sourceType: .camera)
        }
        let choosePhoto = UIAction(title: "Choose from Library", image: UIImage(systemName: "photo")) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }
        photoSelectorButton.menu = UIMenu(title: "", options: .displayInline, children: [takePhoto, choosePhoto])
        photoSelectorButton.showsMenuAsPrimaryAction = true
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = false
        // ✅ important: avoid sheet/card stacking issues
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let cropVC = TOCropViewController(croppingStyle: .default, image: image)
        cropVC.aspectRatioPreset = .presetSquare
        cropVC.aspectRatioLockEnabled = true
        cropVC.resetAspectRatioEnabled = false
        cropVC.delegate = self
        
        // ✅ important: make the cropper full-screen as well
        cropVC.modalPresentationStyle = .fullScreen
        present(cropVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - TOCropViewControllerDelegate
    
    func cropViewController(_ cropViewController: TOCropViewController,
                            didCropTo image: UIImage,
                            with cropRect: CGRect,
                            angle: Int) {
        // ✅ dismiss FROM THE PRESENTER to keep the modal stack correct
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            // optional: simple fade-in instead of cropper’s custom zoom-back
            self.selectedIcon.image = image
            self.selectedImage = image
        }
    }

    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        // ✅ same dismissal path on cancel
        dismiss(animated: true, completion: nil)
    }
}

extension ChangeIconViewController: UICollectionViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout {
    func collectionViewStyle() {
        IconSection.clipsToBounds = false
        IconSection.superview?.clipsToBounds = false
        IconSection.backgroundColor = .systemGray6
        IconSection.layer.cornerRadius = 8
        IconSection.layer.borderWidth = 1 / UIScreen.main.scale
        IconSection.layer.borderColor = UIColor.gray.cgColor
        IconSection.layer.shadowColor = UIColor.black.cgColor
        IconSection.layer.shadowOpacity = 0.25
        IconSection.layer.shadowOffset = CGSize(width: 0, height: 2)
        IconSection.layer.shadowRadius = 4
        IconSection.layer.masksToBounds = false
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        IconCellCollectionViewCell.icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCellCollectionViewCell.id,
                                                      for: indexPath) as! IconCellCollectionViewCell
        cell.iconImageView.image = UIImage(systemName: IconCellCollectionViewCell.icons[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let img = UIImage(systemName: IconCellCollectionViewCell.icons[indexPath.item])
        selectedIcon.image = img
        selectedImage = img
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let minCellSize: CGFloat = 40
        let availableWidth = collectionView.bounds.width - 16
        let maxItemsInRow = Int(availableWidth / minCellSize)
        let spacing: CGFloat = 8 * CGFloat(maxItemsInRow - 1)
        let cellWidth = (availableWidth - spacing) / CGFloat(maxItemsInRow)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
