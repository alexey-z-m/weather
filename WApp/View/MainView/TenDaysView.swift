import UIKit
import SnapKit

class TenDaysView: UIView {
    var data: ForecastResponse?
    private let weatherService = WeatherService(client: URLSessionHTTPClient())
    
    private let containerHours: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .white.withAlphaComponent(0.2)
        return view
    }()
    
    private let imageClock: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "calendar"))
        imageView.tintColor = .white
        return imageView
    }()
    private let labelTodayHours: UILabel = {
        let label = UILabel()
        label.text = "10-day forecast".uppercased()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    let devider = UIView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 55, height: 120)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(HourView.self,
                                forCellWithReuseIdentifier: HourView.identifier)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: ForecastResponse) {
        self.data = data
        self.collectionView.reloadData()
        DispatchQueue.main.async {
            print(self.collectionView.contentSize)
        }
    }
    
    private func setupView() {
        addSubview(containerHours)
        containerHours.addSubview(imageClock)
        containerHours.addSubview(labelTodayHours)
        containerHours.addSubview(devider)
        containerHours.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(CGFloat.adaptive(20, 40))
            make.bottom.equalToSuperview()
        }
        imageClock.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.adaptive(10, 15))
            make.leading.equalToSuperview().offset(CGFloat.adaptive(14, 30))
            make.size.equalTo(CGFloat.adaptive(20, 40))
        }
        labelTodayHours.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.adaptive(10, 15))
            make.trailing.equalToSuperview().inset(CGFloat.adaptive(14, 30))
            make.leading.equalTo(imageClock.snp.trailing).offset(CGFloat.adaptive(14, 30))
        }
        devider.backgroundColor = .white.withAlphaComponent(0.1)
        devider.snp.makeConstraints { make in
            make.top.equalTo(labelTodayHours.snp.bottom).offset(CGFloat.adaptive(14, 30))
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(CGFloat.adaptive(14, 30))
        }
    }
}

extension TenDaysView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getHoursData().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HourView.identifier,
            for: indexPath
        ) as! HourView
        cell.configure(
            hour: indexPath.row == 0 ? "Now" : String(getHoursData()[indexPath.row].time.suffix(5)),
            image: getHoursData()[indexPath.row].condition.icon,
            temperature: getHoursData()[indexPath.row].temp_c.description)
        return cell
    }
    
    func getHoursData() -> [Hour] {
      guard let result = data?.forecast.forecastday.first?.hour.filter({ filterHourNow(data: $0.time) }) else {
            return []
        }
        return result
    }
    
    func filterHourNow(data: String ) -> Bool {
        let format: String = "yyyy-MM-dd HH:mm"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        guard let date = formatter.date(from: data) else {
            return false
        }
        let calendar = Calendar.current
        guard calendar.isDateInToday(date) else {
            return false
        }
        let inputHour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        return inputHour >= currentHour
    }
}
