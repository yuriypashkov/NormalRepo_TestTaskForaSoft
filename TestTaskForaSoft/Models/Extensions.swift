
import UIKit


extension String {
    // обрезаем дату релиза только до года
    func substrForYear() -> String {
        let index = self.index(self.startIndex, offsetBy: 4)
        return String(self.prefix(upTo: index))
    }
    
}

extension UIImageView {
    // функция для загрузки изображений, иначе CV тормозит при прокрутке, идею подглядел на Stackoverflow
    func lazyDownloadImage(link: String) {
        URLSession.shared.dataTask(with: URL(string: link)!) { (data, response, error) in
            DispatchQueue.main.async {
                    if let data = data { self.image = UIImage(data: data) }
                }
        }.resume()
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    // размеры ячейки в CV главного VC
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width - 40, height: 80)
    }
}
