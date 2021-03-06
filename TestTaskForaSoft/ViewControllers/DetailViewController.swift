
import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var album: NewAlbum!
    var arrayOfNewTracks = [NewTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
       
        // спиннер на время поиска
        let activityInd = UIActivityIndicatorView()
        activityInd.center = self.view.center
        activityInd.startAnimating()
        self.view?.addSubview(activityInd)
        
        // делаем запрос на треки по ID альбома
        let urlString = "https://itunes.apple.com/lookup?id=\(album.albumID ?? 0)&entity=song"
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            // если нет интернета или какие-то ошибки - уберем спиннер и ничего не покажем
            // без этой проверки можем получить извлечение опционала из nil дальше
            guard error == nil, data != nil else {
                DispatchQueue.main.async {
                    activityInd.removeFromSuperview()
                }
                return
            }
            // если всё ок - разбираем ответ
            do {
                let parsedResult: TrackListResponse = try JSONDecoder().decode(TrackListResponse.self, from: data!)
                for eachNewTrack in parsedResult.results {
                    if eachNewTrack.trackName != nil { self.arrayOfNewTracks.append(eachNewTrack)}
                }

                // уберем спиннер и обновим данные в таблице
                DispatchQueue.main.async {
                    activityInd.removeFromSuperview()
                    self.tableView.reloadData()
                }
            
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {

    // ячейка-заголовок с данными об альбоме и ее высота
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        cell.setHeader(album: album)
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }

    // нижняя ячейка с копирайтом и ее высота
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell") as! AboutCell
        cell.setAbout(copyright: album.copyright!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    // количество треков
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfNewTracks.count
    }
    
    // высота ячеек-треков
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // формируем в таблице ячейки-треки
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        cell.setTrackCell(trackName: arrayOfNewTracks[indexPath.row].trackName ?? "None", number: indexPath.row + 1, duration: arrayOfNewTracks[indexPath.row].trackTimeMillis ?? 0)
        return cell
    }
    
}
