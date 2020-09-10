
import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var notFoundLabel: UILabel!
    
    var arrayOfFetchedAlbums = [Album]()
    var currentAlbum: Album!
    
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
            arrayOfFetchedAlbums.removeAll()
            collectionView.reloadData()
            notFoundLabel.isHidden = true
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfFetchedAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // формируем ячейки с альбомами в CV
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
        cell.setCell(albumTitle: arrayOfFetchedAlbums[indexPath.row].albumTitle,
                     imageUrl: arrayOfFetchedAlbums[indexPath.row].imageURL60px,
                     artist: arrayOfFetchedAlbums[indexPath.row].artist,
                     year: arrayOfFetchedAlbums[indexPath.row].releaseDate)
        return cell
    }
    
    // переход на VC с деталями альбома и списком треков
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else { return }
        detailViewController.album = arrayOfFetchedAlbums[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // функция для парсинга JSON и создания объекта Album
    func parsJSON(eachFetchedAlbum: [String: Any]) -> Album {
        let albumTitle = eachFetchedAlbum["collectionName"] as? String ?? "None"
        let artist = eachFetchedAlbum["artistName"] as? String ?? "None"
        let imageURL60px = eachFetchedAlbum["artworkUrl60"] as? String ?? "None"
        let imageURL100px = eachFetchedAlbum["artworkUrl100"] as? String ?? "None"
       
        let releaseDateFull = eachFetchedAlbum["releaseDate"] as? String ?? "None"
        let releaseDate = releaseDateFull.substrForYear()
        
        let albumPrice = eachFetchedAlbum["collectionPrice"] as? Double ?? 0
        let copyright = eachFetchedAlbum["copyright"] as? String ?? "None"
        let currency = eachFetchedAlbum["currency"] as? String ?? "None"
        let albumID = eachFetchedAlbum["collectionId"] as? Int ?? 0 // по нему буду вытаскивать список треков дальше
        let genre = eachFetchedAlbum["primaryGenreName"] as? String ?? "None"
        
        let album = Album(albumTitle: albumTitle, artist: artist, imageURL60px: imageURL60px, imageURL100px: imageURL100px, releaseDate: releaseDate, albumPrice: albumPrice, copyright: copyright, currency: currency, albumID: albumID, genre: genre)
        return album
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        arrayOfFetchedAlbums.removeAll()
        searchBar.resignFirstResponder()

        // спиннер на время поиска
        let activityInd = UIActivityIndicatorView()
        activityInd.center = self.view.center
        activityInd.startAnimating()
        self.view?.addSubview(activityInd)
        
        // сформируем url для запроса, по документации пробелы на плюсик вроде надо заменять
        let urlString = "https://itunes.apple.com/search?term=\(searchBar.text!.replacingOccurrences(of: " ", with: "+"))&entity=album"
        let url = URL(string: urlString)
   
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
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
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any] 
                let jsonResults = json["results"] as! [[String: Any]] 
                for eachFetchedAlbum in jsonResults {
                    let album = self.parsJSON(eachFetchedAlbum: eachFetchedAlbum)
                    self.arrayOfFetchedAlbums.append(album)
                }
                
                // сортируем массив по имени альбома
                self.arrayOfFetchedAlbums.sort { (albumFirst, albumSecond) -> Bool in
                    albumFirst.albumTitle < albumSecond.albumTitle
                }
                
                // удаляем спиннер и обновляем CV после загрузки данных
                DispatchQueue.main.async {
                    activityInd.removeFromSuperview()
                    self.collectionView.reloadData()
                    
                    // покажем надпись Ничего не найдено, если ничего не найдено
                    if self.arrayOfFetchedAlbums.isEmpty {
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

