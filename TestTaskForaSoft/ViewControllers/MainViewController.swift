
import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var notFoundLabel: UILabel!

    var arrayOfNewFetchedAlbums = [NewAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // обработчик убирающий клавиатуру при тапе на свободной области
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // надпись Ничего не найдено скрываем
        notFoundLabel.isHidden = true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // очищаем CV при пустой строке поиска и скрываем надпись Ничего не найдено если была
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            arrayOfNewFetchedAlbums.removeAll()
            collectionView.reloadData()
            notFoundLabel.isHidden = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfNewFetchedAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // формируем ячейки с альбомами в CV
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
        cell.setCell(albumTitle: arrayOfNewFetchedAlbums[indexPath.row].albumTitle ?? "None",
                     imageUrl: arrayOfNewFetchedAlbums[indexPath.row].imageURL60px ?? "None",
                     artist: arrayOfNewFetchedAlbums[indexPath.row].artist ?? "None",
                     year: arrayOfNewFetchedAlbums[indexPath.row].releaseDate ?? "None")
        return cell
    }
    
    // переход на VC с деталями альбома и списком треков
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        detailViewController.album = arrayOfNewFetchedAlbums[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        arrayOfNewFetchedAlbums.removeAll()
        searchBar.resignFirstResponder()

        // спиннер на время поиска
        let activityInd = UIActivityIndicatorView()
        activityInd.center = self.view.center
        activityInd.startAnimating()
        self.view?.addSubview(activityInd)
        
        // сформируем url для запроса
        let urlString = "https://itunes.apple.com/search?term=\(searchBar.text ?? "")&entity=album"
        let newUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: newUrl!) else {
            activityInd.removeFromSuperview()
            self.collectionView.reloadData()

            if self.arrayOfNewFetchedAlbums.isEmpty {
                self.notFoundLabel.isHidden = false
            } else {
                self.notFoundLabel.isHidden = true
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
          // если нет интернета или какие-то ошибки - покажем что ничего не нашли
          // без этой проверки можем получить извлечение опционала из nil дальше
            guard error == nil, data != nil else {
                DispatchQueue.main.async {
                    activityInd.removeFromSuperview()
                    self.notFoundLabel.isHidden = false
                }
                return
            }
            // если всё ок - разбираем ответ
            do {
                let parsedResult: AlbumListResponse = try JSONDecoder().decode(AlbumListResponse.self, from: data!)    
                self.arrayOfNewFetchedAlbums = parsedResult.results
                
                // сортируем массив по имени альбома
                self.arrayOfNewFetchedAlbums.sort { (albumFirst, albumSecond) -> Bool in
                    if let first = albumFirst.albumTitle, let second = albumSecond.albumTitle {
                        return first < second
                    }
                    return false
                }
                
                // удаляем спиннер и обновляем CV после загрузки данных
                DispatchQueue.main.async {
                    activityInd.removeFromSuperview()
                    self.collectionView.reloadData()
                    
                    // покажем надпись Ничего не найдено, если ничего не найдено
                    if self.arrayOfNewFetchedAlbums.isEmpty {
                        self.notFoundLabel.isHidden = false
                    } else {
                        self.notFoundLabel.isHidden = true
                    }
                }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

